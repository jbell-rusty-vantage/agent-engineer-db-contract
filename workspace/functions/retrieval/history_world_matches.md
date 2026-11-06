---
id: "fn:retrieval.history_world_matches(tstzrange,timestamptz,timestamptz,timestamptz)"
kind: function
schema: retrieval
name: history_world_matches
domain: retrieval
overloads: ["fn:retrieval.history_world_matches(tstzrange,timestamptz,timestamptz,timestamptz)"]
security: invoker
volatility: immutable
executors: []
raises: []
touches: { reads: [], writes: [] }
tokens: [retrieval, history_world_matches, retrieval.history_world_matches]
defined_in: ["20260914011100_retrieval_history.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# retrieval.history_world_matches

Domain `retrieval`.

## history_world_matches(tstzrange, timestamp with time zone, timestamp with time zone, timestamp with time zone) → boolean

function, immutable, security invoker, language sql, config `search_path=""`. World-time predicate: point containment, half-open interval overlap, or unconstrained. Rejects mixed or reversed bounds.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_interval` | `tstzrange` | — | — |
| `p_at` | `timestamp with time zone` | — | — |
| `p_from` | `timestamp with time zone` | — | — |
| `p_to` | `timestamp with time zone` | — | — |

Execute: no configured role.

TypeScript: `Database["retrieval"]["Functions"]["history_world_matches"]`.

Defined in: `20260914011100_retrieval_history.sql`.
