---
id: "rel:evidence.claim"
kind: table
schema: evidence
name: claim
domain: evidence
lens: evidence
aliases: [claim]
tokens: [evidence, claim, evidence.claim, id, tenant_id, claim_type, statement, structured, status, composite, atomized_from_id, producer_attempt_id, superseded_by_id, created_by_receipt_id, created_at, updated_at, relationship_id, producer_origin_digest]
summary: "Atomic statement with type, status, and creating receipt."
summary_basis: curated
rls: enabled
readers: [executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, pipeline_agent, service_role]
typescript: "Database[\"evidence\"][\"Tables\"][\"claim\"][\"Row\"]"
defined_in: ["20260826000300_evidence_core.sql"]
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# evidence.claim

table in domain `evidence`, lens `evidence`.

> curated (model_assisted, unreviewed) — Atomic statement with type, status, and creating receipt.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id) |
| 3 | `claim_type` | `text` | no | — | FK → [`evidence.claim_type`](claim_type.md).code |
| 4 | `statement` | `text` | no | — | — |
| 5 | `structured` | `jsonb` | yes | — | _curated:_ JSONB; verification manifest digest lives under structured.verification. |
| 6 | `status` | `evidence.claim_status` | no | `'proposed'::evidence.claim_status` | _curated:_ Enum including proposed, verified, disputed, retracted, superseded. |
| 7 | `composite` | `boolean` | no | `false` | — |
| 8 | `atomized_from_id` | `uuid` | yes | — | FK → [`evidence.claim`](claim.md).id |
| 9 | `producer_attempt_id` | `uuid` | yes | — | FK → [`orchestration.attempt`](../orchestration/attempt.md).id |
| 10 | `superseded_by_id` | `uuid` | yes | — | FK → [`evidence.claim`](claim.md).id |
| 11 | `created_by_receipt_id` | `uuid` | yes | — | FK → [`orchestration.operation_receipt`](../orchestration/operation_receipt.md).id |
| 12 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 13 | `updated_at` | `timestamp with time zone` | no | `now()` | — |
| 14 | `relationship_id` | `uuid` | yes | — | FK → [`catalog.relationship`](../catalog/relationship.md).id |
| 15 | `producer_origin_digest` | `text` | yes | — | Originating origin digest (K01 originDigest) of the authenticated invocation that produced this claim when no orchestration attempt did; restates knowledge_verification.origin (no cross-schema FK). claim_producer_identity requires it or producer_attempt_id. |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `claim_producer_identity`: `((producer_attempt_id IS NOT NULL) OR (producer_origin_digest IS NOT NULL))`
- check `claim_producer_origin_digest_check`: `(producer_origin_digest ~ '^sha256:[0-9a-f]{64}$'::text)`

## Relationships

Outbound: `atomized_from_id` → [`evidence.claim`](claim.md)`.id` (+tenant); `claim_type` → [`evidence.claim_type`](claim_type.md)`.code`; `created_by_receipt_id` → [`orchestration.operation_receipt`](../orchestration/operation_receipt.md)`.id` (deferrable); `producer_attempt_id` → [`orchestration.attempt`](../orchestration/attempt.md)`.id` (+tenant); `relationship_id` → [`catalog.relationship`](../catalog/relationship.md)`.id`; `superseded_by_id` → [`evidence.claim`](claim.md)`.id` (+tenant).
Inbound: [`authoring.release_item`](../authoring/release_item.md).claim_id, [`authoring.revision_binding`](../authoring/revision_binding.md).claim_id, [`catalog.entity_alias`](../catalog/entity_alias.md).source_claim_id, [`catalog.relationship`](../catalog/relationship.md).primary_claim_id, [`content.digest_item`](../content/digest_item.md).claim_id, [`content.unit_entity_role`](../content/unit_entity_role.md).claim_id, [`evaluation.review_task`](../evaluation/review_task.md).claim_id, [`evidence.attribution`](attribution.md).claim_id, [`evidence.claim`](claim.md).atomized_from_id|superseded_by_id, [`evidence.claim_conflict`](claim_conflict.md).claim_a_id|claim_b_id, [`evidence.claim_evidence_link`](claim_evidence_link.md).claim_id, [`evidence.claim_record`](claim_record.md).claim_id … 15 more in [details](claim.details.md).
Polymorphic target of: [`evaluation.review_task`](../evaluation/review_task.md) (check constraint review_task_exactly_one_subject), [`retrieval.projection_target`](../retrieval/projection_target.md) (check constraint projection_target_exactly_one).

## Indexes

4 indexes; see [details](claim.details.md).

## Triggers

5 triggers; see [details](claim.details.md).

## Row-level security

Enabled; 1 policies in [details](claim.details.md).

## Grants

`executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: INSERT, SELECT; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`, `control_plane`.

## Read paths

- Named queries: `q:evidence.claims_for_entity`, `q:facts.locators`.
- Exposed through: [`api.claim_candidates`](../api/claim_candidates.md), [`api.claim_conflicts`](../api/claim_conflicts.md), [`api.claim_surfaces`](../api/claim_surfaces.md), [`api.claim_verdicts`](../api/claim_verdicts.md), [`api.community_claims`](../api/community_claims.md), [`api.probes`](../api/probes.md), [`api.source_track_record`](../api/source_track_record.md).
- Direct SELECT: `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`, `pipeline_agent`.

## TypeScript

insert: `Database["evidence"]["Tables"]["claim"]["Insert"]`; row: `Database["evidence"]["Tables"]["claim"]["Row"]`; update: `Database["evidence"]["Tables"]["claim"]["Update"]`

## Examples

Claims naming an entity

```bash
knowledge db query evidence.claims_for_entity --param entity_id=0192b000-0000-7000-8000-000000000001 --param limit=100
```
Joins claim_subject.

Defined in: `20260826000300_evidence_core.sql`.
