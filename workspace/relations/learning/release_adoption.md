---
id: "rel:learning.release_adoption"
kind: table
schema: learning
name: release_adoption
domain: learning
lens: ours
aliases: []
tokens: [learning, release_adoption, learning.release_adoption, id, tenant_id, workspace_id, enrollment_id, sequence_no, previous_adoption_id, source_workspace_id, offer_id, transition_id, personal_revision_id, actor_id, basis, reason, created_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"learning\"][\"Tables\"][\"release_adoption\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# learning.release_adoption

table in domain `learning`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id); unique (tenant_id, workspace_id, enrollment_id, id); unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, id); unique (tenant_id, workspace_id, enrollment_id, id); unique (tenant_id, workspace_id, enrollment_id, sequence_no); unique (tenant_id, workspace_id, id) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, enrollment_id, id); unique (tenant_id, workspace_id, enrollment_id, sequence_no); unique (tenant_id, workspace_id, id) |
| 4 | `enrollment_id` | `uuid` | no | — | unique (tenant_id, workspace_id, enrollment_id, id); unique (tenant_id, workspace_id, enrollment_id, sequence_no) |
| 5 | `sequence_no` | `integer` | no | — | unique (tenant_id, workspace_id, enrollment_id, sequence_no) |
| 6 | `previous_adoption_id` | `uuid` | yes | — | — |
| 7 | `source_workspace_id` | `uuid` | no | — | — |
| 8 | `offer_id` | `uuid` | no | — | — |
| 9 | `transition_id` | `uuid` | yes | — | — |
| 10 | `personal_revision_id` | `uuid` | yes | — | — |
| 11 | `actor_id` | `uuid` | no | — | FK → `auth.users`.id |
| 12 | `basis` | `text` | no | — | — |
| 13 | `reason` | `text` | no | — | — |
| 14 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, workspace_id, enrollment_id, id)
- unique (tenant_id, workspace_id, enrollment_id, sequence_no)
- unique (tenant_id, workspace_id, id)
- check `release_adoption_basis_check`: `(basis = ANY (ARRAY['explicit'::text, 'standing_consent'::text]))`
- check `release_adoption_check`: `((sequence_no = 1) = (previous_adoption_id IS NULL))`
- check `release_adoption_check1`: `((previous_adoption_id IS NULL) OR (transition_id IS NOT NULL))`
- check `release_adoption_reason_check`: `product.nonblank(reason)`
- check `release_adoption_sequence_no_check`: `(sequence_no > 0)`

## Relationships

Outbound: `actor_id` → `auth.users``.id` on delete restrict; `tenant_id,source_workspace_id,offer_id` → [`authoring.distribution_offer`](../authoring/distribution_offer.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,source_workspace_id,transition_id` → [`curriculum.release_transition`](../curriculum/release_transition.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,enrollment_id` → [`learning.enrollment`](enrollment.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,enrollment_id,previous_adoption_id` → [`learning.release_adoption`](release_adoption.md)`.tenant_id,workspace_id,enrollment_id,id` on delete restrict; `tenant_id,workspace_id,personal_revision_id` → [`authoring.work_revision`](../authoring/work_revision.md)`.tenant_id,workspace_id,id` on delete restrict.
Inbound: [`learning.attempt`](attempt.md).workspace_id,enrollment_id,adoption_id, [`learning.credit`](credit.md).workspace_id,enrollment_id,adoption_id, [`learning.release_adoption`](release_adoption.md).workspace_id,enrollment_id,previous_adoption_id.

## Indexes

`release_adoption_actor_id_fkey_ix`; `release_adoption_tenant_id_id_key` unique; `release_adoption_tenant_id_source_workspace_id_offer_id_ix`; `release_adoption_tenant_id_source_workspace_id_transiti_ix`; `release_adoption_tenant_id_workspace_id_enrollment_id_id_key` unique; `release_adoption_tenant_id_workspace_id_enrollment_id_p_ix`; `release_adoption_tenant_id_workspace_id_enrollment_id_seque_key` unique; `release_adoption_tenant_id_workspace_id_id_key` unique; `release_adoption_tenant_id_workspace_id_personal_revisi_ix`

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
- Product operations (best effort): [`adopt_release`](../../ops/adopt_release.md).

## TypeScript

insert: `Database["learning"]["Tables"]["release_adoption"]["Insert"]`; row: `Database["learning"]["Tables"]["release_adoption"]["Row"]`; update: `Database["learning"]["Tables"]["release_adoption"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
