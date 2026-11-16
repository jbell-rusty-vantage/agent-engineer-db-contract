---
id: "task:search-my-notes"
kind: task
lens: private
domains: [library, retrieval, access]
queries: [retrieval.search_unified]
aliases: [my notes, private search, search uploads, search conversations, learner notes]
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:216c4ae7230478c8e60934da25c852e10680d6caed71a662962ea3c0ac1676d3"
---
# Search my own notes, uploads and conversations (private lens)

Domains: [`library`](../domains/library.md), [`retrieval`](../domains/retrieval.md), [`access`](../domains/access.md). Queries: [`q:retrieval.search_unified`](../queries/README.md).

## Navigation

`domains/library.md` → `ops/search.md` (the product operation) or `q:retrieval.search_unified` with `lenses: [private]` and your `workspace_ids`.

## Operation

Through the product (readability rules applied for you):

```sql
select api.product_read(p_workspace_id, 'search', '{"query": "retry with exponential backoff", "limit": 20}'::jsonb);
```

Through the catalog as an operator (you must pass the workspaces you may read):

```json
{
  "schemaVersion": "knowledge-read-intent.v1",
  "intentId": "my-notes-backoff",
  "operations": [
    { "opId": "notes", "kind": "named_query", "query": "retrieval.search_unified", "params": { "query": "retry with exponential backoff", "lenses": ["private", "ours"], "space_slugs": ["learner_notes", "own_content"], "workspace_ids": ["0192a000-0000-7000-8000-000000000001"], "limit": 20 } }
  ]
}
```

## Expected shape

Product `search` returns `[{label, passageId, revisionId, workKind, locator, snippet, rank, lens, tier, channels}]` with `label` in private_note | uploaded_source | conversation | course_material. The catalog form returns `vector_item_id`, `lens`, `source_tier`, `target_kind` = passage, `target_id` (the `library.passage` id), `workspace_id`, `snippet`, `fused_score`.

## Pitfalls

Private items are returned only for the `workspace_ids` passed in; an empty list or null returns no private rows (no error). The product operation additionally hides purged revisions, redacted messages, removed resources and `deny_all` restricted artifacts — the raw catalog query does not, so prefer `ops/search.md` for learners. Without an embedding the search is lexical (english full-text + trigram). Notes become searchable only after the worker `index_passages` runs.
