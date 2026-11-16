---
id: "fn:retrieval.supersede_duplicate_items()"
kind: function
schema: retrieval
name: supersede_duplicate_items
domain: retrieval
lens: corpus
overloads: ["fn:retrieval.supersede_duplicate_items()"]
security: definer
volatility: volatile
executors: [control_plane, pipeline_agent, service_role]
raises: []
touches: { reads: [retrieval.projection_target], writes: [retrieval.vector_item] }
tokens: [retrieval, supersede_duplicate_items, retrieval.supersede_duplicate_items]
defined_in: ["20261110140000_build08_loop3_libraries_talks_capabilities.sql"]
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# retrieval.supersede_duplicate_items

Domain `retrieval`, lens `corpus`.

## supersede_duplicate_items() → integer

function, volatile, security definer, language plpgsql, config `search_path=""`. Repair for D-40 (Build 08 loop 2): keeps the newest active vector item per target and space and marks the older ones superseded. Idempotent.

No arguments.

Execute: `control_plane`, `pipeline_agent`, `service_role`.

Touches (best effort): reads [`retrieval.projection_target`](../../relations/retrieval/projection_target.md); writes [`retrieval.vector_item`](../../relations/retrieval/vector_item.md); calls —.

TypeScript: `Database["retrieval"]["Functions"]["supersede_duplicate_items"]`.

Defined in: `20261110140000_build08_loop3_libraries_talks_capabilities.sql`.
