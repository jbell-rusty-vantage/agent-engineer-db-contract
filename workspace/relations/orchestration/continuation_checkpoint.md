---
id: "rel:orchestration.continuation_checkpoint"
kind: table
schema: orchestration
name: continuation_checkpoint
domain: orchestration-ledger
aliases: []
tokens: [orchestration, continuation_checkpoint, orchestration.continuation_checkpoint, id, mission_id, agent_session_id, constraints_section, decisions, completed, active, blocked, failed_approaches, pending_approvals, digests, refs, verification_status, package_artifact_id, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, service_role]
writers: [control_plane, executor_service, service_role]
typescript: "Database[\"orchestration\"][\"Tables\"][\"continuation_checkpoint\"][\"Row\"]"
defined_in: ["20260826000200_orchestration.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# orchestration.continuation_checkpoint

table in domain `orchestration-ledger`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `mission_id` | `uuid` | no | — | FK → [`orchestration.mission`](mission.md).id |
| 3 | `agent_session_id` | `uuid` | yes | — | FK → [`orchestration.agent_session`](agent_session.md).id |
| 4 | `constraints_section` | `jsonb` | no | `'{}'::jsonb` | — |
| 5 | `decisions` | `jsonb` | no | `'{}'::jsonb` | — |
| 6 | `completed` | `jsonb` | no | `'{}'::jsonb` | — |
| 7 | `active` | `jsonb` | no | `'{}'::jsonb` | — |
| 8 | `blocked` | `jsonb` | no | `'{}'::jsonb` | — |
| 9 | `failed_approaches` | `jsonb` | no | `'{}'::jsonb` | — |
| 10 | `pending_approvals` | `jsonb` | no | `'{}'::jsonb` | — |
| 11 | `digests` | `jsonb` | no | `'{}'::jsonb` | — |
| 12 | `refs` | `jsonb` | no | `'{}'::jsonb` | — |
| 13 | `verification_status` | `text` | no | `'unverified'::text` | — |
| 14 | `package_artifact_id` | `uuid` | yes | — | FK → [`orchestration.artifact`](artifact.md).id |
| 15 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- check `continuation_checkpoint_verification_status_check`: `(verification_status = ANY (ARRAY['unverified'::text, 'verified'::text, 'failed'::text]))`

## Relationships

Outbound: `agent_session_id` → [`orchestration.agent_session`](agent_session.md)`.id`; `mission_id` → [`orchestration.mission`](mission.md)`.id` on delete cascade; `package_artifact_id` → [`orchestration.artifact`](artifact.md)`.id`.
Inbound: [`observability.coordinator_handoff`](../observability/coordinator_handoff.md).checkpoint_id.

## Indexes

`continuation_checkpoint_mission_idx`

## Triggers

- `artifact_retirement_941c03d26bf76583a18699f0` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `false`

## Grants

`control_plane`: INSERT, SELECT, UPDATE; `executor_service`: INSERT, SELECT; `service_role`: INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`.

## Write path

- Direct DML: `control_plane`, `executor_service`.

## TypeScript

insert: `Database["orchestration"]["Tables"]["continuation_checkpoint"]["Insert"]`; row: `Database["orchestration"]["Tables"]["continuation_checkpoint"]["Row"]`; update: `Database["orchestration"]["Tables"]["continuation_checkpoint"]["Update"]`

Defined in: `20260826000200_orchestration.sql`.
