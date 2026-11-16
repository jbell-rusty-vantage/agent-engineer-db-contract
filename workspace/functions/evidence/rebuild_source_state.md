---
id: "fn:evidence.rebuild_source_state()"
kind: function
schema: evidence
name: rebuild_source_state
domain: evidence
lens: evidence
overloads: ["fn:evidence.rebuild_source_state()"]
security: definer
volatility: volatile
executors: [executor_service, service_role]
raises: []
touches: { reads: [evidence.source_encounter, temporal.knowledge_head], writes: [evidence.source] }
tokens: [evidence, rebuild_source_state, evidence.rebuild_source_state]
defined_in: ["20260912011200_km_12_projection_workers.sql"]
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# evidence.rebuild_source_state

Domain `evidence`, lens `evidence`.

## rebuild_source_state() → bigint

function, volatile, security definer, language plpgsql, config `search_path=""`.

No arguments.

Execute: `executor_service`, `service_role`.

Touches (best effort): reads [`evidence.source_encounter`](../../relations/evidence/source_encounter.md), [`temporal.knowledge_head`](../../relations/temporal/knowledge_head.md); writes [`evidence.source`](../../relations/evidence/source.md); calls [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["evidence"]["Functions"]["rebuild_source_state"]`.

Defined in: `20260912011200_km_12_projection_workers.sql`.
