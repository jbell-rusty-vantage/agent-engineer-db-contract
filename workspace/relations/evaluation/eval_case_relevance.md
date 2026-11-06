---
id: "rel:evaluation.eval_case_relevance"
kind: table
schema: evaluation
name: eval_case_relevance
domain: evaluation
aliases: []
tokens: [evaluation, eval_case_relevance, evaluation.eval_case_relevance, tenant_id, eval_case_id, projection_target_id, relevance_grade, rationale, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, service_role]
writers: [control_plane, service_role]
typescript: "Database[\"evaluation\"][\"Tables\"][\"eval_case_relevance\"][\"Row\"]"
defined_in: ["20260903010300_knowledge_retrieval_completeness.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# evaluation.eval_case_relevance

table in domain `evaluation`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | PK |
| 2 | `eval_case_id` | `uuid` | no | — | PK |
| 3 | `projection_target_id` | `uuid` | no | — | PK |
| 4 | `relevance_grade` | `integer` | no | — | — |
| 5 | `rationale` | `text` | yes | — | — |
| 6 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (tenant_id, eval_case_id, projection_target_id)
- check `eval_case_relevance_relevance_grade_check`: `((relevance_grade >= 0) AND (relevance_grade <= 4))`

## Relationships

Outbound: `tenant_id,eval_case_id` → [`evaluation.eval_case`](eval_case.md)`.tenant_id,id` on delete restrict; `tenant_id,projection_target_id` → [`retrieval.projection_target`](../retrieval/projection_target.md)`.tenant_id,id` on delete restrict.
Inbound: none.

## Indexes

_None._

## Triggers

- `eval_case_relevance_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: INSERT, SELECT; `executor_service`: SELECT; `service_role`: INSERT, SELECT. None: `anon`, `app_reader`, `authenticated`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`.

## Write path

- Direct DML: `control_plane`.

## TypeScript

insert: `Database["evaluation"]["Tables"]["eval_case_relevance"]["Insert"]`; row: `Database["evaluation"]["Tables"]["eval_case_relevance"]["Row"]`; update: `Database["evaluation"]["Tables"]["eval_case_relevance"]["Update"]`

Defined in: `20260903010300_knowledge_retrieval_completeness.sql`.
