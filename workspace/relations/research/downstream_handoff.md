---
id: "rel:research.downstream_handoff"
kind: table
schema: research
name: downstream_handoff
domain: research
aliases: []
tokens: [research, downstream_handoff, research.downstream_handoff, id, mission_id, target_pipeline, payload_artifact_id, consumed_by_work_item_id, status, created_at, consumed_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"research\"][\"Tables\"][\"downstream_handoff\"][\"Row\"]"
defined_in: ["20260826000900_research.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# research.downstream_handoff

table in domain `research`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `mission_id` | `uuid` | no | — | FK → [`orchestration.mission`](../orchestration/mission.md).id |
| 3 | `target_pipeline` | `text` | no | — | — |
| 4 | `payload_artifact_id` | `uuid` | yes | — | FK → [`orchestration.artifact`](../orchestration/artifact.md).id |
| 5 | `consumed_by_work_item_id` | `uuid` | yes | — | FK → [`orchestration.work_item`](../orchestration/work_item.md).id |
| 6 | `status` | `text` | no | `'pending'::text` | — |
| 7 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 8 | `consumed_at` | `timestamp with time zone` | yes | — | — |

## Constraints

- PK (id)
- check `downstream_handoff_status_check`: `(status = ANY (ARRAY['pending'::text, 'consumed'::text, 'failed'::text, 'cancelled'::text]))`
- check `downstream_handoff_target_pipeline_check`: `(target_pipeline = ANY (ARRAY['curriculum'::text, 'challenge'::text, 'retrieval'::text, 'ranking'::text, 'publication'::text]))`

## Relationships

Outbound: `consumed_by_work_item_id` → [`orchestration.work_item`](../orchestration/work_item.md)`.id`; `mission_id` → [`orchestration.mission`](../orchestration/mission.md)`.id` on delete cascade; `payload_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.id`.
Inbound: none.

## Indexes

`downstream_handoff_pending_idx` where `(status = 'pending'::text)`

## Triggers

- `artifact_retirement_c8bd9a08b23b2d35b6d3f4ac` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `false`

## Grants

`control_plane`: SELECT; `executor_service`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["research"]["Tables"]["downstream_handoff"]["Insert"]`; row: `Database["research"]["Tables"]["downstream_handoff"]["Row"]`; update: `Database["research"]["Tables"]["downstream_handoff"]["Update"]`

Defined in: `20260826000900_research.sql`.
