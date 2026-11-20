---
id: "rel:evaluation.eval_run"
kind: table
schema: evaluation
name: eval_run
domain: evaluation
lens: machinery
aliases: []
tokens: [evaluation, eval_run, evaluation.eval_run, id, tenant_id, dataset_id, grader_version_id, capability_version_id, space_version_id, target_code_ref, config, code_ref, executed_at, verification_contract_version, dataset_version_id, experiment_arm_id, mission_id, work_item_id, attempt_id, run_manifest_artifact_id, policy_artifact_id, status, started_at, ended_at, target_kind]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, service_role]
writers: [control_plane, service_role]
typescript: "Database[\"evaluation\"][\"Tables\"][\"eval_run\"][\"Row\"]"
defined_in: ["20260826001100_evaluation.sql"]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# evaluation.eval_run

table in domain `evaluation`, lens `machinery`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id) |
| 3 | `dataset_id` | `uuid` | no | — | FK → [`evaluation.eval_dataset`](eval_dataset.md).id |
| 4 | `grader_version_id` | `uuid` | yes | — | FK → [`evaluation.grader_version`](grader_version.md).id |
| 5 | `capability_version_id` | `uuid` | yes | — | FK → [`orchestration.capability_version`](../orchestration/capability_version.md).id |
| 6 | `space_version_id` | `uuid` | yes | — | FK → [`retrieval.vector_space_version`](../retrieval/vector_space_version.md).id |
| 9 | `target_code_ref` | `text` | yes | — | — |
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
| 25 | `target_kind` | `text` | yes | — | generated: ` CASE     WHEN (capability_version_id IS NOT NULL) THEN 'capability_version'::text     WHEN (space_version_id IS NOT NULL) THEN 'vector_space_version'::text     WHEN (target_code_ref IS NOT NULL) THEN 'code_ref'::text     ELSE NULL::text END` |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `eval_run_exactly_one_target`: `(num_nonnulls(capability_version_id, space_version_id, target_code_ref) = 1)`
- check `eval_run_status_check`: `((status IS NULL) OR (status = ANY (ARRAY['running'::text, 'succeeded'::text, 'failed'::text, 'review'::text, 'abstained'::text, 'cancelled…`
- check `eval_run_verification_binding_ck`: `((verification_contract_version IS NULL) OR ((dataset_version_id IS NOT NULL) AND (experiment_arm_id IS NOT NULL) AND (attempt_id IS NOT NU…`
- check `eval_run_verification_contract_version_check`: `((verification_contract_version IS NULL) OR (verification_contract_version = 'verification.v1'::text))`

## Relationships

Outbound: `tenant_id,attempt_id` → [`orchestration.attempt`](../orchestration/attempt.md)`.tenant_id,id` on delete restrict; `capability_version_id` → [`orchestration.capability_version`](../orchestration/capability_version.md)`.id`; `dataset_id` → [`evaluation.eval_dataset`](eval_dataset.md)`.id`; `tenant_id,dataset_version_id` → [`evaluation.eval_dataset_version`](eval_dataset_version.md)`.tenant_id,id` on delete restrict; `tenant_id,experiment_arm_id` → [`evaluation.experiment_arm`](experiment_arm.md)`.tenant_id,id` on delete restrict; `grader_version_id` → [`evaluation.grader_version`](grader_version.md)`.id`; `tenant_id,run_manifest_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict; `tenant_id,mission_id` → [`orchestration.mission`](../orchestration/mission.md)`.tenant_id,id` on delete restrict; `tenant_id,policy_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict; `space_version_id` → [`retrieval.vector_space_version`](../retrieval/vector_space_version.md)`.id`; `tenant_id,work_item_id` → [`orchestration.work_item`](../orchestration/work_item.md)`.tenant_id,id` on delete restrict.
Inbound: [`evaluation.eval_run_case_output`](eval_run_case_output.md).eval_run_id, [`evaluation.eval_score`](eval_score.md).run_id, [`evaluation.gate_result`](gate_result.md).eval_run_id, [`evaluation.metric_observation`](metric_observation.md).eval_run_id, [`evaluation.promotion_gate_result`](promotion_gate_result.md).eval_run_id, [`evaluation.regression`](regression.md).baseline_run_id|current_run_id, [`evaluation.verification_benchmark_arm_publication`](verification_benchmark_arm_publication.md).eval_run_id, [`retrieval.vector_item`](../retrieval/vector_item.md).generation_run_id, [`retrieval.vector_space_version`](../retrieval/vector_space_version.md).promotion_gate_eval_id.
Polymorphic: exactly one of `capability_version_id`, `space_version_id`, `target_code_ref` → [`orchestration.capability_version`](../orchestration/capability_version.md) | [`retrieval.vector_space_version`](../retrieval/vector_space_version.md) — basis: check constraint eval_run_exactly_one_target.

## Indexes

2 indexes; see [details](eval_run.details.md).

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
