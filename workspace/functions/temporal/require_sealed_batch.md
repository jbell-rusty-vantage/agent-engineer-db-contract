---
id: "fn:temporal.require_sealed_batch()"
kind: function
schema: temporal
name: require_sealed_batch
domain: temporal-facts
lens: machinery
overloads: ["fn:temporal.require_sealed_batch()"]
security: invoker
volatility: volatile
executors: [executor_service, service_role]
raises: [unsealed knowledge batch]
touches: { reads: [temporal.knowledge_batch], writes: [] }
tokens: [temporal, require_sealed_batch, temporal.require_sealed_batch]
defined_in: ["20260912010400_km_04_temporal.sql"]
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
---
# temporal.require_sealed_batch

Domain `temporal-facts`, lens `machinery`.

## require_sealed_batch() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `executor_service`, `service_role`.

Raises (mechanically extracted): `unsealed knowledge batch`.

Touches (best effort): reads [`temporal.knowledge_batch`](../../relations/temporal/knowledge_batch.md); writes —; calls —.

Defined in: `20260912010400_km_04_temporal.sql`.
