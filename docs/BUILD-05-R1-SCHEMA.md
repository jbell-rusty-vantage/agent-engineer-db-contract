# Build 05 R1: content blocks, media roles, file sets and deployments, learner layer, projects, challenges, environments

**Status: ACCEPTED by John, 2026-11-05** (“I agree with all your recommendations.” — answers C1–C8 in the [Build 05 record](../../../platform/ai-engineer-research-2026-11-02/10-review-workspace/reviews/BUILD-05-CONTENT-AND-PROJECTS.md)). Implemented in the lab migrations on branch `build-04-product-schema-lab`, folded into the unreleased Build 01–04 files rather than layered on top.

## A. One lesson section, end to end

A lesson revision's body is **`aieng.work-body.v2`**: an ordered tree of blocks. Every block has a **stable `key`** (UUID) that the author keeps across revisions, a `type` from the block-type catalog, optional `children` (sections), `content` (small structured data, text inline), a `fallback` (plain text / description used by text-only surfaces, required for every non-text type) and `bindings` (local keys of the revision's typed bindings). Media and files are never inline: a binding with a **role** points to an artifact (one file) or a **file set** (many files, e.g. a harness-built site). An interactive block names an exact `component` revision (renderer). A block reused across lessons is a `snippet` work referenced with a `uses` binding.

When a revision is saved, the server writes one **`authoring.revision_block`** row per block (key, type, parent, position, digest). That projection gives every surface a validated anchor `(revision, block_key)` for feedback, citations, search passages, learner annotations and progress, and lets a learner's anchor survive a later revision that keeps the key.

## B. Block-type catalog (data, not code)

`authoring.block_type(code, tier, needs_fallback, required_roles text[], allowed_roles text[], description)`. Seeded tier 1: `text, callout, math, code, image, diagram, video, table, chart, quiz, interactive, embedded_site, external_embed, sources_panel, challenge_embed, project_milestone, section, snippet_ref`; tier 2: `runnable_code, terminal, audio, slides`. `video` requires roles `original` + `transcript` + `captions`; `audio` requires `original` + `transcript`; `embedded_site` requires a file-set `build` binding or an external deployment reference; `image`/`diagram` require `original`. Adding a block type is a row plus a component, not a migration of the API.

## C. Changes to accepted relations

| Object | Change |
| --- | --- |
| `authoring.work.kind` | + `snippet`, `challenge`, `project_template` (`project` remains the learner's instance) |
| `authoring.revision_binding` | + `role` (original, transcript, captions, thumbnail, poster, accessible_fallback, source, build, static_export, lockfile, starter, solution, hidden_check, dataset, environment_spec), + `block_key`, + target `file_set_id`, + relation `anchored_to` (learner layer → released or own revision, optional block key). `hidden_check`/`solution` roles are always withheld at release |
| `curriculum.requirement_option.route` | + `learner_project` (maintainer-approved route under which approved learner proposals count) |
| `learning.attempt` | + `equivalence_request_id`, `environment_session_id` |
| `learning.evidence_item` | + targets `file_set_id`, `deployment_id` |
| Release exposure | traverses file-set entries; withheld roles applied |

## D. New relations

| Relation / one row | Key rules |
| --- | --- |
| `authoring.block_type` / one renderable block type | Reference data, tenant-independent; seeded; immutable except new rows |
| `authoring.revision_block` / one block in one saved revision | UNIQUE(revision, block_key); parent key and position; type FK to catalog; written only by the revision writer, sealed with the revision |
| `authoring.file_set` / one immutable multi-file tree (site, repo snapshot, build) | Entry point path; tree digest over sorted `path:sha256`; file count/bytes; every file an artifact admitted to the same workspace |
| `authoring.file_set_entry` / one path in a file set | UNIQUE(file_set, path); normalized relative path (no `..`, no leading `/`) |
| `authoring.deployment` / one place a revision/file set is served | target `platform_static` (isolated origin URL derived from the deployment id) or `external` (URL + provider/commit/deployment id, optional snapshot file set); environment preview/published; status pending/live/failed/retired |
| `learning.equivalence_request` / learner asks that their own project or challenge count for required outcomes | enrollment, learner work revision, requirement keys, evidence plan; assistant check (`aieng.decision-answer.v1`, advisory only); state proposed/checked/approved/rejected/withdrawn; approval by course maintainer, or automatic when the learner owns the course |
| `learning.environment_session` / one real environment a learner works in | provider local_harness / browser_runtime / cloud_sandbox (named adapter) / external; spec revision; status requested/provisioning/ready/stopped/expired/failed; key handles with source byo/platform; spend limit and spent; expiry |
| `access.provided_credential` / one platform-provided key handle with a spending limit | principal, provider key, secret handle (never a secret), limit and period, expiry, revocation; issued by the worker only |

## E. Metadata contracts

- `aieng.challenge.v1`: `designed_by` system/teacher/learner/assistant; `runs_in` in_app/browser_runtime/cloud_sandbox/harness/external_platform/real_deployment; `browser_runtime` pyodide/webcontainers when `runs_in=browser_runtime`; starting-state and solution binding keys; constraints; assistance; `verification` ⊆ auto_in_app/runner/external_evidence/rubric/defense.
- `aieng.project-template.v1`: `mode` guided/challenge_based; brief; environment spec binding; starter binding; milestones are ordered parts (challenge/activity/lesson revisions) whose requirements say which are mandatory.
- `aieng.project.v1` (learner instance): `origin` template/custom; template release item (when from a template); repository; deployments; proposal.

## F. Invariants

Learner-layer works live only in the learner's personal workspace and are private; anchors require a readable target and an existing block key. Learner-designed challenges and custom projects produce practice attempts unless an approved equivalence request covers the requirement and the release offers an approved `learner_project` route. Hidden checks and solutions never reach learners. A deployment never makes a private file public by itself: platform static hosting serves only file sets released or owned by the viewer, from an isolated origin. Provided credentials are handles with limits; secrets never enter rows, bodies or file sets.
