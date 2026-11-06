---
id: "rel:knowledge_service.operation"
kind: table
schema: knowledge_service
name: operation
domain: knowledge-service-runtime
aliases: [KS operation]
tokens: [knowledge_service, operation, knowledge_service.operation, id, tenant_id, operation_kind, idempotency_key, ownership_mode, external_run_id, mission_id, work_item_id, attempt_id, correlation_id, causation_id, actor_identity, capability_version_id, request, request_sha256, status, row_version, created_at, updated_at, completed_at]
summary: Durable knowledge-service operation with ownership_mode and idempotency_key.
summary_basis: curated
rls: enabled
readers: [control_plane, executor_service, service_role]
writers: [control_plane, executor_service, service_role]
typescript: "Database[\"knowledge_service\"][\"Tables\"][\"operation\"][\"Row\"]"
defined_in: ["20260903010200_knowledge_runtime_security.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# knowledge_service.operation

table in domain `knowledge-service-runtime`.

> curated (model_assisted, unreviewed) — Durable knowledge-service operation with ownership_mode and idempotency_key.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id); unique (tenant_id, idempotency_key) |
| 3 | `operation_kind` | `text` | no | — | _curated:_ Includes knowledge_ingestion when the executor applies an intent. |
| 4 | `idempotency_key` | `text` | no | — | unique (tenant_id, idempotency_key) |
| 5 | `ownership_mode` | `text` | no | `'standalone'::text` | _curated:_ standalone, mission_control, or eve. |
| 6 | `external_run_id` | `text` | yes | — | — |
| 7 | `mission_id` | `uuid` | yes | — | — |
| 8 | `work_item_id` | `uuid` | yes | — | — |
| 9 | `attempt_id` | `uuid` | yes | — | — |
| 10 | `correlation_id` | `uuid` | no | — | — |
| 11 | `causation_id` | `uuid` | yes | — | — |
| 12 | `actor_identity` | `text` | no | — | — |
| 13 | `capability_version_id` | `uuid` | yes | — | FK → [`orchestration.capability_version`](../orchestration/capability_version.md).id |
| 14 | `request` | `jsonb` | no | — | — |
| 15 | `request_sha256` | `text` | no | — | — |
| 16 | `status` | `text` | no | `'queued'::text` | — |
| 17 | `row_version` | `bigint` | no | `0` | — |
| 18 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 19 | `updated_at` | `timestamp with time zone` | no | `now()` | — |
| 20 | `completed_at` | `timestamp with time zone` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, idempotency_key)
- check `operation_check`: `((status = ANY (ARRAY['succeeded'::text, 'failed'::text, 'cancelled'::text, 'superseded'::text])) = (completed_at IS NOT NULL))`
- check `operation_ownership_mode_check`: `(ownership_mode = ANY (ARRAY['standalone'::text, 'mission_control'::text, 'eve'::text]))`
- check `operation_request_sha256_check`: `(request_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `operation_status_check`: `(status = ANY (ARRAY['proposed'::text, 'queued'::text, 'running'::text, 'needs_review'::text, 'succeeded'::text, 'failed'::text, 'cancelled…`

## Relationships

Outbound: `capability_version_id` → [`orchestration.capability_version`](../orchestration/capability_version.md)`.id` on delete restrict; `tenant_id,attempt_id` → [`orchestration.attempt`](../orchestration/attempt.md)`.tenant_id,id` on delete restrict; `tenant_id,work_item_id` → [`orchestration.work_item`](../orchestration/work_item.md)`.tenant_id,id` on delete restrict.
Inbound: [`content.representation_decision`](../content/representation_decision.md).decision_operation_id, [`evaluation.verification_benchmark_arm_publication`](../evaluation/verification_benchmark_arm_publication.md).operation_id, [`evaluation.verification_benchmark_comparison`](../evaluation/verification_benchmark_comparison.md).operation_id, [`evaluation.verification_benchmark_run`](../evaluation/verification_benchmark_run.md).operation_id, [`evidence.source_capture`](../evidence/source_capture.md).knowledge_operation_id, [`knowledge_service.callback_delivery`](callback_delivery.md).operation_id, [`knowledge_service.operation_event`](operation_event.md).operation_id, [`knowledge_service.operation_step`](operation_step.md).operation_id, [`knowledge_service.outbox`](outbox.md).operation_id, [`knowledge_service.receipt`](receipt.md).operation_id, [`knowledge_service.review_decision`](review_decision.md).decision_operation_id, [`knowledge_service.review_subject`](review_subject.md).operation_id … 16 more in [details](operation.details.md).

## Indexes

3 indexes; see [details](operation.details.md).

## Triggers

6 triggers; see [details](operation.details.md).

## Row-level security

Enabled; 1 policies in [details](operation.details.md).

## Grants

`control_plane`: INSERT, SELECT, UPDATE; `executor_service`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`.

## Write path

- Direct DML: `control_plane`, `executor_service`.
- Via functions (best effort): [`temporal.emit_outbox`](../../functions/temporal/emit_outbox.md).

## TypeScript

insert: `Database["knowledge_service"]["Tables"]["operation"]["Insert"]`; row: `Database["knowledge_service"]["Tables"]["operation"]["Row"]`; update: `Database["knowledge_service"]["Tables"]["operation"]["Update"]`

## Examples

Head after an operation

```bash
knowledge db query knowledge.head
```
A sealed knowledge_ingestion increments knowledge_seq by one.

Defined in: `20260903010200_knowledge_runtime_security.sql`.
