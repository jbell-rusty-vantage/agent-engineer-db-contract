---
id: "rel:dataset.row"
kind: table
schema: dataset
name: row
domain: inquiry
lens: ours
aliases: []
tokens: [dataset, row, dataset.row, id, tenant_id, workspace_id, dataset_work_id, dataset_kind, row_key, entity_id, label, position, entered_by, proposal_id, from_revision_no, to_revision_no, created_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"dataset\"][\"Tables\"][\"row\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# dataset.row

table in domain `inquiry`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id) |
| 4 | `dataset_work_id` | `uuid` | no | — | — |
| 5 | `dataset_kind` | `text` | no | `'dataset'::text` | — |
| 6 | `row_key` | `uuid` | no | — | — |
| 7 | `entity_id` | `uuid` | yes | — | — |
| 8 | `label` | `text` | yes | — | — |
| 9 | `position` | `integer` | no | — | — |
| 10 | `entered_by` | `uuid` | no | — | FK → `auth.users`.id |
| 11 | `proposal_id` | `uuid` | yes | — | — |
| 12 | `from_revision_no` | `integer` | yes | — | — |
| 13 | `to_revision_no` | `integer` | yes | — | — |
| 14 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, workspace_id, id)
- check `row_check`: `((from_revision_no IS NOT NULL) OR (proposal_id IS NOT NULL))`
- check `row_check1`: `((to_revision_no IS NULL) OR ((from_revision_no IS NOT NULL) AND (to_revision_no >= from_revision_no)))`
- check `row_dataset_kind_check`: `(dataset_kind = 'dataset'::text)`
- check `row_from_revision_no_check`: `(from_revision_no > 0)`
- check `row_label_check`: `(char_length(label) <= 300)`
- check `row_position_check`: `("position" >= 0)`

## Relationships

Outbound: `entered_by` → `auth.users``.id` on delete restrict; `tenant_id,entity_id` → [`catalog.entity`](../catalog/entity.md)`.tenant_id,id` on delete restrict; `tenant_id,workspace_id,dataset_work_id,dataset_kind` → [`authoring.work`](../authoring/work.md)`.tenant_id,workspace_id,id,kind` on delete restrict; `tenant_id,workspace_id,proposal_id` → [`dataset.proposal`](proposal.md)`.tenant_id,workspace_id,id` on delete restrict.
Inbound: none.

## Indexes

`row_entered_by_fkey_ix`; `row_open_uq` unique where `((to_revision_no IS NULL) AND (from_revision_no IS NOT NULL…`; `row_tenant_id_entity_id_fkey_ix`; `row_tenant_id_workspace_id_dataset_work_id_dataset_kind_ix`; `row_tenant_id_workspace_id_id_key` unique; `row_tenant_id_workspace_id_proposal_id_fkey_ix`

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
- Via functions (best effort): [`product.dataset_edit`](../../functions/product/dataset_edit.md), [`product.dispatch_research_command`](../../functions/product/dispatch_research_command.md).
- Product operations (best effort): [`decide_dataset_change`](../../ops/decide_dataset_change.md), [`propose_dataset_change`](../../ops/propose_dataset_change.md).

## TypeScript

insert: `Database["dataset"]["Tables"]["row"]["Insert"]`; row: `Database["dataset"]["Tables"]["row"]["Row"]`; update: `Database["dataset"]["Tables"]["row"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
