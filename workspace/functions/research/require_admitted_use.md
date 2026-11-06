---
id: "fn:research.require_admitted_use(uuid,text,text,int8,text)"
kind: function
schema: research
name: require_admitted_use
domain: research-v2
overloads: ["fn:research.require_admitted_use(uuid,text,text,int8,text)"]
security: invoker
volatility: volatile
executors: [executor_service, service_role]
raises: [EFFECT_CONFLICT, REVIEW_REQUIRED, STALE_DECISION, UNRESOLVED_EFFECT]
touches: { reads: [], writes: [] }
tokens: [research, require_admitted_use, research.require_admitted_use]
defined_in: ["20261024010100_research_report_v2_projection.sql", "20261024010200_research_admission_normalized_values.sql", "20261025010200_research_admission_values_required.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# research.require_admitted_use

Domain `research-v2`.

## require_admitted_use(uuid, text, text, bigint, text) → TABLE(authoritative_epoch bigint, effect_key text)

function, volatile, security invoker, language plpgsql, config `search_path=""`. Internal checker shared by assert_admitted_use and the use_admission insert trigger: knowledge_verification.admit_exact_use (2.4.0; the normalized values digest is required when the decision binds one) outcome -> typed errors KSA01..KSA04; NORMALIZED_VALUES_REQUIRED -> UNRESOLVED_EFFECT (KSA04).

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_tenant` | `uuid` | — | — |
| `p_use_decision_id` | `text` | — | — |
| `p_bound_effect_digest` | `text` | — | — |
| `p_processed_epoch` | `bigint` | — | — |
| `p_normalized_values_digest` | `text` | `NULL::text` | — |

Execute: `executor_service`, `service_role`.

Raises (mechanically extracted): `EFFECT_CONFLICT`; `REVIEW_REQUIRED`; `STALE_DECISION`; `UNRESOLVED_EFFECT`.

TypeScript: `Database["research"]["Functions"]["require_admitted_use"]`.

Defined in: `20261024010100_research_report_v2_projection.sql`, `20261024010200_research_admission_normalized_values.sql`, `20261025010200_research_admission_values_required.sql`.
