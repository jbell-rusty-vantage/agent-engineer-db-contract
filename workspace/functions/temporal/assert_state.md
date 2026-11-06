---
id: "fn:temporal.assert_state(uuid,text,tstzrange,text,text,numeric,text,text,uuid,jsonb,uuid,uuid,text,uuid,text,uuid)"
kind: function
schema: temporal
name: assert_state
domain: temporal-facts
overloads: ["fn:temporal.assert_state(uuid,text,tstzrange,text,text,numeric,text,text,uuid,jsonb,uuid,uuid,text,uuid,text,uuid)"]
security: definer
volatility: volatile
executors: [executor_service, service_role]
raises: [entity stream cannot target relationship, no open knowledge batch, relationship stream cannot target entity, stream does not admit entity kind, stream does not admit relationship kind]
touches: { reads: [corpus.entity, corpus.relationship, taxonomy.relationship_kind, temporal.stream_kind], writes: [temporal.segment, temporal.stream] }
tokens: [temporal, assert_state, temporal.assert_state]
defined_in: ["20260912010400_km_04_temporal.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# temporal.assert_state

Domain `temporal-facts`.

## assert_state(uuid, text, tstzrange, text, text, numeric, text, text, uuid, jsonb, uuid, uuid, text, uuid, text, uuid) → uuid

function, volatile, security definer, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_entity` | `uuid` | — | — |
| `p_stream_kind` | `text` | — | — |
| `p_valid_during` | `tstzrange` | — | — |
| `p_scope_key` | `text` | `''::text` | — |
| `p_status` | `text` | `NULL::text` | — |
| `p_amount` | `numeric` | `NULL::numeric` | — |
| `p_currency` | `text` | `NULL::text` | — |
| `p_unit` | `text` | `NULL::text` | — |
| `p_ref_entity` | `uuid` | `NULL::uuid` | — |
| `p_payload` | `jsonb` | `'{}'::jsonb` | — |
| `p_extent` | `uuid` | `NULL::uuid` | — |
| `p_claim` | `uuid` | `NULL::uuid` | — |
| `p_temporal_basis` | `text` | `'explicit'::text` | — |
| `p_relationship` | `uuid` | `NULL::uuid` | — |
| `p_belief` | `text` | `'accepted'::text` | — |
| `p_specification` | `uuid` | `NULL::uuid` | — |

Execute: `executor_service`, `service_role`.

Raises (mechanically extracted): `entity stream cannot target relationship`; `no open knowledge batch`; `relationship stream cannot target entity`; `stream does not admit entity kind`; `stream does not admit relationship kind`.

Touches (best effort): reads [`corpus.entity`](../../relations/corpus/entity.md), [`corpus.relationship`](../../relations/corpus/relationship.md), [`taxonomy.relationship_kind`](../../relations/taxonomy/relationship_kind.md), [`temporal.stream_kind`](../../relations/temporal/stream_kind.md); writes [`temporal.segment`](../../relations/temporal/segment.md), [`temporal.stream`](../../relations/temporal/stream.md); calls [`temporal.close_segment`](close_segment.md), [`temporal.current_k`](current_k.md), [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["temporal"]["Functions"]["assert_state"]`.

Defined in: `20260912010400_km_04_temporal.sql`.
