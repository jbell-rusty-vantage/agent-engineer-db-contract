---
id: "rel:inquiry.assertion"
kind: table
schema: inquiry
name: assertion
domain: inquiry
lens: ours
aliases: []
tokens: [inquiry, assertion, inquiry.assertion, id, tenant_id, workspace_id, revision_id, assertion_key, block_key, kind, statement, structured, support_status, entity_ids, world_from, world_to, world_precision, uses_claim_id, promoted_claim_id, created_by, created_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"inquiry\"][\"Tables\"][\"assertion\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# inquiry.assertion

table in domain `inquiry`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id); unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, id); unique (tenant_id, workspace_id, id); unique (tenant_id, workspace_id, revision_id, assertion_key) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id); unique (tenant_id, workspace_id, revision_id, assertion_key) |
| 4 | `revision_id` | `uuid` | no | — | unique (tenant_id, workspace_id, revision_id, assertion_key) |
| 5 | `assertion_key` | `uuid` | no | — | unique (tenant_id, workspace_id, revision_id, assertion_key) |
| 6 | `block_key` | `uuid` | yes | — | — |
| 7 | `kind` | `text` | no | — | — |
| 8 | `statement` | `text` | no | — | — |
| 9 | `structured` | `jsonb` | yes | — | — |
| 10 | `support_status` | `text` | no | — | — |
| 11 | `entity_ids` | `uuid[]` | no | `'{}'::uuid[]` | — |
| 12 | `world_from` | `timestamp with time zone` | yes | — | — |
| 13 | `world_to` | `timestamp with time zone` | yes | — | — |
| 14 | `world_precision` | `text` | no | `'unknown'::text` | — |
| 15 | `uses_claim_id` | `uuid` | yes | — | — |
| 16 | `promoted_claim_id` | `uuid` | yes | — | — |
| 17 | `created_by` | `uuid` | no | — | FK → `auth.users`.id |
| 18 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, workspace_id, id)
- unique (tenant_id, workspace_id, revision_id, assertion_key)
- check `assertion_check`: `(((world_precision = 'unknown'::text) AND (world_from IS NULL) AND (world_to IS NULL)) OR ((world_precision = 'instant'::text) AND (world_f…`
- check `assertion_kind_check`: `(kind = ANY (ARRAY['finding'::text, 'claim'::text, 'estimate'::text, 'comparison'::text, 'recommendation'::text, 'assumption'::text, 'limit…`
- check `assertion_statement_check`: `(product.nonblank(statement) AND (char_length(statement) <= 4000))`
- check `assertion_support_status_check`: `(support_status = ANY (ARRAY['supported'::text, 'partially_supported'::text, 'contradicted'::text, 'unsupported'::text, 'judgment'::text, '…`
- check `assertion_world_precision_check`: `(world_precision = ANY (ARRAY['instant'::text, 'day'::text, 'unknown'::text]))`

## Relationships

Outbound: `created_by` → `auth.users``.id` on delete restrict; `tenant_id,promoted_claim_id` → [`evidence.claim`](../evidence/claim.md)`.tenant_id,id` on delete restrict; `tenant_id,uses_claim_id` → [`evidence.claim`](../evidence/claim.md)`.tenant_id,id` on delete restrict; `tenant_id,workspace_id,revision_id` → [`authoring.work_revision`](../authoring/work_revision.md)`.tenant_id,workspace_id,id` on delete restrict.
Inbound: [`authoring.revision_binding`](../authoring/revision_binding.md).assertion_id, [`inquiry.support`](support.md).workspace_id,assertion_id|workspace_id,target_assertion_id.

## Indexes

`assertion_created_by_fkey_ix`; `assertion_key_ix`; `assertion_tenant_id_id_key` unique; `assertion_tenant_id_promoted_claim_id_fkey_ix`; `assertion_tenant_id_uses_claim_id_fkey_ix`; `assertion_tenant_id_workspace_id_id_key` unique; `assertion_tenant_id_workspace_id_revision_id_assertion_key_key` unique

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
- Via functions (best effort): [`product.insert_revision`](../../functions/product/insert_revision.md).

## TypeScript

insert: `Database["inquiry"]["Tables"]["assertion"]["Insert"]`; row: `Database["inquiry"]["Tables"]["assertion"]["Row"]`; update: `Database["inquiry"]["Tables"]["assertion"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
