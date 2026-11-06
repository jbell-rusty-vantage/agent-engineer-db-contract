---
id: "rel:orchestration.agent_session"
kind: table
schema: orchestration
name: agent_session
domain: orchestration-ledger
aliases: []
tokens: [orchestration, agent_session, orchestration.agent_session, id, tenant_id, eve_session_id, mission_id, agent_deployment, compaction_count, rotated_from_id, status, started_at, ended_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, service_role]
writers: [control_plane, executor_service, service_role]
typescript: "Database[\"orchestration\"][\"Tables\"][\"agent_session\"][\"Row\"]"
defined_in: ["20260826000200_orchestration.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# orchestration.agent_session

table in domain `orchestration-ledger`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | — |
| 3 | `eve_session_id` | `text` | no | — | unique (eve_session_id) |
| 4 | `mission_id` | `uuid` | yes | — | FK → [`orchestration.mission`](mission.md).id |
| 5 | `agent_deployment` | `text` | no | — | — |
| 6 | `compaction_count` | `integer` | no | `0` | — |
| 7 | `rotated_from_id` | `uuid` | yes | — | FK → [`orchestration.agent_session`](agent_session.md).id |
| 8 | `status` | `text` | no | `'active'::text` | — |
| 9 | `started_at` | `timestamp with time zone` | no | `now()` | — |
| 10 | `ended_at` | `timestamp with time zone` | yes | — | — |

## Constraints

- PK (id)
- unique (eve_session_id)
- check `agent_session_status_check`: `(status = ANY (ARRAY['active'::text, 'rotated'::text, 'closed'::text, 'failed'::text]))`

## Relationships

Outbound: `mission_id` → [`orchestration.mission`](mission.md)`.id` on delete set null; `rotated_from_id` → [`orchestration.agent_session`](agent_session.md)`.id`.
Inbound: [`observability.coordinator_handoff`](../observability/coordinator_handoff.md).new_session_id|old_session_id, [`orchestration.agent_session`](agent_session.md).rotated_from_id, [`orchestration.attempt`](attempt.md).agent_session_id, [`orchestration.continuation_checkpoint`](continuation_checkpoint.md).agent_session_id.

## Indexes

`agent_session_eve_session_id_key` unique; `agent_session_mission_idx`

## Triggers

_None._

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: INSERT, SELECT, UPDATE; `executor_service`: INSERT, SELECT; `service_role`: INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`.

## Write path

- Direct DML: `control_plane`, `executor_service`.

## TypeScript

insert: `Database["orchestration"]["Tables"]["agent_session"]["Insert"]`; row: `Database["orchestration"]["Tables"]["agent_session"]["Row"]`; update: `Database["orchestration"]["Tables"]["agent_session"]["Update"]`

Defined in: `20260826000200_orchestration.sql`.
