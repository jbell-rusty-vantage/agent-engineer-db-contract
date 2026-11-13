---
id: "fn:temporal.assert_state(uuid,text,tstzrange,text,text,numeric,text,text,uuid,jsonb,uuid,uuid,text,uuid,text)"
kind: function
schema: temporal
name: assert_state
domain: temporal-facts
lens: corpus
overloads: ["fn:temporal.assert_state(uuid,text,tstzrange,text,text,numeric,text,text,uuid,jsonb,uuid,uuid,text,uuid,text)"]
security: definer
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [entity stream cannot target relationship, no open knowledge batch, relationship stream cannot target entity, stream does not admit entity kind, stream does not admit relationship kind]
touches: { reads: [catalog.entity, catalog.relationship, taxonomy.relationship_kind, temporal.stream_kind], writes: [temporal.segment, temporal.stream] }
tokens: [temporal, assert_state, temporal.assert_state]
defined_in: ["20260912010400_km_04_temporal.sql", "20261108120000_build08_r2_knowledge_continuum.sql", part1_renames.sql]
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
---
# temporal.assert_state

Domain `temporal-facts`, lens `corpus`.

## assert_state(uuid, text, tstzrange, text, text, numeric, text, text, uuid, jsonb, uuid, uuid, text, uuid, text) → uuid

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

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `entity stream cannot target relationship`; `no open knowledge batch`; `relationship stream cannot target entity`; `stream does not admit entity kind`; `stream does not admit relationship kind`.

Touches (best effort): reads [`catalog.entity`](../../relations/catalog/entity.md), [`catalog.relationship`](../../relations/catalog/relationship.md), [`taxonomy.relationship_kind`](../../relations/taxonomy/relationship_kind.md), [`temporal.stream_kind`](../../relations/temporal/stream_kind.md); writes [`temporal.segment`](../../relations/temporal/segment.md), [`temporal.stream`](../../relations/temporal/stream.md); calls [`temporal.close_segment`](close_segment.md), [`temporal.current_k`](current_k.md), [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["temporal"]["Functions"]["assert_state"]`.

Defined in: `20260912010400_km_04_temporal.sql`, `20261108120000_build08_r2_knowledge_continuum.sql`, `part1_renames.sql`.
