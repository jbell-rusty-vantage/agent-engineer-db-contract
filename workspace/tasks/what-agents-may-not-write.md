---
id: "task:what-agents-may-not-write"
kind: task
lens: evidence
domains: [verified-knowledge, source-intelligence]
queries: [evidence.verified_claims, evidence.claim_verdicts, chain.governed_writes]
aliases: [not allowed, forbidden write, agent limits, human review, human confirmed, verify claim, admission, release review, append-only, immutable, lines agents do not cross]
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# What is an agent not allowed to write?

Domains: [`verified-knowledge`](../domains/verified-knowledge.md), [`source-intelligence`](../domains/source-intelligence.md). Queries: [`q:evidence.verified_claims`](../queries/README.md), [`q:evidence.claim_verdicts`](../queries/README.md), [`q:chain.governed_writes`](../queries/README.md).

## Navigation

`tasks/write-verification-chain.md` → this page → `domains/verified-knowledge.md` (Verified).

## Operation

Three lines, enforced by the database for every bounded role (pipeline_agent, verifier_agent, executor_service, control_plane, app_reader) and for service_role, whether the write goes through a function or straight at a table.

1. **Verified.** A claim becomes `verified` only when Knowledge Services admits a sealed verification run (`verification.record_admitted_claim_verification`, called with the decision the verification component issued). No governed function sets a status other than `proposed`, or `disputed` after a deterministic contradiction. Setting the status directly fails `VERIFIED_CLAIM_REQUIRES_ADMITTED_USE`.
2. **A person's judgment.** `review_state` `human_confirmed` or `human_rejected` on `verification.probe_verdict` and `verification.claim_triage`, and `method` `reviewed` on `evidence.source_assessment`, say that a person decided. An agent role cannot write such a row (`HUMAN_REVIEW_NOT_AGENT_WRITABLE`), cannot label itself as a person (`ACTOR_INVALID`), and cannot call the product command that records a release review. Attention policies are a person's decisions too.
3. **Nothing rewritten.** Verdicts, triage rows, assessments, receipts, receipt targets, evidence locators and links, admissions and vector items are append-only or immutable: a change is a new row that supersedes. A verified claim is not deleted, restated or re-statused; a contradicting verdict on it is recorded as a proposal with `needs_review` true.

```json
{
  "schemaVersion": "knowledge-read-intent.v1",
  "intentId": "what-did-the-agent-write",
  "operations": [
    { "opId": "writes", "kind": "named_query", "query": "chain.governed_writes", "params": { "function": null, "mc_run_id": null, "key": null, "limit": 20 } },
    { "opId": "verdicts", "kind": "named_query", "query": "evidence.claim_verdicts", "params": { "claim_id": null, "verdict": null, "probe": null, "limit": 20 } }
  ]
}
```

## Expected shape

`writes`: one row per governed write with `function`, `idempotency_key`, `session_role`, `actor_label`, `origin_kind`, `mc_run_id`, `mission_id`. `verdicts`: `review_state` is `agent_proposed` on every row an agent wrote and `decided_by` starts with `agent:`; `human_confirmed` rows were written by a person's path.

## Pitfalls

A supportive verdict is not verification and an agent's confidence is not a review: say "proposed" until `q:evidence.verified_claims` lists the claim. Do not transcribe a person's answer into a verdict, a triage row or a release review; ask for the review instead. An agent's changed verdict may supersede a row a person confirmed, as a new `agent_proposed` row flagged `needs_review`; the person's row stays as written. There is no agent function for a human confirmation, and none should be granted to an agent role.
