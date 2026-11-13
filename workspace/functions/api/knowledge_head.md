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
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
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
