---
id: "fn:api.knowledge_head()"
kind: function
schema: api
name: knowledge_head
domain: api-surface
lens: corpus
overloads: ["fn:api.knowledge_head()"]
security: definer
volatility: stable
executors: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [temporal.knowledge_head], writes: [] }
tokens: [api, knowledge_head, api.knowledge_head]
defined_in: ["20260912020000_km_13_knowledge_intents.sql"]
workspace_fingerprint: "sha256:fbf5703bf7a6f6131c452444ee949f1feec1bbe813c78d772fb3886b510815b9"
---
# api.knowledge_head

Domain `api-surface`, lens `corpus`.

## knowledge_head() → TABLE(knowledge_seq bigint, updated_at timestamp with time zone)

function, stable, security definer, language sql, config `search_path=""`. Current tenant knowledge sequence and its last update; 0 when no batch has been sealed.

No arguments.

Execute: `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`temporal.knowledge_head`](../../relations/temporal/knowledge_head.md); writes —; calls [`util.current_tenant_id`](../util/current_tenant_id.md).

Named queries: `q:knowledge.head`.

TypeScript: `Database["api"]["Functions"]["knowledge_head"]`.

Defined in: `20260912020000_km_13_knowledge_intents.sql`.
