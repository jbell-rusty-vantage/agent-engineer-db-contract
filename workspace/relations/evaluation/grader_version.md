---
id: "rel:evaluation.grader_version"
kind: table
schema: evaluation
name: grader_version
domain: evaluation
aliases: []
tokens: [evaluation, grader_version, evaluation.grader_version, id, grader_id, version, code_ref, model, prompt, config, created_at, tenant_id, verification_contract_version, manifest_artifact_id, manifest_sha256]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, service_role]
writers: [control_plane, service_role]
typescript: "Database[\"evaluation\"][\"Tables\"][\"grader_version\"][\"Row\"]"
defined_in: ["20260826001100_evaluation.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# evaluation.grader_version

table in domain `evaluation`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `grader_id` | `uuid` | no | — | unique (grader_id, version); FK → [`evaluation.grader`](grader.md).id |
| 3 | `version` | `integer` | no | — | unique (grader_id, version) |
| 4 | `code_ref` | `text` | yes | — | — |
| 5 | `model` | `text` | yes | — | — |
| 6 | `prompt` | `text` | yes | — | — |
| 7 | `config` | `jsonb` | no | `'{}'::jsonb` | — |
| 8 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 9 | `tenant_id` | `uuid` | yes | — | unique (tenant_id, id) |
| 10 | `verification_contract_version` | `text` | yes | — | — |
| 11 | `manifest_artifact_id` | `uuid` | yes | — | — |
| 12 | `manifest_sha256` | `text` | yes | — | — |

## Constraints

- PK (id)
- unique (grader_id, version)
- unique (tenant_id, id)
- check `grader_version_manifest_sha256_check`: `((manifest_sha256 IS NULL) OR (manifest_sha256 ~ '^[0-9a-f]{64}$'::text))`
- check `grader_version_verification_contract_version_check`: `((verification_contract_version IS NULL) OR (verification_contract_version = 'verification.v1'::text))`
- check `grader_version_verification_freeze_ck`: `((verification_contract_version IS NULL) OR ((tenant_id IS NOT NULL) AND (manifest_artifact_id IS NOT NULL) AND (manifest_sha256 IS NOT NUL…`

## Relationships

Outbound: `grader_id` → [`evaluation.grader`](grader.md)`.id` (+tenant) on delete cascade; `tenant_id,manifest_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict.
Inbound: [`evaluation.eval_run`](eval_run.md).grader_version_id, [`evaluation.judge_output`](judge_output.md).grader_version_id.

## Indexes

`grader_version_grader_id_version_key` unique; `grader_version_tenant_id_uq` unique

## Triggers

- `artifact_retirement_bd2677f61b9ba67b5fb69fe4` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)
- `grader_version_artifact_admission` → [`evaluation.validate_verification_artifact_consumer`](../../functions/evaluation/validate_verification_artifact_consumer.md)
- `grader_version_verification_freeze` → [`evaluation.guard_verification_freeze`](../../functions/evaluation/guard_verification_freeze.md)

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

insert: `Database["evaluation"]["Tables"]["grader_version"]["Insert"]`; row: `Database["evaluation"]["Tables"]["grader_version"]["Row"]`; update: `Database["evaluation"]["Tables"]["grader_version"]["Update"]`

Defined in: `20260826001100_evaluation.sql`.
