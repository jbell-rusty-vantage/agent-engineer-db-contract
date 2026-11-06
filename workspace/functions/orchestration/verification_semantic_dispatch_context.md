---
id: "fn:orchestration.verification_semantic_dispatch_context()"
kind: function
schema: orchestration
name: verification_semantic_dispatch_context
domain: orchestration-ledger
overloads: ["fn:orchestration.verification_semantic_dispatch_context()"]
security: invoker
volatility: volatile
executors: []
raises: [semantic dispatch context cannot be supplied at reservation, semantic dispatch context immutable, semantic dispatch context requires live lease]
touches: { reads: [], writes: [] }
tokens: [orchestration, verification_semantic_dispatch_context, orchestration.verification_semantic_dispatch_context]
defined_in: ["20260907013000_verification_semantic_provider_observation.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# orchestration.verification_semantic_dispatch_context

Domain `orchestration-ledger`.

## verification_semantic_dispatch_context() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: no configured role.

Raises (mechanically extracted): `semantic dispatch context cannot be supplied at reservation`; `semantic dispatch context immutable`; `semantic dispatch context requires live lease`.

Touches (best effort): reads —; writes —; calls [`orchestration.verification_provider_scope_tuple_is_live`](verification_provider_scope_tuple_is_live.md).

Defined in: `20260907013000_verification_semantic_provider_observation.sql`.
