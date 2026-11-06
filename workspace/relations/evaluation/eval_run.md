---
id: "rel:evaluation.eval_run"
kind: table
schema: evaluation
name: eval_run
domain: evaluation
aliases: []
tokens: [evaluation, eval_run, evaluation.eval_run, id, tenant_id, dataset_id, grader_version_id, capability_version_id, space_version_id, ranking_policy_version_id, metric_definition_version_id, target_code_ref, target_kind, config, code_ref, executed_at, verification_contract_version, dataset_version_id, experiment_arm_id, mission_id, work_item_id, attempt_id, run_manifest_artifact_id, policy_artifact_id, status, started_at, ended_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, service_role]
writers: [control_plane, service_role]
typescript: "Database[\"evaluation\"][\"Tables\"][\"eval_run\"][\"Row\"]"
defined_in: ["20260826001100_evaluation.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# evaluation.eval_run

table in domain `evaluation`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id) |
| 3 | `dataset_id` | `uuid` | no | — | FK → [`evaluation.eval_dataset`](eval_dataset.md).id |
| 4 | `grader_version_id` | `uuid` | yes | — | FK → [`evaluation.grader_version`](grader_version.md).id |
| 5 | `capability_version_id` | `uuid` | yes | — | FK → [`orchestration.capability_version`](../orchestration/capability_version.md).id |
| 6 | `space_version_id` | `uuid` | yes | — | FK → [`retrieval.vector_space_version`](../retrieval/vector_space_version.md).id |
| 7 | `ranking_policy_version_id` | `uuid` | yes | — | FK → [`ranking.ranking_policy_version`](../ranking/ranking_policy_version.md).id |
| 8 | `metric_definition_version_id` | `uuid` | yes | — | FK → [`ranking.metric_definition_version`](../ranking/metric_definition_version.md).id |
| 9 | `target_code_ref` | `text` | yes | — | — |
| 10 | `target_kind` | `text` | yes | — | generated: ` CASE     WHEN (capability_version_id IS NOT NULL) THEN 'capability_version'::text     WHEN (space_version_id IS NOT NULL) THEN 'vector_space_version'::text     WHEN (ranking_policy_version_id IS NOT NULL) THEN 'ranking_policy_version'::text     WHEN (metric_definition_version_id IS NOT NULL) THEN 'metric_definition_version'::text     WHEN (target_code_ref IS NOT NULL) THEN 'code_ref'::text     ELSE NULL::text END` |
| 11 | `config` | `jsonb` | no | `'{}'::jsonb` | — |
| 12 | `code_ref` | `text` | yes | — | — |
| 13 | `executed_at` | `timestamp with time zone` | no | `now()` | — |
| 14 | `verification_contract_version` | `text` | yes | — | — |
| 15 | `dataset_version_id` | `uuid` | yes | — | — |
| 16 | `experiment_arm_id` | `uuid` | yes | — | — |
| 17 | `mission_id` | `uuid` | yes | — | — |
| 18 | `work_item_id` | `uuid` | yes | — | — |
| 19 | `attempt_id` | `uuid` | yes | — | — |
| 20 | `run_manifest_artifact_id` | `uuid` | yes | — | — |
| 21 | `policy_artifact_id` | `uuid` | yes | — | — |
| 22 | `status` | `text` | yes | — | — |
| 23 | `started_at` | `timestamp with time zone` | yes | — | — |
| 24 | `ended_at` | `timestamp with time zone` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `eval_run_exactly_one_target`: `(num_nonnulls(capability_version_id, space_version_id, ranking_policy_version_id, metric_definition_version_id, target_code_ref) = 1)`
- check `eval_run_status_check`: `((status IS NULL) OR (status = ANY (ARRAY['running'::text, 'succeeded'::text, 'failed'::text, 'review'::text, 'abstained'::text, 'cancelled…`
- check `eval_run_verification_binding_ck`: `((verification_contract_version IS NULL) OR ((dataset_version_id IS NOT NULL) AND (experiment_arm_id IS NOT NULL) AND (attempt_id IS NOT NU…`
- check `eval_run_verification_contract_version_check`: `((verification_contract_version IS NULL) OR (verification_contract_version = 'verification.v1'::text))`

## Relationships

13 outbound and 12 inbound foreign keys; full list in [details](eval_run.details.md).

## Indexes

3 indexes; see [details](eval_run.details.md).

## Triggers

4 triggers; see [details](eval_run.details.md).

## Row-level security

Enabled; 1 policies in [details](eval_run.details.md).

## Grants

`control_plane`: INSERT, SELECT, UPDATE; `executor_service`: SELECT; `service_role`: INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`.

## Write path

- Direct DML: `control_plane`.

## TypeScript

insert: `Database["evaluation"]["Tables"]["eval_run"]["Insert"]`; row: `Database["evaluation"]["Tables"]["eval_run"]["Row"]`; update: `Database["evaluation"]["Tables"]["eval_run"]["Update"]`

Defined in: `20260826001100_evaluation.sql`.
