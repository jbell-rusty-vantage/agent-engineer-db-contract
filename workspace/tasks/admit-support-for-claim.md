---
id: "task:admit-support-for-claim"
kind: task
domains: [evidence, temporal-facts]
queries: [evidence.claims_for_entity, evidence.claim_support, evidence.captures_for_source]
aliases: [support, quote]
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# Admit support for a claim

Domains: [`evidence`](../domains/evidence.md), [`temporal-facts`](../domains/temporal-facts.md). Queries: [`q:evidence.claims_for_entity`](../queries/README.md), [`q:evidence.claim_support`](../queries/README.md), [`q:evidence.captures_for_source`](../queries/README.md).

## Navigation

`domains/evidence.md` → `q:evidence.claim_support`

## Operation

```json
{
  "schemaVersion": "knowledge-ingestion-intent.v1",
  "intentId": "admit-price-support",
  "expectedKnowledgeHead": 41,
  "evidence": { "verificationRuns": [{ "runId": "vr_01J8Q000", "manifestDigest": "sha256:c0d0" }] },
  "subjects": [{ "ref": "offering", "mode": "resolved", "entityId": "0192b000-0000-7000-8000-000000000001", "kind": "model_offering" }],
  "proposals": [
    {
      "proposalId": "p-support",
      "kind": "support.admit",
      "targetRef": "0192b9aa-0000-7000-8000-000000000001",
      "supportRole": "primary",
      "belief": "accepted",
      "evidence": [{ "runId": "vr_01J8Q000", "claimId": "c_0011", "locatorRef": "q_06", "role": "primary" }]
    }
  ]
}
```

## Expected shape

One `evidence.segment_support` row with k_to null, claim_id, locator_id, and exactly one of segment_id or event_occurrence_id. `q:evidence.claim_support` returns it.

## Pitfalls

The claim must exist (materialize first). Locator is required. Role on the table is supports, challenges, or context — the intent `supportRole` primary/corroborating/contradicting is mapped by the executor. Support is written only through `temporal.admit_support`.
