---
id: "rel:authoring.workspace_member"
kind: table
schema: authoring
name: workspace_member
domain: authoring
lens: ours
aliases: []
tokens: [authoring, workspace_member, authoring.workspace_member, id, tenant_id, workspace_id, principal_id, role, granted_by, created_at, revoked_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"authoring\"][\"Tables\"][\"workspace_member\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:027ab2b6133d5d59318c478f06d832d89f937e563c387539f37fb3d7668818a8"
---
# authoring.workspace_member

table in domain `authoring`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id) |
| 4 | `principal_id` | `uuid` | no | — | FK → `auth.users`.id |
| 5 | `role` | `text` | no | — | — |
| 6 | `granted_by` | `uuid` | no | — | FK → `auth.users`.id |
| 7 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 8 | `revoked_at` | `timestamp with time zone` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, workspace_id, id)
- check `workspace_member_role_check`: `(role = ANY (ARRAY['owner'::text, 'editor'::text, 'reader'::text]))`

## Relationships

Outbound: `granted_by` → `auth.users``.id` on delete restrict; `principal_id` → `auth.users``.id` on delete restrict; `tenant_id,workspace_id` → [`authoring.workspace`](workspace.md)`.tenant_id,id` on delete restrict.
Inbound: none.

## Indexes

`workspace_member_active_uq` unique where `(revoked_at IS NULL)`; `workspace_member_granted_by_fkey_ix`; `workspace_member_principal_ix` where `(revoked_at IS NULL)`; `workspace_member_tenant_id_workspace_id_id_key` unique

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
- Via functions (best effort): [`product.dispatch_command`](../../functions/product/dispatch_command.md), [`product.personal_workspace`](../../functions/product/personal_workspace.md).
- Product operations (best effort): [`create_workspace`](../../ops/create_workspace.md), [`grant_member`](../../ops/grant_member.md), [`revoke_member`](../../ops/revoke_member.md).

## TypeScript

insert: `Database["authoring"]["Tables"]["workspace_member"]["Insert"]`; row: `Database["authoring"]["Tables"]["workspace_member"]["Row"]`; update: `Database["authoring"]["Tables"]["workspace_member"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
