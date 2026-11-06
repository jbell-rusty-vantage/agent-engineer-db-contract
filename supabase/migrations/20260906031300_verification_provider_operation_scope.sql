-- Optional operation scope for provider accounting. Legacy pilot rows remain
-- valid and retain their original request-digest uniqueness semantics.
begin;

insert into orchestration.artifact_type(code,description) values
 ('verification_structured_extraction_profile','Immutable server-owned structured-extraction provider profile')
on conflict(code) do update set description=excluded.description;

alter table orchestration.verification_provider_attempt
  add column operation_id uuid,
  add column operation_step_id uuid,
  add column profile_artifact_id uuid,
  add column profile_sha256 text check(profile_sha256 is null or profile_sha256 ~ '^[0-9a-f]{64}$'),
  add column reserved_fencing_token bigint check(reserved_fencing_token is null or reserved_fencing_token > 0),
  add column dispatch_fencing_token bigint check(dispatch_fencing_token is null or dispatch_fencing_token > 0);

alter table orchestration.verification_provider_attempt
  add constraint verification_provider_attempt_operation_tenant_fk foreign key(tenant_id,operation_id)
    references knowledge_service.operation(tenant_id,id) on delete restrict,
  add constraint verification_provider_attempt_operation_step_tenant_fk foreign key(tenant_id,operation_step_id)
    references knowledge_service.operation_step(tenant_id,id) on delete restrict,
  add constraint verification_provider_attempt_profile_artifact_tenant_fk foreign key(tenant_id,profile_artifact_id)
    references orchestration.artifact(tenant_id,id) on delete restrict;

alter table orchestration.verification_provider_attempt
  add constraint verification_provider_attempt_operation_scope_ck check(
    (operation_id is null and operation_step_id is null and profile_artifact_id is null and profile_sha256 is null and reserved_fencing_token is null and dispatch_fencing_token is null)
    or
    (operation_id is not null and operation_step_id is not null and profile_artifact_id is not null and profile_sha256 is not null and reserved_fencing_token is not null
      and request_artifact_id is not null
      and (
        (state='reserved' and dispatch_fencing_token is null)
        or (state in ('dispatched','uncertain','settled') and dispatch_fencing_token is not null and dispatch_fencing_token >= reserved_fencing_token)
      ))
  );

do $$
declare constraint_name text; matches integer;
begin
  select count(*), min(conname) into matches, constraint_name
  from pg_constraint
  where conrelid='orchestration.verification_provider_attempt'::regclass
    and contype='u'
    and pg_get_constraintdef(oid)='UNIQUE (tenant_id, request_sha256, attempt_ordinal)';
  if matches<>1 then
    raise exception 'expected exactly one legacy provider-attempt request/ordinal unique constraint, found %',matches;
  end if;
  execute format('alter table orchestration.verification_provider_attempt drop constraint %I',constraint_name);
end $$;
drop index if exists orchestration.verification_provider_attempt_request_sha256_attempt_ordinal_key;
create unique index verification_provider_attempt_legacy_request_ordinal_uq
  on orchestration.verification_provider_attempt(tenant_id,request_sha256,attempt_ordinal)
  where operation_id is null;
create unique index verification_provider_attempt_scoped_operation_ordinal_uq
  on orchestration.verification_provider_attempt(tenant_id,operation_id,attempt_ordinal)
  where operation_id is not null;

create or replace function orchestration.verification_provider_operation_claim() returns trigger
language plpgsql set search_path='' as $$
declare claim jsonb;
begin
  if tg_op='UPDATE' and old.operation_id is not null and new.operation_id is null then
    raise exception 'provider attempt operation scope cannot be removed' using errcode='restrict_violation';
  end if;
  if new.operation_id is null then return new; end if;
  if tg_op='INSERT' and new.state<>'reserved' then
    raise exception 'scoped provider attempt must begin reserved' using errcode='check_violation';
  end if;
  claim:=nullif(current_setting('verification.provider_claim',true),'')::jsonb;
  if claim is null then
    raise exception 'provider attempt active structured extraction lease claim required' using errcode='check_violation';
  end if;
  perform 1 from knowledge_service.operation operation
   where operation.tenant_id=new.tenant_id and operation.id=new.operation_id
     and operation.operation_kind='verification_structured_extraction' and operation.status='running'
   for update;
  if not found then
    raise exception 'provider attempt active structured extraction lease claim required' using errcode='check_violation';
  end if;
  perform step.id from knowledge_service.operation_step step
    join knowledge_service.lease lease on lease.tenant_id=step.tenant_id and lease.operation_step_id=step.id
    where step.tenant_id=new.tenant_id and step.operation_id=new.operation_id
      and step.id=new.operation_step_id and step.id::text=claim->>'stepId'
      and step.step_key='extract_and_register' and step.status='running'
      and lease.lease_token::text=claim->>'leaseToken' and lease.fencing_token::text=claim->>'fencingToken'
      and lease.holder_identity=claim->>'holderIdentity' and lease.released_at is null and lease.expires_at>clock_timestamp()
    for update of step,lease;
  if not found then raise exception 'provider attempt active structured extraction lease claim required' using errcode='check_violation'; end if;
  if not orchestration.verification_artifact_is_admitted(
    new.tenant_id,new.profile_artifact_id,'verification_structured_extraction_profile',new.profile_sha256)
    or not orchestration.verification_provider_artifacts_are_admitted(
      new.tenant_id,new.request_artifact_id,new.request_sha256,new.response_artifact_id) then
    raise exception 'provider attempt scoped profile or provider artifact binding is inadmissible' using errcode='foreign_key_violation';
  end if;
  if tg_op='INSERT' and new.reserved_fencing_token is distinct from (claim->>'fencingToken')::bigint then raise exception 'provider attempt reservation fence mismatch' using errcode='check_violation'; end if;
  if tg_op='UPDATE' and old.state='reserved' and new.state='dispatched' and new.dispatch_fencing_token is distinct from (claim->>'fencingToken')::bigint then raise exception 'provider attempt dispatch fence mismatch' using errcode='check_violation'; end if;
  return new;
end $$;
drop trigger if exists verification_provider_attempt_operation_claim on orchestration.verification_provider_attempt;
create trigger verification_provider_attempt_operation_claim
 before insert or update on orchestration.verification_provider_attempt
 for each row execute function orchestration.verification_provider_operation_claim();

create or replace function orchestration.verification_provider_attempt_scope_guard() returns trigger
language plpgsql set search_path = '' as $$
begin
  if tg_op='DELETE' then return old; end if;
  if old.operation_id is null and new.operation_id is null then return new; end if;
  if old.operation_id is null or new.operation_id is null then
    raise exception 'provider attempt operation scope is immutable' using errcode='restrict_violation';
  end if;
  if new.operation_id is distinct from old.operation_id or new.operation_step_id is distinct from old.operation_step_id
     or new.profile_artifact_id is distinct from old.profile_artifact_id or new.profile_sha256 is distinct from old.profile_sha256
     or new.reserved_fencing_token is distinct from old.reserved_fencing_token then
    raise exception 'verification provider attempt scope identity immutable' using errcode='restrict_violation';
  end if;
  if new.dispatch_fencing_token is distinct from old.dispatch_fencing_token and not(old.state='reserved' and new.state='dispatched' and new.dispatch_fencing_token is not null) then raise exception 'verification provider dispatch fence immutable' using errcode='restrict_violation'; end if;
  return new;
end $$;
drop trigger if exists verification_provider_attempt_scope_guard on orchestration.verification_provider_attempt;
create trigger verification_provider_attempt_scope_guard before update or delete on orchestration.verification_provider_attempt
 for each row execute function orchestration.verification_provider_attempt_scope_guard();

commit;
