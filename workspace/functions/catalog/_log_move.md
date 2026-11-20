---
id: "fn:catalog._log_move(uuid,uuid,text,text,jsonb,text,jsonb)"
kind: function
schema: catalog
name: _log_move
domain: identity
lens: corpus
overloads: ["fn:catalog._log_move(uuid,uuid,text,text,jsonb,text,jsonb)"]
security: invoker
volatility: volatile
executors: []
raises: []
touches: { reads: [], writes: [catalog.identity_move] }
tokens: [catalog, _log_move, catalog._log_move]
defined_in: ["20261119120000_build09_rv01_change_reasons_identity_proposals.sql"]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# catalog._log_move

Domain `identity`, lens `corpus`.

## _log_move(uuid, uuid, text, text, jsonb, text, jsonb) → void

function, volatile, security invoker, language sql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_merge` | `uuid` | — | — |
| `p_split` | `uuid` | — | — |
| `p_table` | `text` | — | — |
| `p_column` | `text` | — | — |
| `p_row_key` | `jsonb` | — | — |
| `p_action` | `text` | — | — |
| `p_detail` | `jsonb` | `'{}'::jsonb` | — |

Execute: no configured role.

Touches (best effort): reads —; writes [`catalog.identity_move`](../../relations/catalog/identity_move.md); calls —.

TypeScript: `Database["catalog"]["Functions"]["_log_move"]`.

Defined in: `20261119120000_build09_rv01_change_reasons_identity_proposals.sql`.
