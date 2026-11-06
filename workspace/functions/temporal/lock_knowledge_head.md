---
id: "fn:temporal.lock_knowledge_head(int8)"
kind: function
schema: temporal
name: lock_knowledge_head
domain: temporal-facts
overloads: ["fn:temporal.lock_knowledge_head(int8)"]
security: definer
volatility: volatile
executors: [executor_service, service_role]
raises: [expected knowledge head required, knowledge batch already open, rebase_required]
touches: { reads: [], writes: [temporal.knowledge_head] }
tokens: [temporal, lock_knowledge_head, temporal.lock_knowledge_head]
defined_in: ["20260914010900_content_link_head_lock.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# temporal.lock_knowledge_head

Domain `temporal-facts`.

## lock_knowledge_head(bigint) → bigint

function, volatile, security definer, language plpgsql, config `search_path=""`. Lock the current tenant knowledge clock through transaction end without opening or advancing a batch; exact expected head required.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_expected_head` | `bigint` | — | — |

Execute: `executor_service`, `service_role`.

Raises (mechanically extracted): `expected knowledge head required`; `knowledge batch already open`; `rebase_required`.

Touches (best effort): reads —; writes [`temporal.knowledge_head`](../../relations/temporal/knowledge_head.md); calls [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["temporal"]["Functions"]["lock_knowledge_head"]`.

Defined in: `20260914010900_content_link_head_lock.sql`.
