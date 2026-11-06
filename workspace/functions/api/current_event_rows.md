---
id: "fn:api.current_event_rows()"
kind: function
schema: api
name: current_event_rows
domain: api-surface
overloads: ["fn:api.current_event_rows()"]
security: definer
volatility: stable
executors: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [temporal.event, temporal.event_occurrence], writes: [] }
tokens: [api, current_event_rows, api.current_event_rows]
defined_in: ["20260912011000_km_10_api.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# api.current_event_rows

Domain `api-surface`. Used by views: [`api.events_current`](../../relations/api/events_current.md).

## current_event_rows() → TABLE(event_id uuid, tenant_id uuid, kind text, subject_entity_id uuid, object_entity_id uuid, occurrence_id uuid, occurred_during tstzrange, occurrence_mode text, payload jsonb)

function, stable, security definer, language sql, config `search_path=""`.

No arguments.

Execute: `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`temporal.event`](../../relations/temporal/event.md), [`temporal.event_occurrence`](../../relations/temporal/event_occurrence.md); writes —; calls [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["api"]["Functions"]["current_event_rows"]`.

Defined in: `20260912011000_km_10_api.sql`.
