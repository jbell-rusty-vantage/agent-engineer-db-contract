---
id: "rel:public.factory_experiment"
kind: table
schema: public
name: factory_experiment
domain: research-starter-protected
aliases: []
tokens: [public, factory_experiment, public.factory_experiment, factory_experiment_id, evolution_proposal_id, experiment_version, split_manifest_digest, policy, status, started_at, finished_at, created_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"public\"][\"Tables\"][\"factory_experiment\"][\"Row\"]"
defined_in: ["20260822010000_app_factory_optimization_control_plane.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# public.factory_experiment

table in domain `research-starter-protected`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `factory_experiment_id` | `uuid` | no | `gen_random_uuid()` | PK |
| 2 | `evolution_proposal_id` | `uuid` | no | — | FK → [`public.factory_evolution_proposal`](factory_evolution_proposal.md).factory_evolution_proposal_id |
| 3 | `experiment_version` | `text` | no | — | — |
| 4 | `split_manifest_digest` | `text` | no | — | — |
| 5 | `policy` | `jsonb` | no | — | — |
| 6 | `status` | `text` | no | `'draft'::text` | — |
| 7 | `started_at` | `timestamp with time zone` | yes | — | — |
| 8 | `finished_at` | `timestamp with time zone` | yes | — | — |
| 9 | `created_at` | `timestamp with time zone` | no | `timezone('utc'::text, now())` | — |

## Constraints

- PK (factory_experiment_id)
- check `factory_experiment_status_check`: `(status = ANY (ARRAY['draft'::text, 'running'::text, 'completed'::text, 'failed'::text, 'cancelled'::text]))`

## Relationships

Outbound: `evolution_proposal_id` → [`public.factory_evolution_proposal`](factory_evolution_proposal.md)`.factory_evolution_proposal_id` on delete cascade.
Inbound: [`public.factory_experiment_arm`](factory_experiment_arm.md).factory_experiment_id, [`public.factory_promotion_decision`](factory_promotion_decision.md).factory_experiment_id.

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

insert: `Database["public"]["Tables"]["factory_experiment"]["Insert"]`; row: `Database["public"]["Tables"]["factory_experiment"]["Row"]`; update: `Database["public"]["Tables"]["factory_experiment"]["Update"]`

Defined in: `20260822010000_app_factory_optimization_control_plane.sql`.
