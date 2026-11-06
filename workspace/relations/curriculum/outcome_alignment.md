---
id: "rel:curriculum.outcome_alignment"
kind: table
schema: curriculum
name: outcome_alignment
domain: curriculum
aliases: []
tokens: [curriculum, outcome_alignment, curriculum.outcome_alignment, id, tenant_id, workspace_id, outcome_id, competency_revision_id, facet, coverage, rationale, created_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"curriculum\"][\"Tables\"][\"outcome_alignment\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# curriculum.outcome_alignment

table in domain `curriculum`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id); unique (tenant_id, workspace_id, outcome_id, competency_revision_id, facet) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id); unique (tenant_id, workspace_id, outcome_id, competency_revision_id, facet) |
| 4 | `outcome_id` | `uuid` | no | — | unique (tenant_id, workspace_id, outcome_id, competency_revision_id, facet) |
| 5 | `competency_revision_id` | `uuid` | no | — | unique (tenant_id, workspace_id, outcome_id, competency_revision_id, facet) |
| 6 | `facet` | `text` | no | — | unique (tenant_id, workspace_id, outcome_id, competency_revision_id, facet) |
| 7 | `coverage` | `text` | no | — | — |
| 8 | `rationale` | `text` | no | — | — |
| 9 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, workspace_id, id)
- unique (tenant_id, workspace_id, outcome_id, competency_revision_id, facet)
- check `outcome_alignment_coverage_check`: `(coverage = ANY (ARRAY['full'::text, 'partial'::text]))`
- check `outcome_alignment_facet_check`: `(facet = ANY (ARRAY['independent'::text, 'assisted'::text, 'agent_directed'::text]))`
- check `outcome_alignment_rationale_check`: `product.nonblank(rationale)`

## Relationships

Outbound: `tenant_id,competency_revision_id` → `authoring.work_revision``.tenant_id,id` on delete restrict; `tenant_id,workspace_id,outcome_id` → [`curriculum.outcome`](outcome.md)`.tenant_id,workspace_id,id` on delete restrict.
Inbound: none.

## Indexes

`outcome_alignment_tenant_id_competency_revision_id_fkey_ix`; `outcome_alignment_tenant_id_workspace_id_id_key` unique; `outcome_alignment_tenant_id_workspace_id_outcome_id_compete_key` unique

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

insert: `Database["curriculum"]["Tables"]["outcome_alignment"]["Insert"]`; row: `Database["curriculum"]["Tables"]["outcome_alignment"]["Row"]`; update: `Database["curriculum"]["Tables"]["outcome_alignment"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
