---
id: "fn:api.release_digest(uuid)"
kind: function
schema: api
name: release_digest
domain: content
lens: corpus
overloads: ["fn:api.release_digest(uuid)"]
security: definer
volatility: stable
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [content.digest_item, content.document_digest, content.document_node, content.document_version, content.unit_entity_role], writes: [] }
tokens: [api, release_digest, api.release_digest]
defined_in: ["20261110140000_build08_loop3_libraries_talks_capabilities.sql"]
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# api.release_digest

Domain `content`, lens `corpus`.

## release_digest(uuid) → TABLE(item_id uuid, ordinal integer, item_kind text, text text, change_items jsonb, symbols jsonb, document_id uuid)

function, stable, security definer, language sql, config `search_path=""`. What changed in a release, as digest items anchored to change_item units and to the changed api_symbol units.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_release` | `uuid` | — | — |

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`content.digest_item`](../../relations/content/digest_item.md), [`content.document_digest`](../../relations/content/document_digest.md), [`content.document_node`](../../relations/content/document_node.md), [`content.document_version`](../../relations/content/document_version.md), [`content.unit_entity_role`](../../relations/content/unit_entity_role.md); writes —; calls [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["api"]["Functions"]["release_digest"]`.

Defined in: `20261110140000_build08_loop3_libraries_talks_capabilities.sql`.
