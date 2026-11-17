---
id: "task:hand-over-for-review"
kind: task
lens: ours
domains: [authoring]
queries: [ours.works_authored]
aliases: [ready for review, request review, review request, hand over, hand-over, submitted for review, review status, feedback, reviewer replies, awaiting review]
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# How do I hand a revision to a person for review, and what feedback did I get?

Domains: [`authoring`](../domains/authoring.md). Queries: [`q:ours.works_authored`](../queries/README.md).

## Navigation

`ops/preview_exposure.md` → `ops/create_thread.md` and `ops/append_message.md` (the note) → `ops/mark_ready_for_review.md` → `ops/list_reviews.md`; the person's act is `ops/review_revision.md`.

## Operation

```sql
-- the author's own act: an owner or editor marks an exact revision ready, naming the hand-over conversation
select api.product_command('0192a000-0000-7000-8000-000000000001', 'mark_ready_for_review', 'module-7:ready:1', null,
  '{"revision_id": "0192a000-0000-7000-8000-000000000002", "ceiling": "workspace",
    "note": "Module 7: two lessons and the activity; every lesson was run.", "thread_id": "0192a000-0000-7000-8000-000000000003"}'::jsonb);
-- requests with their status, the reviews recorded since and the replies after the note
select api.product_read('0192a000-0000-7000-8000-000000000001', 'list_reviews', '{"status": "awaiting_review"}'::jsonb);
```

## Expected shape

`mark_ready_for_review`: `eventId`, `workId`, `revisionId`, `ceiling`, `closureSha256` (computed by the database, equal to `preview_exposure` at that ceiling), `items`, `blockers`, `threadId`, `alreadyRequested` (true when the same revision was already marked at that ceiling; the first request is returned). `list_reviews`: `requests` `[{requestId, revisionId, revisionNo, title, isHead, status, ceiling, closureSha256, note, threadId, actorKind, reviews: [{eventId, kind, reviewType, decision, actorKind, byYou, payload}], replies: [{seq, role, fromPerson, content}]}]` and `reviews` (reviews recorded on a revision without a request).

## Pitfalls

Marking ready records no review and changes nothing a release needs: a person still records `review_revision` (release_review with the closure and ceiling) before `freeze_release`. `status` is `reviewed` only after a person's review (actor kind human); an agent's own review event is listed with actor kind agent and leaves the request awaiting review. A request whose revision is no longer the work's head and was not reviewed is `superseded`. Replies are the messages after the note, from a workspace-visible conversation; a private conversation of another member cannot be attached (NOT_FOUND). Readers of the workspace can list reviews; only owners and editors can mark ready.
