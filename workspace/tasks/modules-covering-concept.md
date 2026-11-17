---
id: "task:modules-covering-concept"
kind: task
lens: ours
domains: [authoring, api-surface, guidance, retrieval]
queries: [catalog.concepts, ours.works_authored, guidance.items, retrieval.search_unified, catalog.software]
aliases: [coverage, modules about, course coverage, what do we teach about]
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# Which of our modules cover <concept>, and what guidance exists for it?

Domains: [`authoring`](../domains/authoring.md), [`api-surface`](../domains/api-surface.md), [`guidance`](../domains/guidance.md), [`retrieval`](../domains/retrieval.md). Queries: [`q:catalog.concepts`](../queries/README.md), [`q:ours.works_authored`](../queries/README.md), [`q:guidance.items`](../queries/README.md), [`q:retrieval.search_unified`](../queries/README.md), [`q:catalog.software`](../queries/README.md).

## Navigation

`q:catalog.concepts` (`modules_covering`, `guidance_items` counts) → `q:ours.works_authored` (text matches `covers_concepts`) → `q:guidance.items` → `q:retrieval.search_unified` with lens ours.

## Operation

```json
{
  "schemaVersion": "knowledge-read-intent.v1",
  "intentId": "coverage-mcp",
  "operations": [
    { "opId": "concept", "kind": "named_query", "query": "catalog.concepts", "params": { "text": "MCP", "limit": 5 } },
    { "opId": "modules", "kind": "named_query", "query": "ours.works_authored", "params": { "kind": "module", "released": null, "text": "MCP", "limit": 50 } },
    { "opId": "guidance", "kind": "named_query", "query": "guidance.items", "params": { "kind": null, "entity_id": "$concept.rows[0].concept_id", "text": null, "limit": 50 } },
    { "opId": "passages", "kind": "named_query", "query": "retrieval.search_unified", "params": { "query": "Model Context Protocol server", "lenses": ["ours"], "space_slugs": ["own_content"], "limit": 20 } }
  ]
}
```

## Expected shape

`modules` rows: `work_id`, `kind`, `slug`, `title`, `head_revision_id`, `released`, `covers_concepts`, `uses_software`, `runtime_requirements`, `source_tier` 1. `guidance` rows: typed items (failure_mode, solution_pattern, …) with `assurance_level` and `subject_entity_ids`. `concept` row counts (`works_about`, `implementations`, `guidance_items`, `modules_covering`) tell you how much exists before you read.

## Pitfalls

Coverage is declared by `authoring.revision_binding` on the head revision; an unreleased draft counts in `modules_covering` unless you filter `released: true`. Lens ours passages exist only for released material indexed in `own_content`; drafts are not searchable. Guidance items are corpus knowledge about the concept, not our teaching text — cite them in a module rather than restating them.
