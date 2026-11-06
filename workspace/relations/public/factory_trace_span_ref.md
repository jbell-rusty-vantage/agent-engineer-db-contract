---
id: "rel:public.factory_trace_span_ref"
kind: table
schema: public
name: factory_trace_span_ref
domain: research-starter-protected
aliases: []
tokens: [public, factory_trace_span_ref, public.factory_trace_span_ref, factory_trace_span_ref_id, factory_episode_id, trace_id, span_id, parent_span_id, agent_role, operation_name, artifact_id, started_at, finished_at, attributes]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"public\"][\"Tables\"][\"factory_trace_span_ref\"][\"Row\"]"
defined_in: ["20260822010000_app_factory_optimization_control_plane.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# public.factory_trace_span_ref

table in domain `research-starter-protected`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `factory_trace_span_ref_id` | `uuid` | no | `gen_random_uuid()` | PK |
| 2 | `factory_episode_id` | `uuid` | no | — | FK → [`public.factory_episode`](factory_episode.md).factory_episode_id |
| 3 | `trace_id` | `text` | no | — | unique (trace_id, span_id) |
| 4 | `span_id` | `text` | no | — | unique (trace_id, span_id) |
| 5 | `parent_span_id` | `text` | yes | — | — |
| 6 | `agent_role` | `text` | yes | — | — |
| 7 | `operation_name` | `text` | no | — | — |
| 8 | `artifact_id` | `uuid` | yes | — | FK → [`public.factory_artifact`](factory_artifact.md).factory_artifact_id |
| 9 | `started_at` | `timestamp with time zone` | yes | — | — |
| 10 | `finished_at` | `timestamp with time zone` | yes | — | — |
| 11 | `attributes` | `jsonb` | no | `'{}'::jsonb` | — |

## Constraints

- PK (factory_trace_span_ref_id)
- unique (trace_id, span_id)

## Relationships

Outbound: `artifact_id` → [`public.factory_artifact`](factory_artifact.md)`.factory_artifact_id` on delete set null; `factory_episode_id` → [`public.factory_episode`](factory_episode.md)`.factory_episode_id` on delete cascade.
Inbound: none.

## Indexes

`factory_trace_span_uniq` unique

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

insert: `Database["public"]["Tables"]["factory_trace_span_ref"]["Insert"]`; row: `Database["public"]["Tables"]["factory_trace_span_ref"]["Row"]`; update: `Database["public"]["Tables"]["factory_trace_span_ref"]["Update"]`

Defined in: `20260822010000_app_factory_optimization_control_plane.sql`.
