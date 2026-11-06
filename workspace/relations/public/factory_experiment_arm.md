---
id: "rel:public.factory_experiment_arm"
kind: table
schema: public
name: factory_experiment_arm
domain: research-starter-protected
aliases: []
tokens: [public, factory_experiment_arm, public.factory_experiment_arm, factory_experiment_arm_id, factory_experiment_id, factory_candidate_id, arm_name, assignment_probability, aggregate_metrics, episode_ids, created_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"public\"][\"Tables\"][\"factory_experiment_arm\"][\"Row\"]"
defined_in: ["20260822010000_app_factory_optimization_control_plane.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# public.factory_experiment_arm

table in domain `research-starter-protected`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `factory_experiment_arm_id` | `uuid` | no | `gen_random_uuid()` | PK |
| 2 | `factory_experiment_id` | `uuid` | no | — | unique (factory_experiment_id, arm_name); FK → [`public.factory_experiment`](factory_experiment.md).factory_experiment_id |
| 3 | `factory_candidate_id` | `uuid` | no | — | FK → [`public.factory_candidate`](factory_candidate.md).factory_candidate_id |
| 4 | `arm_name` | `text` | no | — | unique (factory_experiment_id, arm_name) |
| 5 | `assignment_probability` | `numeric` | yes | — | — |
| 6 | `aggregate_metrics` | `jsonb` | no | `'{}'::jsonb` | — |
| 7 | `episode_ids` | `uuid[]` | no | `'{}'::uuid[]` | — |
| 8 | `created_at` | `timestamp with time zone` | no | `timezone('utc'::text, now())` | — |

## Constraints

- PK (factory_experiment_arm_id)
- unique (factory_experiment_id, arm_name)
- check `factory_experiment_arm_probability_check`: `((assignment_probability IS NULL) OR ((assignment_probability > (0)::numeric) AND (assignment_probability <= (1)::numeric)))`

## Relationships

Outbound: `factory_candidate_id` → [`public.factory_candidate`](factory_candidate.md)`.factory_candidate_id` on delete restrict; `factory_experiment_id` → [`public.factory_experiment`](factory_experiment.md)`.factory_experiment_id` on delete cascade.
Inbound: none.

## Indexes

`factory_experiment_arm_name_uniq` unique

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

insert: `Database["public"]["Tables"]["factory_experiment_arm"]["Insert"]`; row: `Database["public"]["Tables"]["factory_experiment_arm"]["Row"]`; update: `Database["public"]["Tables"]["factory_experiment_arm"]["Update"]`

Defined in: `20260822010000_app_factory_optimization_control_plane.sql`.
