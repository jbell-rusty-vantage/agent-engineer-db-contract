---
id: "rel:content.representation_decision"
kind: table
schema: content
name: representation_decision
domain: content
aliases: []
tokens: [content, representation_decision, content.representation_decision, id, tenant_id, representation_id, conversion_evaluation_id, guarded_sha256, decision, reviewer_identity, policy_version, rationale, expires_at, created_at, knowledge_review_decision_id, decision_operation_id, legacy_provenance]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"content\"][\"Tables\"][\"representation_decision\"][\"Row\"]"
defined_in: ["20260903010000_knowledge_content_contract.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# content.representation_decision

table in domain `content`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id) |
| 3 | `representation_id` | `uuid` | no | — | — |
| 4 | `conversion_evaluation_id` | `uuid` | yes | — | — |
| 5 | `guarded_sha256` | `text` | no | — | — |
| 6 | `decision` | `text` | no | — | — |
| 7 | `reviewer_identity` | `text` | no | — | — |
| 8 | `policy_version` | `text` | no | — | — |
| 9 | `rationale` | `text` | no | — | — |
| 10 | `expires_at` | `timestamp with time zone` | yes | — | — |
| 11 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 12 | `knowledge_review_decision_id` | `uuid` | yes | — | — |
| 13 | `decision_operation_id` | `uuid` | yes | — | — |
| 14 | `legacy_provenance` | `boolean` | no | `false` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `representation_decision_decision_check`: `(decision = ANY (ARRAY['accept'::text, 'reject'::text, 'quarantine'::text, 'defer'::text, 'request_changes'::text]))`
- check `representation_decision_guarded_sha256_check`: `(guarded_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `representation_decision_provenance_ck`: `((legacy_provenance AND (num_nonnulls(knowledge_review_decision_id, decision_operation_id) = 0)) OR ((NOT legacy_provenance) AND (num_nonnu…`

## Relationships

Outbound: `tenant_id,decision_operation_id` → [`knowledge_service.operation`](../knowledge_service/operation.md)`.tenant_id,id` on delete restrict; `tenant_id,knowledge_review_decision_id` → [`knowledge_service.review_decision`](../knowledge_service/review_decision.md)`.tenant_id,id` on delete restrict; `tenant_id,conversion_evaluation_id` → [`content.conversion_evaluation`](conversion_evaluation.md)`.tenant_id,id` on delete restrict; `tenant_id,representation_id` → [`content.document_representation`](document_representation.md)`.tenant_id,id` on delete restrict.
Inbound: [`retrieval.search_projection`](../retrieval/search_projection.md).representation_decision_id.

## Indexes

`representation_decision_tenant_id_id_key` unique

## Triggers

- `representation_decision_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)
- `representation_decision_no_new_legacy` → [`retrieval.reject_new_legacy_governance_provenance`](../../functions/retrieval/reject_new_legacy_governance_provenance.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`executor_service`: INSERT, SELECT; `service_role`: INSERT, SELECT. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `executor_service`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["content"]["Tables"]["representation_decision"]["Insert"]`; row: `Database["content"]["Tables"]["representation_decision"]["Row"]`; update: `Database["content"]["Tables"]["representation_decision"]["Update"]`

Defined in: `20260903010000_knowledge_content_contract.sql`.
