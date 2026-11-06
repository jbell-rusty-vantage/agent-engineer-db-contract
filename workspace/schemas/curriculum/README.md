---
id: "sch:curriculum"
kind: schema
name: curriculum
domains: [curriculum]
relations: 8
functions: 0
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# curriculum

Learning paths, modules, lessons, challenges, knowledge mappings. Domains: [`curriculum`](../../domains/curriculum.md).

| Relation | Kind | Rows | Summary | Key edges |
| --- | --- | --- | --- | --- |
| [`outcome`](../../relations/curriculum/outcome.md) | table | unknown | — | → `authoring.work_revision` |
| [`outcome_alignment`](../../relations/curriculum/outcome_alignment.md) | table | unknown | — | → `authoring.work_revision`, → `curriculum.outcome` |
| [`part`](../../relations/curriculum/part.md) | table | unknown | — | → `authoring.work_revision` |
| [`prerequisite`](../../relations/curriculum/prerequisite.md) | table | unknown | — | → `authoring.work_revision` |
| [`release_transition`](../../relations/curriculum/release_transition.md) | table | unknown | — | → `authoring.release`, → `authoring.event` |
| [`requirement`](../../relations/curriculum/requirement.md) | table | unknown | — | → `curriculum.part`, → `authoring.work_revision`, → `curriculum.outcome` |
| [`requirement_option`](../../relations/curriculum/requirement_option.md) | table | unknown | — | → `auth.users`, → `authoring.work_revision`, → `curriculum.requirement` |
| [`requirement_transition`](../../relations/curriculum/requirement_transition.md) | table | unknown | — | → `curriculum.requirement`, → `curriculum.release_transition` |

Functions: none.

Types: none.
