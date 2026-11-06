-- Preserve original identity for native and direct-executor verification.
alter table orchestration.operation_intent
  add constraint operation_intent_tenant_identity unique (tenant_id,id);

alter table knowledge_service.recovery_original
  alter column original_operation_id drop not null,
  add column original_intent_id uuid,
  add constraint recovery_original_intent_fk foreign key (tenant_id,original_intent_id)
    references orchestration.operation_intent(tenant_id,id),
  add constraint recovery_original_one_authority check
    ((original_operation_id is null) <> (original_intent_id is null));

do $$
declare prior_name text;
begin
  select conname into strict prior_name from pg_constraint
  where conrelid='knowledge_service.recovery_original'::regclass and contype='u'
    and pg_get_constraintdef(oid)='UNIQUE (tenant_id, original_operation_id, original_input_digest)';
  execute format('alter table knowledge_service.recovery_original drop constraint %I',prior_name);
end $$;

create index recovery_original_native_binding on knowledge_service.recovery_original
  (tenant_id,original_operation_id,original_input_digest) where original_operation_id is not null;
create index recovery_original_intent_binding on knowledge_service.recovery_original
  (tenant_id,original_intent_id,original_input_digest) where original_intent_id is not null;

create function knowledge_service.check_recovery_original_authority() returns trigger
language plpgsql set search_path='' as $$
declare source_id uuid; source_kind text;
begin
  source_id := coalesce(new.original_operation_id,new.original_intent_id);
  source_kind := case when new.original_operation_id is not null then 'native' else 'intent' end;
  if new.original_intent_id is not null and not exists (
    select 1 from orchestration.operation_intent i
    where i.tenant_id=new.tenant_id and i.id=new.original_intent_id and i.intent_type='verify_claim'
  ) then
    raise exception 'recovery original requires a tenant-scoped verification intent' using errcode='23514';
  end if;
  -- A binding may contain several original claim IDs, but only one recovery case.
  perform pg_advisory_xact_lock(hashtextextended(
    new.tenant_id::text||':recovery-original:'||source_kind||':'||source_id::text||':'||new.original_input_digest,0));
  if exists (select 1 from knowledge_service.recovery_original prior
    where prior.tenant_id=new.tenant_id and prior.original_input_digest=new.original_input_digest
      and prior.case_id<>new.case_id
      and ((source_kind='native' and prior.original_operation_id=source_id)
        or (source_kind='intent' and prior.original_intent_id=source_id))) then
    raise exception 'recovery original binding already belongs to another case' using errcode='23505';
  end if;
  return new;
end $$;
create trigger recovery_original_authority before insert on knowledge_service.recovery_original
  for each row execute function knowledge_service.check_recovery_original_authority();

create or replace function knowledge_service.guard_recovery_original() returns trigger
language plpgsql set search_path='' as $$
begin
  if (new.tenant_id,new.case_id,new.original_id,new.original_operation_id,new.original_intent_id,new.original_input_digest) is distinct from
     (old.tenant_id,old.case_id,old.original_id,old.original_operation_id,old.original_intent_id,old.original_input_digest)
    or new.used_rounds<old.used_rounds
    or not(new.attempted_input_digests @> old.attempted_input_digests)
    or not(new.attempted_repair_digests @> old.attempted_repair_digests) then
    raise exception 'recovery original counters cannot reset' using errcode='23514';
  end if;
  return new;
end $$;
