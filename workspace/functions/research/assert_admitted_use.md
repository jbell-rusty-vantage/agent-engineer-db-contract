---
id: "fn:research.assert_admitted_use(uuid,text,text,int8,text)"
kind: function
schema: research
name: assert_admitted_use
domain: research-v2
overloads: ["fn:research.assert_admitted_use(uuid,text,text,int8,text)"]
security: invoker
volatility: volatile
executors: [executor_service, service_role]
raises: []
touches: { reads: [], writes: [research.use_admission] }
tokens: [research, assert_admitted_use, research.assert_admitted_use]
defined_in: ["20261024010100_research_report_v2_projection.sql", "20261024010200_research_admission_normalized_values.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# research.assert_admitted_use

Domain `research-v2`.

## assert_admitted_use(uuid, text, text, bigint, text) → research.use_admission

function, volatile, security invoker, language plpgsql, config `search_path=""`. Native exact-use guard (design section 7): call inside the ingestion transaction before canonical writes, presenting the normalized values digest of the values being written. Calls knowledge_verification.admit_exact_use under its epoch lock (held to commit) and records research.use_admission for this transaction; raises STALE_DECISION (KSA01), REVIEW_REQUIRED (KSA02), EFFECT_CONFLICT (KSA03, incl. normalized values mismatch) or UNRESOLVED_EFFECT (KSA04).

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_tenant` | `uuid` | — | — |
| `p_use_decision_id` | `text` | — | — |
| `p_bound_effect_digest` | `text` | — | — |
| `p_processed_epoch` | `bigint` | — | — |
| `p_normalized_values_digest` | `text` | `NULL::text` | — |

Execute: `executor_service`, `service_role`.

Touches (best effort): reads —; writes [`research.use_admission`](../../relations/research/use_admission.md); calls —.

TypeScript: `Database["research"]["Functions"]["assert_admitted_use"]`.

Defined in: `20261024010100_research_report_v2_projection.sql`, `20261024010200_research_admission_normalized_values.sql`.
