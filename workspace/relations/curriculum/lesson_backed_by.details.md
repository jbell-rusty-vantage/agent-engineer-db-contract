---
id: "rel:curriculum.lesson_backed_by#details"
kind: details
schema: curriculum
name: lesson_backed_by
of: "rel:curriculum.lesson_backed_by"
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# curriculum.lesson_backed_by — details

Spill-over from [the main page](lesson_backed_by.md).

## Relationships

Outbound: `advanced_usage_pattern_id` → [`knowledge.advanced_usage_pattern`](../knowledge/advanced_usage_pattern.md)`.id`; `benchmark_result_id` → [`knowledge.benchmark_result`](../knowledge/benchmark_result.md)`.id`; `compatibility_constraint_id` → [`knowledge.compatibility_constraint`](../knowledge/compatibility_constraint.md)`.id`; `failure_mode_id` → [`knowledge.failure_mode`](../knowledge/failure_mode.md)`.id`; `implementation_example_id` → [`knowledge.implementation_example`](../knowledge/implementation_example.md)`.id`; `lesson_version_id` → [`curriculum.lesson_version`](lesson_version.md)`.id` on delete cascade; `operational_practice_id` → [`knowledge.operational_practice`](../knowledge/operational_practice.md)`.id`; `security_consideration_id` → [`knowledge.security_consideration`](../knowledge/security_consideration.md)`.id`; `solution_pattern_id` → [`knowledge.solution_pattern`](../knowledge/solution_pattern.md)`.id`; `technical_problem_id` → [`knowledge.technical_problem`](../knowledge/technical_problem.md)`.id`.
Inbound: none.
Polymorphic: exactly one of `technical_problem_id`, `solution_pattern_id`, `advanced_usage_pattern_id`, `implementation_example_id`, `failure_mode_id`, `benchmark_result_id`, `compatibility_constraint_id`, `operational_practice_id`, `security_consideration_id` → [`knowledge.advanced_usage_pattern`](../knowledge/advanced_usage_pattern.md) | [`knowledge.benchmark_result`](../knowledge/benchmark_result.md) | [`knowledge.compatibility_constraint`](../knowledge/compatibility_constraint.md) | [`knowledge.failure_mode`](../knowledge/failure_mode.md) | [`knowledge.implementation_example`](../knowledge/implementation_example.md) | [`knowledge.operational_practice`](../knowledge/operational_practice.md) | [`knowledge.security_consideration`](../knowledge/security_consideration.md) | [`knowledge.solution_pattern`](../knowledge/solution_pattern.md) | [`knowledge.technical_problem`](../knowledge/technical_problem.md) — basis: check constraint lesson_backed_by_exactly_one.

## Indexes

| Index | Definition |
| --- | --- |
| `lesson_backed_by_kind_idx` | `CREATE INDEX lesson_backed_by_kind_idx ON curriculum.lesson_backed_by USING btree (record_kind)` |
| `lesson_backed_by_lesson_idx` | `CREATE INDEX lesson_backed_by_lesson_idx ON curriculum.lesson_backed_by USING btree (lesson_version_id)` |

## Triggers

_None._

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: using `false`; with check `false`
