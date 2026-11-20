---
id: "fn:util.current_tenant_id()"
kind: function
schema: util
name: current_tenant_id
domain: api-surface
lens: machinery
overloads: ["fn:util.current_tenant_id()"]
security: definer
volatility: stable
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [], writes: [] }
tokens: [util, current_tenant_id, util.current_tenant_id]
defined_in: ["20260826001550_rls_policies.sql", "20260903010200_knowledge_runtime_security.sql", "20261115130000_build08_d82_signed_in_knowledge_reads.sql"]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# util.current_tenant_id

Domain `api-surface`, lens `machinery`. Used by views: [`api.advisories`](../../relations/api/advisories.md), [`api.api_symbols`](../../relations/api/api_symbols.md), [`api.benchmark_scores`](../../relations/api/benchmark_scores.md), [`api.benchmarks`](../../relations/api/benchmarks.md), [`api.bundle_files`](../../relations/api/bundle_files.md), [`api.capabilities`](../../relations/api/capabilities.md), [`api.claim_candidates`](../../relations/api/claim_candidates.md), [`api.claim_conflicts`](../../relations/api/claim_conflicts.md), [`api.claim_surfaces`](../../relations/api/claim_surfaces.md), [`api.claim_triage`](../../relations/api/claim_triage.md), [`api.compute_devices`](../../relations/api/compute_devices.md), [`api.compute_offerings`](../../relations/api/compute_offerings.md), [`api.concepts`](../../relations/api/concepts.md), [`api.digest_items`](../../relations/api/digest_items.md), [`api.endpoints`](../../relations/api/endpoints.md), [`api.events`](../../relations/api/events.md), [`api.guidance_items`](../../relations/api/guidance_items.md), [`api.hook_entries`](../../relations/api/hook_entries.md), [`api.mcp_prompts`](../../relations/api/mcp_prompts.md), [`api.mcp_resources`](../../relations/api/mcp_resources.md), [`api.mcp_tools`](../../relations/api/mcp_tools.md), [`api.organizations`](../../relations/api/organizations.md), [`api.papers`](../../relations/api/papers.md), [`api.people`](../../relations/api/people.md), [`api.protocol_versions`](../../relations/api/protocol_versions.md), [`api.registry_listings`](../../relations/api/registry_listings.md), [`api.software`](../../relations/api/software.md), [`api.software_releases`](../../relations/api/software_releases.md), [`api.symbol_docs`](../../relations/api/symbol_docs.md), [`api.talks`](../../relations/api/talks.md), [`api.verified_claims`](../../relations/api/verified_claims.md).

## current_tenant_id() → uuid

function, stable, security definer, language plpgsql, config `search_path=""`. Active tenant: the app.tenant_id setting when set; a malformed or nil value resolves to NULL. Without the setting it resolves to NULL (tenant predicates match no rows), except for a PostgREST session of role authenticated whose verified JWT carries role authenticated and a subject: that session reads the single deployment tenant, util.default_tenant_id() (Build 08 D-82).

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads —; writes —; calls [`util.default_tenant_id`](default_tenant_id.md).

Named queries: `q:acquisition.fetches_for_url`, `q:acquisition.open_sweeps`, `q:artifacts.by_type`, `q:chain.governed_writes`, `q:content.refresh_checks`, `q:content.unit_changes`, `q:entity.attributes`, `q:entity.by_identifier`, `q:evidence.captures_for_source`, `q:evidence.claim_support`, `q:evidence.claims_for_entity`, `q:evidence.sources_by_domain`, `q:facts.history_for_stream`, `q:receipts.for_intent`, `q:receipts.recent_for_mission`, `q:staging.candidates_for_kind`, `q:staging.unresolved`.

TypeScript: `Database["util"]["Functions"]["current_tenant_id"]`.

Defined in: `20260826001550_rls_policies.sql`, `20260903010200_knowledge_runtime_security.sql`, `20261115130000_build08_d82_signed_in_knowledge_reads.sql`.
