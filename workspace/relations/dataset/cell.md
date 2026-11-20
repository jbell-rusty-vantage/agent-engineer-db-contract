---
id: "rel:dataset.cell"
kind: table
schema: dataset
name: cell
domain: inquiry
lens: ours
aliases: []
tokens: [dataset, cell, dataset.cell, id, tenant_id, workspace_id, dataset_work_id, dataset_kind, row_key, field_key, value, value_status, observed_at, entered_by, entered_kind, entered_origin_ref, proposal_id, from_revision_no, to_revision_no, created_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"dataset\"][\"Tables\"][\"cell\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# dataset.cell

table in domain `inquiry`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id); unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, id); unique (tenant_id, workspace_id, id) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id) |
| 4 | `dataset_work_id` | `uuid` | no | — | — |
| 5 | `dataset_kind` | `text` | no | `'dataset'::text` | — |
| 6 | `row_key` | `uuid` | no | — | — |
| 7 | `field_key` | `uuid` | no | — | — |
| 8 | `value` | `jsonb` | yes | — | — |
| 9 | `value_status` | `text` | no | — | — |
| 10 | `observed_at` | `timestamp with time zone` | yes | — | — |
| 11 | `entered_by` | `uuid` | no | — | FK → `auth.users`.id |
| 12 | `entered_kind` | `text` | no | — | — |
| 13 | `entered_origin_ref` | `jsonb` | no | `'{}'::jsonb` | — |
| 14 | `proposal_id` | `uuid` | yes | — | — |
| 15 | `from_revision_no` | `integer` | yes | — | — |
| 16 | `to_revision_no` | `integer` | yes | — | — |
| 17 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, workspace_id, id)
- check `cell_check`: `((from_revision_no IS NOT NULL) OR (proposal_id IS NOT NULL))`
- check `cell_check1`: `((to_revision_no IS NULL) OR ((from_revision_no IS NOT NULL) AND (to_revision_no >= from_revision_no)))`
- check `cell_check2`: `((value IS NOT NULL) = (value_status = ANY (ARRAY['observed'::text, 'calculated'::text, 'inferred'::text, 'estimated'::text])))`
- check `cell_dataset_kind_check`: `(dataset_kind = 'dataset'::text)`
- check `cell_entered_kind_check`: `(entered_kind = ANY (ARRAY['human'::text, 'agent'::text, 'import'::text]))`
- check `cell_from_revision_no_check`: `(from_revision_no > 0)`
- check `cell_value_check`: `((value IS NULL) OR (octet_length((value)::text) <= 16384))`
- check `cell_value_status_check`: `(value_status = ANY (ARRAY['observed'::text, 'calculated'::text, 'inferred'::text, 'estimated'::text, 'unknown'::text, 'not_found'::text, '…`

## Relationships

Outbound: `entered_by` → `auth.users``.id` on delete restrict; `tenant_id,workspace_id,dataset_work_id,dataset_kind` → [`authoring.work`](../authoring/work.md)`.tenant_id,workspace_id,id,kind` on delete restrict; `tenant_id,workspace_id,proposal_id` → [`dataset.proposal`](proposal.md)`.tenant_id,workspace_id,id` on delete restrict.
Inbound: [`inquiry.support`](../inquiry/support.md).workspace_id,cell_id|workspace_id,target_cell_id.

## Indexes

`cell_entered_by_fkey_ix`; `cell_open_uq` unique where `((to_revision_no IS NULL) AND (from_revision_no IS NOT NULL…`; `cell_revision_ix`; `cell_tenant_id_id_key` unique; `cell_tenant_id_workspace_id_dataset_work_id_dataset_kin_ix`; `cell_tenant_id_workspace_id_id_key` unique; `cell_tenant_id_workspace_id_proposal_id_fkey_ix`

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
- Via functions (best effort): [`product.dataset_close_cell`](../../functions/product/dataset_close_cell.md), [`product.dataset_edit`](../../functions/product/dataset_edit.md), [`product.dispatch_research_command`](../../functions/product/dispatch_research_command.md).
- Product operations (best effort): [`decide_dataset_change`](../../ops/decide_dataset_change.md), [`propose_dataset_change`](../../ops/propose_dataset_change.md).

## TypeScript

insert: `Database["dataset"]["Tables"]["cell"]["Insert"]`; row: `Database["dataset"]["Tables"]["cell"]["Row"]`; update: `Database["dataset"]["Tables"]["cell"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
