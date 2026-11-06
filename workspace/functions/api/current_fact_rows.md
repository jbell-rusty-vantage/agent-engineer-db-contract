---
id: "fn:api.current_fact_rows()"
kind: function
schema: api
name: current_fact_rows
domain: api-surface
overloads: ["fn:api.current_fact_rows()"]
security: definer
volatility: stable
executors: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [temporal.segment, temporal.stream], writes: [] }
tokens: [api, current_fact_rows, api.current_fact_rows]
defined_in: ["20260912011000_km_10_api.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# api.current_fact_rows

Domain `api-surface`. Used by views: [`api.current_facts`](../../relations/api/current_facts.md).

## current_fact_rows() → TABLE(id uuid, tenant_id uuid, stream_id uuid, valid_during tstzrange, belief text, temporal_basis text, status text, amount numeric, currency character, unit text, ref_entity_id uuid, payload jsonb, extent_id uuid, caused_by_event_id uuid, replaces_segment_id uuid, primary_claim_id uuid, k_from bigint, k_to bigint, created_at timestamp with time zone, specification_id uuid, stream_kind text, subject_entity_id uuid, subject_relationship_id uuid, scope_key text)

function, stable, security definer, language sql, config `search_path=""`.

No arguments.

Execute: `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`temporal.segment`](../../relations/temporal/segment.md), [`temporal.stream`](../../relations/temporal/stream.md); writes —; calls [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["api"]["Functions"]["current_fact_rows"]`.

Defined in: `20260912011000_km_10_api.sql`.
