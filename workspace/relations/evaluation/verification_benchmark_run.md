---
id: "rel:evaluation.verification_benchmark_run"
kind: table
schema: evaluation
name: verification_benchmark_run
domain: evaluation
aliases: []
tokens: [evaluation, verification_benchmark_run, evaluation.verification_benchmark_run, id, tenant_id, operation_id, dataset_artifact_id, dataset_sha256, experiment_artifact_id, experiment_sha256, runner_version, network_policy, random_seed, repetitions, checkpoint_plan, checkpoint_plan_sha256, expected_checkpoint_count, started_at, completed_at, run_manifest_artifact_id, run_manifest_sha256, status, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, service_role]
writers: [control_plane, service_role]
typescript: "Database[\"evaluation\"][\"Tables\"][\"verification_benchmark_run\"][\"Row\"]"
defined_in: ["20260906029000_verification_benchmark_durable_run.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# evaluation.verification_benchmark_run

table in domain `evaluation`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | — | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id); unique (tenant_id, operation_id) |
| 3 | `operation_id` | `uuid` | no | — | unique (tenant_id, operation_id) |
| 4 | `dataset_artifact_id` | `uuid` | no | — | — |
| 5 | `dataset_sha256` | `text` | no | — | — |
| 6 | `experiment_artifact_id` | `uuid` | no | — | — |
| 7 | `experiment_sha256` | `text` | no | — | — |
| 8 | `runner_version` | `text` | no | — | — |
| 9 | `network_policy` | `text` | no | — | — |
| 10 | `random_seed` | `integer` | no | — | — |
| 11 | `repetitions` | `integer` | no | — | — |
| 12 | `checkpoint_plan` | `jsonb` | no | — | — |
| 13 | `checkpoint_plan_sha256` | `text` | no | — | — |
| 14 | `expected_checkpoint_count` | `integer` | no | — | — |
| 15 | `started_at` | `timestamp with time zone` | no | — | — |
| 16 | `completed_at` | `timestamp with time zone` | yes | — | — |
| 17 | `run_manifest_artifact_id` | `uuid` | yes | — | — |
| 18 | `run_manifest_sha256` | `text` | yes | — | — |
| 19 | `status` | `text` | no | — | — |
| 20 | `created_at` | `timestamp with time zone` | no | `clock_timestamp()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, operation_id)
- check `verification_benchmark_run_checkpoint_plan_sha256_check`: `(checkpoint_plan_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `verification_benchmark_run_dataset_sha256_check`: `(dataset_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `verification_benchmark_run_expected_checkpoint_count_check`: `((expected_checkpoint_count >= 1) AND (expected_checkpoint_count <= 160000))`
- check `verification_benchmark_run_experiment_sha256_check`: `(experiment_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `verification_benchmark_run_lifecycle_ck`: `(((status = 'running'::text) AND (completed_at IS NULL) AND (run_manifest_artifact_id IS NULL) AND (run_manifest_sha256 IS NULL)) OR ((stat…`
- check `verification_benchmark_run_network_policy_check`: `(network_policy = 'offline'::text)`
- check `verification_benchmark_run_plan_shape_ck`: `((jsonb_typeof(checkpoint_plan) = 'array'::text) AND (jsonb_array_length(checkpoint_plan) = expected_checkpoint_count))`
- check `verification_benchmark_run_repetitions_check`: `((repetitions >= 1) AND (repetitions <= 10))`
- check `verification_benchmark_run_run_manifest_sha256_check`: `((run_manifest_sha256 IS NULL) OR (run_manifest_sha256 ~ '^[0-9a-f]{64}$'::text))`
- check `verification_benchmark_run_runner_version_check`: `((length(runner_version) >= 1) AND (length(runner_version) <= 255))`
- check `verification_benchmark_run_status_check`: `(status = ANY (ARRAY['running'::text, 'completed'::text, 'sealed'::text]))`

## Relationships

Outbound: `tenant_id,dataset_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict; `tenant_id,experiment_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict; `tenant_id,operation_id` → [`knowledge_service.operation`](../knowledge_service/operation.md)`.tenant_id,id` on delete restrict; `tenant_id,run_manifest_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict.
Inbound: [`evaluation.verification_benchmark_arm_publication`](verification_benchmark_arm_publication.md).benchmark_run_id, [`evaluation.verification_benchmark_checkpoint`](verification_benchmark_checkpoint.md).benchmark_run_id, [`evaluation.verification_benchmark_comparison`](verification_benchmark_comparison.md).candidate_run_id|baseline_run_id.

## Indexes

2 indexes; see [details](verification_benchmark_run.details.md).

## Triggers

6 triggers; see [details](verification_benchmark_run.details.md).

## Row-level security

Enabled; 1 policies in [details](verification_benchmark_run.details.md).

## Grants

`control_plane`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `control_plane`.

## Write path

- Direct DML: `control_plane`.

## TypeScript

insert: `Database["evaluation"]["Tables"]["verification_benchmark_run"]["Insert"]`; row: `Database["evaluation"]["Tables"]["verification_benchmark_run"]["Row"]`; update: `Database["evaluation"]["Tables"]["verification_benchmark_run"]["Update"]`

Defined in: `20260906029000_verification_benchmark_durable_run.sql`.
