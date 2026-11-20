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
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
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
