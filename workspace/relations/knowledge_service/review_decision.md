---
id: "rel:knowledge_service.review_decision"
kind: table
schema: knowledge_service
name: review_decision
domain: knowledge-service-runtime
aliases: []
tokens: [knowledge_service, review_decision, knowledge_service.review_decision, id, tenant_id, review_subject_id, guarded_sha256, reviewer_identity, reviewer_role, decision, rationale, created_at, decision_operation_id, legacy_provenance]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, service_role]
writers: [control_plane, executor_service, service_role]
typescript: "Database[\"knowledge_service\"][\"Tables\"][\"review_decision\"][\"Row\"]"
defined_in: ["20260903010200_knowledge_runtime_security.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# knowledge_service.review_decision

table in domain `knowledge-service-runtime`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id); unique (tenant_id, review_subject_id, reviewer_identity) |
| 3 | `review_subject_id` | `uuid` | no | — | unique (tenant_id, review_subject_id, reviewer_identity) |
| 4 | `guarded_sha256` | `text` | no | — | — |
| 5 | `reviewer_identity` | `text` | no | — | unique (tenant_id, review_subject_id, reviewer_identity) |
| 6 | `reviewer_role` | `text` | no | — | — |
| 7 | `decision` | `text` | no | — | — |
| 8 | `rationale` | `text` | no | — | — |
| 9 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 10 | `decision_operation_id` | `uuid` | yes | — | Authenticated durable operation that carried the reviewer actor identity. |
| 11 | `legacy_provenance` | `boolean` | no | `false` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, review_subject_id, reviewer_identity)
- check `review_decision_decision_check`: `(decision = ANY (ARRAY['approve'::text, 'reject'::text, 'defer'::text, 'request_changes'::text]))`
- check `review_decision_guarded_sha256_check`: `(guarded_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `review_decision_provenance_required_ck`: `(legacy_provenance OR (decision_operation_id IS NOT NULL))`

## Relationships

Outbound: `tenant_id,decision_operation_id` → [`knowledge_service.operation`](operation.md)`.tenant_id,id` on delete restrict; `tenant_id,review_subject_id` → [`knowledge_service.review_subject`](review_subject.md)`.tenant_id,id` on delete restrict.
Inbound: [`content.representation_decision`](../content/representation_decision.md).knowledge_review_decision_id, [`retrieval.content_promotion_decision`](../retrieval/content_promotion_decision.md).knowledge_review_decision_id.

## Indexes

`review_decision_tenant_id_id_key` unique; `review_decision_tenant_id_review_subject_id_reviewer_identi_key` unique

## Triggers

- `review_decision_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)
- `review_decision_no_new_legacy` → [`retrieval.reject_new_legacy_governance_provenance`](../../functions/retrieval/reject_new_legacy_governance_provenance.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: INSERT, SELECT, UPDATE; `executor_service`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`.

## Write path

- Direct DML: `control_plane`, `executor_service`.

## TypeScript

insert: `Database["knowledge_service"]["Tables"]["review_decision"]["Insert"]`; row: `Database["knowledge_service"]["Tables"]["review_decision"]["Row"]`; update: `Database["knowledge_service"]["Tables"]["review_decision"]["Update"]`

Defined in: `20260903010200_knowledge_runtime_security.sql`.
