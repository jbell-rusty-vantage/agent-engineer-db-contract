---
id: "rel:authoring.asset_scope"
kind: table
schema: authoring
name: asset_scope
domain: authoring
lens: ours
aliases: []
tokens: [authoring, asset_scope, authoring.asset_scope, id, tenant_id, workspace_id, artifact_id, registered_by, rights_basis, usage, retention, expires_at, created_at, revoked_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"authoring\"][\"Tables\"][\"asset_scope\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# authoring.asset_scope

table in domain `authoring`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, artifact_id); unique (tenant_id, workspace_id, id) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id) |
| 4 | `artifact_id` | `uuid` | no | — | unique (tenant_id, artifact_id) |
| 5 | `registered_by` | `uuid` | no | — | FK → `auth.users`.id |
| 6 | `rights_basis` | `text` | no | — | — |
| 7 | `usage` | `text` | no | — | — |
| 8 | `retention` | `text` | no | `'durable'::text` | — |
| 9 | `expires_at` | `timestamp with time zone` | yes | — | — |
| 10 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 11 | `revoked_at` | `timestamp with time zone` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, artifact_id)
- unique (tenant_id, workspace_id, id)
- check `asset_scope_check`: `((retention = 'temporary'::text) = (expires_at IS NOT NULL))`
- check `asset_scope_retention_check`: `(retention = ANY (ARRAY['durable'::text, 'temporary'::text]))`
- check `asset_scope_rights_basis_check`: `product.nonblank(rights_basis)`
- check `asset_scope_usage_check`: `(usage = ANY (ARRAY['reference_only'::text, 'private_copy'::text, 'redistributable'::text, 'unknown'::text]))`

## Relationships

Outbound: `registered_by` → `auth.users``.id` on delete restrict; `tenant_id,artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict; `tenant_id,workspace_id` → [`authoring.workspace`](workspace.md)`.tenant_id,id` on delete restrict.
Inbound: none.

## Indexes

`asset_scope_registered_by_fkey_ix`; `asset_scope_tenant_id_artifact_id_key` unique; `asset_scope_tenant_id_workspace_id_id_key` unique

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
- Via functions (best effort): [`product.dispatch_command`](../../functions/product/dispatch_command.md), [`product.register_artifact`](../../functions/product/register_artifact.md).
- Product operations (best effort): [`revoke_asset`](../../ops/revoke_asset.md).

## TypeScript

insert: `Database["authoring"]["Tables"]["asset_scope"]["Insert"]`; row: `Database["authoring"]["Tables"]["asset_scope"]["Row"]`; update: `Database["authoring"]["Tables"]["asset_scope"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
