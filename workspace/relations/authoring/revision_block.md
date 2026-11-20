---
id: "rel:authoring.revision_block"
kind: table
schema: authoring
name: revision_block
domain: authoring
lens: ours
aliases: []
tokens: [authoring, revision_block, authoring.revision_block, id, tenant_id, workspace_id, revision_id, block_key, block_type, parent_key, position, content_sha256]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"authoring\"][\"Tables\"][\"revision_block\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# authoring.revision_block

table in domain `authoring`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, revision_id, block_key); unique (tenant_id, workspace_id, id) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id) |
| 4 | `revision_id` | `uuid` | no | — | unique (tenant_id, revision_id, block_key) |
| 5 | `block_key` | `uuid` | no | — | unique (tenant_id, revision_id, block_key) |
| 6 | `block_type` | `text` | no | — | FK → [`authoring.block_type`](block_type.md).code |
| 7 | `parent_key` | `uuid` | yes | — | — |
| 8 | `position` | `integer` | no | — | — |
| 9 | `content_sha256` | `text` | no | — | — |

## Constraints

- PK (id)
- unique (tenant_id, revision_id, block_key)
- unique (tenant_id, workspace_id, id)
- check `revision_block_content_sha256_check`: `(content_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `revision_block_position_check`: `("position" >= 0)`

## Relationships

Outbound: `block_type` → [`authoring.block_type`](block_type.md)`.code` on delete restrict; `tenant_id,workspace_id,revision_id` → [`authoring.work_revision`](work_revision.md)`.tenant_id,workspace_id,id` on delete restrict.
Inbound: none.

## Indexes

`revision_block_block_type_fkey_ix`; `revision_block_key_ix`; `revision_block_tenant_id_revision_id_block_key_key` unique; `revision_block_tenant_id_workspace_id_id_key` unique; `revision_block_tenant_id_workspace_id_revision_id_fkey_ix`

## Triggers

- `immutable_guard` → [`product.guard_immutable`](../../functions/product/guard_immutable.md)
- `seal_guard` → [`product.guard_unsealed_parent`](../../functions/product/guard_unsealed_parent.md)

## Row-level security

Enabled and forced.
- `product_api_all` (ALL) for `product_api_owner`: `true`

## Grants

No role has privileges. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

## Read paths

- No agent role may SELECT directly.

## Write path

- No direct DML for any agent role.
- Via functions (best effort): [`product.walk_blocks`](../../functions/product/walk_blocks.md).

## TypeScript

insert: `Database["authoring"]["Tables"]["revision_block"]["Insert"]`; row: `Database["authoring"]["Tables"]["revision_block"]["Row"]`; update: `Database["authoring"]["Tables"]["revision_block"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
