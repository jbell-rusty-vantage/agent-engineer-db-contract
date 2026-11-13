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
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
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
