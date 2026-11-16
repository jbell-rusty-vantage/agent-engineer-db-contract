---
id: "dom:curriculum"
kind: domain
lens: machinery
schemas: [curriculum]
aliases: [course structure, learning outcomes, requirements, prerequisites, release transitions]
relations: [curriculum.part, curriculum.outcome, curriculum.requirement, curriculum.requirement_option, curriculum.prerequisite, curriculum.outcome_alignment, curriculum.release_transition, curriculum.requirement_transition]
functions: []
tasks: [modules-affected-by-release, modules-covering-concept, read-back-saved-revision]
summary: "Structure, outcomes and requirements of authored course works, keyed to authoring revisions (machinery lens: written by product operations)."
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:216c4ae7230478c8e60934da25c852e10680d6caed71a662962ea3c0ac1676d3"
---
# Curriculum structure

Structure, outcomes and requirements of authored course works, keyed to authoring revisions (machinery lens: written by product operations).

> curated (model_assisted, unreviewed) — Courses, modules and activities are authored works in the `authoring` schema; every
> curriculum row hangs off an `authoring.work_revision`. `curriculum.part` places a child
> revision inside a parent revision at an ordinal, as `recommended` or `optional`.
> `curriculum.outcome` states what a learner can do after a revision (optional Bloom level,
> an `aieng.evidence-rule` for proof). `curriculum.requirement` is what completion needs: an
> `outcome` or a `mandatory_activity` (a part). `curriculum.requirement_option` lists the
> routes that satisfy it (`standard`, `prior_work`, `test_out`, `alternative`,
> `generated_eligible`, `learner_project`), each `proposed` until approved.
> `curriculum.prerequisite` links revisions as `recommended` or `required`.
> `curriculum.outcome_alignment` maps an outcome to a competency revision by facet.
> 
> Releases change over time: `curriculum.release_transition` maps one `authoring.release`
> to the next (`needs_review`, `compatible`, `breaking`), and
> `curriculum.requirement_transition` says per requirement whether learner progress carries,
> needs reassessment or does not apply.
> 
> These rows are written by product operations (create_work, revise_work, freeze_release),
> never directly. Invariants: rows reference revisions, never mutable heads; a part cannot
> contain itself; a requirement is exactly one kind. Trap: putting a product availability
> date in course structure; that fact belongs on
> `temporal.stream_kind:model_offering_availability`, cited from content.

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

[`q:ours.works_authored`](../queries/README.md)

## Tasks

[`modules-affected-by-release`](../tasks/modules-affected-by-release.md), [`modules-covering-concept`](../tasks/modules-covering-concept.md), [`read-back-saved-revision`](../tasks/read-back-saved-revision.md)

Schemas: [`curriculum`](../schemas/curriculum/README.md).
