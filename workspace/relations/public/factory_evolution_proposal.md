---
id: "rel:public.factory_evolution_proposal"
kind: table
schema: public
name: factory_evolution_proposal
domain: research-starter-protected
aliases: []
tokens: [public, factory_evolution_proposal, public.factory_evolution_proposal, factory_evolution_proposal_id, failure_cluster_id, proposed_candidate_id, hypothesized_component_kind, hypothesis, mutation_surface, predicted_impact, risks, evaluation_plan, budget, stop_condition, rollback_component_version_id, status, created_at]
summary: "Bounded, evidence-backed proposal. The optimizer may propose a candidate but cannot alter verifier, reward, promotion, or production authority."
summary_basis: comment
rls: enabled
readers: []
writers: []
typescript: "Database[\"public\"][\"Tables\"][\"factory_evolution_proposal\"][\"Row\"]"
defined_in: ["20260822010000_app_factory_optimization_control_plane.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# public.factory_evolution_proposal

table in domain `research-starter-protected` — Bounded, evidence-backed proposal. The optimizer may propose a candidate but cannot alter verifier, reward, promotion, or production authority..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `factory_evolution_proposal_id` | `uuid` | no | `gen_random_uuid()` | PK |
| 2 | `failure_cluster_id` | `uuid` | yes | — | FK → [`public.factory_failure_cluster`](factory_failure_cluster.md).factory_failure_cluster_id |
| 3 | `proposed_candidate_id` | `uuid` | yes | — | FK → [`public.factory_candidate`](factory_candidate.md).factory_candidate_id |
| 4 | `hypothesized_component_kind` | `text` | no | — | — |
| 5 | `hypothesis` | `text` | no | — | — |
| 6 | `mutation_surface` | `jsonb` | no | — | — |
| 7 | `predicted_impact` | `jsonb` | no | — | — |
| 8 | `risks` | `jsonb` | no | — | — |
| 9 | `evaluation_plan` | `jsonb` | no | — | — |
| 10 | `budget` | `jsonb` | no | — | — |
| 11 | `stop_condition` | `jsonb` | no | — | — |
| 12 | `rollback_component_version_id` | `uuid` | yes | — | FK → [`public.factory_component_version`](factory_component_version.md).component_version_id |
| 13 | `status` | `text` | no | `'proposed'::text` | — |
| 14 | `created_at` | `timestamp with time zone` | no | `timezone('utc'::text, now())` | — |

## Constraints

- PK (factory_evolution_proposal_id)
- check `factory_evolution_status_check`: `(status = ANY (ARRAY['proposed'::text, 'approved'::text, 'running'::text, 'no_promotion'::text, 'promotion_requested'::text, 'rejected'::te…`

## Relationships

Outbound: `failure_cluster_id` → [`public.factory_failure_cluster`](factory_failure_cluster.md)`.factory_failure_cluster_id` on delete set null; `proposed_candidate_id` → [`public.factory_candidate`](factory_candidate.md)`.factory_candidate_id` on delete set null; `rollback_component_version_id` → [`public.factory_component_version`](factory_component_version.md)`.component_version_id` on delete restrict.
Inbound: [`public.factory_experiment`](factory_experiment.md).evolution_proposal_id.

## Indexes

_None._

## Triggers

_None._

## Row-level security

Enabled.

## Grants

No role has privileges. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

## Read paths

- No agent role may SELECT directly.

## Write path

- No direct DML for any agent role.
- No write path for agents; rows are seeded by migrations or platform tooling.

## TypeScript

insert: `Database["public"]["Tables"]["factory_evolution_proposal"]["Insert"]`; row: `Database["public"]["Tables"]["factory_evolution_proposal"]["Row"]`; update: `Database["public"]["Tables"]["factory_evolution_proposal"]["Update"]`

Defined in: `20260822010000_app_factory_optimization_control_plane.sql`.
