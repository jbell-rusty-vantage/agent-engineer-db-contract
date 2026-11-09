---
id: "fn:temporal.require_closed_head()"
kind: function
schema: temporal
name: require_closed_head
domain: temporal-facts
lens: machinery
overloads: ["fn:temporal.require_closed_head()"]
security: invoker
volatility: volatile
executors: [executor_service, service_role]
raises: [knowledge batch must be sealed before commit]
touches: { reads: [temporal.knowledge_head], writes: [] }
tokens: [temporal, require_closed_head, temporal.require_closed_head]
defined_in: ["20260912010400_km_04_temporal.sql"]
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
---
# temporal.require_closed_head

Domain `temporal-facts`, lens `machinery`.

## require_closed_head() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `executor_service`, `service_role`.

Raises (mechanically extracted): `knowledge batch must be sealed before commit`.

Touches (best effort): reads [`temporal.knowledge_head`](../../relations/temporal/knowledge_head.md); writes —; calls —.

Defined in: `20260912010400_km_04_temporal.sql`.
