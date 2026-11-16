---
id: "fn:verification.assert_admitted_use(uuid,text,text,int8,text)"
kind: function
schema: verification
name: assert_admitted_use
domain: evidence
lens: evidence
overloads: ["fn:verification.assert_admitted_use(uuid,text,text,int8,text)"]
security: invoker
volatility: volatile
executors: [executor_service, service_role]
raises: []
touches: { reads: [], writes: [verification.use_admission] }
tokens: [verification, assert_admitted_use, verification.assert_admitted_use]
defined_in: []
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# verification.assert_admitted_use

Domain `evidence`, lens `evidence`.

## assert_admitted_use(uuid, text, text, bigint, text) → verification.use_admission

function, volatile, security invoker, language plpgsql, config `search_path=""`. Native exact-use guard (design section 7): call inside the ingestion transaction before canonical writes, presenting the normalized values digest of the values being written. Calls knowledge_verification.admit_exact_use under its epoch lock (held to commit) and records research.use_admission for this transaction; raises STALE_DECISION (KSA01), REVIEW_REQUIRED (KSA02), EFFECT_CONFLICT (KSA03, incl. normalized values mismatch) or UNRESOLVED_EFFECT (KSA04).

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_tenant` | `uuid` | — | — |
| `p_use_decision_id` | `text` | — | — |
| `p_bound_effect_digest` | `text` | — | — |
| `p_processed_epoch` | `bigint` | — | — |
| `p_normalized_values_digest` | `text` | `NULL::text` | — |

Execute: `executor_service`, `service_role`.

Touches (best effort): reads —; writes [`verification.use_admission`](../../relations/verification/use_admission.md); calls —.

TypeScript: `Database["verification"]["Functions"]["assert_admitted_use"]`.

Defined in: unknown.
