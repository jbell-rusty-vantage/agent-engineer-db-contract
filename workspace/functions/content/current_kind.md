---
id: "fn:content.current_kind(uuid)"
kind: function
schema: content
name: current_kind
domain: content
lens: corpus
overloads: ["fn:content.current_kind(uuid)"]
security: invoker
volatility: stable
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [content.document, content.document_kind_assignment], writes: [] }
tokens: [content, current_kind, content.current_kind]
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", part2_content.sql]
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# content.current_kind

Domain `content`, lens `corpus`.

## current_kind(uuid) → text

function, stable, security invoker, language sql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_document` | `uuid` | — | — |

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`content.document`](../../relations/content/document.md), [`content.document_kind_assignment`](../../relations/content/document_kind_assignment.md); writes —; calls —.

TypeScript: `Database["content"]["Functions"]["current_kind"]`.

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `part2_content.sql`.
