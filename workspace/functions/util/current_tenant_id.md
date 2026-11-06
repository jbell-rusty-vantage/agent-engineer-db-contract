---
id: "fn:util.current_tenant_id()"
kind: function
schema: util
name: current_tenant_id
domain: api-surface
overloads: ["fn:util.current_tenant_id()"]
security: invoker
volatility: stable
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [], writes: [] }
tokens: [util, current_tenant_id, util.current_tenant_id]
defined_in: ["20260826001550_rls_policies.sql", "20260903010200_knowledge_runtime_security.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# util.current_tenant_id

Domain `api-surface`.

## current_tenant_id() → uuid

function, stable, security invoker, language plpgsql, config `search_path=""`. Active tenant for RLS: the app.tenant_id GUC when set, else the single default tenant.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Named queries: `q:artifacts.by_type`, `q:entity.by_identifier`, `q:entity.typed_row`, `q:evidence.captures_for_source`, `q:evidence.claim_support`, `q:evidence.claims_for_entity`, `q:evidence.sources_by_domain`, `q:facts.history_for_stream`, `q:receipts.for_intent`, `q:receipts.recent_for_mission`, `q:reports.artifacts`, `q:reports.assertions`, `q:reports.dependencies`, `q:reports.questions`, `q:reports.sections`, `q:reports.versions`, `q:staging.candidates_for_kind`, `q:staging.unresolved`.

TypeScript: `Database["util"]["Functions"]["current_tenant_id"]`.

Defined in: `20260826001550_rls_policies.sql`, `20260903010200_knowledge_runtime_security.sql`.
