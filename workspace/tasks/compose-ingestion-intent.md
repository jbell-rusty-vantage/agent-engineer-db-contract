---
id: "task:compose-ingestion-intent"
kind: task
lens: corpus
domains: [temporal-facts, identity, relationships, evidence, staging]
queries: [knowledge.head, entity.resolve, vocab.stream_kind, vocab.relationship_kind, vocab.event_kind]
aliases: [ingestion intent, proposal, write, intent skeleton]
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
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
  "intentId": "codex-2026-11-08",
  "expectedKnowledgeHead": 4,
  "onStale": "rebase_if_disjoint",
  "context": { "missionId": "0192a000-0000-7000-8000-000000000001", "correlationId": "loop1-r1", "actor": { "kind": "agent", "id": "eve:research" } },
  "evidence": { "verificationRuns": [{ "runId": "vr_codex_2026_11_08", "manifestDigest": "sha256:c0d0" }] },
  "subjects": [
    { "ref": "codex", "mode": "resolved", "entityId": "0192b000-0000-7000-8000-000000000011", "kind": "product" },
    { "ref": "codex-cli", "mode": "new", "kind": "product", "displayName": "Codex CLI", "attributes": { "category": "coding_agent" }, "identifiers": [{ "scheme": "github", "value": "openai/codex" }], "onMatch": "use_existing" }
  ],
  "proposals": [
    { "proposalId": "p1", "kind": "entity.create", "subjectRef": "codex-cli", "belief": "accepted" },
    { "proposalId": "p2", "kind": "relationship.assert", "fromRef": "codex", "toRef": "codex-cli", "relationshipKind": "has_feature", "worldInterval": { "from": "2026-11-08T00:00:00Z", "to": null, "bounds": "[)" }, "temporalBasis": "explicit", "belief": "accepted" },
    { "proposalId": "p3", "kind": "fact.assert_state", "subjectRef": "codex", "streamKind": "offering_price", "scopeKey": "input_tokens||", "worldInterval": { "from": "2026-11-08T00:00:00Z", "to": null, "bounds": "[)" }, "amount": 1.25, "currency": "USD", "unit": "usd_per_1m_tokens", "payload": { "meter": "input_tokens" }, "extent": { "sourceText": "November 8, 2026", "precision": "day", "earliest": "2026-11-08", "latest": "2026-11-08" }, "temporalBasis": "explicit", "belief": "accepted", "evidence": [{ "runId": "vr_codex_2026_11_08", "claimId": "c_01", "locatorRef": "q_01", "role": "primary" }] }
  ]
}
```

## Expected shape

`knowledge ingest plan` returns `knowledge-ingestion-plan.v1` with every proposal `planned`, `duplicate`, `held`, or `rejected` and the rules that fired. `knowledge ingest apply` returns `knowledge-ingestion-receipt.v1` with `receiptId`, `knowledgeHead.before/after`, and per-proposal outcomes.

## Pitfalls

Every `fact.assert_state` that may correct an existing fact must carry the `scopeKey` of the series it corrects (run `tasks/find-stale-facts.md` first). `streamKind`, `relationshipKind`, `eventKind`, and subject `kind` are vocabulary codes (`vocab.*` queries); a wrong code is `VOCABULARY_VIOLATION` before any transaction; subject `attributes` must satisfy the kind's schema. `expectedKnowledgeHead` comes from the read snapshot; a moved head is `REBASE_REQUIRED` unless `onStale` allows a disjoint rebase. Submit an intent once; the same `intentId` again returns `duplicateOf`. `claim.materialize` needs `context.attemptId`.
