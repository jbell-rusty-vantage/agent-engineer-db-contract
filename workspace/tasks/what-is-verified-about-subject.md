---
id: "task:what-is-verified-about-subject"
kind: task
lens: evidence
domains: [verified-knowledge, evidence]
queries: [evidence.verified_claims, evidence.claim_verdicts, evidence.probes]
aliases: [verified, what is verified, verified claims about, checked statements, admitted claims, tier 0 about a library]
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# What is verified about <subject>?

Domains: [`verified-knowledge`](../domains/verified-knowledge.md), [`evidence`](../domains/evidence.md). Queries: [`q:evidence.verified_claims`](../queries/README.md), [`q:evidence.claim_verdicts`](../queries/README.md), [`q:evidence.probes`](../queries/README.md).

## Navigation

`START_HERE.md` (L1) → `relations/api/verified_claims.md` → `q:evidence.verified_claims`; one claim in depth is `tasks/read-claim-with-evidence.md`.

## Operation

One read: verified claims whose wording or subject matches. Add the judged-but-not-verified claims when the question is "what do we know", not "what may I state as fact".

```json
{
  "schemaVersion": "knowledge-read-intent.v1",
  "intentId": "verified-about-langgraph",
  "operations": [
    { "opId": "verified", "kind": "named_query", "query": "evidence.verified_claims", "params": { "text": "LangGraph", "limit": 50 } },
    { "opId": "judged", "kind": "named_query", "query": "evidence.claim_verdicts", "params": { "claim_id": null, "verdict": null, "probe": null, "limit": 50 } },
    { "opId": "probes", "kind": "named_query", "query": "evidence.probes", "params": { "text": "langgraph", "limit": 20 } }
  ]
}
```

## Expected shape

`verified` rows: `claim_id`, `statement`, `claim_type`, `subjects` (entity names), `verified_at`, `use_decision_id` and `receipt_id` (the Knowledge Services admission), `executor_version`, `verdicts` (array of `probe`, `verdict`, `review_state`). `judged` rows carry the latest `verdict` (`directly_supported`, `supported_with_qualification`, `contradicted`, `not_supported`, `unverifiable`) and `review_state` (`agent_proposed`, `human_confirmed`, `human_rejected`). No row means nothing is verified about it, not that the subject is unknown: check `q:entity.resolve`.

## Pitfalls

Only `api.verified_claims` is verified knowledge. A row of `api.claim_candidates` or `api.claim_verdicts` with a supportive verdict is still a candidate until an admission verifies it; a probe that used a live model, and a community claim, never verify alone. `supported_with_qualification` is verified with a condition: quote the qualification from `rationale`, not the bare statement. The match is on wording and subject names, so resolve an alias first. Verified is about the versions the probe ran: `q:evidence.probe_matrix` shows them, and `tasks/what-is-due.md` shows what a newer release has put in question.
