---
id: "rel:learning.mastery_decision"
kind: table
schema: learning
name: mastery_decision
domain: learning
lens: ours
aliases: []
tokens: [learning, mastery_decision, learning.mastery_decision, id, tenant_id, workspace_id, learner_id, competency_revision_id, facet, state, policy_revision_id, evidence, uncertainty, review_due_at, supersedes_id, decided_by, created_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"learning\"][\"Tables\"][\"mastery_decision\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
---
# learning.mastery_decision

table in domain `learning`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id) |
| 4 | `learner_id` | `uuid` | no | — | FK → `auth.users`.id |
| 5 | `competency_revision_id` | `uuid` | no | — | — |
| 6 | `facet` | `text` | no | — | — |
| 7 | `state` | `text` | no | — | — |
| 8 | `policy_revision_id` | `uuid` | no | — | — |
| 9 | `evidence` | `jsonb` | no | `'[]'::jsonb` | — |
| 10 | `uncertainty` | `text` | no | — | — |
| 11 | `review_due_at` | `timestamp with time zone` | yes | — | — |
| 12 | `supersedes_id` | `uuid` | yes | — | — |
| 13 | `decided_by` | `text` | no | — | — |
| 14 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, workspace_id, id)
- check `mastery_decision_decided_by_check`: `(decided_by = ANY (ARRAY['policy'::text, 'human'::text]))`
- check `mastery_decision_facet_check`: `(facet = ANY (ARRAY['independent'::text, 'assisted'::text, 'agent_directed'::text]))`
- check `mastery_decision_state_check`: `(state = ANY (ARRAY['not_assessed'::text, 'developing'::text, 'demonstrated'::text, 'retained'::text, 'transferred'::text]))`
- check `mastery_decision_uncertainty_check`: `product.nonblank(uncertainty)`

## Relationships

Outbound: `learner_id` → `auth.users``.id` on delete restrict; `tenant_id,competency_revision_id` → [`authoring.work_revision`](../authoring/work_revision.md)`.tenant_id,id` on delete restrict; `tenant_id,policy_revision_id` → [`authoring.work_revision`](../authoring/work_revision.md)`.tenant_id,id` on delete restrict; `tenant_id,workspace_id` → [`authoring.workspace`](../authoring/workspace.md)`.tenant_id,id` on delete restrict; `tenant_id,workspace_id,supersedes_id` → [`learning.mastery_decision`](mastery_decision.md)`.tenant_id,workspace_id,id` on delete restrict.
Inbound: [`learning.attempt`](attempt.md).workspace_id,mastery_decision_id, [`learning.mastery_decision`](mastery_decision.md).workspace_id,supersedes_id.

## Indexes

`mastery_current_ix`; `mastery_decision_tenant_id_competency_revision_id_fkey_ix`; `mastery_decision_tenant_id_policy_revision_id_fkey_ix`; `mastery_decision_tenant_id_workspace_id_id_key` unique; `mastery_decision_tenant_id_workspace_id_supersedes_id_f_ix`

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
- No write path for agents; rows are seeded by migrations or platform tooling.

## TypeScript

insert: `Database["learning"]["Tables"]["mastery_decision"]["Insert"]`; row: `Database["learning"]["Tables"]["mastery_decision"]["Row"]`; update: `Database["learning"]["Tables"]["mastery_decision"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
