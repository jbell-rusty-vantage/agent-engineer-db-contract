---
id: "dom:knowledge-service-runtime"
kind: domain
lens: machinery
schemas: [knowledge_service]
aliases: [operations, outbox, leases]
relations: [knowledge_service.operation, knowledge_service.operation_step, knowledge_service.operation_event, knowledge_service.outbox, knowledge_service.lease, knowledge_service.callback_delivery, knowledge_service.eve_operation_binding]
functions: [temporal.emit_outbox]
tasks: [check-knowledge-head]
summary: "Durable KS operations, steps, outbox, and eve bindings (machinery lens)."
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
---
# Knowledge service runtime

Durable KS operations, steps, outbox, and eve bindings (machinery lens).

> curated (model_assisted, unreviewed) — `knowledge_service.operation` is the durable record of a platform or eve call
> (operation_kind, idempotency_key, ownership_mode standalone | mission_control | eve,
> attempt_id, request_sha256, status). Steps and events decompose the run. The outbox
> emits knowledge.batch_sealed when a temporal batch commits and projection.rebuilt
> when retrieval projections refresh.
> 
> Leases, callback deliveries, and eve operation bindings are runtime control. Agents
> do not write these tables. The knowledge executor records a `knowledge_ingestion`
> operation when it applies an intent. If a batch sealed but an artifact upload is pending,
> the artifact row keeps `storage_state='pending'` and a retry step finishes it.
> 
> Trap: treating the outbox as a query catalog — agents should `check-knowledge-head` /
> `q:knowledge.head` after a sealed batch instead of polling `knowledge_service.outbox`.
> `temporal.emit_outbox` runs inside `temporal.commit_batch`; do not call it yourself.

## Relations that matter

| Relation | Summary | Enforced | Direct writers |
| --- | --- | --- | --- |
| [`knowledge_service.operation`](../relations/knowledge_service/operation.md) | Durable knowledge-service operation with ownership_mode and idempotency_key. | PK (id); unique (tenant_id, id), (tenant_id, idempotency_key); RLS | `control_plane`, `executor_service` |
| [`knowledge_service.operation_step`](../relations/knowledge_service/operation_step.md) | table | PK (id); unique (tenant_id, id), (tenant_id, operation_id, step_key); RLS | `control_plane`, `executor_service` |
| [`knowledge_service.operation_event`](../relations/knowledge_service/operation_event.md) | table | PK (id); unique (tenant_id, id), (tenant_id, id, operation_id); RLS | `control_plane`, `executor_service` |
| [`knowledge_service.outbox`](../relations/knowledge_service/outbox.md) | table | PK (id); unique (tenant_id, id); RLS | `control_plane`, `executor_service` |
| [`knowledge_service.lease`](../relations/knowledge_service/lease.md) | table | PK (id); unique (lease_token), (tenant_id, id), (tenant_id, operation_step_id); RLS | `control_plane`, `executor_service` |
| [`knowledge_service.callback_delivery`](../relations/knowledge_service/callback_delivery.md) | Append-only authenticated A2A callback receipt and cross-restart replay ledger; payloads and secrets are neve… | PK (callback_id); unique (tenant_id, callback_id); RLS | `control_plane`, `executor_service` |
| [`knowledge_service.eve_operation_binding`](../relations/knowledge_service/eve_operation_binding.md) | Immutable first-lineage binding for API-verified Eve verification requests. It grants no authority itself. | PK (tenant_id, operation_id); unique (tenant_id, idempotency_key); RLS | `control_plane` |

## Functions

[`temporal.emit_outbox`](../functions/temporal/emit_outbox.md)

## Named queries

[`q:knowledge.head`](../queries/README.md)

## Tasks

[`check-knowledge-head`](../tasks/check-knowledge-head.md)

Schemas: [`knowledge_service`](../schemas/knowledge_service/README.md).
