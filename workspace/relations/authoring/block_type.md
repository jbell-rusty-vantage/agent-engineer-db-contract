---
id: "rel:authoring.block_type"
kind: table
schema: authoring
name: block_type
domain: authoring
lens: ours
aliases: []
tokens: [authoring, block_type, authoring.block_type, code, tier, needs_fallback, required_roles, allowed_roles, description]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"authoring\"][\"Tables\"][\"block_type\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
---
# authoring.block_type

table in domain `authoring`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `code` | `text` | no | — | PK |
| 2 | `tier` | `integer` | no | — | — |
| 3 | `needs_fallback` | `boolean` | no | — | — |
| 4 | `required_roles` | `text[]` | no | `'{}'::text[]` | — |
| 5 | `allowed_roles` | `text[]` | no | `'{}'::text[]` | — |
| 6 | `description` | `text` | no | — | — |

## Constraints

- PK (code)
- check `block_type_code_check`: `(code ~ '^[a-z][a-z_]{1,40}$'::text)`
- check `block_type_tier_check`: `(tier = ANY (ARRAY[1, 2]))`

## Relationships

Outbound: none.
Inbound: [`authoring.revision_block`](revision_block.md).block_type.

## Indexes

_None._

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
- No write path for agents; rows are seeded by migrations or platform tooling.

## TypeScript

insert: `Database["authoring"]["Tables"]["block_type"]["Insert"]`; row: `Database["authoring"]["Tables"]["block_type"]["Row"]`; update: `Database["authoring"]["Tables"]["block_type"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
