---
id: "fn:temporal.begin_batch(int8)"
kind: function
schema: temporal
name: begin_batch
domain: temporal-facts
overloads: ["fn:temporal.begin_batch(int8)"]
security: definer
volatility: volatile
executors: [executor_service, service_role]
raises: [knowledge batch already open, rebase_required]
touches: { reads: [], writes: [temporal.knowledge_head] }
tokens: [temporal, begin_batch, temporal.begin_batch]
defined_in: ["20260912010400_km_04_temporal.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# temporal.begin_batch

Domain `temporal-facts`.

## begin_batch(bigint) → bigint

function, volatile, security definer, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_expected_head` | `bigint` | `NULL::bigint` | — |

Execute: `executor_service`, `service_role`.

Raises (mechanically extracted): `knowledge batch already open`; `rebase_required`.

Touches (best effort): reads —; writes [`temporal.knowledge_head`](../../relations/temporal/knowledge_head.md); calls [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["temporal"]["Functions"]["begin_batch"]`.

Defined in: `20260912010400_km_04_temporal.sql`.
