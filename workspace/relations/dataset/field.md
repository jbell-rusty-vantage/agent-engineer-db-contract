---
id: "rel:dataset.field"
kind: table
schema: dataset
name: field
domain: inquiry
lens: ours
aliases: []
tokens: [dataset, field, dataset.field, id, tenant_id, workspace_id, dataset_work_id, dataset_kind, field_key, name, value_type, unit, currency, meaning, required, position, entered_by, from_revision_no, to_revision_no, created_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"dataset\"][\"Tables\"][\"field\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# dataset.field

table in domain `inquiry`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id) |
| 4 | `dataset_work_id` | `uuid` | no | — | — |
| 5 | `dataset_kind` | `text` | no | `'dataset'::text` | — |
| 6 | `field_key` | `uuid` | no | — | — |
| 7 | `name` | `text` | no | — | — |
| 8 | `value_type` | `text` | no | — | — |
| 9 | `unit` | `text` | yes | — | — |
| 10 | `currency` | `text` | yes | — | — |
| 11 | `meaning` | `text` | no | — | — |
| 12 | `required` | `boolean` | no | `false` | — |
| 13 | `position` | `integer` | no | — | — |
| 14 | `entered_by` | `uuid` | no | — | FK → `auth.users`.id |
| 15 | `from_revision_no` | `integer` | no | — | — |
| 16 | `to_revision_no` | `integer` | yes | — | — |
| 17 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, workspace_id, id)
- check `field_check`: `((to_revision_no IS NULL) OR (to_revision_no >= from_revision_no))`
- check `field_check1`: `((value_type = 'money'::text) = (currency IS NOT NULL))`
- check `field_currency_check`: `(currency ~ '^[A-Z]{3}$'::text)`
- check `field_dataset_kind_check`: `(dataset_kind = 'dataset'::text)`
- check `field_from_revision_no_check`: `(from_revision_no > 0)`
- check `field_meaning_check`: `product.nonblank(meaning)`
- check `field_name_check`: `(product.nonblank(name) AND (char_length(name) <= 200))`
- check `field_position_check`: `("position" >= 0)`
- check `field_value_type_check`: `(value_type = ANY (ARRAY['text'::text, 'number'::text, 'integer'::text, 'boolean'::text, 'date'::text, 'datetime'::text, 'money'::text, 'pe…`

## Relationships

Outbound: `entered_by` → `auth.users``.id` on delete restrict; `tenant_id,workspace_id,dataset_work_id,dataset_kind` → [`authoring.work`](../authoring/work.md)`.tenant_id,workspace_id,id,kind` on delete restrict.
Inbound: none.

## Indexes

`field_entered_by_fkey_ix`; `field_open_name_uq` unique where `(to_revision_no IS NULL)`; `field_open_uq` unique where `(to_revision_no IS NULL)`; `field_tenant_id_workspace_id_dataset_work_id_dataset_ki_ix`; `field_tenant_id_workspace_id_id_key` unique

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
- Via functions (best effort): [`product.dataset_edit`](../../functions/product/dataset_edit.md).

## TypeScript

insert: `Database["dataset"]["Tables"]["field"]["Insert"]`; row: `Database["dataset"]["Tables"]["field"]["Row"]`; update: `Database["dataset"]["Tables"]["field"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
