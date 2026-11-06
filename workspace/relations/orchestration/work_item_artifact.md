---
id: "rel:orchestration.work_item_artifact"
kind: table
schema: orchestration
name: work_item_artifact
domain: orchestration-ledger
aliases: []
tokens: [orchestration, work_item_artifact, orchestration.work_item_artifact, work_item_id, artifact_id, role]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, service_role]
writers: [control_plane, executor_service, service_role]
typescript: "Database[\"orchestration\"][\"Tables\"][\"work_item_artifact\"][\"Row\"]"
defined_in: ["20260826000200_orchestration.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# orchestration.work_item_artifact

table in domain `orchestration-ledger`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `work_item_id` | `uuid` | no | — | PK; FK → [`orchestration.work_item`](work_item.md).id |
| 2 | `artifact_id` | `uuid` | no | — | PK; FK → [`orchestration.artifact`](artifact.md).id |
| 3 | `role` | `text` | no | — | PK |

## Constraints

- PK (work_item_id, artifact_id, role)
- check `work_item_artifact_role_check`: `(role = ANY (ARRAY['produced'::text, 'consumed'::text]))`

## Relationships

Outbound: `artifact_id` → [`orchestration.artifact`](artifact.md)`.id` on delete cascade; `work_item_id` → [`orchestration.work_item`](work_item.md)`.id` on delete cascade.
Inbound: none.

## Indexes

_None._

## Triggers

- `artifact_retirement_aa58d456a40edc920d80b03c` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)

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

insert: `Database["orchestration"]["Tables"]["work_item_artifact"]["Insert"]`; row: `Database["orchestration"]["Tables"]["work_item_artifact"]["Row"]`; update: `Database["orchestration"]["Tables"]["work_item_artifact"]["Update"]`

Defined in: `20260826000200_orchestration.sql`.
