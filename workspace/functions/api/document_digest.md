---
id: "fn:api.document_digest(uuid)"
kind: function
schema: api
name: document_digest
domain: api-surface
lens: corpus
overloads: ["fn:api.document_digest(uuid)"]
security: definer
volatility: stable
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [catalog.entity, content.digest_item, content.document_digest, content.document_version], writes: [] }
tokens: [api, document_digest, api.document_digest]
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", part4_views_seeds.sql]
workspace_fingerprint: "sha256:fbf5703bf7a6f6131c452444ee949f1feec1bbe813c78d772fb3886b510815b9"
---
# api.document_digest

Domain `api-surface`, lens `corpus`.

## document_digest(uuid) → TABLE(digest_id uuid, version_label text, scope text, producer_kind text, ordinal integer, item_kind text, text text, payload jsonb, entity text, node_ids uuid[], claim_id uuid, confidence numeric)

function, stable, security definer, language sql, config `search_path=""`. The structured digest of a document's newest version: key points, entity roles, assertion references, changes, open questions and research directions, each anchored to units.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_document` | `uuid` | — | — |

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`catalog.entity`](../../relations/catalog/entity.md), [`content.digest_item`](../../relations/content/digest_item.md), [`content.document_digest`](../../relations/content/document_digest.md), [`content.document_version`](../../relations/content/document_version.md); writes —; calls [`util.current_tenant_id`](../util/current_tenant_id.md).

Named queries: `q:content.document_digest`.

TypeScript: `Database["api"]["Functions"]["document_digest"]`.

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `part4_views_seeds.sql`.
