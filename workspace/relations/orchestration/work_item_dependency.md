---
id: "rel:orchestration.work_item_dependency"
kind: table
schema: orchestration
name: work_item_dependency
domain: orchestration-ledger
aliases: []
tokens: [orchestration, work_item_dependency, orchestration.work_item_dependency, work_item_id, depends_on_id, dependency_kind, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, service_role]
writers: [control_plane, executor_service, service_role]
typescript: "Database[\"orchestration\"][\"Tables\"][\"work_item_dependency\"][\"Row\"]"
defined_in: ["20260826000200_orchestration.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# orchestration.work_item_dependency

table in domain `orchestration-ledger`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `work_item_id` | `uuid` | no | — | PK; FK → [`orchestration.work_item`](work_item.md).id |
| 2 | `depends_on_id` | `uuid` | no | — | PK; FK → [`orchestration.work_item`](work_item.md).id |
| 3 | `dependency_kind` | `text` | no | `'completion'::text` | — |
| 4 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (work_item_id, depends_on_id)
- check `work_item_dependency_dependency_kind_check`: `(dependency_kind = ANY (ARRAY['completion'::text, 'artifact'::text, 'approval'::text, 'data'::text]))`
- check `work_item_dependency_no_self`: `(work_item_id <> depends_on_id)`

## Relationships

Outbound: `depends_on_id` → [`orchestration.work_item`](work_item.md)`.id` on delete cascade; `work_item_id` → [`orchestration.work_item`](work_item.md)`.id` on delete cascade.
Inbound: none.

## Indexes

`work_item_dependency_reverse_idx`

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

insert: `Database["orchestration"]["Tables"]["work_item_dependency"]["Insert"]`; row: `Database["orchestration"]["Tables"]["work_item_dependency"]["Row"]`; update: `Database["orchestration"]["Tables"]["work_item_dependency"]["Update"]`

Defined in: `20260826000200_orchestration.sql`.
