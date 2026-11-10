---
id: "fn:util.current_tenant_id()"
kind: function
schema: util
name: current_tenant_id
domain: api-surface
lens: machinery
overloads: ["fn:util.current_tenant_id()"]
security: invoker
volatility: stable
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [], writes: [] }
tokens: [util, current_tenant_id, util.current_tenant_id]
defined_in: ["20260826001550_rls_policies.sql", "20260903010200_knowledge_runtime_security.sql"]
workspace_fingerprint: "sha256:027ab2b6133d5d59318c478f06d832d89f937e563c387539f37fb3d7668818a8"
---
# util.current_tenant_id

Domain `api-surface`, lens `machinery`. Used by views: [`api.advisories`](../../relations/api/advisories.md), [`api.api_symbols`](../../relations/api/api_symbols.md), [`api.benchmark_scores`](../../relations/api/benchmark_scores.md), [`api.benchmarks`](../../relations/api/benchmarks.md), [`api.claim_candidates`](../../relations/api/claim_candidates.md), [`api.claim_conflicts`](../../relations/api/claim_conflicts.md), [`api.compute_devices`](../../relations/api/compute_devices.md), [`api.compute_offerings`](../../relations/api/compute_offerings.md), [`api.concepts`](../../relations/api/concepts.md), [`api.endpoints`](../../relations/api/endpoints.md), [`api.events`](../../relations/api/events.md), [`api.guidance_items`](../../relations/api/guidance_items.md), [`api.organizations`](../../relations/api/organizations.md), [`api.papers`](../../relations/api/papers.md), [`api.people`](../../relations/api/people.md), [`api.protocol_versions`](../../relations/api/protocol_versions.md), [`api.registry_listings`](../../relations/api/registry_listings.md), [`api.software`](../../relations/api/software.md), [`api.software_releases`](../../relations/api/software_releases.md), [`api.talks`](../../relations/api/talks.md).

## current_tenant_id() → uuid

function, stable, security invoker, language plpgsql, config `search_path=""`. Active tenant for RLS: the app.tenant_id GUC when set, else the single default tenant.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Named queries: `q:acquisition.fetches_for_url`, `q:artifacts.by_type`, `q:content.refresh_checks`, `q:content.unit_changes`, `q:entity.attributes`, `q:entity.by_identifier`, `q:evidence.captures_for_source`, `q:evidence.claim_support`, `q:evidence.claims_for_entity`, `q:evidence.sources_by_domain`, `q:facts.history_for_stream`, `q:receipts.for_intent`, `q:receipts.recent_for_mission`, `q:staging.candidates_for_kind`, `q:staging.unresolved`.

TypeScript: `Database["util"]["Functions"]["current_tenant_id"]`.

Defined in: `20260826001550_rls_policies.sql`, `20260903010200_knowledge_runtime_security.sql`.
