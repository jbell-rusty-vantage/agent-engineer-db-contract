---
id: "fn:temporal.assert_event(text,uuid,tstzrange,text,uuid,uuid,text,uuid,uuid,jsonb,text)"
kind: function
schema: temporal
name: assert_event
domain: temporal-facts
lens: corpus
overloads: ["fn:temporal.assert_event(text,uuid,tstzrange,text,uuid,uuid,text,uuid,uuid,jsonb,text)"]
security: definer
volatility: volatile
executors: [executor_service, service_role]
raises: [event object kind mismatch, event subject kind mismatch, no open knowledge batch]
touches: { reads: [catalog.entity, temporal.event_kind], writes: [temporal.event, temporal.event_occurrence] }
tokens: [temporal, assert_event, temporal.assert_event]
defined_in: ["20260912010400_km_04_temporal.sql"]
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# temporal.assert_event

Domain `temporal-facts`, lens `corpus`.

## assert_event(text, uuid, tstzrange, text, uuid, uuid, text, uuid, uuid, jsonb, text) → uuid

function, volatile, security definer, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_kind` | `text` | — | — |
| `p_subject` | `uuid` | — | — |
| `p_occurred_during` | `tstzrange` | — | — |
| `p_mode` | `text` | `'actual'::text` | — |
| `p_object` | `uuid` | `NULL::uuid` | — |
| `p_relationship` | `uuid` | `NULL::uuid` | — |
| `p_dedupe_key` | `text` | `NULL::text` | — |
| `p_extent` | `uuid` | `NULL::uuid` | — |
| `p_claim` | `uuid` | `NULL::uuid` | — |
| `p_payload` | `jsonb` | `'{}'::jsonb` | — |
| `p_belief` | `text` | `'accepted'::text` | — |

Execute: `executor_service`, `service_role`.

Raises (mechanically extracted): `event object kind mismatch`; `event subject kind mismatch`; `no open knowledge batch`.

Touches (best effort): reads [`catalog.entity`](../../relations/catalog/entity.md), [`temporal.event_kind`](../../relations/temporal/event_kind.md); writes [`temporal.event`](../../relations/temporal/event.md), [`temporal.event_occurrence`](../../relations/temporal/event_occurrence.md); calls [`temporal.current_k`](current_k.md), [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["temporal"]["Functions"]["assert_event"]`.

Defined in: `20260912010400_km_04_temporal.sql`.
