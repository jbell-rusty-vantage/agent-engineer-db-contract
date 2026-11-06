-- Knowledge model v2: knowledge read/ingestion intents.
-- See docs/SCHEMA_WORKSPACE_MATERIALIZATION_SPEC.md §5.5, §6.4, §7.6.
begin;
set local lock_timeout = '15s';

insert into orchestration.artifact_type (code, description) values
  ('knowledge_read_intent', 'knowledge-read-intent.v1: a reproducible batch of named queries and retrieval operations'),
  ('knowledge_read_snapshot', 'knowledge-read-snapshot.v1: digested read results at one tenant knowledge head'),
  ('knowledge_ingestion_plan', 'knowledge-ingestion-plan.v1: deterministic per-proposal admission plan for one ingestion intent'),
  ('knowledge_ingestion_receipt', 'knowledge-ingestion-receipt.v1: outcome of applying one ingestion intent through the temporal helpers'),
  ('schema_workspace_manifest', 'Schema workspace manifest (fingerprint, migration head, scope) an agent session observed'),
  ('knowledge_report_markdown', 'Source-attributed Markdown report produced alongside a knowledge ingestion')
on conflict (code) do update set description = excluded.description;

insert into orchestration.intent_type (code, description, schema_version) values
  ('knowledge_ingestion', 'knowledge-ingestion-intent.v1: evidence-backed proposals applied by the knowledge executor as executor_service', 1)
on conflict (code) do update set description = excluded.description, schema_version = excluded.schema_version;

-- Tenant knowledge head for app_reader callers; pipeline_agent may read temporal.knowledge_head directly.
create function api.knowledge_head() returns table(knowledge_seq bigint, updated_at timestamptz)
language sql stable security definer set search_path='' as $$
  select coalesce(h.knowledge_seq, 0), coalesce(h.updated_at, 'epoch'::timestamptz)
  from (select 1) one
  left join temporal.knowledge_head h on h.tenant_id = util.current_tenant_id()
$$;
comment on function api.knowledge_head() is 'Current tenant knowledge sequence and its last update; 0 when no batch has been sealed.';
revoke all on function api.knowledge_head() from public, anon;
grant execute on function api.knowledge_head() to app_reader, authenticated, executor_service, pipeline_agent, verifier_agent, control_plane, service_role;

commit;
