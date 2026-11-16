---
id: "task:record-claim-with-evidence"
kind: task
lens: evidence
domains: [verified-knowledge, evidence]
queries: [evidence.claim, evidence.claim_restatements, content.document_units, evidence.captures_for_source]
aliases: [record claim, write claim, new claim, claim candidate write, evidence anchor, locator, quote, restate claim, restatement write, atomized claim]
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:216c4ae7230478c8e60934da25c852e10680d6caed71a662962ea3c0ac1676d3"
---
# How do I record a claim with its evidence, or restate one?

Domains: [`verified-knowledge`](../domains/verified-knowledge.md), [`evidence`](../domains/evidence.md). Queries: [`q:evidence.claim`](../queries/README.md), [`q:evidence.claim_restatements`](../queries/README.md), [`q:content.document_units`](../queries/README.md), [`q:evidence.captures_for_source`](../queries/README.md).

## Navigation

`tasks/write-verification-chain.md` → `functions/api/record_claim.md` or `functions/api/restate_claim.md` → `q:evidence.claim` to read it back.

## Operation

`api.record_claim` (pipeline_agent, executor_service) stores a statement as `proposed` with 1 to 50 evidence anchors. An anchor is an existing locator, or a quote that is verbatim in a content unit of a capture:

```sql
select api.record_claim(
  p_idempotency_key => 'thread-36957:claim:2',
  p_claim_type => 'assertion',
  p_statement => 'The post states that checkpoint_ns in the config is not stored.',
  p_evidence => '[{"capture_id":"0192d000-0000-7000-8000-000000000001","node_id":"0192d000-0000-7000-8000-000000000002","quote":"checkpoint_ns is ignored","role":"context"},
                  {"locator_id":"0192d000-0000-7000-8000-000000000003","role":"supports"}]',
  p_subjects => '["0192b000-0000-7000-8000-000000000011"]',
  p_attributions => '[{"entity_id":"0192b000-0000-7000-8000-000000000012","role":"stated_by"}]',
  p_structured => '{"path":"community_thread","source_role":"community","stated_at":"2026-11-10"}');
```

`api.restate_claim` turns an attribution-framed proposed claim ("the post states that X") into X, the statement a probe can test:

```sql
select api.restate_claim(
  p_idempotency_key => 'thread-36957:claim:2:restate',
  p_original_claim_id => '0192b000-0000-7000-8000-000000000001',
  p_statement => 'Passing checkpoint_ns in the config does not change where a root invoke stores checkpoints.',
  p_qualified => false, p_dropped => 'attribution', p_polarity => '{"negative":true}');
```

Find `node_id` and the text to quote with `q:content.document_units`.

## Expected shape

`record_claim`: `claim_id`, `created`, `reused`, `status`, `locator_ids`, `subjects`, `attributions`. `restate_claim`: `claim_id`, `original_claim_id`, `created`, `reused`, `status`, `probe` (the probe of the original's current verdict, if any), `copied` (subjects, attributions, evidence links taken from the original).

## Pitfalls

A new anchor is stored only when the quote is in the unit's text (whitespace and typographic quotes aside): `QUOTE_NOT_IN_UNIT`; the unit must belong to a document version read from that capture: `EVIDENCE_UNIT_NOT_IN_CAPTURE`. New anchors are `text_quote`, or `json_pointer` with `pointer`; any other kind is passed as `locator_id`. The same statement again returns the existing claim with `reused` true and adds no evidence to it. `path` `restatement` is reserved for `api.restate_claim`. One restatement per original; only a `proposed` claim that is not itself a restatement is restated, and the original is never changed. Neither function sets a status other than `proposed`.
