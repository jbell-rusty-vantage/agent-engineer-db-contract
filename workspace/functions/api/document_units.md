---
id: "fn:api.document_units(uuid,text[])"
kind: function
schema: api
name: document_units
domain: api-surface
lens: corpus
overloads: ["fn:api.document_units(uuid,text[])"]
security: definer
volatility: stable
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [content.document, content.document_node, content.document_representation, content.document_version], writes: [] }
tokens: [api, document_units, api.document_units]
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", part4_views_seeds.sql]
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
---
# api.document_units

Domain `api-surface`, lens `corpus`.

## document_units(uuid, text[]) → TABLE(node_id uuid, version_label text, unit_kind text, logical_key text, attributes jsonb, inline_text text, page_number integer, start_ms integer, end_ms integer, stable_local_key text)

function, stable, security definer, language sql, config `search_path=""`. Typed units of a document across its versions (newest first): the structural view a question drills into after the L1 row.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_document` | `uuid` | — | — |
| `p_unit_kinds` | `text[]` | `NULL::text[]` | — |

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`content.document`](../../relations/content/document.md), [`content.document_node`](../../relations/content/document_node.md), [`content.document_representation`](../../relations/content/document_representation.md), [`content.document_version`](../../relations/content/document_version.md); writes —; calls [`util.current_tenant_id`](../util/current_tenant_id.md).

Named queries: `q:content.document_units`.

TypeScript: `Database["api"]["Functions"]["document_units"]`.

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `part4_views_seeds.sql`.
