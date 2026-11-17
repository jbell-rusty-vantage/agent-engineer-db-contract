---
id: "rel:learning.credit"
kind: table
schema: learning
name: credit
domain: learning
lens: ours
aliases: []
tokens: [learning, credit, learning.credit, id, tenant_id, workspace_id, learner_id, enrollment_id, adoption_id, requirement_id, route, facet, result_id, carried_from_credit_id, transition_id, status, status_reason, created_at, ended_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"learning\"][\"Tables\"][\"credit\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# learning.credit

table in domain `learning`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id) |
| 4 | `learner_id` | `uuid` | no | — | FK → `auth.users`.id |
| 5 | `enrollment_id` | `uuid` | no | — | — |
| 6 | `adoption_id` | `uuid` | no | — | — |
| 7 | `requirement_id` | `uuid` | no | — | — |
| 8 | `route` | `text` | no | — | — |
| 9 | `facet` | `text` | no | — | — |
| 10 | `result_id` | `uuid` | yes | — | — |
| 11 | `carried_from_credit_id` | `uuid` | yes | — | — |
| 12 | `transition_id` | `uuid` | yes | — | — |
| 13 | `status` | `text` | no | — | — |
| 14 | `status_reason` | `text` | yes | — | — |
| 15 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 16 | `ended_at` | `timestamp with time zone` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, workspace_id, id)
- check `credit_check`: `(num_nonnulls(result_id, carried_from_credit_id) = 1)`
- check `credit_check1`: `((carried_from_credit_id IS NULL) = (transition_id IS NULL))`
- check `credit_check2`: `((status = 'active'::text) = (ended_at IS NULL))`
- check `credit_facet_check`: `(facet = ANY (ARRAY['independent'::text, 'assisted'::text, 'agent_directed'::text]))`
- check `credit_route_check`: `(route = ANY (ARRAY['standard'::text, 'prior_work'::text, 'test_out'::text, 'alternative'::text, 'generated_eligible'::text, 'learner_proje…`
- check `credit_status_check`: `(status = ANY (ARRAY['active'::text, 'revoked'::text, 'superseded'::text]))`

## Relationships

Outbound: `learner_id` → `auth.users``.id` on delete restrict; `tenant_id,requirement_id` → [`curriculum.requirement`](../curriculum/requirement.md)`.tenant_id,id` on delete restrict; `tenant_id,transition_id` → [`curriculum.release_transition`](../curriculum/release_transition.md)`.tenant_id,id` on delete restrict; `tenant_id,workspace_id,carried_from_credit_id` → [`learning.credit`](credit.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,enrollment_id,adoption_id` → [`learning.release_adoption`](release_adoption.md)`.tenant_id,workspace_id,enrollment_id,id` on delete restrict; `tenant_id,workspace_id,result_id` → [`learning.assessment_result`](assessment_result.md)`.tenant_id,workspace_id,id` on delete restrict.
Inbound: [`learning.credit`](credit.md).workspace_id,carried_from_credit_id.

## Indexes

`credit_active_uq` unique where `(status = 'active'::text)`; `credit_learner_id_fkey_ix`; `credit_tenant_id_requirement_id_fkey_ix`; `credit_tenant_id_transition_id_fkey_ix`; `credit_tenant_id_workspace_id_carried_from_credit_id_fk_ix`; `credit_tenant_id_workspace_id_enrollment_id_adoption_id_ix`; `credit_tenant_id_workspace_id_id_key` unique; `credit_tenant_id_workspace_id_result_id_fkey_ix`

## Triggers

- `mutable_guard` → [`product.guard_mutable`](../../functions/product/guard_mutable.md)

## Row-level security

Enabled and forced.
- `product_api_all` (ALL) for `product_api_owner`: `true`

## Grants

No role has privileges. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

## Read paths

- No agent role may SELECT directly.

## Write path

- No direct DML for any agent role.
- Via functions (best effort): [`product.finalize`](../../functions/product/finalize.md).

## TypeScript

insert: `Database["learning"]["Tables"]["credit"]["Insert"]`; row: `Database["learning"]["Tables"]["credit"]["Row"]`; update: `Database["learning"]["Tables"]["credit"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
