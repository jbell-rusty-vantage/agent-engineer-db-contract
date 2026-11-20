---
id: "fn:catalog._carry_relationship_streams(uuid,uuid,text)"
kind: function
schema: catalog
name: _carry_relationship_streams
domain: identity
lens: corpus
overloads: ["fn:catalog._carry_relationship_streams(uuid,uuid,text)"]
security: invoker
volatility: volatile
executors: []
raises: []
touches: { reads: [temporal.segment, temporal.stream], writes: [] }
tokens: [catalog, _carry_relationship_streams, catalog._carry_relationship_streams]
defined_in: ["20261119120000_build09_rv01_change_reasons_identity_proposals.sql"]
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# catalog._carry_relationship_streams

Domain `identity`, lens `corpus`.

## _carry_relationship_streams(uuid, uuid, text) → void

function, volatile, security invoker, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_from_rel` | `uuid` | — | — |
| `p_to_rel` | `uuid` | — | — |
| `p_reason` | `text` | — | — |

Execute: no configured role.

Touches (best effort): reads [`temporal.segment`](../../relations/temporal/segment.md), [`temporal.stream`](../../relations/temporal/stream.md); writes —; calls [`catalog._ensure_stream`](_ensure_stream.md), [`catalog._move_segment`](_move_segment.md), [`temporal.current_k`](../temporal/current_k.md), [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["catalog"]["Functions"]["_carry_relationship_streams"]`.

Defined in: `20261119120000_build09_rv01_change_reasons_identity_proposals.sql`.
