---
id: "fn:verification.require_admitted_use(uuid,text,text,int8,text)"
kind: function
schema: verification
name: require_admitted_use
domain: evidence
lens: evidence
overloads: ["fn:verification.require_admitted_use(uuid,text,text,int8,text)"]
security: invoker
volatility: volatile
executors: [executor_service, service_role]
raises: [EFFECT_CONFLICT, REVIEW_REQUIRED, STALE_DECISION, UNRESOLVED_EFFECT]
touches: { reads: [], writes: [] }
tokens: [verification, require_admitted_use, verification.require_admitted_use]
defined_in: ["20261113150000_build08_ks_admission_verified_claims.sql", "20261113150100_build08_loop6_fixup_require_admitted_use.sql"]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# verification.require_admitted_use

Domain `evidence`, lens `evidence`.

## require_admitted_use(uuid, text, text, bigint, text) → TABLE(authoritative_epoch bigint, effect_key text)

function, volatile, security invoker, language plpgsql, config `search_path=""`. Internal checker shared by assert_admitted_use and the use_admission insert trigger: knowledge_verification.admit_exact_use (normalized values digest forwarded) outcome -> typed errors KSA01..KSA04.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_tenant` | `uuid` | — | — |
| `p_use_decision_id` | `text` | — | — |
| `p_bound_effect_digest` | `text` | — | — |
| `p_processed_epoch` | `bigint` | — | — |
| `p_normalized_values_digest` | `text` | `NULL::text` | — |

Execute: `executor_service`, `service_role`.

Raises (mechanically extracted): `EFFECT_CONFLICT`; `REVIEW_REQUIRED`; `STALE_DECISION`; `UNRESOLVED_EFFECT`.

TypeScript: `Database["verification"]["Functions"]["require_admitted_use"]`.

Defined in: `20261113150000_build08_ks_admission_verified_claims.sql`, `20261113150100_build08_loop6_fixup_require_admitted_use.sql`.
