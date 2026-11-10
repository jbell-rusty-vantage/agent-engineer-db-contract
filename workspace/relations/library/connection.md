---
id: "rel:library.connection"
kind: table
schema: library
name: connection
domain: library
lens: ours
aliases: []
tokens: [library, connection, library.connection, id, tenant_id, workspace_id, provider, account_label, capabilities, credential_handle, status, connected_by, created_at, disconnected_at, last_error]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"library\"][\"Tables\"][\"connection\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:027ab2b6133d5d59318c478f06d832d89f937e563c387539f37fb3d7668818a8"
---
# library.connection

table in domain `library`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id) |
| 4 | `provider` | `text` | no | — | — |
| 5 | `account_label` | `text` | no | — | — |
| 6 | `capabilities` | `text[]` | no | — | — |
| 7 | `credential_handle` | `text` | no | — | — |
| 8 | `status` | `text` | no | — | — |
| 9 | `connected_by` | `uuid` | no | — | FK → `auth.users`.id |
| 10 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 11 | `disconnected_at` | `timestamp with time zone` | yes | — | — |
| 12 | `last_error` | `text` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, workspace_id, id)
- check `connection_account_label_check`: `product.nonblank(account_label)`
- check `connection_capabilities_check`: `((capabilities <@ ARRAY['read'::text, 'write'::text, 'watch'::text]) AND (cardinality(capabilities) > 0))`
- check `connection_check`: `((status = 'disconnected'::text) = (disconnected_at IS NOT NULL))`
- check `connection_credential_handle_check`: `((credential_handle ~ '^[a-z0-9][a-z0-9_./:-]{2,200}$'::text) AND (credential_handle !~ '(sk-\|ghp_\|xox[bp]-\|AKIA\|secret_)'::text))`
- check `connection_provider_check`: `(provider = ANY (ARRAY['obsidian'::text, 'notion'::text, 'google_drive'::text, 'local_folder'::text]))`
- check `connection_status_check`: `(status = ANY (ARRAY['active'::text, 'error'::text, 'disconnected'::text]))`

## Relationships

Outbound: `connected_by` → `auth.users``.id` on delete restrict; `tenant_id,workspace_id` → [`authoring.workspace`](../authoring/workspace.md)`.tenant_id,id` on delete restrict.
Inbound: [`library.connected_item`](connected_item.md).workspace_id,connection_id.

## Indexes

`connection_connected_by_fkey_ix`; `connection_tenant_id_workspace_id_id_key` unique

## Triggers

- `immutable_guard` → [`product.guard_mutable`](../../functions/product/guard_mutable.md)

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
- Product operations (best effort): [`create_connection`](../../ops/create_connection.md).

## TypeScript

insert: `Database["library"]["Tables"]["connection"]["Insert"]`; row: `Database["library"]["Tables"]["connection"]["Row"]`; update: `Database["library"]["Tables"]["connection"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
