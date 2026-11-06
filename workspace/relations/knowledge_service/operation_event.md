---
id: "rel:knowledge_service.operation_event"
kind: table
schema: knowledge_service
name: operation_event
domain: knowledge-service-runtime
aliases: []
tokens: [knowledge_service, operation_event, knowledge_service.operation_event, id, tenant_id, operation_id, step_id, event_kind, from_state, to_state, actor_identity, correlation_id, causation_id, guarded_sha256, payload, occurred_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, service_role]
writers: [control_plane, executor_service, service_role]
typescript: "Database[\"knowledge_service\"][\"Tables\"][\"operation_event\"][\"Row\"]"
defined_in: ["20260903010200_knowledge_runtime_security.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# knowledge_service.operation_event

table in domain `knowledge-service-runtime`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id); unique (tenant_id, id, operation_id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id); unique (tenant_id, id, operation_id) |
| 3 | `operation_id` | `uuid` | no | — | unique (tenant_id, id, operation_id) |
| 4 | `step_id` | `uuid` | yes | — | — |
| 5 | `event_kind` | `text` | no | — | — |
| 6 | `from_state` | `text` | yes | — | — |
| 7 | `to_state` | `text` | yes | — | — |
| 8 | `actor_identity` | `text` | no | — | — |
| 9 | `correlation_id` | `uuid` | no | — | — |
| 10 | `causation_id` | `uuid` | yes | — | — |
| 11 | `guarded_sha256` | `text` | yes | — | — |
| 12 | `payload` | `jsonb` | no | `'{}'::jsonb` | — |
| 13 | `occurred_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, id, operation_id)

## Relationships

Outbound: `tenant_id,operation_id` → [`knowledge_service.operation`](operation.md)`.tenant_id,id` on delete restrict; `tenant_id,step_id` → [`knowledge_service.operation_step`](operation_step.md)`.tenant_id,id` on delete restrict.
Inbound: [`knowledge_service.outbox`](outbox.md).event_id,operation_id|event_id.

## Indexes

`operation_event_tenant_id_id_key` unique; `operation_event_tenant_id_operation_uq` unique

## Triggers

- `operation_event_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: INSERT, SELECT, UPDATE; `executor_service`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`.

## Write path

- Direct DML: `control_plane`, `executor_service`.
- Via functions (best effort): [`temporal.emit_outbox`](../../functions/temporal/emit_outbox.md).

## TypeScript

insert: `Database["knowledge_service"]["Tables"]["operation_event"]["Insert"]`; row: `Database["knowledge_service"]["Tables"]["operation_event"]["Row"]`; update: `Database["knowledge_service"]["Tables"]["operation_event"]["Update"]`

Defined in: `20260903010200_knowledge_runtime_security.sql`.
