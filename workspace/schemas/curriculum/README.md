---
id: "sch:curriculum"
kind: schema
name: curriculum
domains: [curriculum]
relations: 13
functions: 1
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# curriculum

Learning paths, modules, lessons, challenges, knowledge mappings. Domains: [`curriculum`](../../domains/curriculum.md).

| Relation | Kind | Rows | Summary | Key edges |
| --- | --- | --- | --- | --- |
| [`challenge`](../../relations/curriculum/challenge.md) | table | unknown | — | → `curriculum.module` |
| [`challenge_derived_from`](../../relations/curriculum/challenge_derived_from.md) | table | unknown | — | → `curriculum.challenge_version`, → `knowledge.failure_mode`, → `knowledge.implementation_example`, → `knowledge.technical_problem` |
| [`challenge_targets`](../../relations/curriculum/challenge_targets.md) | table | unknown | — | → `corpus.entity`, → `curriculum.challenge_version`, → `knowledge.solution_pattern` |
| [`challenge_version`](../../relations/curriculum/challenge_version.md) | table | unknown | — | → `curriculum.challenge`, → `orchestration.artifact` |
| [`curriculum`](../../relations/curriculum/curriculum.md) | table | unknown | — | — |
| [`learning_objective`](../../relations/curriculum/learning_objective.md) | table | unknown | — | → `curriculum.lesson_version` |
| [`lesson`](../../relations/curriculum/lesson.md) | table | unknown | — | → `curriculum.module` |
| [`lesson_backed_by`](../../relations/curriculum/lesson_backed_by.md) | table | unknown | — | → `knowledge.advanced_usage_pattern`, → `knowledge.benchmark_result`, → `knowledge.compatibility_constraint`, → `knowledge.failure_mode` |
| [`lesson_covers_concept`](../../relations/curriculum/lesson_covers_concept.md) | table | unknown | — | → `corpus.entity`, → `curriculum.lesson_version` |
| [`lesson_prerequisite`](../../relations/curriculum/lesson_prerequisite.md) | table | unknown | — | → `curriculum.lesson` |
| [`lesson_version`](../../relations/curriculum/lesson_version.md) | table | unknown | — | → `orchestration.artifact`, → `curriculum.lesson` |
| [`module`](../../relations/curriculum/module.md) | table | unknown | — | → `taxonomy.term`, → `curriculum.track` |
| [`track`](../../relations/curriculum/track.md) | table | unknown | — | → `curriculum.curriculum` |

Functions: [`lesson_version_guard`](../../functions/curriculum/lesson_version_guard.md).

Types: [`types/curriculum.md`](../../types/curriculum.md).
