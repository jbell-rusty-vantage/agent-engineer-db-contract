---
id: "rel:curriculum.lesson_version"
kind: table
schema: curriculum
name: lesson_version
domain: curriculum
aliases: []
tokens: [curriculum, lesson_version, curriculum.lesson_version, id, lesson_id, version, content_artifact_id, status, published_at, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"curriculum\"][\"Tables\"][\"lesson_version\"][\"Row\"]"
defined_in: ["20260826001300_curriculum.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# curriculum.lesson_version

table in domain `curriculum`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `lesson_id` | `uuid` | no | — | unique (lesson_id, version); FK → [`curriculum.lesson`](lesson.md).id |
| 3 | `version` | `integer` | no | — | unique (lesson_id, version) |
| 4 | `content_artifact_id` | `uuid` | yes | — | FK → [`orchestration.artifact`](../orchestration/artifact.md).id |
| 5 | `status` | `curriculum.publish_status` | no | `'draft'::curriculum.publish_status` | — |
| 6 | `published_at` | `timestamp with time zone` | yes | — | — |
| 7 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (lesson_id, version)

## Relationships

Outbound: `content_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.id`; `lesson_id` → [`curriculum.lesson`](lesson.md)`.id` on delete cascade.
Inbound: [`curriculum.learning_objective`](learning_objective.md).lesson_version_id, [`curriculum.lesson_backed_by`](lesson_backed_by.md).lesson_version_id, [`curriculum.lesson_covers_concept`](lesson_covers_concept.md).lesson_version_id.

## Indexes

`lesson_version_lesson_id_version_key` unique

## Triggers

- `artifact_retirement_334d79a60f4f7b084c2725e2` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)
- `lesson_version_immutable_when_published` → [`curriculum.lesson_version_guard`](../../functions/curriculum/lesson_version_guard.md)

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

insert: `Database["curriculum"]["Tables"]["lesson_version"]["Insert"]`; row: `Database["curriculum"]["Tables"]["lesson_version"]["Row"]`; update: `Database["curriculum"]["Tables"]["lesson_version"]["Update"]`

Defined in: `20260826001300_curriculum.sql`.
