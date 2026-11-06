---
id: "rel:public.research_pre_research_session"
kind: table
schema: public
name: research_pre_research_session
domain: research-starter-protected
aliases: []
tokens: [public, research_pre_research_session, public.research_pre_research_session, pre_research_session_id, run_id, phase, attempt, eve_session_id, status, started_at, completed_at, error_code, error_detail, result_summary]
summary: null
summary_basis: none
rls: enabled
readers: [service_role]
writers: [service_role]
typescript: "Database[\"public\"][\"Tables\"][\"research_pre_research_session\"][\"Row\"]"
defined_in: ["20260816205231_pre_research_v2_schema.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# public.research_pre_research_session

table in domain `research-starter-protected`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `pre_research_session_id` | `uuid` | no | `gen_random_uuid()` | PK |
| 2 | `run_id` | `uuid` | no | — | unique (run_id, phase, attempt); FK → [`public.research_pre_research_run`](research_pre_research_run.md).run_id |
| 3 | `phase` | `text` | no | — | unique (run_id, phase, attempt) |
| 4 | `attempt` | `integer` | no | — | unique (run_id, phase, attempt) |
| 5 | `eve_session_id` | `text` | no | — | unique (eve_session_id) |
| 6 | `status` | `text` | no | — | — |
| 7 | `started_at` | `timestamp with time zone` | no | `timezone('utc'::text, now())` | — |
| 8 | `completed_at` | `timestamp with time zone` | yes | — | — |
| 9 | `error_code` | `text` | yes | — | — |
| 10 | `error_detail` | `text` | yes | — | — |
| 11 | `result_summary` | `jsonb` | yes | — | — |

## Constraints

- PK (pre_research_session_id)
- unique (eve_session_id)
- unique (run_id, phase, attempt)
- check `research_pre_research_session_attempt_check`: `(attempt >= 1)`
- check `research_pre_research_session_phase_check`: `(phase = ANY (ARRAY['research'::text, 'synthesis'::text]))`
- check `research_pre_research_session_status_check`: `(status = ANY (ARRAY['started'::text, 'completed'::text, 'failed'::text, 'cancelled'::text]))`

## Relationships

Outbound: `run_id` → [`public.research_pre_research_run`](research_pre_research_run.md)`.run_id` on delete cascade.
Inbound: none.

## Indexes

`research_pre_research_session_eve_session_id_key` unique; `research_pre_research_session_run_id_phase_attempt_key` unique; `research_pre_research_session_run_idx`

## Triggers

_None._

## Row-level security

Enabled.

## Grants

`service_role`: DELETE, INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Read paths

- No agent role may SELECT directly.

## Write path

- No direct DML for any agent role.
- Via functions (best effort): [`research_private.begin_research_session`](../../functions/research_private/begin_research_session.md), [`research_private.begin_synthesis_session`](../../functions/research_private/begin_synthesis_session.md), [`research_private.complete_research_phase`](../../functions/research_private/complete_research_phase.md), [`research_private.complete_synthesis_phase`](../../functions/research_private/complete_synthesis_phase.md).

## TypeScript

insert: `Database["public"]["Tables"]["research_pre_research_session"]["Insert"]`; row: `Database["public"]["Tables"]["research_pre_research_session"]["Row"]`; update: `Database["public"]["Tables"]["research_pre_research_session"]["Update"]`

Defined in: `20260816205231_pre_research_v2_schema.sql`.
