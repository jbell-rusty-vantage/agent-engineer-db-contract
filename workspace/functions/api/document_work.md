---
id: "fn:api.document_work(uuid)"
kind: function
schema: api
name: document_work
domain: api-surface
lens: corpus
overloads: ["fn:api.document_work(uuid)"]
security: definer
volatility: stable
executors: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [catalog.work, content.document, content.document_about_entity], writes: [] }
tokens: [api, document_work, api.document_work]
defined_in: ["20261110140000_build08_loop3_libraries_talks_capabilities.sql"]
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# api.document_work

Domain `api-surface`, lens `corpus`. Used by views: [`api.digest_items`](../../relations/api/digest_items.md).

## document_work(uuid) → uuid

function, stable, security definer, language sql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_document` | `uuid` | — | — |

Execute: `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`catalog.work`](../../relations/catalog/work.md), [`content.document`](../../relations/content/document.md), [`content.document_about_entity`](../../relations/content/document_about_entity.md); writes —; calls —.

TypeScript: `Database["api"]["Functions"]["document_work"]`.

Defined in: `20261110140000_build08_loop3_libraries_talks_capabilities.sql`.
