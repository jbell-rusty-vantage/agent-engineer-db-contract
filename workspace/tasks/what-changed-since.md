---
id: "task:what-changed-since"
kind: task
lens: corpus
domains: [temporal-facts, content, acquisition]
queries: [facts.changes_since, content.unit_changes, content.refresh_checks, catalog.models_at, catalog.model_offerings_at]
aliases: [changes since, "what's new", delta since date, recent changes, refresh results]
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# What changed since <date> (facts, events, refreshed documents)?

Domains: [`temporal-facts`](../domains/temporal-facts.md), [`content`](../domains/content.md), [`acquisition`](../domains/acquisition.md). Queries: [`q:facts.changes_since`](../queries/README.md), [`q:content.unit_changes`](../queries/README.md), [`q:content.refresh_checks`](../queries/README.md), [`q:catalog.models_at`](../queries/README.md), [`q:catalog.model_offerings_at`](../queries/README.md).

## Navigation

`START_HERE.md` (L2) → `functions/api/changes_since.md` → `q:facts.changes_since`; for the document side `q:content.unit_changes` and `q:content.refresh_checks`.

## Operation

```json
{
  "schemaVersion": "knowledge-read-intent.v1",
  "intentId": "changes-since-october",
  "operations": [
    { "opId": "changes", "kind": "named_query", "query": "facts.changes_since", "params": { "since": "2026-10-01T00:00:00Z", "stream_kinds": ["offering_price", "model_availability"], "entity_kinds": null, "document_types": ["pricing_page", "release_notes"] } },
    { "opId": "units", "kind": "named_query", "query": "content.unit_changes", "params": { "document_id": null, "since": "2026-10-01T00:00:00Z", "limit": 100 } },
    { "opId": "refresh", "kind": "named_query", "query": "content.refresh_checks", "params": { "document_id": null, "outcome": "changed", "limit": 50 } }
  ]
}
```

To see a whole table as it stood before the change, use `q:catalog.models_at` / `q:catalog.model_offerings_at` with `at` = the date.

## Expected shape

`changes` rows: `change_source` (fact | event | document), `change_kind` (opened | replaced | …), `learned_at` and `knowledge_seq` (knowledge clock), `world_from` (world clock), `subject`, `stream_kind`, `scope_key`, `old_value`/`new_value`, and for documents `document_title`, `logical_key`, `unit_kind`, `changed_attributes`. `refresh` rows with `outcome = unchanged` are honest no-ops.

## Pitfalls

Two clocks: `since` is matched against `learned_at` (when we recorded it); a fact that *holds* since October but was learned later appears with its own `learned_at`. Unit changes are not yet facts — an `attribute_changed` price_row is an update proposal until an assertion mapping and a receipt turn it into a segment. Filter by `stream_kinds`/`document_types`; an unfiltered call over a busy tenant is large.
