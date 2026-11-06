---
id: "rel:evaluation.judge_output"
kind: table
schema: evaluation
name: judge_output
domain: evaluation
aliases: []
tokens: [evaluation, judge_output, evaluation.judge_output, id, tenant_id, eval_run_case_output_id, grader_version_id, prompt_sha256, model_identity, schema_version, calibration_identity, output, output_sha256, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, service_role]
writers: [control_plane, service_role]
typescript: "Database[\"evaluation\"][\"Tables\"][\"judge_output\"][\"Row\"]"
defined_in: ["20260903010300_knowledge_retrieval_completeness.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# evaluation.judge_output

table in domain `evaluation`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | — |
| 3 | `eval_run_case_output_id` | `uuid` | no | — | — |
| 4 | `grader_version_id` | `uuid` | no | — | FK → [`evaluation.grader_version`](grader_version.md).id |
| 5 | `prompt_sha256` | `text` | no | — | — |
| 6 | `model_identity` | `text` | no | — | — |
| 7 | `schema_version` | `text` | no | — | — |
| 8 | `calibration_identity` | `text` | yes | — | — |
| 9 | `output` | `jsonb` | no | — | — |
| 10 | `output_sha256` | `text` | no | — | — |
| 11 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- check `judge_output_output_sha256_check`: `(output_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `judge_output_prompt_sha256_check`: `(prompt_sha256 ~ '^[0-9a-f]{64}$'::text)`

## Relationships

Outbound: `grader_version_id` → [`evaluation.grader_version`](grader_version.md)`.id` on delete restrict; `tenant_id,eval_run_case_output_id` → [`evaluation.eval_run_case_output`](eval_run_case_output.md)`.tenant_id,id` on delete restrict.
Inbound: none.

## Indexes

_None._

## Triggers

- `judge_output_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

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

insert: `Database["evaluation"]["Tables"]["judge_output"]["Insert"]`; row: `Database["evaluation"]["Tables"]["judge_output"]["Row"]`; update: `Database["evaluation"]["Tables"]["judge_output"]["Update"]`

Defined in: `20260903010300_knowledge_retrieval_completeness.sql`.
