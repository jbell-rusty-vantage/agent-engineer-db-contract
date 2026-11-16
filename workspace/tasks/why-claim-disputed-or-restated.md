---
id: "task:why-claim-disputed-or-restated"
kind: task
lens: evidence
domains: [verified-knowledge, evidence]
queries: [evidence.claim, evidence.claim_conflicts, evidence.claim_restatements, evidence.claim_verdicts, evidence.claim_triage]
aliases: [disputed, conflict, contradicted, restated, restatement, original claim, not checkable, why not verified]
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:216c4ae7230478c8e60934da25c852e10680d6caed71a662962ea3c0ac1676d3"
---
# Why is a claim disputed, or why was it restated?

Domains: [`verified-knowledge`](../domains/verified-knowledge.md), [`evidence`](../domains/evidence.md). Queries: [`q:evidence.claim`](../queries/README.md), [`q:evidence.claim_conflicts`](../queries/README.md), [`q:evidence.claim_restatements`](../queries/README.md), [`q:evidence.claim_verdicts`](../queries/README.md), [`q:evidence.claim_triage`](../queries/README.md).

## Navigation

`relations/api/claim_conflicts.md` or `relations/api/claim_restatements.md` → `q:evidence.claim_conflicts` / `q:evidence.claim_restatements` → `q:evidence.claim_verdicts` → `q:evidence.claim_triage`.

## Operation

Four different reasons a claim is not simply verified: a contradicting verdict (`api.claim_verdicts`), a kept conflict (`api.claim_conflicts`), a restatement (`api.claim_restatements`) or a triage outcome (`api.claim_triage`). Read all four for one `claim_id`.

```json
{
  "schemaVersion": "knowledge-read-intent.v1",
  "intentId": "why-not-verified",
  "operations": [
    { "opId": "claim", "kind": "named_query", "query": "evidence.claim", "params": { "claim_id": "0192b000-0000-7000-8000-000000000001" } },
    { "opId": "verdict", "kind": "named_query", "query": "evidence.claim_verdicts", "params": { "claim_id": "0192b000-0000-7000-8000-000000000001", "verdict": null, "probe": null, "limit": 5 } },
    { "opId": "conflicts", "kind": "named_query", "query": "evidence.claim_conflicts", "params": { "claim_id": "0192b000-0000-7000-8000-000000000001", "limit": 20 } },
    { "opId": "restated", "kind": "named_query", "query": "evidence.claim_restatements", "params": { "claim_id": "0192b000-0000-7000-8000-000000000001", "limit": 20 } },
    { "opId": "triage", "kind": "named_query", "query": "evidence.claim_triage", "params": { "claim_id": "0192b000-0000-7000-8000-000000000001", "disposition": null, "limit": 5 } }
  ]
}
```

## Expected shape

`verdict`: `contradicted` or `not_supported` with `rationale` and `cells` is a probe result that moved the claim to `disputed`. `conflicts`: `conflict_kind` (value, scope or subject disagreement, for example `scope_mismatch`), both statements with their status, `other_source_role`, `detected_by`, and `reconciliation` (null until someone decides). `restated`: the restated claim (`statement`, `status`, `qualified`, `dropped`, `probe`) beside `original_claim_id`, `original_statement`, `original_status`. `triage`: `disposition` (`probe`, `docs_check`, `registry_check`, `not_checkable`, `duplicate`, `out_of_scope`), `checkability`, `rationale`, `duplicate_of_claim_id`.

## Pitfalls

Disputed is not false: it means a deterministic probe contradicted the statement as worded, in the cells it ran. A conflict is kept, never averaged away; with `reconciliation` null neither side wins. A restatement exists because the original was attribution-framed ("the post states that X"): the probe verifies X, and the original stays `proposed` as the record of what the source said, so do not count both. `qualified` true means the restated claim holds only with the condition in its statement; `dropped` says what was left out. `not_checkable` (advice, experience, opinion) is a triage outcome, not a verdict.
