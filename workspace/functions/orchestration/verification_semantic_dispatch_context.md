---
id: "fn:orchestration.verification_semantic_dispatch_context()"
kind: function
schema: orchestration
name: verification_semantic_dispatch_context
domain: orchestration-ledger
lens: machinery
overloads: ["fn:orchestration.verification_semantic_dispatch_context()"]
security: invoker
volatility: volatile
executors: []
raises: [semantic dispatch context cannot be supplied at reservation, semantic dispatch context immutable, semantic dispatch context requires live lease]
touches: { reads: [], writes: [] }
tokens: [orchestration, verification_semantic_dispatch_context, orchestration.verification_semantic_dispatch_context]
defined_in: ["20260907013000_verification_semantic_provider_observation.sql"]
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# orchestration.verification_semantic_dispatch_context

Domain `orchestration-ledger`, lens `machinery`.

## verification_semantic_dispatch_context() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: no configured role.

Raises (mechanically extracted): `semantic dispatch context cannot be supplied at reservation`; `semantic dispatch context immutable`; `semantic dispatch context requires live lease`.

Touches (best effort): reads —; writes —; calls [`orchestration.verification_provider_scope_tuple_is_live`](verification_provider_scope_tuple_is_live.md).

Defined in: `20260907013000_verification_semantic_provider_observation.sql`.
