---
id: "rel:public.factory_candidate"
kind: table
schema: public
name: factory_candidate
domain: research-starter-protected
aliases: []
tokens: [public, factory_candidate, public.factory_candidate, factory_candidate_id, parent_candidate_id, candidate_kind, content_digest, source_revision, proposer, rationale, mutation_surface, component_versions, status, created_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"public\"][\"Tables\"][\"factory_candidate\"][\"Row\"]"
defined_in: ["20260822010000_app_factory_optimization_control_plane.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# public.factory_candidate

table in domain `research-starter-protected`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `factory_candidate_id` | `uuid` | no | `gen_random_uuid()` | PK |
| 2 | `parent_candidate_id` | `uuid` | yes | — | FK → [`public.factory_candidate`](factory_candidate.md).factory_candidate_id |
| 3 | `candidate_kind` | `text` | no | — | — |
| 4 | `content_digest` | `text` | no | — | — |
| 5 | `source_revision` | `text` | no | — | — |
| 6 | `proposer` | `text` | no | — | — |
| 7 | `rationale` | `text` | no | — | — |
| 8 | `mutation_surface` | `jsonb` | no | — | — |
| 9 | `component_versions` | `jsonb` | no | — | — |
| 10 | `status` | `text` | no | `'proposed'::text` | — |
| 11 | `created_at` | `timestamp with time zone` | no | `timezone('utc'::text, now())` | — |

## Constraints

- PK (factory_candidate_id)
- check `factory_candidate_kind_check`: `(candidate_kind = ANY (ARRAY['instructions'::text, 'skill'::text, 'tool'::text, 'retriever'::text, 'workflow'::text, 'model_route'::text, '…`
- check `factory_candidate_status_check`: `(status = ANY (ARRAY['proposed'::text, 'evaluating'::text, 'rejected'::text, 'approved'::text, 'canary'::text, 'promoted'::text, 'rolled_ba…`

## Relationships

Outbound: `parent_candidate_id` → [`public.factory_candidate`](factory_candidate.md)`.factory_candidate_id` on delete set null.
Inbound: [`public.factory_candidate`](factory_candidate.md).parent_candidate_id, [`public.factory_episode`](factory_episode.md).factory_candidate_id, [`public.factory_evolution_proposal`](factory_evolution_proposal.md).proposed_candidate_id, [`public.factory_experiment_arm`](factory_experiment_arm.md).factory_candidate_id, [`public.factory_promotion_decision`](factory_promotion_decision.md).baseline_candidate_id|candidate_id.

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

insert: `Database["public"]["Tables"]["factory_candidate"]["Insert"]`; row: `Database["public"]["Tables"]["factory_candidate"]["Row"]`; update: `Database["public"]["Tables"]["factory_candidate"]["Update"]`

Defined in: `20260822010000_app_factory_optimization_control_plane.sql`.
