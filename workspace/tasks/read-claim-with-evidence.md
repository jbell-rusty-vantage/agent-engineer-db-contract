---
id: "task:read-claim-with-evidence"
kind: task
lens: evidence
domains: [verified-knowledge, evidence]
queries: [evidence.claim, evidence.verified_claims, evidence.claim_verdicts, evidence.probe_matrix, evidence.claim_restatements, evidence.claim_conflicts]
aliases: [one claim, claim detail, evidence for a claim, why is this claim verified, verdict of a claim, probe runs for a claim]
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# Read one claim with its evidence and verdicts

Domains: [`verified-knowledge`](../domains/verified-knowledge.md), [`evidence`](../domains/evidence.md). Queries: [`q:evidence.claim`](../queries/README.md), [`q:evidence.verified_claims`](../queries/README.md), [`q:evidence.claim_verdicts`](../queries/README.md), [`q:evidence.probe_matrix`](../queries/README.md), [`q:evidence.claim_restatements`](../queries/README.md), [`q:evidence.claim_conflicts`](../queries/README.md).

## Navigation

`tasks/what-is-verified-about-subject.md` or a search hit (`target_kind` claim) gives the `claim_id` → `relations/api/claim_candidates.md` → `q:evidence.claim` → `q:evidence.claim_verdicts` → `q:evidence.probe_matrix`.

## Operation

```json
{
  "schemaVersion": "knowledge-read-intent.v1",
  "intentId": "claim-in-depth",
  "operations": [
    { "opId": "claim", "kind": "named_query", "query": "evidence.claim", "params": { "claim_id": "0192b000-0000-7000-8000-000000000001" } },
    { "opId": "verdict", "kind": "named_query", "query": "evidence.claim_verdicts", "params": { "claim_id": "0192b000-0000-7000-8000-000000000001", "verdict": null, "probe": null, "limit": 5 } },
    { "opId": "runs", "kind": "named_query", "query": "evidence.probe_matrix", "params": { "probe": "$verdict.rows[0].probe" } },
    { "opId": "restated", "kind": "named_query", "query": "evidence.claim_restatements", "params": { "claim_id": "0192b000-0000-7000-8000-000000000001", "limit": 20 } },
    { "opId": "conflicts", "kind": "named_query", "query": "evidence.claim_conflicts", "params": { "claim_id": "0192b000-0000-7000-8000-000000000001", "limit": 20 } }
  ]
}
```

The claim is a row of `api.claim_candidates`, its latest verdict a row of `api.claim_verdicts`, the runs come from `api.probe_matrix`. The admission behind a verified status is the matching row of `q:evidence.verified_claims` (`use_decision_id`, `receipt_id`, `effect`).

## Expected shape

`claim`: `status` (`proposed`, `verified`, `disputed`), `path` (how it entered: `deterministic_first_party`, `L1_candidate`, `community_thread`, `restatement`, `own_probe_finding`, …), `source_role`, `subjects`, `speakers`, `document_node_id` and `document_title` (where it was read). `verdict`: who stated it (`stated_by`, `channel`, `stated_at`, `quote`), the latest `verdict`, `probe`, `review_state`, `decided_by`, `cells` (per-cell summary) and `rationale`. `runs`: one row per cell with `outcome`, `resolved` (package versions that cell installed), `observations`, `started_at`, `locator_id`.

## Pitfalls

A probe run's `outcome` (pass or fail) is about the probe's own checks, not about the claim; the claim's answer is the `verdict`. A cell is a date (what a tutorial follower got that day) or an explicit pin: read `resolved` before saying which version a verdict covers. `api.claim_verdicts` holds the latest verdict only; a verified claim lists every current one in `api.verified_claims.verdicts`. A claim read from a document carries `document_node_id`; the exact locator of a fact is `q:facts.locators`, and claim-to-fact support is `q:evidence.claim_support` (pipeline_agent).
