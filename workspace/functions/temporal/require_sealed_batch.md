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
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
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
