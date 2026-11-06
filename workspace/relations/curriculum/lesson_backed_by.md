---
id: "rel:curriculum.lesson_backed_by"
kind: table
schema: curriculum
name: lesson_backed_by
domain: curriculum
aliases: []
tokens: [curriculum, lesson_backed_by, curriculum.lesson_backed_by, id, lesson_version_id, technical_problem_id, solution_pattern_id, advanced_usage_pattern_id, implementation_example_id, failure_mode_id, benchmark_result_id, compatibility_constraint_id, operational_practice_id, security_consideration_id, record_kind, assertion_ref, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"curriculum\"][\"Tables\"][\"lesson_backed_by\"][\"Row\"]"
defined_in: ["20260826001300_curriculum.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# curriculum.lesson_backed_by

table in domain `curriculum`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `lesson_version_id` | `uuid` | no | — | FK → [`curriculum.lesson_version`](lesson_version.md).id |
| 3 | `technical_problem_id` | `uuid` | yes | — | FK → [`knowledge.technical_problem`](../knowledge/technical_problem.md).id |
| 4 | `solution_pattern_id` | `uuid` | yes | — | FK → [`knowledge.solution_pattern`](../knowledge/solution_pattern.md).id |
| 5 | `advanced_usage_pattern_id` | `uuid` | yes | — | FK → [`knowledge.advanced_usage_pattern`](../knowledge/advanced_usage_pattern.md).id |
| 6 | `implementation_example_id` | `uuid` | yes | — | FK → [`knowledge.implementation_example`](../knowledge/implementation_example.md).id |
| 7 | `failure_mode_id` | `uuid` | yes | — | FK → [`knowledge.failure_mode`](../knowledge/failure_mode.md).id |
| 8 | `benchmark_result_id` | `uuid` | yes | — | FK → [`knowledge.benchmark_result`](../knowledge/benchmark_result.md).id |
| 9 | `compatibility_constraint_id` | `uuid` | yes | — | FK → [`knowledge.compatibility_constraint`](../knowledge/compatibility_constraint.md).id |
| 10 | `operational_practice_id` | `uuid` | yes | — | FK → [`knowledge.operational_practice`](../knowledge/operational_practice.md).id |
| 11 | `security_consideration_id` | `uuid` | yes | — | FK → [`knowledge.security_consideration`](../knowledge/security_consideration.md).id |
| 12 | `record_kind` | `text` | yes | — | generated: ` CASE     WHEN (technical_problem_id IS NOT NULL) THEN 'technical_problem'::text     WHEN (solution_pattern_id IS NOT NULL) THEN 'solution_pattern'::text     WHEN (advanced_usage_pattern_id IS NOT NULL) THEN 'advanced_usage_pattern'::text     WHEN (implementation_example_id IS NOT NULL) THEN 'implementation_example'::text     WHEN (failure_mode_id IS NOT NULL) THEN 'failure_mode'::text     WHEN (benchmark_result_id IS NOT NULL) THEN 'benchmark_result'::text     WHEN (compatibility_constraint_id IS NOT NULL) THEN 'compatibility_constraint'::text     WHEN (operational_practice_id IS NOT NULL) THEN 'operational_practice'::text     WHEN (security_consideration_id IS NOT NULL) THEN 'security_consideration'::text     ELSE NULL::text END` |
| 13 | `assertion_ref` | `text` | yes | — | — |
| 14 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- check `lesson_backed_by_exactly_one`: `(num_nonnulls(technical_problem_id, solution_pattern_id, advanced_usage_pattern_id, implementation_example_id, failure_mode_id, benchmark_r…`

## Relationships

10 outbound and 0 inbound foreign keys; full list in [details](lesson_backed_by.details.md).

## Indexes

2 indexes; see [details](lesson_backed_by.details.md).

## Triggers

0 triggers; see [details](lesson_backed_by.details.md).

## Row-level security

Enabled; 1 policies in [details](lesson_backed_by.details.md).

## Grants

`executor_service`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `executor_service`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["curriculum"]["Tables"]["lesson_backed_by"]["Insert"]`; row: `Database["curriculum"]["Tables"]["lesson_backed_by"]["Row"]`; update: `Database["curriculum"]["Tables"]["lesson_backed_by"]["Update"]`

Defined in: `20260826001300_curriculum.sql`.
