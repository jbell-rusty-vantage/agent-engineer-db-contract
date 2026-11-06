---
id: "rel:evaluation.eval_case"
kind: table
schema: evaluation
name: eval_case
domain: evaluation
aliases: []
tokens: [evaluation, eval_case, evaluation.eval_case, id, dataset_id, external_key, input, expected, metadata, created_at, tenant_id, dataset_version_id, verification_contract_version, input_manifest_artifact_id, gold_artifact_id, case_sha256]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, service_role]
writers: [control_plane, service_role]
typescript: "Database[\"evaluation\"][\"Tables\"][\"eval_case\"][\"Row\"]"
defined_in: ["20260826001100_evaluation.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# evaluation.eval_case

table in domain `evaluation`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `dataset_id` | `uuid` | no | — | unique (dataset_id, external_key); FK → [`evaluation.eval_dataset`](eval_dataset.md).id |
| 3 | `external_key` | `text` | yes | — | unique (dataset_id, external_key) |
| 4 | `input` | `jsonb` | no | — | — |
| 5 | `expected` | `jsonb` | yes | — | — |
| 6 | `metadata` | `jsonb` | no | `'{}'::jsonb` | — |
| 7 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 8 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id) |
| 9 | `dataset_version_id` | `uuid` | yes | — | — |
| 10 | `verification_contract_version` | `text` | yes | — | — |
| 11 | `input_manifest_artifact_id` | `uuid` | yes | — | — |
| 12 | `gold_artifact_id` | `uuid` | yes | — | — |
| 13 | `case_sha256` | `text` | yes | — | — |

## Constraints

- PK (id)
- unique (dataset_id, external_key)
- unique (tenant_id, id)
- check `eval_case_case_sha256_check`: `((case_sha256 IS NULL) OR (case_sha256 ~ '^[0-9a-f]{64}$'::text))`
- check `eval_case_verification_contract_version_check`: `((verification_contract_version IS NULL) OR (verification_contract_version = 'verification.v1'::text))`
- check `eval_case_verification_freeze_ck`: `((verification_contract_version IS NULL) OR ((dataset_version_id IS NOT NULL) AND (input_manifest_artifact_id IS NOT NULL) AND (gold_artifa…`

## Relationships

Outbound: `dataset_id` → [`evaluation.eval_dataset`](eval_dataset.md)`.id` (+tenant) on delete cascade; `tenant_id,gold_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict; `tenant_id,input_manifest_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict; `tenant_id,dataset_version_id` → [`evaluation.eval_dataset_version`](eval_dataset_version.md)`.tenant_id,id` on delete restrict.
Inbound: [`evaluation.eval_case_expected_filter`](eval_case_expected_filter.md).eval_case_id, [`evaluation.eval_case_provenance`](eval_case_provenance.md).eval_case_id, [`evaluation.eval_case_relevance`](eval_case_relevance.md).eval_case_id, [`evaluation.eval_label`](eval_label.md).case_id, [`evaluation.eval_run_case_output`](eval_run_case_output.md).eval_case_id, [`evaluation.eval_score`](eval_score.md).case_id, [`evaluation.metric_observation`](metric_observation.md).eval_case_id.

## Indexes

`eval_case_dataset_id_external_key_key` unique; `eval_case_tenant_id_uq` unique

## Triggers

- `artifact_retirement_767c413f24512b66c66dac26` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)
- `artifact_retirement_cc985024656064e355009ae4` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)
- `eval_case_artifact_admission` → [`evaluation.validate_verification_artifact_consumer`](../../functions/evaluation/validate_verification_artifact_consumer.md)
- `eval_case_verification_freeze` → [`evaluation.guard_verification_freeze`](../../functions/evaluation/guard_verification_freeze.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `false`

## Grants

`control_plane`: INSERT, SELECT, UPDATE; `executor_service`: SELECT; `service_role`: INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`.

## Write path

- Direct DML: `control_plane`.

## TypeScript

insert: `Database["evaluation"]["Tables"]["eval_case"]["Insert"]`; row: `Database["evaluation"]["Tables"]["eval_case"]["Row"]`; update: `Database["evaluation"]["Tables"]["eval_case"]["Update"]`

Defined in: `20260826001100_evaluation.sql`.
