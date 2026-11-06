---
id: "rel:evaluation.eval_run_case_output"
kind: table
schema: evaluation
name: eval_run_case_output
domain: evaluation
aliases: []
tokens: [evaluation, eval_run_case_output, evaluation.eval_run_case_output, id, tenant_id, eval_run_id, eval_case_id, plan, candidates, packets, answer, output_sha256, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, service_role]
writers: [control_plane, service_role]
typescript: "Database[\"evaluation\"][\"Tables\"][\"eval_run_case_output\"][\"Row\"]"
defined_in: ["20260903010100_knowledge_retrieval_contract.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# evaluation.eval_run_case_output

table in domain `evaluation`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, eval_run_id, eval_case_id); unique (tenant_id, id) |
| 3 | `eval_run_id` | `uuid` | no | — | unique (tenant_id, eval_run_id, eval_case_id) |
| 4 | `eval_case_id` | `uuid` | no | — | unique (tenant_id, eval_run_id, eval_case_id); FK → [`evaluation.eval_case`](eval_case.md).id |
| 5 | `plan` | `jsonb` | yes | — | — |
| 6 | `candidates` | `jsonb` | yes | — | — |
| 7 | `packets` | `jsonb` | yes | — | — |
| 8 | `answer` | `jsonb` | yes | — | — |
| 9 | `output_sha256` | `text` | no | — | — |
| 10 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, eval_run_id, eval_case_id)
- unique (tenant_id, id)
- check `eval_run_case_output_output_sha256_check`: `(output_sha256 ~ '^[0-9a-f]{64}$'::text)`

## Relationships

Outbound: `eval_case_id` → [`evaluation.eval_case`](eval_case.md)`.id` on delete restrict; `tenant_id,eval_run_id` → [`evaluation.eval_run`](eval_run.md)`.tenant_id,id` on delete restrict.
Inbound: [`evaluation.judge_output`](judge_output.md).eval_run_case_output_id.

## Indexes

`eval_run_case_output_tenant_id_eval_run_id_eval_case_id_key` unique; `eval_run_case_output_tenant_id_id_key` unique

## Triggers

- `eval_run_case_output_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: INSERT, SELECT; `service_role`: INSERT, SELECT. None: `anon`, `app_reader`, `authenticated`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `control_plane`.

## Write path

- Direct DML: `control_plane`.

## TypeScript

insert: `Database["evaluation"]["Tables"]["eval_run_case_output"]["Insert"]`; row: `Database["evaluation"]["Tables"]["eval_run_case_output"]["Row"]`; update: `Database["evaluation"]["Tables"]["eval_run_case_output"]["Update"]`

Defined in: `20260903010100_knowledge_retrieval_contract.sql`.
