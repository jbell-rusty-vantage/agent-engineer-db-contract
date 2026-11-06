---
id: "task:compose-ingestion-intent"
kind: task
domains: [temporal-facts, identity, relationships, evidence, staging]
queries: [knowledge.head, entity.resolve, vocab.stream_kind, vocab.relationship_kind, vocab.event_kind]
aliases: [ingestion intent, proposal, write, intent skeleton]
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# Compose a knowledge ingestion intent

Domains: [`temporal-facts`](../domains/temporal-facts.md), [`identity`](../domains/identity.md), [`relationships`](../domains/relationships.md), [`evidence`](../domains/evidence.md), [`staging`](../domains/staging.md). Queries: [`q:knowledge.head`](../queries/README.md), [`q:entity.resolve`](../queries/README.md), [`q:vocab.stream_kind`](../queries/README.md), [`q:vocab.relationship_kind`](../queries/README.md), [`q:vocab.event_kind`](../queries/README.md).

## Navigation

`rules/README.md` → `vocabularies/temporal.stream_kind.md` → this page → `tasks/verify-ingestion-result.md`

## Operation

One intent = one source or report, one `expectedKnowledgeHead`, subjects declared once, proposals referencing subjects by `subjectRef`. Proposal kinds: `entity.create`, `entity.alias`, `entity.identifier`, `fact.assert_state`, `relationship.assert`, `event.assert`, `claim.materialize`, `support.admit`, `candidate.stage`.

```json
{
  "schemaVersion": "knowledge-ingestion-intent.v1",
  "intentId": "codex-2026-09-11",
  "expectedKnowledgeHead": 4,
  "onStale": "rebase_if_disjoint",
  "context": { "missionId": "0192a000-0000-7000-8000-000000000001", "correlationId": "exp3-a-r1", "actor": { "kind": "agent", "id": "eve:db-aware-research" } },
  "evidence": { "verificationRuns": [{ "runId": "vr_codex_2026_09_11", "manifestDigest": "sha256:c0d0" }] },
  "subjects": [
    { "ref": "codex", "mode": "resolved", "entityId": "0192b000-0000-7000-8000-000000000011", "kind": "product" },
    { "ref": "codex-cli", "mode": "new", "kind": "product", "displayName": "Codex CLI", "identifiers": [{ "scheme": "github", "value": "openai/codex" }], "onMatch": "use_existing" }
  ],
  "proposals": [
    { "proposalId": "p1", "kind": "entity.create", "subjectRef": "codex-cli", "belief": "accepted" },
    { "proposalId": "p2", "kind": "relationship.assert", "fromRef": "codex", "toRef": "codex-cli", "relationshipKind": "has_feature", "worldInterval": { "from": "2026-09-11T00:00:00Z", "to": null, "bounds": "[)" }, "temporalBasis": "explicit", "belief": "accepted" },
    { "proposalId": "p3", "kind": "fact.assert_state", "subjectRef": "codex", "streamKind": "model_offering_price", "scopeKey": "per_1m_input_tokens", "worldInterval": { "from": "2026-09-11T00:00:00Z", "to": null, "bounds": "[)" }, "amount": 1.25, "currency": "USD", "unit": "per_1m_input_tokens", "extent": { "sourceText": "September 11, 2026", "precision": "day", "earliest": "2026-09-11", "latest": "2026-09-11" }, "temporalBasis": "explicit", "belief": "accepted", "evidence": [{ "runId": "vr_codex_2026_09_11", "claimId": "c_01", "locatorRef": "q_01", "role": "primary" }] }
  ]
}
```

## Expected shape

`knowledge ingest plan` returns `knowledge-ingestion-plan.v1` with every proposal `planned`, `duplicate`, `held`, or `rejected` and the rules that fired. `knowledge ingest apply` returns `knowledge-ingestion-receipt.v1` with `receiptId`, `knowledgeHead.before/after`, and per-proposal outcomes.

## Pitfalls

Every `fact.assert_state` that may correct an existing fact must carry the `scopeKey` of the series it corrects (run `tasks/find-stale-facts.md` first); the unit is the default only for a series that does not exist yet. `streamKind`, `relationshipKind`, `eventKind`, and subject `kind` are vocabulary codes (`vocab.*` queries); a wrong code is `VOCABULARY_VIOLATION` before any transaction. `expectedKnowledgeHead` comes from the read snapshot you based the intent on; a moved head is `REBASE_REQUIRED` unless `onStale` allows a disjoint rebase. Submit an intent once; the same `intentId` again returns `duplicateOf`, never a second batch. `claim.materialize` needs `context.attemptId`.
