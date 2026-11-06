---
id: "rel:orchestration.work_item_event"
kind: table
schema: orchestration
name: work_item_event
domain: orchestration-ledger
aliases: []
tokens: [orchestration, work_item_event, orchestration.work_item_event, id, tenant_id, work_item_id, attempt_id, event_type, actor, message, payload, occurred_at]
summary: Append-only cross-agent progress ledger. Lease state remains on work_item; every transition and checkpoint is recorded here.
summary_basis: comment
rls: enabled
readers: [app_reader, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
typescript: "Database[\"orchestration\"][\"Tables\"][\"work_item_event\"][\"Row\"]"
defined_in: ["20260829012402_cloud_agent_research_operations.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# orchestration.work_item_event

table in domain `orchestration-ledger` — Append-only cross-agent progress ledger. Lease state remains on work_item; every transition and checkpoint is recorded here..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | — |
| 3 | `work_item_id` | `uuid` | no | — | FK → [`orchestration.work_item`](work_item.md).id |
| 4 | `attempt_id` | `uuid` | yes | — | FK → [`orchestration.attempt`](attempt.md).id |
| 5 | `event_type` | `text` | no | — | — |
| 6 | `actor` | `text` | no | — | — |
| 7 | `message` | `text` | yes | — | — |
| 8 | `payload` | `jsonb` | no | `'{}'::jsonb` | — |
| 9 | `occurred_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- check `work_item_event_event_type_check`: `(event_type = ANY (ARRAY['created'::text, 'ready'::text, 'claimed'::text, 'heartbeat'::text, 'checkpoint'::text, 'blocked'::text, 'released…`

## Relationships

Outbound: `attempt_id` → [`orchestration.attempt`](attempt.md)`.id` on delete set null; `work_item_id` → [`orchestration.work_item`](work_item.md)`.id` on delete cascade.
Inbound: none.

## Indexes

`work_item_event_attempt_idx` where `(attempt_id IS NOT NULL)`; `work_item_event_item_idx`

## Triggers

- `work_item_event_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`app_reader`: SELECT; `control_plane`: INSERT, SELECT; `executor_service`: INSERT, SELECT; `pipeline_agent`: INSERT, SELECT; `service_role`: INSERT, SELECT; `verifier_agent`: INSERT, SELECT. None: `anon`, `authenticated`.

## Read paths

- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## TypeScript

insert: `Database["orchestration"]["Tables"]["work_item_event"]["Insert"]`; row: `Database["orchestration"]["Tables"]["work_item_event"]["Row"]`; update: `Database["orchestration"]["Tables"]["work_item_event"]["Update"]`

Defined in: `20260829012402_cloud_agent_research_operations.sql`.
