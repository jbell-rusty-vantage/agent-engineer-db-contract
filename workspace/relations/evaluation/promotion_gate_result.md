---
id: "rel:evaluation.promotion_gate_result"
kind: table
schema: evaluation
name: promotion_gate_result
domain: evaluation
aliases: []
tokens: [evaluation, promotion_gate_result, evaluation.promotion_gate_result, id, tenant_id, gate_version_id, eval_run_id, passed, false_acceptance_count, observations, result_sha256, created_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"evaluation\"][\"Tables\"][\"promotion_gate_result\"][\"Row\"]"
defined_in: ["20260903010100_knowledge_retrieval_contract.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# evaluation.promotion_gate_result

table in domain `evaluation`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id) |
| 3 | `gate_version_id` | `uuid` | no | — | — |
| 4 | `eval_run_id` | `uuid` | no | — | — |
| 5 | `passed` | `boolean` | no | — | — |
| 6 | `false_acceptance_count` | `integer` | no | `0` | — |
| 7 | `observations` | `jsonb` | no | — | — |
| 8 | `result_sha256` | `text` | no | — | — |
| 9 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `promotion_gate_result_result_sha256_check`: `(result_sha256 ~ '^[0-9a-f]{64}$'::text)`

## Relationships

Outbound: `tenant_id,eval_run_id` → [`evaluation.eval_run`](eval_run.md)`.tenant_id,id` on delete restrict; `tenant_id,gate_version_id` → [`evaluation.promotion_gate_version`](promotion_gate_version.md)`.tenant_id,id` on delete restrict.
Inbound: [`evaluation.regression_baseline`](regression_baseline.md).gate_result_id, [`retrieval.space_publication`](../retrieval/space_publication.md).evaluation_result_id.

## Indexes

`promotion_gate_result_tenant_id_id_key` unique

## Triggers

- `promotion_gate_result_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

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

insert: `Database["evaluation"]["Tables"]["promotion_gate_result"]["Insert"]`; row: `Database["evaluation"]["Tables"]["promotion_gate_result"]["Row"]`; update: `Database["evaluation"]["Tables"]["promotion_gate_result"]["Update"]`

Defined in: `20260903010100_knowledge_retrieval_contract.sql`.
