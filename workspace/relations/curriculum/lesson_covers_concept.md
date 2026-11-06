---
id: "rel:curriculum.lesson_covers_concept"
kind: table
schema: curriculum
name: lesson_covers_concept
domain: curriculum
aliases: []
tokens: [curriculum, lesson_covers_concept, curriculum.lesson_covers_concept, id, lesson_version_id, concept_id, depth]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"curriculum\"][\"Tables\"][\"lesson_covers_concept\"][\"Row\"]"
defined_in: ["20260826001300_curriculum.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# curriculum.lesson_covers_concept

table in domain `curriculum`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `lesson_version_id` | `uuid` | no | — | unique (lesson_version_id, concept_id); FK → [`curriculum.lesson_version`](lesson_version.md).id |
| 3 | `concept_id` | `uuid` | no | — | unique (lesson_version_id, concept_id); FK → [`corpus.entity`](../corpus/entity.md).id |
| 4 | `depth` | `text` | no | `'mention'::text` | — |

## Constraints

- PK (id)
- unique (lesson_version_id, concept_id)
- check `lesson_covers_concept_depth_check`: `(depth = ANY (ARRAY['mention'::text, 'section'::text, 'dedicated'::text]))`

## Relationships

Outbound: `concept_id` → [`corpus.entity`](../corpus/entity.md)`.id`; `lesson_version_id` → [`curriculum.lesson_version`](lesson_version.md)`.id` on delete cascade.
Inbound: none.

## Indexes

`lesson_covers_concept_lesson_version_id_concept_id_key` unique

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

insert: `Database["curriculum"]["Tables"]["lesson_covers_concept"]["Insert"]`; row: `Database["curriculum"]["Tables"]["lesson_covers_concept"]["Row"]`; update: `Database["curriculum"]["Tables"]["lesson_covers_concept"]["Update"]`

Defined in: `20260826001300_curriculum.sql`.
