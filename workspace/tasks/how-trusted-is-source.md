---
id: "task:how-trusted-is-source"
kind: task
lens: evidence
domains: [source-intelligence, evidence]
queries: [evidence.source_registry, evidence.source_track_record, acquisition.attention_policies]
aliases: [source trust, trustworthy source, authority, reliability, track record, source registry, source assessment, who to believe about]
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# How much is a source trusted on a topic?

Domains: [`source-intelligence`](../domains/source-intelligence.md), [`evidence`](../domains/evidence.md). Queries: [`q:evidence.source_registry`](../queries/README.md), [`q:evidence.source_track_record`](../queries/README.md), [`q:acquisition.attention_policies`](../queries/README.md).

## Navigation

`START_HERE.md` (L1) → `relations/api/source_registry.md` → `q:evidence.source_registry` → `q:evidence.source_track_record` for the claims behind the counts.

## Operation

`api.source_registry` is the latest assessment per source and topic; `api.source_track_record` is the claims it rests on.

```json
{
  "schemaVersion": "knowledge-read-intent.v1",
  "intentId": "sources-on-langchain",
  "operations": [
    { "opId": "registry", "kind": "named_query", "query": "evidence.source_registry", "params": { "source": null, "topic": "LangChain", "limit": 20 } },
    { "opId": "record", "kind": "named_query", "query": "evidence.source_track_record", "params": { "source_entity_id": "$registry.rows[0].source_entity_id", "source": null, "limit": 50 } }
  ]
}
```

## Expected shape

`registry` rows, one per source and topic at its latest assessment (`as_of`): `source`, `source_kind`, `platform`, `url`, `topic`, `source_role_code`, `conflict_of_interest`, `method_disclosure`, `claims_observed`, `claims_checked`, `confirmed`, `qualified`, `refuted`, `self_checked`, `median_lead_days`, `noise_ratio`, `authority_score`, `recommended_watch_level`, `current_watch_level`, `rationale`. `record` rows: each claim the source stated with `status`, `stated_at`, `first_party_at`, `verdict`, `probe`.

## Pitfalls

Read the components, not the score alone: `authority_score` is derived from the role prior and the checked claims, and with few `claims_checked` it is mostly the prior. A watch level is recommended only from five checked claims. `self_checked` counts claims the source checked about itself; they are shown and not scored. A null `topic` is the source overall; a topic row is trust on that topic only. `median_lead_days` is how long before the first-party docs the source said it. Trust is about what was checked: `q:evidence.source_track_record` shows which claims, and a refuted claim there is `tasks/why-claim-disputed-or-restated.md`.
