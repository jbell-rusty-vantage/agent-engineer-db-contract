---
id: "task:modules-affected-by-release"
kind: task
lens: ours
domains: [authoring, api-surface]
queries: [catalog.software_releases, ours.modules_affected_by_release, ours.works_authored]
aliases: [flywheel, release impact, stale modules, needs review after release]
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
---
# Which of our modules does a new software release affect?

Domains: [`authoring`](../domains/authoring.md), [`api-surface`](../domains/api-surface.md). Queries: [`q:catalog.software_releases`](../queries/README.md), [`q:ours.modules_affected_by_release`](../queries/README.md), [`q:ours.works_authored`](../queries/README.md).

## Navigation

`tasks/release-history.md` → `q:catalog.software_releases` (get `release_id`) → `functions/api/modules_affected_by_release.md` → `q:ours.modules_affected_by_release` → `ops/revise_work.md`.

## Operation

```json
{
  "schemaVersion": "knowledge-read-intent.v1",
  "intentId": "flywheel-langgraph",
  "operations": [
    { "opId": "releases", "kind": "named_query", "query": "catalog.software_releases", "params": { "software_id": null, "text": "langgraph", "limit": 5 } },
    { "opId": "affected", "kind": "named_query", "query": "ours.modules_affected_by_release", "params": { "release_id": "$releases.rows[0].release_id" } }
  ]
}
```

Then, per affected head revision, read it with `api.product_read(workspace, 'get_revision', {"revision_id": …})` and propose a new revision with `api.product_command(workspace, 'revise_work', key, head, {"work_id": …, "revision": {…}})` (`ops/revise_work.md`), or record a `review_revision` with reviewType `runtime_review`.

## Expected shape

Rows: `work_id`, `work_kind`, `work_slug`, `revision_id`, `revision_title`, `revision_created_at`, `software`, `release`, `released_at`, `breaking`, `binding` (uses | covers | requires), `version_spec`. `breaking = true` rows need review first.

## Pitfalls

Only head revisions authored *before* the release appear; a revision created after it is assumed to know about it. `version_spec` is the author's declared range — a release inside the range is not "affected" unless `breaking`. Agents may propose revisions and `runtime_review` events but cannot record human `release_review` approvals. Curriculum `curriculum.release_transition` is about *our* releases, not software releases.
