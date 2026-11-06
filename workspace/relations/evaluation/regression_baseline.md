---
id: "rel:evaluation.regression_baseline"
kind: table
schema: evaluation
name: regression_baseline
domain: evaluation
aliases: []
tokens: [evaluation, regression_baseline, evaluation.regression_baseline, id, tenant_id, name, gate_result_id, vector_space_version_id, baseline_sha256, created_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"evaluation\"][\"Tables\"][\"regression_baseline\"][\"Row\"]"
defined_in: ["20260903010100_knowledge_retrieval_contract.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# evaluation.regression_baseline

table in domain `evaluation`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id) |
| 3 | `name` | `text` | no | — | — |
| 4 | `gate_result_id` | `uuid` | no | — | — |
| 5 | `vector_space_version_id` | `uuid` | yes | — | — |
| 6 | `baseline_sha256` | `text` | no | — | — |
| 7 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `regression_baseline_baseline_sha256_check`: `(baseline_sha256 ~ '^[0-9a-f]{64}$'::text)`

## Relationships

Outbound: `tenant_id,gate_result_id` → [`evaluation.promotion_gate_result`](promotion_gate_result.md)`.tenant_id,id` on delete restrict; `tenant_id,vector_space_version_id` → [`retrieval.vector_space_version`](../retrieval/vector_space_version.md)`.tenant_id,id` on delete restrict.
Inbound: none.

## Indexes

`regression_baseline_tenant_id_id_key` unique

## Triggers

- `regression_baseline_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

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

insert: `Database["evaluation"]["Tables"]["regression_baseline"]["Insert"]`; row: `Database["evaluation"]["Tables"]["regression_baseline"]["Row"]`; update: `Database["evaluation"]["Tables"]["regression_baseline"]["Update"]`

Defined in: `20260903010100_knowledge_retrieval_contract.sql`.
