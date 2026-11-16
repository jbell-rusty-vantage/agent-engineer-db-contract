---
id: "rel:library.preparation"
kind: table
schema: library
name: preparation
domain: library
lens: ours
aliases: []
tokens: [library, preparation, library.preparation, id, tenant_id, workspace_id, revision_id, artifact_id, stage, procedure_version, status, attempt_count, failure_class, output_ref, origin_ref, updated_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"library\"][\"Tables\"][\"preparation\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:94ffe6a458de74a3cfebdee4fb31f371d14c89d7eaa16cfe1ab1cae9dc94743b"
---
# library.preparation

table in domain `library`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id) |
| 4 | `revision_id` | `uuid` | yes | — | — |
| 5 | `artifact_id` | `uuid` | yes | — | — |
| 6 | `stage` | `text` | no | — | — |
| 7 | `procedure_version` | `text` | no | — | — |
| 8 | `status` | `text` | no | — | — |
| 9 | `attempt_count` | `integer` | no | `0` | — |
| 10 | `failure_class` | `text` | yes | — | — |
| 11 | `output_ref` | `jsonb` | no | `'{}'::jsonb` | — |
| 12 | `origin_ref` | `jsonb` | no | `'{}'::jsonb` | — |
| 13 | `updated_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, workspace_id, id)
- check `preparation_attempt_count_check`: `(attempt_count >= 0)`
- check `preparation_check`: `(num_nonnulls(revision_id, artifact_id) = 1)`
- check `preparation_check1`: `((status = 'failed'::text) = (failure_class IS NOT NULL))`
- check `preparation_procedure_version_check`: `product.nonblank(procedure_version)`
- check `preparation_stage_check`: `(stage = ANY (ARRAY['receive'::text, 'convert'::text, 'extract'::text, 'index_lexical'::text, 'index_semantic'::text]))`
- check `preparation_status_check`: `(status = ANY (ARRAY['pending'::text, 'running'::text, 'succeeded'::text, 'failed'::text, 'skipped'::text]))`

## Relationships

Outbound: `tenant_id,artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict; `tenant_id,workspace_id,revision_id` → [`authoring.work_revision`](../authoring/work_revision.md)`.tenant_id,workspace_id,id` on delete restrict.
Inbound: none.

## Indexes

`preparation_target_uq` unique; `preparation_tenant_id_artifact_id_fkey_ix`; `preparation_tenant_id_workspace_id_id_key` unique; `preparation_tenant_id_workspace_id_revision_id_fkey_ix`

## Triggers

- `mutable_guard` → [`product.guard_mutable`](../../functions/product/guard_mutable.md)

## Row-level security

Enabled and forced.
- `product_api_all` (ALL) for `product_api_owner`: `true`

## Grants

No role has privileges. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

## Read paths

- No agent role may SELECT directly.

## Write path

- No direct DML for any agent role.
- Via functions (best effort): [`product.dispatch_worker`](../../functions/product/dispatch_worker.md).
- Product operations (best effort): [`index_passages`](../../ops/index_passages.md).

## TypeScript

insert: `Database["library"]["Tables"]["preparation"]["Insert"]`; row: `Database["library"]["Tables"]["preparation"]["Row"]`; update: `Database["library"]["Tables"]["preparation"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
