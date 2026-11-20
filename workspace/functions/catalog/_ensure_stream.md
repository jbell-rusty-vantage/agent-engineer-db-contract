---
id: "fn:catalog._ensure_stream(text,uuid,uuid,text)"
kind: function
schema: catalog
name: _ensure_stream
domain: identity
lens: corpus
overloads: ["fn:catalog._ensure_stream(text,uuid,uuid,text)"]
security: invoker
volatility: volatile
executors: []
raises: []
touches: { reads: [], writes: [temporal.stream] }
tokens: [catalog, _ensure_stream, catalog._ensure_stream]
defined_in: ["20261119120000_build09_rv01_change_reasons_identity_proposals.sql"]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# catalog._ensure_stream

Domain `identity`, lens `corpus`.

## _ensure_stream(text, uuid, uuid, text) → uuid

function, volatile, security invoker, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_kind` | `text` | — | — |
| `p_entity` | `uuid` | — | — |
| `p_relationship` | `uuid` | — | — |
| `p_scope_key` | `text` | — | — |

Execute: no configured role.

Touches (best effort): reads —; writes [`temporal.stream`](../../relations/temporal/stream.md); calls [`util.current_tenant_id`](../util/current_tenant_id.md).

TypeScript: `Database["catalog"]["Functions"]["_ensure_stream"]`.

Defined in: `20261119120000_build09_rv01_change_reasons_identity_proposals.sql`.
