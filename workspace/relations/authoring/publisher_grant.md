---
id: "rel:authoring.publisher_grant"
kind: table
schema: authoring
name: publisher_grant
domain: authoring
lens: ours
aliases: []
tokens: [authoring, publisher_grant, authoring.publisher_grant, id, tenant_id, principal_id, channel, granted_by, created_at, revoked_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"authoring\"][\"Tables\"][\"publisher_grant\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# authoring.publisher_grant

table in domain `authoring`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `tenant_id` | `uuid` | no | — | — |
| 3 | `principal_id` | `uuid` | no | — | FK → `auth.users`.id |
| 4 | `channel` | `text` | no | — | — |
| 5 | `granted_by` | `uuid` | yes | — | FK → `auth.users`.id |
| 6 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 7 | `revoked_at` | `timestamp with time zone` | yes | — | — |

## Constraints

- PK (id)
- check `publisher_grant_channel_check`: `(channel = 'official_catalog'::text)`

## Relationships

Outbound: `granted_by` → `auth.users``.id` on delete restrict; `principal_id` → `auth.users``.id` on delete restrict.
Inbound: none.

## Indexes

`publisher_grant_active_uq` unique where `(revoked_at IS NULL)`; `publisher_grant_granted_by_fkey_ix`; `publisher_grant_principal_id_fkey_ix`

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
- Via functions (best effort): [`product.dispatch_worker`](../../functions/product/dispatch_worker.md).
- Product operations (best effort): [`grant_publisher`](../../ops/grant_publisher.md).

## TypeScript

insert: `Database["authoring"]["Tables"]["publisher_grant"]["Insert"]`; row: `Database["authoring"]["Tables"]["publisher_grant"]["Row"]`; update: `Database["authoring"]["Tables"]["publisher_grant"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
