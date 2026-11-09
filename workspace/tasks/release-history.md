---
id: "task:release-history"
kind: task
lens: corpus
domains: [api-surface, temporal-facts]
queries: [catalog.software, catalog.software_releases, events.current_for_entity, facts.changes_since]
aliases: [releases, changelog, version history, what shipped, breaking changes]
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
---
# Release history of a library, MCP server or model (what shipped when, breaking or not)

Domains: [`api-surface`](../domains/api-surface.md), [`temporal-facts`](../domains/temporal-facts.md). Queries: [`q:catalog.software`](../queries/README.md), [`q:catalog.software_releases`](../queries/README.md), [`q:events.current_for_entity`](../queries/README.md), [`q:facts.changes_since`](../queries/README.md).

## Navigation

`q:catalog.software` (find `software_id`) → `q:catalog.software_releases` → for the event view `q:events.current_for_entity`.

## Operation

```json
{
  "schemaVersion": "knowledge-read-intent.v1",
  "intentId": "langgraph-releases",
  "operations": [
    { "opId": "sw", "kind": "named_query", "query": "catalog.software", "params": { "kind": "library", "text": "langgraph", "limit": 10 } },
    { "opId": "releases", "kind": "named_query", "query": "catalog.software_releases", "params": { "software_id": "$sw.rows[0].software_id", "text": null, "limit": 100 } },
    { "opId": "events", "kind": "named_query", "query": "events.current_for_entity", "params": { "entity_id": "$sw.rows[0].software_id" } }
  ]
}
```

## Expected shape

`releases` rows newest first: `release` (the library_release entity), `version_label`, `released_at`, `breaking`, `highlights`, `release_url`, `learned_k` (knowledge seq when we learned it), `observed_at`. `events` rows: `release_published`, `release_yanked`, `repo_*` occurrences with `occurred_during`.

## Pitfalls

A release is an entity (`library_release`, `version_of` the library); its date is a fact, its publication an event — the view folds them. `breaking` null means unknown, not false. `learned_k` later than `released_at` is normal (we learned about it later); order by `released_at` for history, by `learned_k` for "what did we learn recently" (or use `tasks/what-changed-since.md`). Models version the same way (`ai_model_version`, `model_version_released`), but their table is `q:catalog.models`.
