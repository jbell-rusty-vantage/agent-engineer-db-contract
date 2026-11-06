-- km_14: knowledge executor follow-ups surfaced while wiring the schema workspace executor.
--
-- 1. orchestration.artifact_lineage had a tenant-scoped RLS policy but no bounded-role grants,
--    so executors that write orchestration.artifact could not record lineage. Mirror the artifact
--    writers (append-only: no update/delete).
-- 2. Three global vocabularies (no tenant_id) inherited the blanket "no tenant column → deny all"
--    policy from 20260903010200 even though bounded roles hold SELECT grants on them. Ingestion
--    validates intent codes against exactly these tables, so replace the deny-all policy with a
--    read-only one. Writes stay denied (no insert/update/delete policy).
begin;
set local lock_timeout = '15s';

grant select, insert on orchestration.artifact_lineage to executor_service, control_plane;
grant select on orchestration.artifact_lineage to pipeline_agent;

do $$
declare target text;
begin
  foreach target in array array['orchestration.artifact_type', 'orchestration.intent_type', 'taxonomy.entity_kind'] loop
    execute format('drop policy if exists bounded_role_access on %s', target);
    execute format(
      'create policy global_vocabulary_read on %s for select to executor_service, pipeline_agent, verifier_agent, control_plane, app_reader using (true)',
      target
    );
  end loop;
end $$;

commit;
