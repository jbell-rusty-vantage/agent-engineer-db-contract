---
id: "fn:api.talks_about(uuid)"
kind: function
schema: api
name: talks_about
domain: content
lens: corpus
overloads: ["fn:api.talks_about(uuid)"]
security: definer
volatility: stable
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [api.digest_items, catalog.work, content.document, content.document_about_entity, content.document_node, content.document_representation, content.document_version, content.unit_entity_role], writes: [] }
tokens: [api, talks_about, api.talks_about]
defined_in: ["20261110140000_build08_loop3_libraries_talks_capabilities.sql"]
workspace_fingerprint: "sha256:fbf5703bf7a6f6131c452444ee949f1feec1bbe813c78d772fb3886b510815b9"
---
# api.talks_about

Domain `content`, lens `corpus`.

## talks_about(uuid) → TABLE(talk_id uuid, talk text, level text, entity_role text, item_kind text, text text, start_ms integer, end_ms integer, deep_link text, item_id uuid, node_id uuid, document_id uuid)

function, stable, security definer, language sql, config `search_path=""`. Two levels in one call: level document/summary = the talk is about the entity in a stated role (document_about_entity, digest items of kind entity_role); level passage = the entity is mentioned in that transcript segment (unit_entity_role), with timecode and deep link.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_entity` | `uuid` | — | — |

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`api.digest_items`](../../relations/api/digest_items.md), [`catalog.work`](../../relations/catalog/work.md), [`content.document`](../../relations/content/document.md), [`content.document_about_entity`](../../relations/content/document_about_entity.md), [`content.document_node`](../../relations/content/document_node.md), [`content.document_representation`](../../relations/content/document_representation.md), [`content.document_version`](../../relations/content/document_version.md), [`content.unit_entity_role`](../../relations/content/unit_entity_role.md); writes —; calls [`api.document_work`](document_work.md), [`api.timecode_link`](timecode_link.md), [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["api"]["Functions"]["talks_about"]`.

Defined in: `20261110140000_build08_loop3_libraries_talks_capabilities.sql`.
