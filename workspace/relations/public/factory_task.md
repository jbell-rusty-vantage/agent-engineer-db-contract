---
id: "rel:public.factory_task"
kind: table
schema: public
name: factory_task
domain: research-starter-protected
aliases: []
tokens: [public, factory_task, public.factory_task, factory_task_id, challenge_id, parent_task_id, task_kind, slug, version, spec_digest, spec, risk_tier, data_split, status, created_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"public\"][\"Tables\"][\"factory_task\"][\"Row\"]"
defined_in: ["20260822010000_app_factory_optimization_control_plane.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# public.factory_task

table in domain `research-starter-protected`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `factory_task_id` | `uuid` | no | `gen_random_uuid()` | PK |
| 2 | `challenge_id` | `uuid` | yes | — | — |
| 3 | `parent_task_id` | `uuid` | yes | — | FK → [`public.factory_task`](factory_task.md).factory_task_id |
| 4 | `task_kind` | `text` | no | — | — |
| 5 | `slug` | `text` | no | — | unique (slug, version) |
| 6 | `version` | `text` | no | — | unique (slug, version) |
| 7 | `spec_digest` | `text` | no | — | — |
| 8 | `spec` | `jsonb` | no | — | — |
| 9 | `risk_tier` | `text` | no | `'standard'::text` | — |
| 10 | `data_split` | `text` | no | — | — |
| 11 | `status` | `text` | no | `'draft'::text` | — |
| 12 | `created_at` | `timestamp with time zone` | no | `timezone('utc'::text, now())` | — |

## Constraints

- PK (factory_task_id)
- unique (slug, version)
- check `factory_task_data_split_check`: `(data_split = ANY (ARRAY['train'::text, 'development'::text, 'hidden_holdout'::text, 'adversarial'::text, 'temporal_frontier'::text, 'human…`
- check `factory_task_kind_check`: `(task_kind = ANY (ARRAY['research_ingestion'::text, 'curriculum_generation'::text, 'app_feature'::text, 'app_repair'::text, 'learner_submis…`
- check `factory_task_risk_tier_check`: `(risk_tier = ANY (ARRAY['low'::text, 'standard'::text, 'high'::text, 'regulated'::text]))`
- check `factory_task_status_check`: `(status = ANY (ARRAY['draft'::text, 'review'::text, 'active'::text, 'retired'::text, 'quarantined'::text]))`

## Relationships

Outbound: `parent_task_id` → [`public.factory_task`](factory_task.md)`.factory_task_id` on delete set null.
Inbound: [`public.factory_episode`](factory_episode.md).factory_task_id, [`public.factory_task`](factory_task.md).parent_task_id.

## Indexes

`factory_task_slug_version_uniq` unique

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

insert: `Database["public"]["Tables"]["factory_task"]["Insert"]`; row: `Database["public"]["Tables"]["factory_task"]["Row"]`; update: `Database["public"]["Tables"]["factory_task"]["Update"]`

Defined in: `20260822010000_app_factory_optimization_control_plane.sql`.
