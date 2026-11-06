---
id: "rel:knowledge_service.scoped_checkpoint"
kind: table
schema: knowledge_service
name: scoped_checkpoint
domain: knowledge-service-runtime
aliases: []
tokens: [knowledge_service, scoped_checkpoint, knowledge_service.scoped_checkpoint, tenant_id, id, scope_id, parent_checkpoint_id, revision, idempotency_key, request_digest, manifest_artifact_id, manifest_handle, mode, committed_at, harness_request_digest]
summary: Standalone KS durable workspace custody; no mission workflow acceptance or scheduler ownership.
summary_basis: comment
rls: enabled
readers: [executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"knowledge_service\"][\"Tables\"][\"scoped_checkpoint\"][\"Row\"]"
defined_in: ["20260914010500_scoped_checkpoints.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# knowledge_service.scoped_checkpoint

table in domain `knowledge-service-runtime` — Standalone KS durable workspace custody; no mission workflow acceptance or scheduler ownership..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `tenant_id` | `uuid` | no | — | PK; unique (tenant_id, scope_id, id); unique (tenant_id, scope_id, idempotency_key); unique (tenant_id, scope_id, revision) |
| 2 | `id` | `uuid` | no | — | PK; unique (tenant_id, scope_id, id) |
| 3 | `scope_id` | `uuid` | no | — | unique (tenant_id, scope_id, id); unique (tenant_id, scope_id, idempotency_key); unique (tenant_id, scope_id, revision) |
| 4 | `parent_checkpoint_id` | `uuid` | yes | — | — |
| 5 | `revision` | `bigint` | no | — | unique (tenant_id, scope_id, revision) |
| 6 | `idempotency_key` | `text` | no | — | unique (tenant_id, scope_id, idempotency_key) |
| 7 | `request_digest` | `text` | no | — | — |
| 8 | `manifest_artifact_id` | `uuid` | no | — | — |
| 9 | `manifest_handle` | `jsonb` | no | — | — |
| 10 | `mode` | `text` | no | — | — |
| 11 | `committed_at` | `timestamp with time zone` | no | `date_trunc('milliseconds'::text, clock_timestamp())` | — |
| 12 | `harness_request_digest` | `text` | yes | — | Stable original harness input binding for acknowledgement recovery before capturing a fresh executor snapshot; separate from full manifest request_digest. |

## Constraints

- PK (tenant_id, id)
- unique (tenant_id, scope_id, id)
- unique (tenant_id, scope_id, idempotency_key)
- unique (tenant_id, scope_id, revision)
- check `scoped_checkpoint_check`: `(NOT ((manifest_handle ->> 'artifactId'::text) IS DISTINCT FROM (manifest_artifact_id)::text))`
- check `scoped_checkpoint_check1`: `(NOT ((manifest_handle ->> 'tenantId'::text) IS DISTINCT FROM (tenant_id)::text))`
- check `scoped_checkpoint_harness_request_digest_check`: `((harness_request_digest IS NULL) OR (harness_request_digest ~ '^sha256:[0-9a-f]{64}$'::text))`
- check `scoped_checkpoint_idempotency_key_check`: `((length(btrim(idempotency_key)) >= 1) AND (length(btrim(idempotency_key)) <= 256))`
- check `scoped_checkpoint_manifest_handle_check`: `(jsonb_typeof(manifest_handle) = 'object'::text)`
- check `scoped_checkpoint_mode_check`: `(mode = ANY (ARRAY['archive'::text, 'continuation'::text]))`
- check `scoped_checkpoint_request_digest_check`: `(request_digest ~ '^sha256:[0-9a-f]{64}$'::text)`
- check `scoped_checkpoint_revision_check`: `(revision > 0)`

## Relationships

Outbound: `tenant_id,manifest_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id`; `tenant_id,scope_id` → [`knowledge_service.checkpoint_scope`](checkpoint_scope.md)`.tenant_id,id`; `tenant_id,scope_id,parent_checkpoint_id` → [`knowledge_service.scoped_checkpoint`](scoped_checkpoint.md)`.tenant_id,scope_id,id`.
Inbound: [`knowledge_service.checkpoint_artifact_reference`](checkpoint_artifact_reference.md).checkpoint_id, [`knowledge_service.checkpoint_scope`](checkpoint_scope.md).id,head_checkpoint_id, [`knowledge_service.scoped_checkpoint`](scoped_checkpoint.md).scope_id,parent_checkpoint_id.

## Indexes

`scoped_checkpoint_tenant_id_scope_id_id_key` unique; `scoped_checkpoint_tenant_id_scope_id_idempotency_key_key` unique; `scoped_checkpoint_tenant_id_scope_id_revision_key` unique

## Triggers

- `artifact_retirement_8771935a59ffcd3c1da90d9f` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)
- `scoped_checkpoint_admission` → [`knowledge_service.guard_scoped_checkpoint`](../../functions/knowledge_service/guard_scoped_checkpoint.md)
- `scoped_checkpoint_complete` → [`knowledge_service.require_checkpoint_commit`](../../functions/knowledge_service/require_checkpoint_commit.md) (constraint trigger, deferred)
- `scoped_checkpoint_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled.
- `scoped_checkpoint_tenant` (ALL) for `executor_service`: `(tenant_id = util.current_tenant_id())`

## Grants

`executor_service`: INSERT, SELECT; `service_role`: INSERT, SELECT. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `executor_service`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["knowledge_service"]["Tables"]["scoped_checkpoint"]["Insert"]`; row: `Database["knowledge_service"]["Tables"]["scoped_checkpoint"]["Row"]`; update: `Database["knowledge_service"]["Tables"]["scoped_checkpoint"]["Update"]`

Defined in: `20260914010500_scoped_checkpoints.sql`.
