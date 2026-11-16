---
id: "task:triage-claims-and-assess-sources"
kind: task
lens: evidence
domains: [verified-knowledge, source-intelligence]
queries: [evidence.claim_triage, evidence.source_registry, evidence.source_track_record]
aliases: [record triage, triage write, checkability, not checkable, duplicate claim, record source assessment, prior, derived assessment, source write]
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# How do I triage a claim candidate or record a source assessment?

Domains: [`verified-knowledge`](../domains/verified-knowledge.md), [`source-intelligence`](../domains/source-intelligence.md). Queries: [`q:evidence.claim_triage`](../queries/README.md), [`q:evidence.source_registry`](../queries/README.md), [`q:evidence.source_track_record`](../queries/README.md).

## Navigation

`tasks/write-verification-chain.md` → `functions/api/record_triage.md` or `functions/api/record_source_assessment.md` → `q:evidence.claim_triage` / `q:evidence.source_registry`.

## Operation

Both are pipeline_agent, verifier_agent or control_plane.

```sql
select api.record_triage(
  p_idempotency_key => 'triage:claim-1:v1', p_claim_id => '0192b000-0000-7000-8000-000000000001',
  p_disposition => 'probe', p_checkability => 'deterministic_local',
  p_rationale => 'a short script with a fake model can observe the namespace', p_priority => 85,
  p_components => '{"module_subject":true,"version_bounded":true}');
select api.record_source_assessment(
  p_idempotency_key => 'source:forum:prior', p_subject_entity_id => '0192b000-0000-7000-8000-000000000021',
  p_method => 'prior', p_source_role_code => 'community', p_conflict_of_interest => 'none', p_rationale => 'a community forum');
select api.record_source_assessment(
  p_idempotency_key => 'source:forum:derived:2026-11-16', p_subject_entity_id => '0192b000-0000-7000-8000-000000000021',
  p_method => 'derived', p_topic_entity_id => '0192b000-0000-7000-8000-000000000011');
```

Triage says what to do with a candidate (`probe`, `docs_check`, `registry_check`, `not_checkable`, `duplicate` with `p_duplicate_of_claim_id`, `out_of_scope`); `p_probe_id` names the probe it became. A prior is scored by the role's `authority_rank`; a derived assessment is computed from the latest verdicts on the claims the source stated.

## Expected shape

`record_triage`: `triage_id`, `written`, `unchanged`, `disposition`, `review_state`, `supersedes_id`. `record_source_assessment`: `assessment_id`, `method`, `written`, `unchanged`, `authority_score`, and for a derived row `claims_observed`, `claims_checked`, `self_checked`, `recommended_watch_level`, `supersedes_id`.

## Pitfalls

Triage never judges whether a claim is true, and only a `proposed` claim is triaged. Rows are append-only: a changed triage supersedes the agent's current row, the same triage again writes nothing, and a row a person reviewed is not superseded (`TRIAGE_REVIEWED_BY_PERSON`). The caller never passes a score. A derived assessment needs a prior first (`ASSESSMENT_BASE_REQUIRED`) and takes role, conflict of interest and disclosure from it. `p_method` `reviewed` is a person's judgment and is refused (`HUMAN_REVIEW_NOT_AGENT_WRITABLE`). A source is a `source_channel`, `community_actor`, `organization` or `person`. Read `authority_score` with `claims_checked`; a watch level is suggested only from five checked claims.
