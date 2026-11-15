---
id: "rel:library.connected_item"
kind: table
schema: library
name: connected_item
domain: library
lens: ours
aliases: []
tokens: [library, connected_item, library.connected_item, id, tenant_id, workspace_id, connection_id, external_id, external_kind, external_location, selected_via, work_id, editing_home, remote_revision, synced_revision_id, sync_state, suppressed_at, updated_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"library\"][\"Tables\"][\"connected_item\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
---
# library.connected_item

table in domain `library`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, workspace_id, connection_id, external_id); unique (tenant_id, workspace_id, id); unique (tenant_id, workspace_id, work_id) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, connection_id, external_id); unique (tenant_id, workspace_id, id); unique (tenant_id, workspace_id, work_id) |
| 4 | `connection_id` | `uuid` | no | — | unique (tenant_id, workspace_id, connection_id, external_id) |
| 5 | `external_id` | `text` | no | — | unique (tenant_id, workspace_id, connection_id, external_id) |
| 6 | `external_kind` | `text` | no | — | — |
| 7 | `external_location` | `text` | no | — | — |
| 8 | `selected_via` | `text` | no | — | — |
| 9 | `work_id` | `uuid` | no | — | unique (tenant_id, workspace_id, work_id) |
| 10 | `editing_home` | `text` | no | — | — |
| 11 | `remote_revision` | `text` | yes | — | — |
| 12 | `synced_revision_id` | `uuid` | yes | — | — |
| 13 | `sync_state` | `text` | no | — | — |
| 14 | `suppressed_at` | `timestamp with time zone` | yes | — | — |
| 15 | `updated_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, workspace_id, connection_id, external_id)
- unique (tenant_id, workspace_id, id)
- unique (tenant_id, workspace_id, work_id)
- check `connected_item_editing_home_check`: `(editing_home = ANY (ARRAY['external'::text, 'native'::text]))`
- check `connected_item_external_kind_check`: `(external_kind = ANY (ARRAY['page'::text, 'document'::text, 'file'::text, 'folder'::text]))`
- check `connected_item_selected_via_check`: `(selected_via = ANY (ARRAY['explicit'::text, 'folder_rule'::text]))`
- check `connected_item_sync_state_check`: `(sync_state = ANY (ARRAY['in_sync'::text, 'pending'::text, 'conflict'::text, 'unavailable'::text, 'remote_deleted'::text, 'disconnected'::t…`

## Relationships

Outbound: `tenant_id,workspace_id,connection_id` → [`library.connection`](connection.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,work_id` → [`authoring.work`](../authoring/work.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,work_id,synced_revision_id` → [`authoring.work_revision`](../authoring/work_revision.md)`.tenant_id,workspace_id,work_id,id` on delete restrict.
Inbound: none.

## Indexes

`connected_item_tenant_id_workspace_id_connection_id_externa_key` unique; `connected_item_tenant_id_workspace_id_id_key` unique; `connected_item_tenant_id_workspace_id_work_id_key` unique; `connected_item_tenant_id_workspace_id_work_id_synced_re_ix`

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
- Via functions (best effort): [`product.dispatch_command`](../../functions/product/dispatch_command.md).
- Product operations (best effort): [`confirm_removal`](../../ops/confirm_removal.md).

## TypeScript

insert: `Database["library"]["Tables"]["connected_item"]["Insert"]`; row: `Database["library"]["Tables"]["connected_item"]["Row"]`; update: `Database["library"]["Tables"]["connected_item"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
