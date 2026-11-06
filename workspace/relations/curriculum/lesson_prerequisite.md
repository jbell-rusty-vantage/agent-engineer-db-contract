---
id: "rel:curriculum.lesson_prerequisite"
kind: table
schema: curriculum
name: lesson_prerequisite
domain: curriculum
aliases: []
tokens: [curriculum, lesson_prerequisite, curriculum.lesson_prerequisite, lesson_id, requires_lesson_id]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"curriculum\"][\"Tables\"][\"lesson_prerequisite\"][\"Row\"]"
defined_in: ["20260826001300_curriculum.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# curriculum.lesson_prerequisite

table in domain `curriculum`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `lesson_id` | `uuid` | no | — | PK; FK → [`curriculum.lesson`](lesson.md).id |
| 2 | `requires_lesson_id` | `uuid` | no | — | PK; FK → [`curriculum.lesson`](lesson.md).id |

## Constraints

- PK (lesson_id, requires_lesson_id)
- check `lesson_prerequisite_no_self`: `(lesson_id <> requires_lesson_id)`

## Relationships

Outbound: `lesson_id` → [`curriculum.lesson`](lesson.md)`.id` on delete cascade; `requires_lesson_id` → [`curriculum.lesson`](lesson.md)`.id` on delete cascade.
Inbound: none.

## Indexes

_None._

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

insert: `Database["curriculum"]["Tables"]["lesson_prerequisite"]["Insert"]`; row: `Database["curriculum"]["Tables"]["lesson_prerequisite"]["Row"]`; update: `Database["curriculum"]["Tables"]["lesson_prerequisite"]["Update"]`

Defined in: `20260826001300_curriculum.sql`.
