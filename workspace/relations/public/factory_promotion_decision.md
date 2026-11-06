---
id: "rel:public.factory_promotion_decision"
kind: table
schema: public
name: factory_promotion_decision
domain: research-starter-protected
aliases: []
tokens: [public, factory_promotion_decision, public.factory_promotion_decision, factory_promotion_decision_id, factory_experiment_id, baseline_candidate_id, candidate_id, decision, promotion_policy_version, evidence, reasons, decided_by, rollback_component_version_id, created_at]
summary: Independent signed promotion outcome with evidence and an explicit rollback target.
summary_basis: comment
rls: enabled
readers: []
writers: []
typescript: "Database[\"public\"][\"Tables\"][\"factory_promotion_decision\"][\"Row\"]"
defined_in: ["20260822010000_app_factory_optimization_control_plane.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# public.factory_promotion_decision

table in domain `research-starter-protected` — Independent signed promotion outcome with evidence and an explicit rollback target..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `factory_promotion_decision_id` | `uuid` | no | `gen_random_uuid()` | PK |
| 2 | `factory_experiment_id` | `uuid` | no | — | FK → [`public.factory_experiment`](factory_experiment.md).factory_experiment_id |
| 3 | `baseline_candidate_id` | `uuid` | no | — | FK → [`public.factory_candidate`](factory_candidate.md).factory_candidate_id |
| 4 | `candidate_id` | `uuid` | no | — | FK → [`public.factory_candidate`](factory_candidate.md).factory_candidate_id |
| 5 | `decision` | `text` | no | — | — |
| 6 | `promotion_policy_version` | `text` | no | — | — |
| 7 | `evidence` | `jsonb` | no | — | — |
| 8 | `reasons` | `text[]` | no | `'{}'::text[]` | — |
| 9 | `decided_by` | `text` | no | — | — |
| 10 | `rollback_component_version_id` | `uuid` | yes | — | FK → [`public.factory_component_version`](factory_component_version.md).component_version_id |
| 11 | `created_at` | `timestamp with time zone` | no | `timezone('utc'::text, now())` | — |

## Constraints

- PK (factory_promotion_decision_id)
- check `factory_promotion_decision_check`: `(decision = ANY (ARRAY['promote'::text, 'reject'::text, 'shadow'::text, 'canary'::text, 'roll_back'::text, 'needs_human_review'::text]))`

## Relationships

Outbound: `baseline_candidate_id` → [`public.factory_candidate`](factory_candidate.md)`.factory_candidate_id` on delete restrict; `candidate_id` → [`public.factory_candidate`](factory_candidate.md)`.factory_candidate_id` on delete restrict; `factory_experiment_id` → [`public.factory_experiment`](factory_experiment.md)`.factory_experiment_id` on delete restrict; `rollback_component_version_id` → [`public.factory_component_version`](factory_component_version.md)`.component_version_id` on delete restrict.
Inbound: [`public.factory_canary_result`](factory_canary_result.md).promotion_decision_id.

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

insert: `Database["public"]["Tables"]["factory_promotion_decision"]["Insert"]`; row: `Database["public"]["Tables"]["factory_promotion_decision"]["Row"]`; update: `Database["public"]["Tables"]["factory_promotion_decision"]["Update"]`

Defined in: `20260822010000_app_factory_optimization_control_plane.sql`.
