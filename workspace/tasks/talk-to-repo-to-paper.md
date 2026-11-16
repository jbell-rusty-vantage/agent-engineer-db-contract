---
id: "task:talk-to-repo-to-paper"
kind: task
lens: corpus
domains: [api-surface, relationships]
queries: [catalog.talks, catalog.software, catalog.papers, entity.relationships, relationships.current_by_kind]
aliases: [talk code, has_code, paper behind, repo for talk, technique lineage]
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:94ffe6a458de74a3cfebdee4fb31f371d14c89d7eaa16cfe1ab1cae9dc94743b"
---
# From a talk to the code it demos and the paper behind it

Domains: [`api-surface`](../domains/api-surface.md), [`relationships`](../domains/relationships.md). Queries: [`q:catalog.talks`](../queries/README.md), [`q:catalog.software`](../queries/README.md), [`q:catalog.papers`](../queries/README.md), [`q:entity.relationships`](../queries/README.md), [`q:relationships.current_by_kind`](../queries/README.md).

## Navigation

`q:catalog.talks` (`repositories` column) → `q:catalog.software` (`kind: repository`) → `q:catalog.papers` (`repositories`, `techniques`, `talks_about`); edges by hand with `q:entity.relationships`.

## Operation

```json
{
  "schemaVersion": "knowledge-read-intent.v1",
  "intentId": "talk-repo-paper",
  "operations": [
    { "opId": "talk", "kind": "named_query", "query": "catalog.talks", "params": { "text": "Agentic RAG", "event_id": null, "limit": 5 } },
    { "opId": "edges", "kind": "named_query", "query": "entity.relationships", "params": { "entity_id": "$talk.rows[0].talk_id", "kind": "has_code", "direction": "outgoing" } },
    { "opId": "repo", "kind": "named_query", "query": "catalog.software", "params": { "kind": "repository", "text": "$talk.rows[0].repositories[0]", "limit": 5 } },
    { "opId": "paper", "kind": "named_query", "query": "catalog.papers", "params": { "text": "$repo.rows[0].software", "limit": 10 } }
  ]
}
```

## Expected shape

`talk.repositories` names the has_code targets; `repo` rows carry `repository_url`, `developers`, `latest_release`, `stars`, `concepts`; `paper` rows carry `arxiv_id`, `doi`, `authors`, `repositories` (backed_by_repository), `techniques` (introduces_technique) and `talks_about`. `edges` gives the raw `catalog.relationship` rows with `primary_claim_id`.

## Pitfalls

The kinds are `has_code` (talk → repository), `backed_by_repository` (paper → repository), `introduces_technique` / `uses_technique` and `about` — check `q:vocab.relationship_kind` before asserting a new edge. A repository and a library are different entities (`backed_by_repository` vs `version_of`). Text filters on L1 views are substring matches; prefer ids once you have them.
