---
id: "rel:inquiry.support"
kind: table
schema: inquiry
name: support
domain: inquiry
lens: ours
aliases: []
tokens: [inquiry, support, inquiry.support, id, tenant_id, workspace_id, assertion_id, dataset_work_id, row_key, field_key, cell_id, role, source_revision_id, locator_id, capture_id, claim_id, record_id, target_assertion_id, target_cell_id, decision_revision_id, answer_key, selector, excerpt, method, assessed_by, assessed_kind, verification_ref, assessed_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"inquiry\"][\"Tables\"][\"support\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# inquiry.support

table in domain `inquiry`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id) |
| 4 | `assertion_id` | `uuid` | yes | — | — |
| 5 | `dataset_work_id` | `uuid` | yes | — | — |
| 6 | `row_key` | `uuid` | yes | — | — |
| 7 | `field_key` | `uuid` | yes | — | — |
| 8 | `cell_id` | `uuid` | yes | — | — |
| 9 | `role` | `text` | no | — | — |
| 10 | `source_revision_id` | `uuid` | yes | — | — |
| 11 | `locator_id` | `uuid` | yes | — | — |
| 12 | `capture_id` | `uuid` | yes | — | — |
| 13 | `claim_id` | `uuid` | yes | — | — |
| 14 | `record_id` | `uuid` | yes | — | — |
| 15 | `target_assertion_id` | `uuid` | yes | — | — |
| 16 | `target_cell_id` | `uuid` | yes | — | — |
| 17 | `decision_revision_id` | `uuid` | yes | — | — |
| 18 | `answer_key` | `text` | yes | — | — |
| 19 | `selector` | `jsonb` | yes | — | — |
| 20 | `excerpt` | `text` | yes | — | — |
| 21 | `method` | `jsonb` | yes | — | — |
| 22 | `assessed_by` | `uuid` | no | — | FK → `auth.users`.id |
| 23 | `assessed_kind` | `text` | no | — | — |
| 24 | `verification_ref` | `text` | yes | — | — |
| 25 | `assessed_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, workspace_id, id)
- check `support_assessed_kind_check`: `(assessed_kind = ANY (ARRAY['human'::text, 'agent'::text, 'verification'::text]))`
- check `support_check`: `(num_nonnulls(assertion_id, dataset_work_id) = 1)`
- check `support_check1`: `((dataset_work_id IS NOT NULL) OR (num_nonnulls(row_key, field_key, cell_id) = 0))`
- check `support_check2`: `((cell_id IS NULL) OR ((row_key IS NOT NULL) AND (field_key IS NOT NULL)))`
- check `support_check3`: `(num_nonnulls(source_revision_id, locator_id, capture_id, claim_id, record_id, target_assertion_id, target_cell_id, decision_revision_id) =…`
- check `support_check4`: `((role <> 'calculated_from'::text) OR (method ? 'expression'::text))`
- check `support_check5`: `((role <> 'inferred_by'::text) OR (decision_revision_id IS NOT NULL) OR ((assessed_kind = 'agent'::text) AND (method IS NOT NULL)))`
- check `support_check6`: `((decision_revision_id IS NULL) = (answer_key IS NULL))`
- check `support_check7`: `((selector IS NULL) OR (source_revision_id IS NOT NULL))`
- check `support_check8`: `((assessed_kind = 'verification'::text) = (verification_ref IS NOT NULL))`
- check `support_excerpt_check`: `(char_length(excerpt) <= 2000)`
- check `support_method_check`: `((method IS NULL) OR (jsonb_typeof(method) = 'object'::text))`
- check `support_role_check`: `(role = ANY (ARRAY['supports'::text, 'contradicts'::text, 'qualifies'::text, 'context'::text, 'calculated_from'::text, 'inferred_by'::text]…`
- check `support_selector_check`: `((selector IS NULL) OR (jsonb_typeof(selector) = 'object'::text))`

## Relationships

Outbound: `assessed_by` → `auth.users``.id` on delete restrict; `tenant_id,capture_id` → [`evidence.source_capture`](../evidence/source_capture.md)`.tenant_id,id` on delete restrict; `tenant_id,claim_id` → [`evidence.claim`](../evidence/claim.md)`.tenant_id,id` on delete restrict; `tenant_id,locator_id` → [`evidence.locator`](../evidence/locator.md)`.tenant_id,id` on delete restrict; `tenant_id,record_id` → [`guidance.item`](../guidance/item.md)`.tenant_id,id` on delete restrict; `tenant_id,workspace_id,assertion_id` → [`inquiry.assertion`](assertion.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,cell_id` → [`dataset.cell`](../dataset/cell.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,decision_revision_id` → [`authoring.work_revision`](../authoring/work_revision.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,source_revision_id` → [`authoring.work_revision`](../authoring/work_revision.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,target_assertion_id` → [`inquiry.assertion`](assertion.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,target_cell_id` → [`dataset.cell`](../dataset/cell.md)`.tenant_id,workspace_id,id` on delete restrict.
Inbound: none.

## Indexes

14 indexes; see [details](support.details.md).

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
- Product operations (best effort): [`add_support`](../../ops/add_support.md).

## TypeScript

insert: `Database["inquiry"]["Tables"]["support"]["Insert"]`; row: `Database["inquiry"]["Tables"]["support"]["Row"]`; update: `Database["inquiry"]["Tables"]["support"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
