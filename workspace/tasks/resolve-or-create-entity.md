---
id: "task:resolve-or-create-entity"
kind: task
lens: corpus
domains: [identity, staging]
queries: [entity.resolve, entity.by_identifier, entity.attributes, staging.unresolved]
aliases: [create entity, identity]
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# Resolve or create an entity

Domains: [`identity`](../domains/identity.md), [`staging`](../domains/staging.md). Queries: [`q:entity.resolve`](../queries/README.md), [`q:entity.by_identifier`](../queries/README.md), [`q:entity.attributes`](../queries/README.md), [`q:staging.unresolved`](../queries/README.md).

## Navigation

`domains/identity.md` → `domains/staging.md` → `tasks/stage-uncertain-candidate.md`

## Operation

Read first, then ingest only if resolve and identifier miss:

```json
{
  "schemaVersion": "knowledge-read-intent.v1",
  "intentId": "resolve-gpt-offering",
  "operations": [
    { "opId": "id", "kind": "named_query", "query": "entity.by_identifier", "params": { "scheme": "other", "value": "gpt-5.6-terra" } },
    { "opId": "name", "kind": "named_query", "query": "entity.resolve", "params": { "text": "GPT-5.6 Terra" } }
  ]
}
```

```json
{
  "schemaVersion": "knowledge-ingestion-intent.v1",
  "intentId": "create-gpt-5-6-terra-offering",
  "expectedKnowledgeHead": 41,
  "onStale": "rebase_if_disjoint",
  "subjects": [
    {
      "ref": "gpt-5.6-terra-offering",
      "mode": "new",
      "kind": "model_offering",
      "displayName": "GPT-5.6 Terra (API)",
      "attributes": { "offering_key": "gpt-5.6-terra", "region": "global", "tier": "standard" },
      "identifiers": [{ "scheme": "other", "value": "gpt-5.6-terra" }],
      "onMatch": "review"
    }
  ],
  "proposals": [
    { "proposalId": "p-create", "kind": "entity.create", "subjectRef": "gpt-5.6-terra-offering", "belief": "accepted" }
  ]
}
```

## Expected shape

Identifier hit: one row, score implied 1.0. Name resolve: score ≥ 0.98 means use the existing id. Otherwise a new subject becomes one `catalog.entity` row whose `attributes` passed the kind's `attributes_schema`, after a receipt.

## Pitfalls

`kind` must be a `taxonomy.entity_kind` code and `attributes` must satisfy that kind's schema (`model_offering` requires `offering_key`; `ai_model_version` requires `version_label`). Do not invent identifier schemes; the scheme check is a closed list (use `other` when there is no native scheme). High-confidence matches without `onMatch: use_existing` become `review_required`. A `model_offering` also needs its parent `ai_model_version` and an `offered_as` relationship.
