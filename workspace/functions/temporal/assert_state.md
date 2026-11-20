---
id: "fn:temporal.assert_state(uuid,text,tstzrange,text,text,numeric,text,text,uuid,jsonb,uuid,uuid,text,uuid,text,text,text,uuid)"
kind: function
schema: temporal
name: assert_state
domain: temporal-facts
lens: corpus
overloads: ["fn:temporal.assert_state(uuid,text,tstzrange,text,text,numeric,text,text,uuid,jsonb,uuid,uuid,text,uuid,text,text,text,uuid)"]
security: definer
volatility: volatile
executors: [executor_service, service_role]
raises: [a correction reason belongs to a correction, a world change cannot rewrite the start of the fact it replaces, correction requires a reason, entity stream cannot target relationship, no open knowledge batch, relationship stream cannot target entity, revision kind is world_change or correction, stream does not admit entity kind, stream does not admit relationship kind]
touches: { reads: [catalog.entity, catalog.relationship, taxonomy.relationship_kind, temporal.correction_reason, temporal.stream_kind], writes: [temporal.segment, temporal.stream] }
tokens: [temporal, assert_state, temporal.assert_state]
defined_in: ["20260912010400_km_04_temporal.sql", "20261108120000_build08_r2_knowledge_continuum.sql", "20261119120000_build09_rv01_change_reasons_identity_proposals.sql", part1_renames.sql]
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# temporal.assert_state

Domain `temporal-facts`, lens `corpus`.

## assert_state(uuid, text, tstzrange, text, text, numeric, text, text, uuid, jsonb, uuid, uuid, text, uuid, text, text, text, uuid) → uuid

function, volatile, security definer, language plpgsql, config `search_path=""`. Assert a fact. A replacement is a world_change (the new fact starts later than the one it replaces; may name p_caused_by_event) or a correction (it rewrites the past; p_correction_reason required). Saying nothing is allowed only for a world change.

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
| `p_revision_kind` | `text` | `NULL::text` | — |
| `p_correction_reason` | `text` | `NULL::text` | — |
| `p_caused_by_event` | `uuid` | `NULL::uuid` | — |

Execute: `executor_service`, `service_role`.

Raises (mechanically extracted): `a correction reason belongs to a correction`; `a world change cannot rewrite the start of the fact it replaces`; `correction requires a reason`; `entity stream cannot target relationship`; `no open knowledge batch`; `relationship stream cannot target entity`; `revision kind is world_change or correction`; `stream does not admit entity kind`; `stream does not admit relationship kind`.

Touches (best effort): reads [`catalog.entity`](../../relations/catalog/entity.md), [`catalog.relationship`](../../relations/catalog/relationship.md), [`taxonomy.relationship_kind`](../../relations/taxonomy/relationship_kind.md), [`temporal.correction_reason`](../../relations/temporal/correction_reason.md), [`temporal.stream_kind`](../../relations/temporal/stream_kind.md); writes [`temporal.segment`](../../relations/temporal/segment.md), [`temporal.stream`](../../relations/temporal/stream.md); calls [`temporal.close_segment`](close_segment.md), [`temporal.current_k`](current_k.md), [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["temporal"]["Functions"]["assert_state"]`.

Defined in: `20260912010400_km_04_temporal.sql`, `20261108120000_build08_r2_knowledge_continuum.sql`, `20261119120000_build09_rv01_change_reasons_identity_proposals.sql`, `part1_renames.sql`.
