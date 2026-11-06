---
id: "rel:evaluation.eval_dataset_version"
kind: table
schema: evaluation
name: eval_dataset_version
domain: evaluation
aliases: []
tokens: [evaluation, eval_dataset_version, evaluation.eval_dataset_version, id, tenant_id, dataset_id, version, manifest_sha256, manifest, created_at, contract_version, manifest_artifact_id, frozen_at, label_provenance, case_count]
summary: Immutable dataset version; verification.v1 rows require a frozen artifact-backed manifest and explicit label provenance.
summary_basis: comment
rls: enabled
readers: [control_plane, service_role]
writers: [control_plane, service_role]
typescript: "Database[\"evaluation\"][\"Tables\"][\"eval_dataset_version\"][\"Row\"]"
defined_in: ["20260903010100_knowledge_retrieval_contract.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# evaluation.eval_dataset_version

table in domain `evaluation` — Immutable dataset version; verification.v1 rows require a frozen artifact-backed manifest and explicit label provenance..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, dataset_id, version); unique (tenant_id, id) |
| 3 | `dataset_id` | `uuid` | no | — | unique (tenant_id, dataset_id, version) |
| 4 | `version` | `integer` | no | — | unique (tenant_id, dataset_id, version) |
| 5 | `manifest_sha256` | `text` | no | — | — |
| 6 | `manifest` | `jsonb` | no | — | — |
| 7 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 8 | `contract_version` | `text` | yes | — | — |
| 9 | `manifest_artifact_id` | `uuid` | yes | — | — |
| 10 | `frozen_at` | `timestamp with time zone` | yes | — | — |
| 11 | `label_provenance` | `text` | yes | — | — |
| 12 | `case_count` | `integer` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, dataset_id, version)
- unique (tenant_id, id)
- check `eval_dataset_version_case_count_check`: `((case_count IS NULL) OR (case_count > 0))`
- check `eval_dataset_version_contract_version_check`: `((contract_version IS NULL) OR (contract_version = 'verification.v1'::text))`
- check `eval_dataset_version_label_provenance_check`: `(label_provenance = ANY (ARRAY['human_adjudicated'::text, 'human_reviewed'::text, 'synthetic'::text, 'agent_generated'::text]))`
- check `eval_dataset_version_manifest_sha256_check`: `(manifest_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `eval_dataset_version_verification_freeze_ck`: `((contract_version IS NULL) OR ((manifest_artifact_id IS NOT NULL) AND (frozen_at IS NOT NULL) AND (label_provenance IS NOT NULL) AND (case…`

## Relationships

Outbound: `tenant_id,manifest_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict; `tenant_id,dataset_id` → [`evaluation.eval_dataset`](eval_dataset.md)`.tenant_id,id` on delete restrict.
Inbound: [`evaluation.eval_case`](eval_case.md).dataset_version_id, [`evaluation.eval_run`](eval_run.md).dataset_version_id, [`evaluation.experiment`](experiment.md).dataset_version_id.

## Indexes

`eval_dataset_version_tenant_id_dataset_id_version_key` unique; `eval_dataset_version_tenant_id_id_key` unique

## Triggers

- `artifact_retirement_3f4f27525db2e99a0a7afe9f` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)
- `eval_dataset_version_benchmark_publication_immutable` → [`evaluation.guard_benchmark_publication_dependency`](../../functions/evaluation/guard_benchmark_publication_dependency.md)
- `eval_dataset_version_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)
- `eval_dataset_version_manifest_binding` → [`evaluation.validate_verification_dataset_manifest`](../../functions/evaluation/validate_verification_dataset_manifest.md)

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

insert: `Database["evaluation"]["Tables"]["eval_dataset_version"]["Insert"]`; row: `Database["evaluation"]["Tables"]["eval_dataset_version"]["Row"]`; update: `Database["evaluation"]["Tables"]["eval_dataset_version"]["Update"]`

Defined in: `20260903010100_knowledge_retrieval_contract.sql`.
