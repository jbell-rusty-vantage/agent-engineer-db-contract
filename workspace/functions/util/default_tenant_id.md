---
id: "fn:util.default_tenant_id()"
kind: function
schema: util
name: default_tenant_id
domain: api-surface
lens: machinery
overloads: ["fn:util.default_tenant_id()"]
security: invoker
volatility: immutable
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [], writes: [] }
tokens: [util, default_tenant_id, util.default_tenant_id]
defined_in: ["20260826000100_foundation.sql"]
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# util.default_tenant_id

Domain `api-surface`, lens `machinery`. Used by views: [`api.works_authored`](../../relations/api/works_authored.md).

## default_tenant_id() → uuid

function, immutable, security invoker, language sql, config `search_path=""`. The single tenant. Replace with a session/JWT lookup when multi-tenancy arrives.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

TypeScript: `Database["util"]["Functions"]["default_tenant_id"]`.

Defined in: `20260826000100_foundation.sql`.
