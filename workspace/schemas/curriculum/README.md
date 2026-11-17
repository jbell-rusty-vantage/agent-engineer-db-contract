---
id: "sch:curriculum"
kind: schema
name: curriculum
lens: machinery
domains: [curriculum]
relations: 8
functions: 0
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# curriculum

Learning paths, modules, lessons, challenges, knowledge mappings. Lens `machinery`. Domains: [`curriculum`](../../domains/curriculum.md).

| Relation | Kind | Rows | Summary | Key edges |
| --- | --- | --- | --- | --- |
| [`outcome`](../../relations/curriculum/outcome.md) | table | unknown | — | → `authoring.work_revision` |
| [`outcome_alignment`](../../relations/curriculum/outcome_alignment.md) | table | unknown | — | → `authoring.work_revision`, → `curriculum.outcome` |
| [`part`](../../relations/curriculum/part.md) | table | small | — | → `authoring.work_revision` |
| [`prerequisite`](../../relations/curriculum/prerequisite.md) | table | unknown | — | → `authoring.work_revision` |
| [`release_transition`](../../relations/curriculum/release_transition.md) | table | unknown | — | → `authoring.release`, → `authoring.event` |
| [`requirement`](../../relations/curriculum/requirement.md) | table | unknown | — | → `curriculum.part`, → `authoring.work_revision`, → `curriculum.outcome` |
| [`requirement_option`](../../relations/curriculum/requirement_option.md) | table | small | — | → `auth.users`, → `authoring.work_revision`, → `curriculum.requirement` |
| [`requirement_transition`](../../relations/curriculum/requirement_transition.md) | table | unknown | — | → `curriculum.requirement`, → `curriculum.release_transition` |

Functions: none.

Types: none.
