---
id: "rel:public.factory_episode"
kind: table
schema: public
name: factory_episode
domain: research-starter-protected
aliases: []
tokens: [public, factory_episode, public.factory_episode, factory_episode_id, factory_task_id, environment_version_id, factory_candidate_id, attempt_id, seed, idempotency_key, workflow_run_id, eve_session_id, sandbox_provider, sandbox_session_id, source_revision, status, terminal_state, started_at, finished_at, duration_ms, model_tokens, cost_usd, metadata, created_at]
summary: Immutable-identity app-factory or optimization rollout. External artifacts and OTel traces are referenced by content hash.
summary_basis: comment
rls: enabled
readers: []
writers: []
typescript: "Database[\"public\"][\"Tables\"][\"factory_episode\"][\"Row\"]"
defined_in: ["20260822010000_app_factory_optimization_control_plane.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# public.factory_episode

table in domain `research-starter-protected` — Immutable-identity app-factory or optimization rollout. External artifacts and OTel traces are referenced by content hash..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `factory_episode_id` | `uuid` | no | `gen_random_uuid()` | PK |
| 2 | `factory_task_id` | `uuid` | no | — | FK → [`public.factory_task`](factory_task.md).factory_task_id |
| 3 | `environment_version_id` | `uuid` | no | — | FK → [`public.factory_environment_version`](factory_environment_version.md).environment_version_id |
| 4 | `factory_candidate_id` | `uuid` | no | — | FK → [`public.factory_candidate`](factory_candidate.md).factory_candidate_id |
| 5 | `attempt_id` | `uuid` | yes | — | — |
| 6 | `seed` | `bigint` | no | — | — |
| 7 | `idempotency_key` | `text` | no | — | unique (idempotency_key) |
| 8 | `workflow_run_id` | `text` | yes | — | — |
| 9 | `eve_session_id` | `text` | yes | — | — |
| 10 | `sandbox_provider` | `text` | yes | — | — |
| 11 | `sandbox_session_id` | `text` | yes | — | — |
| 12 | `source_revision` | `text` | no | — | — |
| 13 | `status` | `text` | no | `'queued'::text` | — |
| 14 | `terminal_state` | `text` | yes | — | — |
| 15 | `started_at` | `timestamp with time zone` | yes | — | — |
| 16 | `finished_at` | `timestamp with time zone` | yes | — | — |
| 17 | `duration_ms` | `bigint` | yes | — | — |
| 18 | `model_tokens` | `bigint` | no | `0` | — |
| 19 | `cost_usd` | `numeric` | no | `0` | — |
| 20 | `metadata` | `jsonb` | no | `'{}'::jsonb` | — |
| 21 | `created_at` | `timestamp with time zone` | no | `timezone('utc'::text, now())` | — |

## Constraints

- PK (factory_episode_id)
- unique (idempotency_key)
- check `factory_episode_nonnegative_usage_check`: `((model_tokens >= 0) AND (cost_usd >= (0)::numeric) AND ((duration_ms IS NULL) OR (duration_ms >= 0)))`
- check `factory_episode_status_check`: `(status = ANY (ARRAY['queued'::text, 'running'::text, 'waiting'::text, 'verifying'::text, 'completed'::text, 'failed'::text, 'cancelled'::t…`
- check `factory_episode_terminal_state_check`: `((terminal_state IS NULL) OR (terminal_state = ANY (ARRAY['completed'::text, 'failed'::text, 'timed_out'::text, 'cancelled'::text, 'budget_…`

## Relationships

Outbound: `environment_version_id` → [`public.factory_environment_version`](factory_environment_version.md)`.environment_version_id` on delete restrict; `factory_candidate_id` → [`public.factory_candidate`](factory_candidate.md)`.factory_candidate_id` on delete restrict; `factory_task_id` → [`public.factory_task`](factory_task.md)`.factory_task_id` on delete restrict.
Inbound: [`public.factory_artifact`](factory_artifact.md).factory_episode_id, [`public.factory_assertion_result`](factory_assertion_result.md).factory_episode_id, [`public.factory_runtime_event`](factory_runtime_event.md).factory_episode_id, [`public.factory_score_vector`](factory_score_vector.md).factory_episode_id, [`public.factory_trace_span_ref`](factory_trace_span_ref.md).factory_episode_id.

## Indexes

`factory_episode_candidate_idx`; `factory_episode_eve_session_uniq` unique where `(eve_session_id IS NOT NULL)`; `factory_episode_idempotency_key_key` unique; `factory_episode_status_idx`; `factory_episode_task_idx`

## Triggers

- `protect_factory_episode_identity_and_terminal` → [`public.protect_factory_episode_identity_and_terminal`](../../functions/public/protect_factory_episode_identity_and_terminal.md)

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

insert: `Database["public"]["Tables"]["factory_episode"]["Insert"]`; row: `Database["public"]["Tables"]["factory_episode"]["Row"]`; update: `Database["public"]["Tables"]["factory_episode"]["Update"]`

Defined in: `20260822010000_app_factory_optimization_control_plane.sql`.
