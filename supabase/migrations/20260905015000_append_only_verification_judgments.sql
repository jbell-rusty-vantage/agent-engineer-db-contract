-- A run may contain deterministic, semantic, human, policy, and statistical
-- observations for the same claim. Each immutable judgment has its own ID.
begin;

alter table evidence.verification_finding
 drop constraint verification_finding_run_id_claim_id_key,
 add column judgment_id text,
 add column evidence_id text,
 add column observed_at timestamptz,
 add constraint verification_finding_tenant_run_judgment_uq unique(tenant_id,run_id,judgment_id);

alter table evidence.verification_finding drop constraint verification_finding_v1_fields_ck;
alter table evidence.verification_finding add constraint verification_finding_v1_fields_ck check(
 verification_contract_version is null or
 (tenant_id is not null and judgment_id is not null and btrim(judgment_id)<>'' and observed_at is not null
  and judge_kind is not null and grader_version is not null
  and output_schema_sha256 is not null and blinded_input_artifact_sha256 is not null
  and properties is not null and supporting_fragment_ids is not null and contradicting_fragment_ids is not null
  and unsupported_facets is not null and public_rationale is not null and latency_ms is not null and retries is not null)
);

comment on table evidence.verification_finding is
 'Append-only verification judgment observations. Multiple judge kinds may assess one claim in a run.';

commit;
