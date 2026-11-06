---
id: "rel:evaluation.experiment_arm"
kind: table
schema: evaluation
name: experiment_arm
domain: evaluation
aliases: []
tokens: [evaluation, experiment_arm, evaluation.experiment_arm, id, tenant_id, experiment_id, name, configuration, is_control, created_at, verification_contract_version, configuration_artifact_id, configuration_sha256]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, service_role]
writers: [control_plane, service_role]
typescript: "Database[\"evaluation\"][\"Tables\"][\"experiment_arm\"][\"Row\"]"
defined_in: ["20260903010100_knowledge_retrieval_contract.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# evaluation.experiment_arm

table in domain `evaluation`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, experiment_id, name); unique (tenant_id, id) |
| 3 | `experiment_id` | `uuid` | no | — | unique (tenant_id, experiment_id, name) |
| 4 | `name` | `text` | no | — | unique (tenant_id, experiment_id, name) |
| 5 | `configuration` | `jsonb` | no | — | — |
| 6 | `is_control` | `boolean` | no | `false` | — |
| 7 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 8 | `verification_contract_version` | `text` | yes | — | — |
| 9 | `configuration_artifact_id` | `uuid` | yes | — | — |
| 10 | `configuration_sha256` | `text` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, experiment_id, name)
- unique (tenant_id, id)
- check `experiment_arm_configuration_sha256_check`: `((configuration_sha256 IS NULL) OR (configuration_sha256 ~ '^[0-9a-f]{64}$'::text))`
- check `experiment_arm_verification_contract_version_check`: `((verification_contract_version IS NULL) OR (verification_contract_version = 'verification.v1'::text))`
- check `experiment_arm_verification_freeze_ck`: `((verification_contract_version IS NULL) OR ((configuration_artifact_id IS NOT NULL) AND (configuration_sha256 IS NOT NULL)))`

## Relationships

Outbound: `tenant_id,configuration_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict; `tenant_id,experiment_id` → [`evaluation.experiment`](experiment.md)`.tenant_id,id` on delete restrict.
Inbound: [`evaluation.eval_run`](eval_run.md).experiment_arm_id, [`evaluation.verification_benchmark_arm_publication`](verification_benchmark_arm_publication.md).experiment_arm_id.

## Indexes

`experiment_arm_tenant_id_experiment_id_name_key` unique; `experiment_arm_tenant_id_id_key` unique

## Triggers

- `artifact_retirement_0a50dbb9d3e1c0d08788bde1` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)
- `experiment_arm_artifact_admission` → [`evaluation.validate_verification_artifact_consumer`](../../functions/evaluation/validate_verification_artifact_consumer.md)
- `experiment_arm_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)
- `experiment_arm_verification_freeze` → [`evaluation.guard_verification_freeze`](../../functions/evaluation/guard_verification_freeze.md)

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

insert: `Database["evaluation"]["Tables"]["experiment_arm"]["Insert"]`; row: `Database["evaluation"]["Tables"]["experiment_arm"]["Row"]`; update: `Database["evaluation"]["Tables"]["experiment_arm"]["Update"]`

Defined in: `20260903010100_knowledge_retrieval_contract.sql`.
