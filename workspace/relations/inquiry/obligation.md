---
id: "rel:inquiry.obligation"
kind: table
schema: inquiry
name: obligation
domain: inquiry
lens: ours
aliases: []
tokens: [inquiry, obligation, inquiry.obligation, id, tenant_id, workspace_id, acceptance_id, obligation_key, form, enforcement, expected_work_kind, criteria, mc_obligation_key, position]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"inquiry\"][\"Tables\"][\"obligation\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:fbf5703bf7a6f6131c452444ee949f1feec1bbe813c78d772fb3886b510815b9"
---
# inquiry.obligation

table in domain `inquiry`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, workspace_id, acceptance_id, obligation_key); unique (tenant_id, workspace_id, id) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, acceptance_id, obligation_key); unique (tenant_id, workspace_id, id) |
| 4 | `acceptance_id` | `uuid` | no | — | unique (tenant_id, workspace_id, acceptance_id, obligation_key) |
| 5 | `obligation_key` | `text` | no | — | unique (tenant_id, workspace_id, acceptance_id, obligation_key) |
| 6 | `form` | `text` | no | — | — |
| 7 | `enforcement` | `text` | no | — | — |
| 8 | `expected_work_kind` | `text` | yes | — | — |
| 9 | `criteria` | `jsonb` | no | `'{}'::jsonb` | — |
| 10 | `mc_obligation_key` | `text` | yes | — | — |
| 11 | `position` | `integer` | no | — | — |

## Constraints

- PK (id)
- unique (tenant_id, workspace_id, acceptance_id, obligation_key)
- unique (tenant_id, workspace_id, id)
- check `obligation_criteria_check`: `(jsonb_typeof(criteria) = 'object'::text)`
- check `obligation_enforcement_check`: `(enforcement = ANY (ARRAY['required'::text, 'expected'::text, 'optional'::text]))`
- check `obligation_form_check`: `(form = ANY (ARRAY['dataset'::text, 'report'::text, 'experience'::text, 'finding_set'::text, 'file'::text, 'course_content'::text]))`
- check `obligation_mc_obligation_key_check`: `(mc_obligation_key ~ '^[a-z0-9][a-z0-9._:-]{0,199}$'::text)`
- check `obligation_obligation_key_check`: `(obligation_key ~ '^[a-z0-9][a-z0-9._:-]{0,99}$'::text)`
- check `obligation_position_check`: `("position" >= 0)`

## Relationships

Outbound: `tenant_id,workspace_id,acceptance_id` → [`inquiry.acceptance`](acceptance.md)`.tenant_id,workspace_id,id` on delete restrict.
Inbound: [`inquiry.delivery`](delivery.md).workspace_id,obligation_id.

## Indexes

`obligation_tenant_id_workspace_id_acceptance_id_obligation__key` unique; `obligation_tenant_id_workspace_id_id_key` unique

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
- Via functions (best effort): [`product.dispatch_research_command`](../../functions/product/dispatch_research_command.md).
- Product operations (best effort): [`accept_research`](../../ops/accept_research.md).

## TypeScript

insert: `Database["inquiry"]["Tables"]["obligation"]["Insert"]`; row: `Database["inquiry"]["Tables"]["obligation"]["Row"]`; update: `Database["inquiry"]["Tables"]["obligation"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
