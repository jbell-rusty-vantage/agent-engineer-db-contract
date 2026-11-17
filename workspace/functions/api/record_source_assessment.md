---
id: "fn:api.record_source_assessment(text,uuid,text,uuid,text,text,text,text,jsonb)"
kind: function
schema: api
name: record_source_assessment
domain: source-intelligence
lens: corpus
overloads: ["fn:api.record_source_assessment(text,uuid,text,uuid,text,text,text,text,jsonb)"]
security: definer
volatility: volatile
executors: [control_plane, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [catalog.entity, content.source_role], writes: [evidence.source_assessment] }
tokens: [api, record_source_assessment, api.record_source_assessment]
defined_in: ["20261116130000_build08_governed_chain_writes.sql"]
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# api.record_source_assessment

Domain `source-intelligence`, lens `corpus`.

## record_source_assessment(text, uuid, text, uuid, text, text, text, text, jsonb) → jsonb

function, volatile, security definer, language plpgsql, config `search_path=""`. Governed write: append what we know about a source (a channel, a handle, an organization, a person), on a topic or overall. method prior: the role prior, scored by the role's authority rank, never by the caller. method derived: evidence.derive_source_assessment over the latest verdicts on the claims the source stated (self-checked claims not scored, D-61; a watch level only from 5 checked claims, D-69); needs a prior. method reviewed is a person's and is refused. Idempotent on p_idempotency_key. Returns {assessment_id, method, written, unchanged, authority_score, claims_observed, claims_checked, self_checked, recommended_watch_level, supersedes_id, receipt_id, intent_id, replayed}. Errors: the common ones, HUMAN_REVIEW_NOT_AGENT_WRITABLE, ASSESSMENT_METHOD_INVALID, ASSESSMENT_SUBJECT_NOT_FOUND, ASSESSMENT_SUBJECT_INVALID, ASSESSMENT_TOPIC_NOT_FOUND, ASSESSMENT_ROLE_UNKNOWN, ASSESSMENT_INVALID, ASSESSMENT_REVIEWED_BY_PERSON, ASSESSMENT_BASE_REQUIRED.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_idempotency_key` | `text` | — | — |
| `p_subject_entity_id` | `uuid` | — | — |
| `p_method` | `text` | — | — |
| `p_topic_entity_id` | `uuid` | `NULL::uuid` | — |
| `p_source_role_code` | `text` | `NULL::text` | — |
| `p_conflict_of_interest` | `text` | `NULL::text` | — |
| `p_method_disclosure` | `text` | `NULL::text` | — |
| `p_rationale` | `text` | `NULL::text` | — |
| `p_actor` | `jsonb` | `'{}'::jsonb` | — |

Execute: `control_plane`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`catalog.entity`](../../relations/catalog/entity.md), [`content.source_role`](../../relations/content/source_role.md); writes [`evidence.source_assessment`](../../relations/evidence/source_assessment.md); calls [`evidence.derive_source_assessment`](../evidence/derive_source_assessment.md), [`util.uuidv7`](../util/uuidv7.md), [`verification.chain_begin`](../verification/chain_begin.md), [`verification.chain_fail`](../verification/chain_fail.md), [`verification.chain_record`](../verification/chain_record.md), [`verification.chain_target`](../verification/chain_target.md).

TypeScript: `Database["api"]["Functions"]["record_source_assessment"]`.

Defined in: `20261116130000_build08_governed_chain_writes.sql`.
