---
id: "rel:orchestration.artifact_manifest"
kind: table
schema: orchestration
name: artifact_manifest
domain: orchestration-ledger
aliases: []
tokens: [orchestration, artifact_manifest, orchestration.artifact_manifest, id, mission_id, work_item_id, required, produced, omitted, failed, deferred, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, service_role]
writers: [control_plane, executor_service, service_role]
typescript: "Database[\"orchestration\"][\"Tables\"][\"artifact_manifest\"][\"Row\"]"
defined_in: ["20260826000200_orchestration.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# orchestration.artifact_manifest

table in domain `orchestration-ledger`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `mission_id` | `uuid` | yes | — | FK → [`orchestration.mission`](mission.md).id |
| 3 | `work_item_id` | `uuid` | yes | — | FK → [`orchestration.work_item`](work_item.md).id |
| 4 | `required` | `jsonb` | no | `'[]'::jsonb` | — |
| 5 | `produced` | `jsonb` | no | `'[]'::jsonb` | — |
| 6 | `omitted` | `jsonb` | no | `'[]'::jsonb` | — |
| 7 | `failed` | `jsonb` | no | `'[]'::jsonb` | — |
| 8 | `deferred` | `jsonb` | no | `'[]'::jsonb` | — |
| 9 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- check `artifact_manifest_scope`: `(num_nonnulls(mission_id, work_item_id) >= 1)`

## Relationships

Outbound: `mission_id` → [`orchestration.mission`](mission.md)`.id` on delete cascade; `work_item_id` → [`orchestration.work_item`](work_item.md)`.id` on delete cascade.
Inbound: none.

## Indexes

_None._

## Triggers

_None._

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

insert: `Database["orchestration"]["Tables"]["artifact_manifest"]["Insert"]`; row: `Database["orchestration"]["Tables"]["artifact_manifest"]["Row"]`; update: `Database["orchestration"]["Tables"]["artifact_manifest"]["Update"]`

Defined in: `20260826000200_orchestration.sql`.
