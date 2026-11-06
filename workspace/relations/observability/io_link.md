---
id: "rel:observability.io_link"
kind: table
schema: observability
name: io_link
domain: observability
aliases: []
tokens: [observability, io_link, observability.io_link, id, trace_id, span_id, artifact_id, direction, encrypted, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, service_role]
writers: [control_plane, service_role]
typescript: "Database[\"observability\"][\"Tables\"][\"io_link\"][\"Row\"]"
defined_in: ["20260826001200_observability.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# observability.io_link

table in domain `observability`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `trace_id` | `text` | yes | — | — |
| 3 | `span_id` | `text` | yes | — | — |
| 4 | `artifact_id` | `uuid` | no | — | FK → [`orchestration.artifact`](../orchestration/artifact.md).id |
| 5 | `direction` | `text` | no | — | — |
| 6 | `encrypted` | `boolean` | no | `true` | — |
| 7 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- check `io_link_direction_check`: `(direction = ANY (ARRAY['input'::text, 'output'::text]))`

## Relationships

Outbound: `artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.id`.
Inbound: none.

## Indexes

`io_link_span_idx`

## Triggers

- `artifact_retirement_44dbbcf7632018e2c61387b5` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)

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

insert: `Database["observability"]["Tables"]["io_link"]["Insert"]`; row: `Database["observability"]["Tables"]["io_link"]["Row"]`; update: `Database["observability"]["Tables"]["io_link"]["Update"]`

Defined in: `20260826001200_observability.sql`.
