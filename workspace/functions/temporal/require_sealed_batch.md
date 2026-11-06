---
id: "fn:temporal.require_sealed_batch()"
kind: function
schema: temporal
name: require_sealed_batch
domain: temporal-facts
overloads: ["fn:temporal.require_sealed_batch()"]
security: invoker
volatility: volatile
executors: [executor_service, service_role]
raises: [unsealed knowledge batch]
touches: { reads: [temporal.knowledge_batch], writes: [] }
tokens: [temporal, require_sealed_batch, temporal.require_sealed_batch]
defined_in: ["20260912010400_km_04_temporal.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# temporal.require_sealed_batch

Domain `temporal-facts`.

## require_sealed_batch() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `executor_service`, `service_role`.

Raises (mechanically extracted): `unsealed knowledge batch`.

Touches (best effort): reads [`temporal.knowledge_batch`](../../relations/temporal/knowledge_batch.md); writes —; calls —.

Defined in: `20260912010400_km_04_temporal.sql`.
