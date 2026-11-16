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
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# util.default_tenant_id

Domain `api-surface`, lens `machinery`. Used by views: [`api.works_authored`](../../relations/api/works_authored.md).

## default_tenant_id() → uuid

function, immutable, security invoker, language sql, config `search_path=""`. The single tenant. Replace with a session/JWT lookup when multi-tenancy arrives.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

TypeScript: `Database["util"]["Functions"]["default_tenant_id"]`.

Defined in: `20260826000100_foundation.sql`.
