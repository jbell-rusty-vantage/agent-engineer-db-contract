---
id: "rel:access.policy_version"
kind: table
schema: access
name: policy_version
domain: access
lens: ours
aliases: []
tokens: [access, policy_version, access.policy_version, id, tenant_id, version, body, body_sha256, approved_by, active_from, created_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"access\"][\"Tables\"][\"policy_version\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:216c4ae7230478c8e60934da25c852e10680d6caed71a662962ea3c0ac1676d3"
---
# access.policy_version

table in domain `access`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, id); unique (tenant_id, version) |
| 3 | `version` | `integer` | no | — | unique (tenant_id, version) |
| 4 | `body` | `jsonb` | no | — | — |
| 5 | `body_sha256` | `text` | no | — | — |
| 6 | `approved_by` | `uuid` | yes | — | FK → `auth.users`.id |
| 7 | `active_from` | `timestamp with time zone` | no | `now()` | — |
| 8 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, version)
- check `policy_version_body_check`: `((body ->> 'schema'::text) = 'aieng.access-policy.v1'::text)`
- check `policy_version_body_sha256_check`: `(body_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `policy_version_version_check`: `(version > 0)`

## Relationships

Outbound: `approved_by` → `auth.users``.id` on delete restrict.
Inbound: [`access.account_profile`](account_profile.md).policy_version_id, [`access.processing_authorization`](processing_authorization.md).policy_version_id.

## Indexes

`policy_version_approved_by_fkey_ix`; `policy_version_tenant_id_id_key` unique; `policy_version_tenant_id_version_key` unique

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
- Product operations (best effort): [`add_policy_version`](../../ops/add_policy_version.md).

## TypeScript

insert: `Database["access"]["Tables"]["policy_version"]["Insert"]`; row: `Database["access"]["Tables"]["policy_version"]["Row"]`; update: `Database["access"]["Tables"]["policy_version"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
