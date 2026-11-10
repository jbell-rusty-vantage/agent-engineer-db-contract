---
id: "rel:authoring.file_set"
kind: table
schema: authoring
name: file_set
domain: authoring
lens: ours
aliases: []
tokens: [authoring, file_set, authoring.file_set, id, tenant_id, workspace_id, entrypoint, tree_sha256, file_count, total_bytes, origin, created_by, created_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"authoring\"][\"Tables\"][\"file_set\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:027ab2b6133d5d59318c478f06d832d89f937e563c387539f37fb3d7668818a8"
---
# authoring.file_set

table in domain `authoring`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id); unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, id); unique (tenant_id, workspace_id, id) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id) |
| 4 | `entrypoint` | `text` | no | — | — |
| 5 | `tree_sha256` | `text` | no | — | — |
| 6 | `file_count` | `integer` | no | — | — |
| 7 | `total_bytes` | `bigint` | no | — | — |
| 8 | `origin` | `text` | no | — | — |
| 9 | `created_by` | `uuid` | no | — | FK → `auth.users`.id |
| 10 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, workspace_id, id)
- check `file_set_entrypoint_check`: `(entrypoint !~ '(^/\|\.\.)'::text)`
- check `file_set_file_count_check`: `((file_count > 0) AND (file_count <= 5000))`
- check `file_set_origin_check`: `(origin = ANY (ARRAY['web'::text, 'harness'::text, 'mcp'::text, 'cli'::text, 'worker'::text]))`
- check `file_set_total_bytes_check`: `(total_bytes >= 0)`
- check `file_set_tree_sha256_check`: `(tree_sha256 ~ '^[0-9a-f]{64}$'::text)`

## Relationships

Outbound: `created_by` → `auth.users``.id` on delete restrict; `tenant_id,workspace_id` → [`authoring.workspace`](workspace.md)`.tenant_id,id` on delete restrict.
Inbound: [`authoring.deployment`](deployment.md).workspace_id,file_set_id|workspace_id,snapshot_file_set_id, [`authoring.file_set_entry`](file_set_entry.md).workspace_id,file_set_id, [`authoring.revision_binding`](revision_binding.md).workspace_id,file_set_id, [`inquiry.delivery`](../inquiry/delivery.md).workspace_id,file_set_id, [`learning.evidence_item`](../learning/evidence_item.md).workspace_id,file_set_id.

## Indexes

`file_set_created_by_fkey_ix`; `file_set_tenant_id_id_key` unique; `file_set_tenant_id_workspace_id_id_key` unique

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

insert: `Database["authoring"]["Tables"]["file_set"]["Insert"]`; row: `Database["authoring"]["Tables"]["file_set"]["Row"]`; update: `Database["authoring"]["Tables"]["file_set"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
