---
id: "rel:curriculum.challenge_derived_from"
kind: table
schema: curriculum
name: challenge_derived_from
domain: curriculum
aliases: []
tokens: [curriculum, challenge_derived_from, curriculum.challenge_derived_from, id, challenge_version_id, technical_problem_id, failure_mode_id, implementation_example_id, record_kind]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"curriculum\"][\"Tables\"][\"challenge_derived_from\"][\"Row\"]"
defined_in: ["20260826001300_curriculum.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# curriculum.challenge_derived_from

table in domain `curriculum`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `challenge_version_id` | `uuid` | no | — | FK → [`curriculum.challenge_version`](challenge_version.md).id |
| 3 | `technical_problem_id` | `uuid` | yes | — | FK → [`knowledge.technical_problem`](../knowledge/technical_problem.md).id |
| 4 | `failure_mode_id` | `uuid` | yes | — | FK → [`knowledge.failure_mode`](../knowledge/failure_mode.md).id |
| 5 | `implementation_example_id` | `uuid` | yes | — | FK → [`knowledge.implementation_example`](../knowledge/implementation_example.md).id |
| 6 | `record_kind` | `text` | yes | — | generated: ` CASE     WHEN (technical_problem_id IS NOT NULL) THEN 'technical_problem'::text     WHEN (failure_mode_id IS NOT NULL) THEN 'failure_mode'::text     WHEN (implementation_example_id IS NOT NULL) THEN 'implementation_example'::text     ELSE NULL::text END` |

## Constraints

- PK (id)
- check `challenge_derived_exactly_one`: `(num_nonnulls(technical_problem_id, failure_mode_id, implementation_example_id) = 1)`

## Relationships

Outbound: `challenge_version_id` → [`curriculum.challenge_version`](challenge_version.md)`.id` on delete cascade; `failure_mode_id` → [`knowledge.failure_mode`](../knowledge/failure_mode.md)`.id`; `implementation_example_id` → [`knowledge.implementation_example`](../knowledge/implementation_example.md)`.id`; `technical_problem_id` → [`knowledge.technical_problem`](../knowledge/technical_problem.md)`.id`.
Inbound: none.
Polymorphic: exactly one of `technical_problem_id`, `failure_mode_id`, `implementation_example_id` → [`knowledge.failure_mode`](../knowledge/failure_mode.md) | [`knowledge.implementation_example`](../knowledge/implementation_example.md) | [`knowledge.technical_problem`](../knowledge/technical_problem.md) — basis: check constraint challenge_derived_exactly_one.

## Indexes

`challenge_derived_from_version_idx`

## Triggers

_None._

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `false`

## Grants

`executor_service`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `executor_service`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["curriculum"]["Tables"]["challenge_derived_from"]["Insert"]`; row: `Database["curriculum"]["Tables"]["challenge_derived_from"]["Row"]`; update: `Database["curriculum"]["Tables"]["challenge_derived_from"]["Update"]`

Defined in: `20260826001300_curriculum.sql`.
