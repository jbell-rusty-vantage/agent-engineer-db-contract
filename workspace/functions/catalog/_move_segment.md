---
id: "fn:catalog._move_segment(uuid,uuid,uuid,text)"
kind: function
schema: catalog
name: _move_segment
domain: identity
lens: corpus
overloads: ["fn:catalog._move_segment(uuid,uuid,uuid,text)"]
security: invoker
volatility: volatile
executors: []
raises: []
touches: { reads: [], writes: [evidence.segment_support, temporal.segment] }
tokens: [catalog, _move_segment, catalog._move_segment]
defined_in: ["20261119120000_build09_rv01_change_reasons_identity_proposals.sql"]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# catalog._move_segment

Domain `identity`, lens `corpus`.

## _move_segment(uuid, uuid, uuid, text) → uuid

function, volatile, security invoker, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_segment` | `uuid` | — | — |
| `p_stream` | `uuid` | — | — |
| `p_ref` | `uuid` | — | — |
| `p_reason` | `text` | — | — |

Execute: no configured role.

Touches (best effort): reads —; writes [`evidence.segment_support`](../../relations/evidence/segment_support.md), [`temporal.segment`](../../relations/temporal/segment.md); calls [`temporal.close_segment`](../temporal/close_segment.md), [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["catalog"]["Functions"]["_move_segment"]`.

Defined in: `20261119120000_build09_rv01_change_reasons_identity_proposals.sql`.
