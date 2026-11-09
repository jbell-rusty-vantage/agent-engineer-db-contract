-- Build 08 R2 draft, fixup 5 (loop-1 deltas D-10/D-14): readers reach claim candidates and kept conflicts through api views
-- (evidence.* stays closed to app_reader; the view carries the claim text, status, subjects and the verification path).
begin;
create or replace view api.claim_candidates as
  select c.id as claim_id, c.claim_type, c.statement, c.status::text as status, c.structured->>'path' as path, c.structured->>'source_role' as source_role,
    (c.structured->>'subject_resolved')::boolean as subject_resolved, c.structured->'speakers' as speakers, c.structured->>'attribution' as attribution,
    c.structured->>'learned_at' as learned_at, c.structured->>'agrees_with_first_party_claim' as agrees_with_first_party_claim,
    api.names((select array_agg(s.entity_id) from evidence.claim_subject s where s.claim_id = c.id)) as subjects,
    (select x.document_node_id from evidence.extraction_record x where x.claim_id = c.id limit 1) as document_node_id,
    (select d.canonical_title from evidence.extraction_record x join content.document_node n on n.id = x.document_node_id join content.document_representation r on r.id = n.representation_id
       join content.document_version v on v.id = r.document_version_id join content.document d on d.id = v.document_id where x.claim_id = c.id limit 1) as document_title,
    c.created_at
  from evidence.claim c where c.tenant_id = util.current_tenant_id();
comment on view api.claim_candidates is 'L3/evidence: every claim with its path (deterministic_first_party = cheap path, L1_candidate = prose/media candidate awaiting verification), status, subjects and the document it was read from. Candidates are never facts.';
create or replace view api.claim_conflicts as
  select x.id as conflict_id, x.conflict_kind, x.detected_by, x.detected_at,
    a.id as first_party_claim_id, a.statement as first_party_statement, a.status::text as first_party_status,
    b.id as other_claim_id, b.statement as other_statement, b.status::text as other_status, b.structured->>'source_role' as other_source_role, b.structured->>'provenance' as other_provenance,
    (select r.outcome from evidence.conflict_reconciliation r where r.conflict_id = x.id order by r.decided_at desc limit 1) as reconciliation
  from evidence.claim_conflict x join evidence.claim a on a.id = x.claim_a_id join evidence.claim b on b.id = x.claim_b_id where a.tenant_id = util.current_tenant_id();
comment on view api.claim_conflicts is 'Kept disagreements between a first-party claim and another statement (value, scope or subject ambiguity); never averaged away, reconciled only by an explicit decision.';
grant select on api.claim_candidates, api.claim_conflicts to app_reader, pipeline_agent, verifier_agent, control_plane, executor_service, product_api_owner, authenticated, service_role;
commit;
