---
id: "task:price-with-locator"
kind: task
lens: corpus
domains: [api-surface, temporal-facts, evidence]
queries: [entity.resolve, catalog.model_offerings, facts.price_history, facts.locators, content.document_units]
aliases: [price, pricing, cost per token, citation for price, where does the price come from]
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:94ffe6a458de74a3cfebdee4fb31f371d14c89d7eaa16cfe1ab1cae9dc94743b"
---
# What does X cost per 1M tokens, and where exactly was that read?

Domains: [`api-surface`](../domains/api-surface.md), [`temporal-facts`](../domains/temporal-facts.md), [`evidence`](../domains/evidence.md). Queries: [`q:entity.resolve`](../queries/README.md), [`q:catalog.model_offerings`](../queries/README.md), [`q:facts.price_history`](../queries/README.md), [`q:facts.locators`](../queries/README.md), [`q:content.document_units`](../queries/README.md).

## Navigation

`tasks/compare-models.md` or `q:entity.resolve` → `q:catalog.model_offerings` → `q:facts.locators` (`api.fact_locators`) → optionally `q:content.document_units`.

## Operation

```json
{
  "schemaVersion": "knowledge-read-intent.v1",
  "intentId": "price-with-locator",
  "operations": [
    { "opId": "resolve", "kind": "named_query", "query": "entity.resolve", "params": { "text": "GPT-5.6 (API)" } },
    { "opId": "offer", "kind": "named_query", "query": "catalog.model_offerings", "params": { "model_version_id": null, "text": "GPT-5.6", "limit": 20 } },
    { "opId": "history", "kind": "named_query", "query": "facts.price_history", "params": { "offering_id": "$offer.rows[0].offering_id", "meter": "input_tokens" } },
    { "opId": "where", "kind": "named_query", "query": "facts.locators", "params": { "entity_id": "$offer.rows[0].offering_id", "stream_kind": "offering_price", "scope_key": null } }
  ]
}
```

## Expected shape

`offer` rows: `input_usd_per_1m`, `output_usd_per_1m`, `cached_input_usd_per_1m`, `batch_input_usd_per_1m`, `price_valid_from`, `price_observed_at`, `price_claim_id`, `price_locator_id`. `where` rows: the current fact plus `claim_statement`, `selector_kind`, `selector`, `normalized_value`, `request_url`, `captured_at`, and the typed unit (`unit_kind` price_row, `logical_key` like `price_row:gpt-5.6|input_tokens|standard|global`). `history` rows: every belief with `valid_during`, `k_from`/`k_to`, `learned_at`, `retracted_at`.

## Pitfalls

The offering is the subject of the price, not the model. `scope_key` is `meter|tier|region`; pass `null` to see every meter. A row in `history` with `k_to` set is a superseded belief — quote the current one unless the question is about history. `normalized_value` is the number as read; `amount` is normalized to USD per 1M tokens — say which you cite.
