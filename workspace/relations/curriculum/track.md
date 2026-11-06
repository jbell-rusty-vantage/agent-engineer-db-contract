---
id: "rel:curriculum.track"
kind: table
schema: curriculum
name: track
domain: curriculum
aliases: []
tokens: [curriculum, track, curriculum.track, id, curriculum_id, slug, title, ordering, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"curriculum\"][\"Tables\"][\"track\"][\"Row\"]"
defined_in: ["20260826001300_curriculum.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# curriculum.track

table in domain `curriculum`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `curriculum_id` | `uuid` | no | — | unique (curriculum_id, slug); FK → [`curriculum.curriculum`](curriculum.md).id |
| 3 | `slug` | `text` | no | — | unique (curriculum_id, slug) |
| 4 | `title` | `text` | no | — | — |
| 5 | `ordering` | `integer` | no | `0` | — |
| 6 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (curriculum_id, slug)

## Relationships

Outbound: `curriculum_id` → [`curriculum.curriculum`](curriculum.md)`.id` on delete cascade.
Inbound: [`curriculum.module`](module.md).track_id.

## Indexes

`track_curriculum_id_slug_key` unique

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

insert: `Database["curriculum"]["Tables"]["track"]["Insert"]`; row: `Database["curriculum"]["Tables"]["track"]["Row"]`; update: `Database["curriculum"]["Tables"]["track"]["Update"]`

Defined in: `20260826001300_curriculum.sql`.
