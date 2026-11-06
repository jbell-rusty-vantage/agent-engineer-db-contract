---
id: "fn:retrieval.history_receipt_k(uuid)"
kind: function
schema: retrieval
name: history_receipt_k
domain: retrieval
overloads: ["fn:retrieval.history_receipt_k(uuid)"]
security: definer
volatility: stable
executors: []
raises: []
touches: { reads: [orchestration.operation_intent, orchestration.operation_receipt, temporal.knowledge_batch], writes: [] }
tokens: [retrieval, history_receipt_k, retrieval.history_receipt_k]
defined_in: ["20260914011100_retrieval_history.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# retrieval.history_receipt_k

Domain `retrieval`.

## history_receipt_k(uuid) → bigint

function, stable, security definer, language sql, config `search_path=""`. Knowledge sequence sealed for an applied canonical receipt; null when the receipt never advanced belief.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_receipt` | `uuid` | — | — |

Execute: no configured role.

Touches (best effort): reads [`orchestration.operation_intent`](../../relations/orchestration/operation_intent.md), [`orchestration.operation_receipt`](../../relations/orchestration/operation_receipt.md), [`temporal.knowledge_batch`](../../relations/temporal/knowledge_batch.md); writes —; calls [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["retrieval"]["Functions"]["history_receipt_k"]`.

Defined in: `20260914011100_retrieval_history.sql`.
