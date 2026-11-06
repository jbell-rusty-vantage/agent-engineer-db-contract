begin;
set local lock_timeout = '10s';

insert into orchestration.intent_type (code, description, schema_version) values
  ('content_link', 'content-link-intent.v1: evidence-backed canonical document, chunk, summary and projection links', 1)
on conflict (code) do update set description = excluded.description, schema_version = excluded.schema_version;

insert into orchestration.artifact_type (code, description) values
  ('content_link_intent', 'content-link-intent.v1: immutable typed content-link proposals and evidence references'),
  ('content_link_plan', 'content-link-plan.v1: per-operation admission and dependency outcomes'),
  ('content_link_receipt', 'content-link-receipt.v1: exact canonical row keys and applied, held or no-op outcomes'),
  ('verification_source_authority_receipt', 'Immutable host-approved source, capture, claim and policy authority with an explicit critical-fact census')
on conflict (code) do update set description = excluded.description;

-- As with entity and claim writes, the final receipt is inserted once after
-- effects are known. Both existence and tenant checks still run at commit.
alter table knowledge.record alter constraint record_created_by_receipt_id_fkey deferrable initially immediate;
drop trigger record_receipt_tenant on knowledge.record;
create constraint trigger record_receipt_tenant after insert or update on knowledge.record
  deferrable initially immediate for each row execute function corpus.check_receipt_tenant();

commit;
