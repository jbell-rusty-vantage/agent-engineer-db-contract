---
id: "rel:knowledge_service.callback_delivery"
kind: table
schema: knowledge_service
name: callback_delivery
domain: knowledge-service-runtime
aliases: []
tokens: [knowledge_service, callback_delivery, knowledge_service.callback_delivery, callback_id, tenant_id, task_id, operation_id, correlation_id, causation_id, signing_key_reference, receiver_identity, payload_sha256, signature, occurred_at, received_at]
summary: Append-only authenticated A2A callback receipt and cross-restart replay ledger; payloads and secrets are never stored.
summary_basis: comment
rls: enabled
readers: [control_plane, executor_service, service_role]
writers: [control_plane, executor_service, service_role]
typescript: "Database[\"knowledge_service\"][\"Tables\"][\"callback_delivery\"][\"Row\"]"
defined_in: ["20260903010900_callback_delivery_replay_ledger.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# knowledge_service.callback_delivery

table in domain `knowledge-service-runtime` — Append-only authenticated A2A callback receipt and cross-restart replay ledger; payloads and secrets are never stored..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `callback_id` | `uuid` | no | — | PK; unique (tenant_id, callback_id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, callback_id) |
| 3 | `task_id` | `uuid` | no | — | — |
| 4 | `operation_id` | `uuid` | no | — | — |
| 5 | `correlation_id` | `text` | no | — | — |
| 6 | `causation_id` | `text` | yes | — | — |
| 7 | `signing_key_reference` | `text` | no | — | — |
| 8 | `receiver_identity` | `text` | no | — | — |
| 9 | `payload_sha256` | `text` | no | — | — |
| 10 | `signature` | `text` | no | — | — |
| 11 | `occurred_at` | `timestamp with time zone` | no | — | — |
| 12 | `received_at` | `timestamp with time zone` | no | `clock_timestamp()` | — |

## Constraints

- PK (callback_id)
- unique (tenant_id, callback_id)
- check `callback_delivery_check`: `(occurred_at >= (received_at - '00:05:00'::interval))`
- check `callback_delivery_check1`: `(occurred_at <= (received_at + '00:00:30'::interval))`
- check `callback_delivery_payload_sha256_check`: `(payload_sha256 ~ '^sha256:[0-9a-f]{64}$'::text)`
- check `callback_delivery_signature_check`: `(signature ~ '^sha256=[0-9a-f]{64}$'::text)`

## Relationships

Outbound: `tenant_id,operation_id` → [`knowledge_service.operation`](operation.md)`.tenant_id,id` on delete restrict.
Inbound: none.

## Indexes

`callback_delivery_operation_idx`; `callback_delivery_tenant_id_callback_id_key` unique

## Triggers

- `callback_delivery_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `control_plane`, `executor_service`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: INSERT, SELECT; `executor_service`: INSERT, SELECT; `service_role`: INSERT, SELECT. None: `anon`, `app_reader`, `authenticated`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`.

## Write path

- Direct DML: `control_plane`, `executor_service`.

## TypeScript

insert: `Database["knowledge_service"]["Tables"]["callback_delivery"]["Insert"]`; row: `Database["knowledge_service"]["Tables"]["callback_delivery"]["Row"]`; update: `Database["knowledge_service"]["Tables"]["callback_delivery"]["Update"]`

Defined in: `20260903010900_callback_delivery_replay_ledger.sql`.
