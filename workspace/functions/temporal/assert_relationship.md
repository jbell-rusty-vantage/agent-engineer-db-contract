---
id: "fn:temporal.assert_relationship(text,uuid,uuid,tstzrange,text,int4,jsonb,uuid,uuid)"
kind: function
schema: temporal
name: assert_relationship
domain: relationships
overloads: ["fn:temporal.assert_relationship(text,uuid,uuid,tstzrange,text,int4,jsonb,uuid,uuid)"]
security: definer
volatility: volatile
executors: [executor_service, service_role]
raises: [no open knowledge batch, non-temporal relationship rejects a temporal interval, temporal relationship requires world interval]
touches: { reads: [taxonomy.relationship_kind], writes: [corpus.relationship] }
tokens: [temporal, assert_relationship, temporal.assert_relationship]
defined_in: ["20260912010400_km_04_temporal.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# temporal.assert_relationship

Domain `relationships`.

## assert_relationship(text, uuid, uuid, tstzrange, text, integer, jsonb, uuid, uuid) → uuid

function, volatile, security definer, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_kind` | `text` | — | — |
| `p_from` | `uuid` | — | — |
| `p_to` | `uuid` | — | — |
| `p_valid_during` | `tstzrange` | `NULL::tstzrange` | — |
| `p_qualifier` | `text` | `''::text` | — |
| `p_episode` | `integer` | `1` | — |
| `p_properties` | `jsonb` | `'{}'::jsonb` | — |
| `p_extent` | `uuid` | `NULL::uuid` | — |
| `p_claim` | `uuid` | `NULL::uuid` | — |

Execute: `executor_service`, `service_role`.

Raises (mechanically extracted): `no open knowledge batch`; `non-temporal relationship rejects a temporal interval`; `temporal relationship requires world interval`.

Touches (best effort): reads [`taxonomy.relationship_kind`](../../relations/taxonomy/relationship_kind.md); writes [`corpus.relationship`](../../relations/corpus/relationship.md); calls [`temporal.assert_state`](assert_state.md), [`temporal.current_k`](current_k.md), [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["temporal"]["Functions"]["assert_relationship"]`.

Defined in: `20260912010400_km_04_temporal.sql`.
