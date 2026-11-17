---
id: "task:read-back-saved-revision"
kind: task
lens: ours
domains: [authoring, curriculum]
queries: [ours.works_authored]
aliases: [my workspaces, shared workspaces, workspace id, can I write, read back, saved structure, what did I save, bindings of a revision, parts of a module, revision structure]
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# Which workspaces can I write to, and what exactly did I save in this revision?

Domains: [`authoring`](../domains/authoring.md), [`curriculum`](../domains/curriculum.md). Queries: [`q:ours.works_authored`](../queries/README.md).

## Navigation

`domains/authoring.md` → `ops/list_workspaces.md` → `ops/list_works.md` → `ops/get_revision_structure.md` (and `ops/get_report.md` for the body and statements with support counts).

## Operation

```sql
-- the caller's own memberships; {"writable_only": true} keeps owner and editor
select api.product_read(null, 'list_workspaces', '{"writable_only": true}'::jsonb);
-- one saved revision: bindings, parts, outcomes, requirements with routes, prerequisites, runtime, statements
select api.product_read('0192a000-0000-7000-8000-000000000001', 'get_revision_structure',
                        '{"revision_id": "0192a000-0000-7000-8000-000000000002"}'::jsonb);
```

## Expected shape

`list_workspaces`: `[{workspaceId, name, kind, role, canWrite, ownedByYou, memberSince}]`, the personal workspace first (absent until `ensure_personal_workspace` has run once). `get_revision_structure`: `revisionId`, `workId`, `workKind`, `workSlug`, `workspaceId`, `revisionNo`, `title`, `origin`, `contentSha256`, `isHead`, `headRevisionId`, and the arrays `bindings` (`localKey`, `relation`, `target` {kind, id}, `role`, `blockKey`, `usage`), `parts` (`occurrenceKey`, `ordinal`, `role`, `childRevisionId`, `childKind`, `childTitle`, `childIsHead`), `outcomes` (with `evidenceRule` and `alignments`), `requirements` (`kind`, `outcomeKey` or `occurrenceKey`, `options` with `route` and `approvalState`), `prerequisites`, `runtime` (`versionSpec`, `resolvedVersion`), `statements` (`blockKey`, `supportStatus`, `usesClaimId`).

## Pitfalls

The structure read answers members of the revision's workspace only; a learner who reads a released revision uses `get_lesson_view`, and a non-member gets NOT_FOUND. A client grant that names workspaces narrows both reads to them. `childIsHead` false means the child was revised after it was placed: revise the parent to place the new revision. The body and blocks are `get_revision`; this read does not repeat them.
