---
id: "rel:curriculum.requirement_option"
kind: table
schema: curriculum
name: requirement_option
domain: curriculum
aliases: []
tokens: [curriculum, requirement_option, curriculum.requirement_option, id, tenant_id, workspace_id, requirement_id, route, activity_revision_id, evidence_rule, approval_state, approved_by, created_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"curriculum\"][\"Tables\"][\"requirement_option\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# curriculum.requirement_option

table in domain `curriculum`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id); unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, id); unique (tenant_id, workspace_id, id) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id) |
| 4 | `requirement_id` | `uuid` | no | — | — |
| 5 | `route` | `text` | no | — | — |
| 6 | `activity_revision_id` | `uuid` | yes | — | — |
| 7 | `evidence_rule` | `jsonb` | no | — | — |
| 8 | `approval_state` | `text` | no | — | — |
| 9 | `approved_by` | `uuid` | yes | — | FK → `auth.users`.id |
| 10 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, workspace_id, id)
- check `requirement_option_approval_state_check`: `(approval_state = ANY (ARRAY['proposed'::text, 'approved'::text]))`
- check `requirement_option_check`: `((approval_state = 'approved'::text) = (approved_by IS NOT NULL))`
- check `requirement_option_check1`: `(((route = ANY (ARRAY['standard'::text, 'test_out'::text])) = (activity_revision_id IS NOT NULL)) OR (route = ANY (ARRAY['prior_work'::text…`
- check `requirement_option_check2`: `((route <> 'learner_project'::text) OR (activity_revision_id IS NULL))`
- check `requirement_option_check3`: `((route <> 'generated_eligible'::text) OR (activity_revision_id IS NULL))`
- check `requirement_option_evidence_rule_check`: `((evidence_rule ->> 'schema'::text) = ANY (ARRAY['aieng.evidence-rule.v1'::text, 'aieng.evidence-rule.v2'::text]))`
- check `requirement_option_route_check`: `(route = ANY (ARRAY['standard'::text, 'prior_work'::text, 'test_out'::text, 'alternative'::text, 'generated_eligible'::text, 'learner_proje…`

## Relationships

Outbound: `approved_by` → `auth.users``.id` on delete restrict; `tenant_id,workspace_id,activity_revision_id` → `authoring.work_revision``.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,requirement_id` → [`curriculum.requirement`](requirement.md)`.tenant_id,workspace_id,id` on delete restrict.
Inbound: none.

## Indexes

`requirement_option_approved_by_fkey_ix`; `requirement_option_tenant_id_id_key` unique; `requirement_option_tenant_id_workspace_id_activity_revi_ix`; `requirement_option_tenant_id_workspace_id_id_key` unique; `requirement_option_tenant_id_workspace_id_requirement_i_ix`

## Triggers

- `immutable_guard` → `product.guard_immutable`
- `seal_guard` → `product.guard_unsealed_parent`

## Row-level security

Enabled and forced.
- `product_api_all` (ALL) for `product_api_owner`: `true`

## Grants

No role has privileges. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

## Read paths

- No agent role may SELECT directly.

## Write path

- No direct DML for any agent role.
- No write path for agents; rows are seeded by migrations or platform tooling.

## TypeScript

insert: `Database["curriculum"]["Tables"]["requirement_option"]["Insert"]`; row: `Database["curriculum"]["Tables"]["requirement_option"]["Row"]`; update: `Database["curriculum"]["Tables"]["requirement_option"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
