---
id: "rel:evaluation.eval_score"
kind: table
schema: evaluation
name: eval_score
domain: evaluation
aliases: []
tokens: [evaluation, eval_score, evaluation.eval_score, id, run_id, case_id, metrics, passed, false_acceptance, false_rejection, created_at, tenant_id, verification_contract_version, result_artifact_id, result_sha256]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, service_role]
writers: [control_plane, service_role]
typescript: "Database[\"evaluation\"][\"Tables\"][\"eval_score\"][\"Row\"]"
defined_in: ["20260826001100_evaluation.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# evaluation.eval_score

table in domain `evaluation`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `run_id` | `uuid` | no | — | unique (run_id, case_id); FK → [`evaluation.eval_run`](eval_run.md).id |
| 3 | `case_id` | `uuid` | no | — | unique (run_id, case_id); FK → [`evaluation.eval_case`](eval_case.md).id |
| 4 | `metrics` | `jsonb` | no | `'{}'::jsonb` | — |
| 5 | `passed` | `boolean` | yes | — | — |
| 6 | `false_acceptance` | `boolean` | no | `false` | — |
| 7 | `false_rejection` | `boolean` | no | `false` | — |
| 8 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 9 | `tenant_id` | `uuid` | yes | — | — |
| 10 | `verification_contract_version` | `text` | yes | — | — |
| 11 | `result_artifact_id` | `uuid` | yes | — | — |
| 12 | `result_sha256` | `text` | yes | — | — |

## Constraints

- PK (id)
- unique (run_id, case_id)
- check `eval_score_result_sha256_check`: `((result_sha256 IS NULL) OR (result_sha256 ~ '^[0-9a-f]{64}$'::text))`
- check `eval_score_verification_binding_ck`: `((verification_contract_version IS NULL) OR ((tenant_id IS NOT NULL) AND (result_artifact_id IS NOT NULL) AND (result_sha256 IS NOT NULL)))`
- check `eval_score_verification_contract_version_check`: `((verification_contract_version IS NULL) OR (verification_contract_version = 'verification.v1'::text))`

## Relationships

Outbound: `case_id` → [`evaluation.eval_case`](eval_case.md)`.id` (+tenant); `tenant_id,result_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict; `run_id` → [`evaluation.eval_run`](eval_run.md)`.id` (+tenant) on delete cascade.
Inbound: none.

## Indexes

`eval_score_false_acceptance_idx` where `false_acceptance`; `eval_score_run_id_case_id_key` unique

## Triggers

- `artifact_retirement_1d6eb8ac1f61ea282470c85d` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)
- `eval_score_artifact_admission` → [`evaluation.validate_verification_artifact_consumer`](../../functions/evaluation/validate_verification_artifact_consumer.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: INSERT, SELECT, UPDATE; `executor_service`: SELECT; `service_role`: INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`.

## Write path

- Direct DML: `control_plane`.

## TypeScript

insert: `Database["evaluation"]["Tables"]["eval_score"]["Insert"]`; row: `Database["evaluation"]["Tables"]["eval_score"]["Row"]`; update: `Database["evaluation"]["Tables"]["eval_score"]["Update"]`

Defined in: `20260826001100_evaluation.sql`.
