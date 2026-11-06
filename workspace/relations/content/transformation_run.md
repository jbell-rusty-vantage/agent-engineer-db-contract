---
id: "rel:content.transformation_run"
kind: table
schema: content
name: transformation_run
domain: content
aliases: []
tokens: [content, transformation_run, content.transformation_run, id, tenant_id, transformation_kind, contract_version, capability_version_id, code_ref, package_lock_sha256, environment_sha256, model_identity, provider_route, parameters, parameters_sha256, operation_id, attempt_id, status, idempotency_key, input_manifest_sha256, output_manifest_sha256, receipt, failure_class, resource_observations, cost_usd, started_at, ended_at, created_at, converter_identity, converter_version]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"content\"][\"Tables\"][\"transformation_run\"][\"Row\"]"
defined_in: ["20260903010000_knowledge_content_contract.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# content.transformation_run

table in domain `content`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id); unique (tenant_id, idempotency_key) |
| 3 | `transformation_kind` | `text` | no | — | FK → [`content.transformation_kind`](transformation_kind.md).code |
| 4 | `contract_version` | `text` | no | — | — |
| 5 | `capability_version_id` | `uuid` | yes | — | FK → [`orchestration.capability_version`](../orchestration/capability_version.md).id |
| 6 | `code_ref` | `text` | yes | — | — |
| 7 | `package_lock_sha256` | `text` | yes | — | — |
| 8 | `environment_sha256` | `text` | yes | — | — |
| 9 | `model_identity` | `text` | yes | — | — |
| 10 | `provider_route` | `text` | yes | — | — |
| 11 | `parameters` | `jsonb` | no | `'{}'::jsonb` | — |
| 12 | `parameters_sha256` | `text` | no | — | — |
| 13 | `operation_id` | `uuid` | yes | — | — |
| 14 | `attempt_id` | `uuid` | yes | — | — |
| 15 | `status` | `text` | no | `'queued'::text` | — |
| 16 | `idempotency_key` | `text` | no | — | unique (tenant_id, idempotency_key) |
| 17 | `input_manifest_sha256` | `text` | yes | — | — |
| 18 | `output_manifest_sha256` | `text` | yes | — | — |
| 19 | `receipt` | `jsonb` | yes | — | — |
| 20 | `failure_class` | `text` | yes | — | — |
| 21 | `resource_observations` | `jsonb` | no | `'{}'::jsonb` | — |
| 22 | `cost_usd` | `numeric(14,6)` | yes | — | — |
| 23 | `started_at` | `timestamp with time zone` | yes | — | — |
| 24 | `ended_at` | `timestamp with time zone` | yes | — | — |
| 25 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 26 | `converter_identity` | `text` | yes | — | — |
| 27 | `converter_version` | `text` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, idempotency_key)
- check `transformation_run_check`: `((status = ANY (ARRAY['succeeded'::text, 'failed'::text, 'cancelled'::text, 'superseded'::text])) = (ended_at IS NOT NULL))`
- check `transformation_run_environment_sha256_check`: `((environment_sha256 IS NULL) OR (environment_sha256 ~ '^[0-9a-f]{64}$'::text))`
- check `transformation_run_input_manifest_sha256_check`: `((input_manifest_sha256 IS NULL) OR (input_manifest_sha256 ~ '^[0-9a-f]{64}$'::text))`
- check `transformation_run_output_manifest_sha256_check`: `((output_manifest_sha256 IS NULL) OR (output_manifest_sha256 ~ '^[0-9a-f]{64}$'::text))`
- check `transformation_run_package_lock_sha256_check`: `((package_lock_sha256 IS NULL) OR (package_lock_sha256 ~ '^[0-9a-f]{64}$'::text))`
- check `transformation_run_parameters_sha256_check`: `(parameters_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `transformation_run_status_check`: `(status = ANY (ARRAY['proposed'::text, 'queued'::text, 'running'::text, 'needs_review'::text, 'succeeded'::text, 'failed'::text, 'cancelled…`

## Relationships

Outbound: `capability_version_id` → [`orchestration.capability_version`](../orchestration/capability_version.md)`.id` on delete restrict; `tenant_id,attempt_id` → [`orchestration.attempt`](../orchestration/attempt.md)`.tenant_id,id` on delete restrict; `transformation_kind` → [`content.transformation_kind`](transformation_kind.md)`.code`.
Inbound: [`content.document_representation`](document_representation.md).transformation_run_id, [`content.document_summary`](document_summary.md).transformation_run_id, [`content.transformation_input`](transformation_input.md).transformation_run_id, [`content.transformation_output`](transformation_output.md).transformation_run_id, [`orchestration.artifact_lineage`](../orchestration/artifact_lineage.md).transformation_run_id.

## Indexes

`transformation_operation_idx`; `transformation_run_tenant_id_id_key` unique; `transformation_run_tenant_id_idempotency_key_key` unique

## Triggers

- `transformation_run_terminal_guard` → [`content.guard_terminal_transformation`](../../functions/content/guard_terminal_transformation.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`executor_service`: INSERT, SELECT; `service_role`: INSERT, SELECT. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `executor_service`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["content"]["Tables"]["transformation_run"]["Insert"]`; row: `Database["content"]["Tables"]["transformation_run"]["Row"]`; update: `Database["content"]["Tables"]["transformation_run"]["Update"]`

Defined in: `20260903010000_knowledge_content_contract.sql`.
