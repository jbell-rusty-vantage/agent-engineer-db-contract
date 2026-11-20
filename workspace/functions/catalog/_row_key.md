---
id: "fn:catalog._row_key(regclass,jsonb)"
kind: function
schema: catalog
name: _row_key
domain: identity
lens: corpus
overloads: ["fn:catalog._row_key(regclass,jsonb)"]
security: invoker
volatility: stable
executors: []
raises: []
touches: { reads: [], writes: [] }
tokens: [catalog, _row_key, catalog._row_key]
defined_in: ["20261119120000_build09_rv01_change_reasons_identity_proposals.sql"]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# catalog._row_key

Domain `identity`, lens `corpus`.

## _row_key(regclass, jsonb) → jsonb

function, stable, security invoker, language sql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_table` | `regclass` | — | — |
| `p_row` | `jsonb` | — | — |

Execute: no configured role.

TypeScript: `Database["catalog"]["Functions"]["_row_key"]`.

Defined in: `20261119120000_build09_rv01_change_reasons_identity_proposals.sql`.
