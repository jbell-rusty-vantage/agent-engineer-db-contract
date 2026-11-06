---
id: "rel:curriculum.lesson"
kind: table
schema: curriculum
name: lesson
domain: curriculum
aliases: []
tokens: [curriculum, lesson, curriculum.lesson, id, module_id, slug, title, ordering, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"curriculum\"][\"Tables\"][\"lesson\"][\"Row\"]"
defined_in: ["20260826001300_curriculum.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# curriculum.lesson

table in domain `curriculum`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `module_id` | `uuid` | no | — | unique (module_id, slug); FK → [`curriculum.module`](module.md).id |
| 3 | `slug` | `text` | no | — | unique (module_id, slug) |
| 4 | `title` | `text` | no | — | — |
| 5 | `ordering` | `integer` | no | `0` | — |
| 6 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (module_id, slug)

## Relationships

Outbound: `module_id` → [`curriculum.module`](module.md)`.id` on delete cascade.
Inbound: [`curriculum.lesson_prerequisite`](lesson_prerequisite.md).lesson_id|requires_lesson_id, [`curriculum.lesson_version`](lesson_version.md).lesson_id, [`taxonomy.assignment`](../taxonomy/assignment.md).lesson_id.
Polymorphic target of: [`taxonomy.assignment`](../taxonomy/assignment.md) (check constraint assignment_check).

## Indexes

`lesson_module_id_slug_key` unique

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

insert: `Database["curriculum"]["Tables"]["lesson"]["Insert"]`; row: `Database["curriculum"]["Tables"]["lesson"]["Row"]`; update: `Database["curriculum"]["Tables"]["lesson"]["Update"]`

Defined in: `20260826001300_curriculum.sql`.
