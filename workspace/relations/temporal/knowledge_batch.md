---
id: "rel:temporal.knowledge_batch"
kind: table
schema: temporal
name: knowledge_batch
domain: temporal-facts
aliases: [sealed batch]
tokens: [temporal, knowledge_batch, temporal.knowledge_batch, tenant_id, knowledge_seq, recorded_at, receipt_id, operation_id, idempotency_key, input_digest, summary]
summary: "One sealed admission transaction with receipt, idempotency key, and input digest."
summary_basis: curated
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"temporal\"][\"Tables\"][\"knowledge_batch\"][\"Row\"]"
defined_in: ["20260912010400_km_04_temporal.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# temporal.knowledge_batch

table in domain `temporal-facts`.

> curated (model_assisted, unreviewed) — One sealed admission transaction with receipt, idempotency key, and input digest.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | PK; unique (tenant_id, idempotency_key) |
| 2 | `knowledge_seq` | `bigint` | no | — | PK |
| 3 | `recorded_at` | `timestamp with time zone` | no | `now()` | — |
| 4 | `receipt_id` | `uuid` | no | — | FK → [`orchestration.operation_receipt`](../orchestration/operation_receipt.md).id; _curated:_ Not null FK to orchestration.operation_receipt; required before facts can exist. |
| 5 | `operation_id` | `uuid` | yes | — | FK → [`knowledge_service.operation`](../knowledge_service/operation.md).id |
| 6 | `idempotency_key` | `text` | no | — | unique (tenant_id, idempotency_key); _curated:_ Unique per tenant; duplicate submits reuse this batch. |
| 7 | `input_digest` | `text` | no | — | _curated:_ 64 lowercase hex chars of the intent digest. |
| 8 | `summary` | `jsonb` | no | `'{}'::jsonb` | — |

## Constraints

- PK (tenant_id, knowledge_seq)
- unique (tenant_id, idempotency_key)
- check `knowledge_batch_input_digest_check`: `(input_digest ~ '^[0-9a-f]{64}$'::text)`

## Relationships

Outbound: `operation_id` → [`knowledge_service.operation`](../knowledge_service/operation.md)`.id` (+tenant); `receipt_id` → [`orchestration.operation_receipt`](../orchestration/operation_receipt.md)`.id`.
Inbound: none.

## Indexes

`knowledge_batch_tenant_id_idempotency_key_key` unique

## Triggers

_None._

## Row-level security

Enabled.
- `km_tenant_access` (ALL) for `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: SELECT; `executor_service`: SELECT; `pipeline_agent`: SELECT; `service_role`: SELECT; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Named queries: `q:receipts.for_intent`, `q:receipts.recent_for_mission`.
- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- No direct DML for any agent role.
- Via functions (best effort): [`temporal.commit_batch`](../../functions/temporal/commit_batch.md).

## TypeScript

insert: `Database["temporal"]["Tables"]["knowledge_batch"]["Insert"]`; row: `Database["temporal"]["Tables"]["knowledge_batch"]["Row"]`; update: `Database["temporal"]["Tables"]["knowledge_batch"]["Update"]`

## Examples

Intent plus sealed batch

```bash
knowledge db query receipts.for_intent --param intent_id=0192f000-0000-7000-8000-000000000001
```
Joins on idempotency_key because pipeline_agent cannot select operation_receipt.

Defined in: `20260912010400_km_04_temporal.sql`.
