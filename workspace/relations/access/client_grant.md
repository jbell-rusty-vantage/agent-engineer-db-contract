---
id: "rel:access.client_grant"
kind: table
schema: access
name: client_grant
domain: access
lens: ours
aliases: []
tokens: [access, client_grant, access.client_grant, id, tenant_id, principal_id, client_kind, label, token_sha256, scopes, workspace_ids, expires_at, created_at, last_used_at, revoked_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"access\"][\"Tables\"][\"client_grant\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
---
# access.client_grant

table in domain `access`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, id) |
| 3 | `principal_id` | `uuid` | no | — | FK → `auth.users`.id |
| 4 | `client_kind` | `text` | no | — | — |
| 5 | `label` | `text` | no | — | — |
| 6 | `token_sha256` | `text` | no | — | unique (token_sha256) |
| 7 | `scopes` | `text[]` | no | — | — |
| 8 | `workspace_ids` | `uuid[]` | yes | — | — |
| 9 | `expires_at` | `timestamp with time zone` | no | — | — |
| 10 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 11 | `last_used_at` | `timestamp with time zone` | yes | — | — |
| 12 | `revoked_at` | `timestamp with time zone` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (token_sha256)
- check `client_grant_check`: `(expires_at > created_at)`
- check `client_grant_client_kind_check`: `(client_kind = ANY (ARRAY['mcp'::text, 'cli'::text, 'harness'::text, 'api'::text]))`
- check `client_grant_label_check`: `product.nonblank(label)`
- check `client_grant_scopes_check`: `((cardinality(scopes) > 0) AND (scopes <@ ARRAY['read'::text, 'author'::text, 'learn'::text, 'library'::text, 'assess'::text]))`
- check `client_grant_token_sha256_check`: `(token_sha256 ~ '^[0-9a-f]{64}$'::text)`

## Relationships

Outbound: `principal_id` → `auth.users``.id` on delete restrict.
Inbound: [`authoring.command`](../authoring/command.md).client_grant_id.

## Indexes

`client_grant_principal_id_fkey_ix`; `client_grant_tenant_id_id_key` unique; `client_grant_token_sha256_key` unique

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
- Via functions (best effort): [`product.client_grant`](../../functions/product/client_grant.md), [`product.dispatch_command`](../../functions/product/dispatch_command.md).
- Product operations (best effort): [`create_client_grant`](../../ops/create_client_grant.md), [`revoke_client_grant`](../../ops/revoke_client_grant.md).

## TypeScript

insert: `Database["access"]["Tables"]["client_grant"]["Insert"]`; row: `Database["access"]["Tables"]["client_grant"]["Row"]`; update: `Database["access"]["Tables"]["client_grant"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
