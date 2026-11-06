---
id: "dom:curriculum"
kind: domain
schemas: [curriculum]
aliases: [course structure, learning outcomes, requirements, prerequisites, release transitions]
relations: [curriculum.part, curriculum.outcome, curriculum.requirement, curriculum.requirement_option, curriculum.prerequisite, curriculum.outcome_alignment, curriculum.release_transition, curriculum.requirement_transition]
functions: []
tasks: [what-do-we-know-about-entity]
summary: "Structure, outcomes and requirements of authored course works, keyed to authoring revisions."
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# Curriculum

Structure, outcomes and requirements of authored course works, keyed to authoring revisions.

> curated (model_assisted, unreviewed) — Since the Build 01 product schema (2026-11-05), curriculum no longer owns lessons,
> challenges or tracks. Courses, modules and activities are authored works in the
> `authoring` schema; every curriculum row hangs off an `authoring.work_revision`.
> The thirteen legacy relations (`curriculum.curriculum`, `track`, `module`,
> `lesson`, `lesson_version`, `challenge`, `learning_objective`, …) were dropped by
> the curriculum cutover migration.
> 
> `curriculum.part` places a child revision inside a parent revision at an ordinal,
> as `recommended` or `optional`. `curriculum.outcome` states what a learner can do
> after a revision (optional Bloom level, an `aieng.evidence-rule` for proof).
> `curriculum.requirement` is what completion needs: an `outcome` or a
> `mandatory_activity` (a part). `curriculum.requirement_option` lists the routes
> that satisfy it (`standard`, `prior_work`, `test_out`, `alternative`,
> `generated_eligible`, `learner_project`), each `proposed` until approved.
> `curriculum.prerequisite` links revisions as `recommended` or `required`, with a
> rationale. `curriculum.outcome_alignment` maps an outcome to a competency revision
> by facet (`independent`, `assisted`, `agent_directed`) and coverage.
> 
> Releases change over time: `curriculum.release_transition` maps one
> `authoring.release` to the next (`needs_review`, `compatible`, `breaking`; a
> compatible transition needs a reviewed event), and
> `curriculum.requirement_transition` says per requirement whether learner progress
> carries, needs reassessment or does not apply.
> 
> Invariants: rows are scoped by tenant and workspace and reference revisions, never
> mutable heads; a part cannot contain itself; a requirement is exactly one kind.
> Trap: putting a product availability date in course structure; that fact belongs
> on `temporal.stream_kind:model_offering_availability`, cited from content. Resolve
> a concept with `what-do-we-know-about-entity` / `q:entity.card` before course
> content names it.

## Relations that matter

| Relation | Summary | Enforced | Direct writers |
| --- | --- | --- | --- |
| [`curriculum.part`](../relations/curriculum/part.md) | table | PK (id); unique (tenant_id, id), (tenant_id, workspace_id, id), (tenant_id, workspace_id, parent_revision_id, occurrence_key), (tenant_id, workspace_id, parent_revision_id, ordinal); RLS | helpers only |
| [`curriculum.outcome`](../relations/curriculum/outcome.md) | table | PK (id); unique (tenant_id, id), (tenant_id, workspace_id, id), (tenant_id, workspace_id, revision_id, id), (tenant_id, workspace_id, revision_id, outcome_key); RLS | helpers only |
| [`curriculum.requirement`](../relations/curriculum/requirement.md) | table | PK (id); unique (tenant_id, id), (tenant_id, workspace_id, id), (tenant_id, workspace_id, revision_id, requirement_key); RLS | helpers only |
| [`curriculum.requirement_option`](../relations/curriculum/requirement_option.md) | table | PK (id); unique (tenant_id, id), (tenant_id, workspace_id, id); RLS | helpers only |
| [`curriculum.prerequisite`](../relations/curriculum/prerequisite.md) | table | PK (id); unique (tenant_id, workspace_id, id), (tenant_id, workspace_id, revision_id, required_revision_id); RLS | helpers only |
| [`curriculum.outcome_alignment`](../relations/curriculum/outcome_alignment.md) | table | PK (id); unique (tenant_id, workspace_id, id), (tenant_id, workspace_id, outcome_id, competency_revision_id, facet); RLS | helpers only |
| [`curriculum.release_transition`](../relations/curriculum/release_transition.md) | table | PK (id); unique (tenant_id, id), (tenant_id, workspace_id, from_release_id, to_release_id), (tenant_id, workspace_id, id); RLS | helpers only |
| [`curriculum.requirement_transition`](../relations/curriculum/requirement_transition.md) | table | PK (id); unique (tenant_id, workspace_id, id); RLS | helpers only |

## Named queries

[`q:entity.card`](../queries/README.md)

## Tasks

[`what-do-we-know-about-entity`](../tasks/what-do-we-know-about-entity.md)

Schemas: [`curriculum`](../schemas/curriculum/README.md).
