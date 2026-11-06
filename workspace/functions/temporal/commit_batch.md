---
id: "fn:temporal.commit_batch(uuid,text,text,jsonb)"
kind: function
schema: temporal
name: commit_batch
domain: temporal-facts
overloads: ["fn:temporal.commit_batch(uuid,text,text,jsonb)"]
security: definer
volatility: volatile
executors: [executor_service, service_role]
raises: [no open knowledge batch, receipt tenant mismatch, stream slot/payload rules violated]
touches: { reads: [orchestration.operation_intent, orchestration.operation_receipt, temporal.segment, temporal.stream, temporal.stream_kind], writes: [temporal.knowledge_batch, temporal.knowledge_head] }
tokens: [temporal, commit_batch, temporal.commit_batch]
defined_in: ["20260912010400_km_04_temporal.sql", "20260912011200_km_12_projection_workers.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# temporal.commit_batch

Domain `temporal-facts`.

## commit_batch(uuid, text, text, jsonb) → bigint

function, volatile, security definer, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_receipt` | `uuid` | — | — |
| `p_idempotency_key` | `text` | — | — |
| `p_input_digest` | `text` | — | — |
| `p_summary` | `jsonb` | `'{}'::jsonb` | — |

Execute: `executor_service`, `service_role`.

Raises (mechanically extracted): `no open knowledge batch`; `receipt tenant mismatch`; `stream slot/payload rules violated`.

Touches (best effort): reads [`orchestration.operation_intent`](../../relations/orchestration/operation_intent.md), [`orchestration.operation_receipt`](../../relations/orchestration/operation_receipt.md), [`temporal.segment`](../../relations/temporal/segment.md), [`temporal.stream`](../../relations/temporal/stream.md), [`temporal.stream_kind`](../../relations/temporal/stream_kind.md); writes [`temporal.knowledge_batch`](../../relations/temporal/knowledge_batch.md), [`temporal.knowledge_head`](../../relations/temporal/knowledge_head.md); calls [`temporal.current_k`](current_k.md), [`temporal.emit_outbox`](emit_outbox.md), [`temporal.payload_valid`](payload_valid.md), [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["temporal"]["Functions"]["commit_batch"]`.

Defined in: `20260912010400_km_04_temporal.sql`, `20260912011200_km_12_projection_workers.sql`.
