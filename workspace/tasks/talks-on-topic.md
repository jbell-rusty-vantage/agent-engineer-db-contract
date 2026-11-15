---
id: "task:talks-on-topic"
kind: task
lens: corpus
domains: [api-surface, content, retrieval]
queries: [catalog.concepts, catalog.talks, retrieval.search_unified, content.document_digest]
aliases: [talks about, sessions on, who spoke about, conference talks on]
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
---
# Which talks cover <topic>, who gave them, where?

Domains: [`api-surface`](../domains/api-surface.md), [`content`](../domains/content.md), [`retrieval`](../domains/retrieval.md). Queries: [`q:catalog.concepts`](../queries/README.md), [`q:catalog.talks`](../queries/README.md), [`q:retrieval.search_unified`](../queries/README.md), [`q:content.document_digest`](../queries/README.md).

## Navigation

`q:catalog.talks` (text matches title, topics, speakers) → for passages `q:retrieval.search_unified` with `document_types: [aie_talk]` → `q:content.document_digest` for the talk's digest.

## Operation

```json
{
  "schemaVersion": "knowledge-read-intent.v1",
  "intentId": "talks-context-engineering",
  "operations": [
    { "opId": "concept", "kind": "named_query", "query": "catalog.concepts", "params": { "text": "context engineering", "limit": 5 } },
    { "opId": "talks", "kind": "named_query", "query": "catalog.talks", "params": { "text": "context engineering", "event_id": null, "limit": 50 } },
    { "opId": "passages", "kind": "named_query", "query": "retrieval.search_unified", "params": { "query": "context engineering", "lenses": ["corpus"], "document_types": ["aie_talk"], "unit_kinds": ["transcript_segment", "slide"], "limit": 20 } },
    { "opId": "digest", "kind": "named_query", "query": "content.document_digest", "params": { "document_id": "$passages.rows[0].document_id" } }
  ]
}
```

## Expected shape

`talks` rows: `title`, `talk_kind`, `track`, `event`, `event_starts_on`, `speakers`, `speaker_affiliations`, `topics` (about edges), `repositories` (has_code), `video_url`, `slides_url`, `document_count`. `passages` rows: `snippet`, `start_ms`/`end_ms`, `document_id`, `unit_kind`, `fused_score`. `digest` rows: key points and entity roles anchored to `node_ids`.

## Pitfalls

`topics` come from `about` relationships to concept entities; a talk that mentions a topic only in its transcript appears in `passages`, not in `talks`. Without an embedding `search_unified` is lexical (full-text + trigram). Speaker is the talk's presenter unless a segment carries a speaker attribute; ai.engineer transcripts have none. Follow `tasks/talk-passage-at-timecode.md` to quote a passage.
