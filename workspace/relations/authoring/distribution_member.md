---
id: "rel:authoring.distribution_member"
kind: table
schema: authoring
name: distribution_member
domain: authoring
lens: ours
aliases: []
tokens: [authoring, distribution_member, authoring.distribution_member, id, tenant_id, workspace_id, distribution_id, principal_id, grant_basis, granted_by, created_at, revoked_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"authoring\"][\"Tables\"][\"distribution_member\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# authoring.distribution_member

table in domain `authoring`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id) |
| 4 | `distribution_id` | `uuid` | no | — | — |
| 5 | `principal_id` | `uuid` | no | — | FK → `auth.users`.id |
| 6 | `grant_basis` | `text` | no | — | — |
| 7 | `granted_by` | `uuid` | no | — | FK → `auth.users`.id |
| 8 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 9 | `revoked_at` | `timestamp with time zone` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, workspace_id, id)
- check `distribution_member_grant_basis_check`: `(grant_basis = 'invited'::text)`

## Relationships

Outbound: `granted_by` → `auth.users``.id` on delete restrict; `principal_id` → `auth.users``.id` on delete restrict; `tenant_id,workspace_id,distribution_id` → [`authoring.distribution`](distribution.md)`.tenant_id,workspace_id,id` on delete restrict.
Inbound: none.

## Indexes

`distribution_member_active_uq` unique where `(revoked_at IS NULL)`; `distribution_member_granted_by_fkey_ix`; `distribution_member_principal_id_fkey_ix`; `distribution_member_tenant_id_workspace_id_distribution_ix`; `distribution_member_tenant_id_workspace_id_id_key` unique

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
- Product operations (best effort): [`grant_reader`](../../ops/grant_reader.md).

## TypeScript

insert: `Database["authoring"]["Tables"]["distribution_member"]["Insert"]`; row: `Database["authoring"]["Tables"]["distribution_member"]["Row"]`; update: `Database["authoring"]["Tables"]["distribution_member"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
