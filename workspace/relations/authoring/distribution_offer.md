---
id: "rel:authoring.distribution_offer"
kind: table
schema: authoring
name: distribution_offer
domain: authoring
lens: ours
aliases: []
tokens: [authoring, distribution_offer, authoring.distribution_offer, id, tenant_id, workspace_id, distribution_id, release_id, offer_no, terms_schema, terms, approval_event_id, offered_by, created_at, ended_at, end_kind, end_event_id]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"authoring\"][\"Tables\"][\"distribution_offer\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# authoring.distribution_offer

table in domain `authoring`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id); unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, id); unique (tenant_id, workspace_id, distribution_id, offer_no); unique (tenant_id, workspace_id, distribution_id, release_id); unique (tenant_id, workspace_id, id) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, distribution_id, offer_no); unique (tenant_id, workspace_id, distribution_id, release_id); unique (tenant_id, workspace_id, id) |
| 4 | `distribution_id` | `uuid` | no | — | unique (tenant_id, workspace_id, distribution_id, offer_no); unique (tenant_id, workspace_id, distribution_id, release_id) |
| 5 | `release_id` | `uuid` | no | — | unique (tenant_id, workspace_id, distribution_id, release_id) |
| 6 | `offer_no` | `integer` | no | — | unique (tenant_id, workspace_id, distribution_id, offer_no) |
| 7 | `terms_schema` | `text` | no | — | — |
| 8 | `terms` | `jsonb` | no | — | — |
| 9 | `approval_event_id` | `uuid` | no | — | — |
| 10 | `offered_by` | `uuid` | no | — | FK → `auth.users`.id |
| 11 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 12 | `ended_at` | `timestamp with time zone` | yes | — | — |
| 13 | `end_kind` | `text` | yes | — | — |
| 14 | `end_event_id` | `uuid` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, workspace_id, distribution_id, offer_no)
- unique (tenant_id, workspace_id, distribution_id, release_id)
- unique (tenant_id, workspace_id, id)
- check `distribution_offer_check`: `(((ended_at IS NULL) = (end_kind IS NULL)) AND ((ended_at IS NULL) = (end_event_id IS NULL)))`
- check `distribution_offer_end_kind_check`: `(end_kind = ANY (ARRAY['retire'::text, 'revoke'::text]))`
- check `distribution_offer_offer_no_check`: `(offer_no > 0)`
- check `distribution_offer_terms_schema_check`: `(terms_schema = 'aieng.use-terms.v1'::text)`

## Relationships

Outbound: `offered_by` → `auth.users``.id` on delete restrict; `tenant_id,workspace_id,approval_event_id` → [`authoring.event`](event.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,distribution_id` → [`authoring.distribution`](distribution.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,end_event_id` → [`authoring.event`](event.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,release_id` → [`authoring.release`](release.md)`.tenant_id,workspace_id,id` on delete restrict.
Inbound: [`conversation.context_item`](../conversation/context_item.md).offer_id, [`learning.release_adoption`](../learning/release_adoption.md).source_workspace_id,offer_id.

## Indexes

`distribution_offer_offered_by_fkey_ix`; `distribution_offer_tenant_id_id_key` unique; `distribution_offer_tenant_id_workspace_id_approval_even_ix`; `distribution_offer_tenant_id_workspace_id_distribution_id_o_key` unique; `distribution_offer_tenant_id_workspace_id_distribution_id_r_key` unique; `distribution_offer_tenant_id_workspace_id_end_event_id__ix`; `distribution_offer_tenant_id_workspace_id_id_key` unique; `distribution_offer_tenant_id_workspace_id_release_id_fk_ix`

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
- Via functions (best effort): [`product.dispatch_command`](../../functions/product/dispatch_command.md).
- Product operations (best effort): [`end_offer`](../../ops/end_offer.md), [`offer_release`](../../ops/offer_release.md).

## TypeScript

insert: `Database["authoring"]["Tables"]["distribution_offer"]["Insert"]`; row: `Database["authoring"]["Tables"]["distribution_offer"]["Row"]`; update: `Database["authoring"]["Tables"]["distribution_offer"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
