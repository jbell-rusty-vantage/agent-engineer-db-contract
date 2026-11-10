---
id: "rel:library.resource_control"
kind: table
schema: library
name: resource_control
domain: library
lens: ours
aliases: []
tokens: [library, resource_control, library.resource_control, tenant_id, workspace_id, work_id, excluded_at, excluded_by, semantic_index, updated_by, updated_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"library\"][\"Tables\"][\"resource_control\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:027ab2b6133d5d59318c478f06d832d89f937e563c387539f37fb3d7668818a8"
---
# library.resource_control

table in domain `library`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `tenant_id` | `uuid` | no | — | PK |
| 2 | `workspace_id` | `uuid` | no | — | PK |
| 3 | `work_id` | `uuid` | no | — | PK |
| 4 | `excluded_at` | `timestamp with time zone` | yes | — | — |
| 5 | `excluded_by` | `uuid` | yes | — | FK → `auth.users`.id |
| 6 | `semantic_index` | `boolean` | no | `false` | — |
| 7 | `updated_by` | `uuid` | no | — | FK → `auth.users`.id |
| 8 | `updated_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (tenant_id, workspace_id, work_id)
- check `resource_control_check`: `((excluded_at IS NULL) = (excluded_by IS NULL))`

## Relationships

Outbound: `excluded_by` → `auth.users``.id` on delete restrict; `tenant_id,workspace_id,work_id` → [`authoring.work`](../authoring/work.md)`.tenant_id,workspace_id,id` on delete restrict; `updated_by` → `auth.users``.id` on delete restrict.
Inbound: none.

## Indexes

`resource_control_excluded_by_fkey_ix`; `resource_control_updated_by_fkey_ix`

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
- Product operations (best effort): [`set_control`](../../ops/set_control.md).

## TypeScript

insert: `Database["library"]["Tables"]["resource_control"]["Insert"]`; row: `Database["library"]["Tables"]["resource_control"]["Row"]`; update: `Database["library"]["Tables"]["resource_control"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
