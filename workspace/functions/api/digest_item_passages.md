---
id: "fn:api.digest_item_passages(uuid)"
kind: function
schema: api
name: digest_item_passages
domain: content
lens: corpus
overloads: ["fn:api.digest_item_passages(uuid)"]
security: definer
volatility: stable
executors: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [catalog.work, content.digest_item, content.document, content.document_node, content.document_representation, content.document_version], writes: [] }
tokens: [api, digest_item_passages, api.digest_item_passages]
defined_in: ["20261110140000_build08_loop3_libraries_talks_capabilities.sql"]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# api.digest_item_passages

Domain `content`, lens `corpus`.

## digest_item_passages(uuid) → TABLE(node_id uuid, unit_kind text, start_ms integer, end_ms integer, text text, logical_key text, document_id uuid, deep_link text)

function, stable, security definer, language sql, config `search_path=""`. Open the passage behind a digest item: its anchor units in source order, with a timecode deep link for talks.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_item` | `uuid` | — | — |

Execute: `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`catalog.work`](../../relations/catalog/work.md), [`content.digest_item`](../../relations/content/digest_item.md), [`content.document`](../../relations/content/document.md), [`content.document_node`](../../relations/content/document_node.md), [`content.document_representation`](../../relations/content/document_representation.md), [`content.document_version`](../../relations/content/document_version.md); writes —; calls [`api.document_work`](document_work.md), [`api.timecode_link`](timecode_link.md), [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["api"]["Functions"]["digest_item_passages"]`.

Defined in: `20261110140000_build08_loop3_libraries_talks_capabilities.sql`.
