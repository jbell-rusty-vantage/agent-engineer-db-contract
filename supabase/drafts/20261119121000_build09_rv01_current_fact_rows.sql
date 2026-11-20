-- Build 09, unit RV01: repair found by the prototype's own check.
-- temporal.segment gained two columns in 20261119120000. api.current_fact_rows returned "s.*" into a fixed column list, so it and the
-- view api.current_facts stopped working. The function now names its columns and also returns the two new ones.
drop view api.current_facts;
drop function api.current_fact_rows();
create function api.current_fact_rows() returns table(id uuid, tenant_id uuid, stream_id uuid, valid_during tstzrange, belief text, temporal_basis text, status text, amount numeric, currency character, unit text, ref_entity_id uuid, payload jsonb, extent_id uuid, caused_by_event_id uuid, replaces_segment_id uuid, primary_claim_id uuid, k_from bigint, k_to bigint, created_at timestamptz,
  stream_kind text, subject_entity_id uuid, subject_relationship_id uuid, scope_key text, revision_kind text, correction_reason text)
language sql stable security definer set search_path = '' as $$
  select s.id, s.tenant_id, s.stream_id, s.valid_during, s.belief, s.temporal_basis, s.status, s.amount, s.currency, s.unit, s.ref_entity_id, s.payload, s.extent_id, s.caused_by_event_id, s.replaces_segment_id, s.primary_claim_id, s.k_from, s.k_to, s.created_at,
         st.kind, st.subject_entity_id, st.subject_relationship_id, st.scope_key, s.revision_kind, s.correction_reason
    from temporal.segment s join temporal.stream st on st.id = s.stream_id
   where s.tenant_id = util.current_tenant_id() and s.k_to is null and s.valid_during @> now()
$$;
revoke all on function api.current_fact_rows() from public;
grant execute on function api.current_fact_rows() to app_reader, authenticated, executor_service, pipeline_agent, verifier_agent, control_plane, service_role;
create view api.current_facts as select * from api.current_fact_rows();
grant select on api.current_facts to control_plane, executor_service, pipeline_agent, verifier_agent, authenticated, service_role, app_reader;
comment on function api.current_fact_rows() is 'Facts that hold now, as currently known, with their stream. revision_kind and correction_reason say how each fact relates to the one it replaced.';
