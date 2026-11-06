begin;
do $$
begin
  if not exists (select 1 from orchestration.intent_type where code = 'content_link' and schema_version = 1) then
    raise exception 'content-link intent vocabulary is missing';
  end if;
  if not exists (select 1 from orchestration.artifact_type where code = 'verification_source_authority_receipt') then
    raise exception 'native source authority receipt vocabulary is missing';
  end if;
  if (select count(*) from orchestration.artifact_type where code in ('content_link_intent', 'content_link_plan', 'content_link_receipt')) <> 3 then
    raise exception 'content-link custody vocabulary is incomplete';
  end if;
  if not exists (select 1 from pg_constraint where conrelid = 'knowledge.record'::regclass
      and conname = 'record_created_by_receipt_id_fkey' and contype = 'f' and condeferrable and not condeferred) then
    raise exception 'record receipt foreign key must be opt-in deferred';
  end if;
  if not exists (select 1 from pg_trigger where tgrelid = 'knowledge.record'::regclass
      and tgname = 'record_receipt_tenant' and tgdeferrable and not tginitdeferred
      and tgenabled = 'O' and tgfoid = 'corpus.check_receipt_tenant()'::regprocedure) then
    raise exception 'record receipt tenant guard must remain enabled and opt-in deferred';
  end if;
end $$;
rollback;
