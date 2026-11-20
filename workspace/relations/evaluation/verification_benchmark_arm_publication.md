---
id: "rel:evaluation.verification_benchmark_arm_publication"
kind: table
schema: evaluation
name: verification_benchmark_arm_publication
domain: evaluation
lens: machinery
aliases: []
tokens: [evaluation, verification_benchmark_arm_publication, evaluation.verification_benchmark_arm_publication, id, tenant_id, benchmark_run_id, operation_id, benchmark_arm_id, experiment_arm_id, eval_run_id, publication_manifest_artifact_id, publication_manifest_sha256, configuration_artifact_id, configuration_sha256, policy_artifact_id, policy_sha256, target_code_ref, terminal_status, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, service_role]
writers: [control_plane, service_role]
typescript: "Database[\"evaluation\"][\"Tables\"][\"verification_benchmark_arm_publication\"][\"Row\"]"
defined_in: ["20260906030000_verification_benchmark_arm_publication.sql"]
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# evaluation.verification_benchmark_arm_publication

table in domain `evaluation`, lens `machinery`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, benchmark_run_id, benchmark_arm_id); unique (tenant_id, benchmark_run_id, experiment_arm_id); unique (tenant_id, eval_run_id); unique (tenant_id, id) |
| 3 | `benchmark_run_id` | `uuid` | no | — | unique (tenant_id, benchmark_run_id, benchmark_arm_id); unique (tenant_id, benchmark_run_id, experiment_arm_id) |
| 4 | `operation_id` | `uuid` | no | — | — |
| 5 | `benchmark_arm_id` | `text` | no | — | unique (tenant_id, benchmark_run_id, benchmark_arm_id) |
| 6 | `experiment_arm_id` | `uuid` | no | — | unique (tenant_id, benchmark_run_id, experiment_arm_id) |
| 7 | `eval_run_id` | `uuid` | no | — | unique (tenant_id, eval_run_id) |
| 8 | `publication_manifest_artifact_id` | `uuid` | no | — | — |
| 9 | `publication_manifest_sha256` | `text` | no | — | — |
| 10 | `configuration_artifact_id` | `uuid` | no | — | — |
| 11 | `configuration_sha256` | `text` | no | — | — |
| 12 | `policy_artifact_id` | `uuid` | no | — | — |
| 13 | `policy_sha256` | `text` | no | — | — |
| 14 | `target_code_ref` | `text` | no | — | — |
| 15 | `terminal_status` | `text` | no | — | — |
| 16 | `created_at` | `timestamp with time zone` | no | `clock_timestamp()` | — |

## Constraints

- PK (id)
- unique (tenant_id, benchmark_run_id, benchmark_arm_id)
- unique (tenant_id, benchmark_run_id, experiment_arm_id)
- unique (tenant_id, eval_run_id)
- unique (tenant_id, id)
- check `verification_benchmark_arm_pu_publication_manifest_sha256_check`: `(publication_manifest_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `verification_benchmark_arm_publicati_configuration_sha256_check`: `(configuration_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `verification_benchmark_arm_publication_benchmark_arm_id_check`: `(((length(benchmark_arm_id) >= 1) AND (length(benchmark_arm_id) <= 255)) AND (btrim(benchmark_arm_id) <> ''::text))`
- check `verification_benchmark_arm_publication_policy_sha256_check`: `(policy_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `verification_benchmark_arm_publication_target_code_ref_check`: `(((length(target_code_ref) >= 1) AND (length(target_code_ref) <= 4096)) AND (btrim(target_code_ref) <> ''::text))`
- check `verification_benchmark_arm_publication_terminal_status_check`: `(terminal_status = ANY (ARRAY['succeeded'::text, 'failed'::text, 'review'::text, 'abstained'::text]))`

## Relationships

Outbound: `tenant_id,configuration_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict; `tenant_id,policy_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict; `tenant_id,publication_manifest_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict; `tenant_id,experiment_arm_id` → [`evaluation.experiment_arm`](experiment_arm.md)`.tenant_id,id` on delete restrict; `tenant_id,benchmark_run_id` → [`evaluation.verification_benchmark_run`](verification_benchmark_run.md)`.tenant_id,id` on delete restrict; `tenant_id,operation_id` → [`knowledge_service.operation`](../knowledge_service/operation.md)`.tenant_id,id` on delete restrict; `tenant_id,eval_run_id` → [`evaluation.eval_run`](eval_run.md)`.tenant_id,id` on delete restrict.
Inbound: none.

## Indexes

`verification_benchmark_arm_pu_tenant_id_benchmark_run_id_be_key` unique; `verification_benchmark_arm_pu_tenant_id_benchmark_run_id_ex_key` unique; `verification_benchmark_arm_publicatio_tenant_id_eval_run_id_key` unique; `verification_benchmark_arm_publication_tenant_id_id_key` unique

## Triggers

- `artifact_retirement_21d6250956bc8b3d3886db90` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)
- `artifact_retirement_7256ab444770f6cd417e4104` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)
- `artifact_retirement_975f49b3ab6f197833466ea9` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)
- `verification_benchmark_arm_publication_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)
- `verification_benchmark_arm_publication_validate` → [`evaluation.validate_verification_benchmark_arm_publication`](../../functions/evaluation/validate_verification_benchmark_arm_publication.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `control_plane`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: INSERT, SELECT; `service_role`: INSERT, SELECT. None: `anon`, `app_reader`, `authenticated`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `control_plane`.

## Write path

- Direct DML: `control_plane`.

## TypeScript

insert: `Database["evaluation"]["Tables"]["verification_benchmark_arm_publication"]["Insert"]`; row: `Database["evaluation"]["Tables"]["verification_benchmark_arm_publication"]["Row"]`; update: `Database["evaluation"]["Tables"]["verification_benchmark_arm_publication"]["Update"]`

Defined in: `20260906030000_verification_benchmark_arm_publication.sql`.
