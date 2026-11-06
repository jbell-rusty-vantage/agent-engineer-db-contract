---
id: "dom:curriculum"
kind: domain
schemas: [curriculum]
aliases: [lessons, challenges, learning paths]
relations: [curriculum.curriculum, curriculum.track, curriculum.module, curriculum.lesson, curriculum.lesson_version, curriculum.challenge, curriculum.learning_objective, curriculum.lesson_backed_by]
functions: [curriculum.lesson_version_guard]
tasks: [what-do-we-know-about-entity]
summary: Learning paths that point at concepts and knowledge records.
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# Curriculum

Learning paths that point at concepts and knowledge records.

> curated (model_assisted, unreviewed) — Curriculum is tracks, modules, versioned lessons, challenges, and learning
> objectives. `curriculum.lesson_covers_concept` and `curriculum.challenge_targets`
> reference `corpus.entity` (often kind concept, library, mcp_server, agent_skill).
> `curriculum.lesson_backed_by` points at typed knowledge records so a lesson is
> grounded in admitted engineering knowledge.
> 
> Lessons are not claims and not temporal facts. When a lesson cites a product
> behavior, the behavior still lives on a stream; the lesson only links. Agents
> building official courses should resolve the concept entity first, then attach
> backing records that already have receipts. `curriculum.lesson_prerequisite` and
> `curriculum.challenge_derived_from` keep the graph of what a learner must already
> know. Do not create a lesson that names a library the corpus cannot resolve.
> 
> Invariant: a lesson version is immutable; edits create `curriculum.lesson_version`
> rows. Trap: putting a product availability date on a lesson — that date belongs
> on `temporal.stream_kind:model_offering_availability`. Start with
> `what-do-we-know-about-entity` / `q:entity.card` for the concept, then attach
> backing records that already have receipts. Challenges
> (`curriculum.challenge`, `curriculum.challenge_version`) target the same
> identities. Official courses are agent-native: they must resolve the concept
> before they name it in prose.

## Relations that matter

| Relation | Summary | Enforced | Direct writers |
| --- | --- | --- | --- |
| [`curriculum.curriculum`](../relations/curriculum/curriculum.md) | table | PK (id); unique (tenant_id, slug, version); RLS | `executor_service` |
| [`curriculum.track`](../relations/curriculum/track.md) | table | PK (id); unique (curriculum_id, slug); RLS | `executor_service` |
| [`curriculum.module`](../relations/curriculum/module.md) | table | PK (id); unique (track_id, slug); RLS | `executor_service` |
| [`curriculum.lesson`](../relations/curriculum/lesson.md) | table | PK (id); unique (module_id, slug); RLS | `executor_service` |
| [`curriculum.lesson_version`](../relations/curriculum/lesson_version.md) | table | PK (id); unique (lesson_id, version); RLS | `executor_service` |
| [`curriculum.challenge`](../relations/curriculum/challenge.md) | table | PK (id); unique (tenant_id, slug); RLS | `executor_service` |
| [`curriculum.learning_objective`](../relations/curriculum/learning_objective.md) | table | PK (id); RLS | `executor_service` |
| [`curriculum.lesson_backed_by`](../relations/curriculum/lesson_backed_by.md) | table | PK (id); RLS | `executor_service` |

## Functions

[`curriculum.lesson_version_guard`](../functions/curriculum/lesson_version_guard.md)

## Named queries

[`q:entity.card`](../queries/README.md)

## Tasks

[`what-do-we-know-about-entity`](../tasks/what-do-we-know-about-entity.md)

Schemas: [`curriculum`](../schemas/curriculum/README.md).
