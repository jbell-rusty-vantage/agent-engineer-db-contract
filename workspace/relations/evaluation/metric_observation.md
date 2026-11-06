---
id: "rel:evaluation.metric_observation"
kind: table
schema: evaluation
name: metric_observation
domain: evaluation
aliases: []
tokens: [evaluation, metric_observation, evaluation.metric_observation, id, tenant_id, metric_definition_id, eval_run_id, eval_case_id, value, details, created_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"evaluation\"][\"Tables\"][\"metric_observation\"][\"Row\"]"
defined_in: ["20260903010100_knowledge_retrieval_contract.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# evaluation.metric_observation

table in domain `evaluation`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | — |
| 3 | `metric_definition_id` | `uuid` | no | — | — |
| 4 | `eval_run_id` | `uuid` | no | — | — |
| 5 | `eval_case_id` | `uuid` | yes | — | FK → [`evaluation.eval_case`](eval_case.md).id |
| 6 | `value` | `numeric` | yes | — | — |
| 7 | `details` | `jsonb` | no | `'{}'::jsonb` | — |
| 8 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)

## Relationships

Outbound: `eval_case_id` → [`evaluation.eval_case`](eval_case.md)`.id` on delete restrict; `tenant_id,eval_run_id` → [`evaluation.eval_run`](eval_run.md)`.tenant_id,id` on delete restrict; `tenant_id,metric_definition_id` → [`evaluation.metric_definition`](metric_definition.md)`.tenant_id,id` on delete restrict.
Inbound: none.

## Indexes

_None._

## Triggers

- `metric_observation_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

No role has privileges. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

## Read paths

- No agent role may SELECT directly.

## Write path

- No direct DML for any agent role.
- No write path for agents; rows are seeded by migrations or platform tooling.

## TypeScript

insert: `Database["evaluation"]["Tables"]["metric_observation"]["Insert"]`; row: `Database["evaluation"]["Tables"]["metric_observation"]["Row"]`; update: `Database["evaluation"]["Tables"]["metric_observation"]["Update"]`

Defined in: `20260903010100_knowledge_retrieval_contract.sql`.
