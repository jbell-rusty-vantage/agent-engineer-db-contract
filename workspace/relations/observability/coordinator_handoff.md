---
id: "rel:observability.coordinator_handoff"
kind: table
schema: observability
name: coordinator_handoff
domain: observability
aliases: []
tokens: [observability, coordinator_handoff, observability.coordinator_handoff, id, old_session_id, new_session_id, checkpoint_id, verification_state, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, service_role]
writers: [control_plane, service_role]
typescript: "Database[\"observability\"][\"Tables\"][\"coordinator_handoff\"][\"Row\"]"
defined_in: ["20260826001200_observability.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# observability.coordinator_handoff

table in domain `observability`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `old_session_id` | `uuid` | yes | — | FK → [`orchestration.agent_session`](../orchestration/agent_session.md).id |
| 3 | `new_session_id` | `uuid` | yes | — | FK → [`orchestration.agent_session`](../orchestration/agent_session.md).id |
| 4 | `checkpoint_id` | `uuid` | yes | — | FK → [`orchestration.continuation_checkpoint`](../orchestration/continuation_checkpoint.md).id |
| 5 | `verification_state` | `text` | no | `'unverified'::text` | — |
| 6 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- check `coordinator_handoff_verification_state_check`: `(verification_state = ANY (ARRAY['unverified'::text, 'verified'::text, 'failed'::text]))`

## Relationships

Outbound: `checkpoint_id` → [`orchestration.continuation_checkpoint`](../orchestration/continuation_checkpoint.md)`.id`; `new_session_id` → [`orchestration.agent_session`](../orchestration/agent_session.md)`.id`; `old_session_id` → [`orchestration.agent_session`](../orchestration/agent_session.md)`.id`.
Inbound: none.

## Indexes

_None._

## Triggers

_None._

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `false`

## Grants

`control_plane`: INSERT, SELECT; `service_role`: INSERT, SELECT. None: `anon`, `app_reader`, `authenticated`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `control_plane`.

## Write path

- Direct DML: `control_plane`.

## TypeScript

insert: `Database["observability"]["Tables"]["coordinator_handoff"]["Insert"]`; row: `Database["observability"]["Tables"]["coordinator_handoff"]["Row"]`; update: `Database["observability"]["Tables"]["coordinator_handoff"]["Update"]`

Defined in: `20260826001200_observability.sql`.
