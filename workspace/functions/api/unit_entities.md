---
id: "fn:api.unit_entities(uuid)"
kind: function
schema: api
name: unit_entities
domain: content
lens: corpus
overloads: ["fn:api.unit_entities(uuid)"]
security: definer
volatility: stable
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [catalog.entity, content.unit_entity_role], writes: [] }
tokens: [api, unit_entities, api.unit_entities]
defined_in: ["20261110140000_build08_loop3_libraries_talks_capabilities.sql", "20261110140200_build08_loop3_fixups2.sql"]
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# api.unit_entities

Domain `content`, lens `corpus`.

## unit_entities(uuid) → TABLE(entity_id uuid, entity text, entity_kind text, role text, method text, confidence numeric)

function, stable, security definer, language sql, config `search_path=""`. L3 full-content level: the entities one unit (transcript segment, docs section, symbol, file) names or belongs to, with the role and how the link was made.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_node` | `uuid` | — | — |

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`catalog.entity`](../../relations/catalog/entity.md), [`content.unit_entity_role`](../../relations/content/unit_entity_role.md); writes —; calls [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["api"]["Functions"]["unit_entities"]`.

Defined in: `20261110140000_build08_loop3_libraries_talks_capabilities.sql`, `20261110140200_build08_loop3_fixups2.sql`.
