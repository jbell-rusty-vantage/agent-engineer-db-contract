---
id: "rel:authoring.file_set_entry"
kind: table
schema: authoring
name: file_set_entry
domain: authoring
lens: ours
aliases: []
tokens: [authoring, file_set_entry, authoring.file_set_entry, id, tenant_id, workspace_id, file_set_id, path, artifact_id, sha256, size_bytes, media_type]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"authoring\"][\"Tables\"][\"file_set_entry\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
---
# authoring.file_set_entry

table in domain `authoring`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, workspace_id, file_set_id, path); unique (tenant_id, workspace_id, id) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, file_set_id, path); unique (tenant_id, workspace_id, id) |
| 4 | `file_set_id` | `uuid` | no | — | unique (tenant_id, workspace_id, file_set_id, path) |
| 5 | `path` | `text` | no | — | unique (tenant_id, workspace_id, file_set_id, path) |
| 6 | `artifact_id` | `uuid` | no | — | — |
| 7 | `sha256` | `text` | no | — | — |
| 8 | `size_bytes` | `bigint` | no | — | — |
| 9 | `media_type` | `text` | no | — | — |

## Constraints

- PK (id)
- unique (tenant_id, workspace_id, file_set_id, path)
- unique (tenant_id, workspace_id, id)
- check `file_set_entry_path_check`: `((char_length(path) <= 512) AND (path ~ '^[A-Za-z0-9._@+-][A-Za-z0-9._@+/-]*$'::text) AND (path !~ '(^\|/)\.\.(/\|$)'::text) AND (path !~ '//…`
- check `file_set_entry_sha256_check`: `(sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `file_set_entry_size_bytes_check`: `(size_bytes >= 0)`

## Relationships

Outbound: `tenant_id,artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict; `tenant_id,workspace_id,file_set_id` → [`authoring.file_set`](file_set.md)`.tenant_id,workspace_id,id` on delete restrict.
Inbound: none.

## Indexes

`file_set_entry_tenant_id_artifact_id_fkey_ix`; `file_set_entry_tenant_id_workspace_id_file_set_id_path_key` unique; `file_set_entry_tenant_id_workspace_id_id_key` unique

## Triggers

- `immutable_guard` → [`product.guard_immutable`](../../functions/product/guard_immutable.md)

## Row-level security

Enabled and forced.
- `product_api_all` (ALL) for `product_api_owner`: `true`

## Grants

No role has privileges. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

## Read paths

- No agent role may SELECT directly.

## Write path

- No direct DML for any agent role.
- Via functions (best effort): [`product.dispatch_command`](../../functions/product/dispatch_command.md).
- Product operations (best effort): [`register_file_set`](../../ops/register_file_set.md).

## TypeScript

insert: `Database["authoring"]["Tables"]["file_set_entry"]["Insert"]`; row: `Database["authoring"]["Tables"]["file_set_entry"]["Row"]`; update: `Database["authoring"]["Tables"]["file_set_entry"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
