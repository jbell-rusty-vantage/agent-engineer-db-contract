---
id: "task:talk-passage-at-timecode"
kind: task
lens: corpus
domains: [content, api-surface]
queries: [catalog.talks, content.talk_segments, content.document_units, vocab.unit_kind]
aliases: [timecode, transcript window, quote from talk, at minute, slide at]
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
---
# What was said in talk X between mm:ss and mm:ss (or where was Y said)?

Domains: [`content`](../domains/content.md), [`api-surface`](../domains/api-surface.md). Queries: [`q:catalog.talks`](../queries/README.md), [`q:content.talk_segments`](../queries/README.md), [`q:content.document_units`](../queries/README.md), [`q:vocab.unit_kind`](../queries/README.md).

## Navigation

`q:catalog.talks` (get `talk_id`) → `functions/api/talk_segments.md` → `q:content.talk_segments`.

## Operation

```json
{
  "schemaVersion": "knowledge-read-intent.v1",
  "intentId": "talk-window",
  "operations": [
    { "opId": "talk", "kind": "named_query", "query": "catalog.talks", "params": { "text": "Harness engineering", "event_id": null, "limit": 5 } },
    { "opId": "window", "kind": "named_query", "query": "content.talk_segments", "params": { "talk_id": "$talk.rows[0].talk_id", "from_ms": 600000, "to_ms": 720000, "query": null } },
    { "opId": "find", "kind": "named_query", "query": "content.talk_segments", "params": { "talk_id": "$talk.rows[0].talk_id", "from_ms": null, "to_ms": null, "query": "sandbox" } }
  ]
}
```

## Expected shape

Rows ordered by `start_ms`: `node_id`, `unit_kind` (`transcript_segment` or `slide`), `start_ms`, `end_ms`, `slide_n`, `text`, `document_id`, `representation_id`, `logical_key`. The `node_id` is the locator anchor for a citation (selector kind media_timecode).

## Pitfalls

Timecodes are milliseconds. A window may span a slide change: slides and transcript segments interleave by `start_ms`. `query` is a text filter on the segment text, not semantic — use `tasks/talks-on-topic.md` for meaning. The talk's transcript is a `content.document` (document type `aie_talk` or `video_transcript`) of the talk work entity; `q:content.document_units` shows all unit kinds of that document (`talk_header`, `talk_resource`, `talk_writeup`, …).
