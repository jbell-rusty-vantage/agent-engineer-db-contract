---
id: "fn:api.change_explanation(uuid,uuid,uuid,bool)"
kind: function
schema: api
name: change_explanation
domain: api-surface
lens: corpus
overloads: ["fn:api.change_explanation(uuid,uuid,uuid,bool)"]
security: definer
volatility: stable
executors: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: ["name one fact, one event or one relationship", no such fact, no such relationship]
touches: { reads: [catalog.entity, catalog.relationship, evidence.attribution, evidence.claim, evidence.locator, evidence.segment_support, evidence.source, evidence.source_capture, temporal.correction_reason, temporal.event, temporal.event_occurrence, temporal.segment, temporal.stream], writes: [] }
tokens: [api, change_explanation, api.change_explanation]
defined_in: ["20261119120000_build09_rv01_change_reasons_identity_proposals.sql"]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# api.change_explanation

Domain `api-surface`, lens `corpus`.

## change_explanation(uuid, uuid, uuid, boolean) → jsonb

function, stable, security definer, language plpgsql, config `search_path=""`. Why a fact, an event or a relationship changed, in three separate parts: the cause event; what a source said the reason was (claims with role explains, attributed); and, only when asked, our own proposals, marked ours.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_segment` | `uuid` | `NULL::uuid` | — |
| `p_event` | `uuid` | `NULL::uuid` | — |
| `p_relationship` | `uuid` | `NULL::uuid` | — |
| `p_include_proposals` | `boolean` | `false` | — |

Execute: `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `name one fact, one event or one relationship`; `no such fact`; `no such relationship`.

Touches (best effort): reads [`catalog.entity`](../../relations/catalog/entity.md), [`catalog.relationship`](../../relations/catalog/relationship.md), [`evidence.attribution`](../../relations/evidence/attribution.md), [`evidence.claim`](../../relations/evidence/claim.md), [`evidence.locator`](../../relations/evidence/locator.md), [`evidence.segment_support`](../../relations/evidence/segment_support.md), [`evidence.source`](../../relations/evidence/source.md), [`evidence.source_capture`](../../relations/evidence/source_capture.md), [`temporal.correction_reason`](../../relations/temporal/correction_reason.md), [`temporal.event`](../../relations/temporal/event.md), [`temporal.event_occurrence`](../../relations/temporal/event_occurrence.md), [`temporal.segment`](../../relations/temporal/segment.md), [`temporal.stream`](../../relations/temporal/stream.md); writes —; calls [`api.proposals`](proposals.md), [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["api"]["Functions"]["change_explanation"]`.

Defined in: `20261119120000_build09_rv01_change_reasons_identity_proposals.sql`.
