---
id: "rel:curriculum.module"
kind: table
schema: curriculum
name: module
domain: curriculum
aliases: []
tokens: [curriculum, module, curriculum.module, id, track_id, slug, title, ordering, learning_level_term_id, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"curriculum\"][\"Tables\"][\"module\"][\"Row\"]"
defined_in: ["20260826001300_curriculum.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# curriculum.module

table in domain `curriculum`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `track_id` | `uuid` | no | — | unique (track_id, slug); FK → [`curriculum.track`](track.md).id |
| 3 | `slug` | `text` | no | — | unique (track_id, slug) |
| 4 | `title` | `text` | no | — | — |
| 5 | `ordering` | `integer` | no | `0` | — |
| 6 | `learning_level_term_id` | `uuid` | yes | — | FK → [`taxonomy.term`](../taxonomy/term.md).id |
| 7 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (track_id, slug)

## Relationships

Outbound: `learning_level_term_id` → [`taxonomy.term`](../taxonomy/term.md)`.id`; `track_id` → [`curriculum.track`](track.md)`.id` on delete cascade.
Inbound: [`curriculum.challenge`](challenge.md).module_id, [`curriculum.lesson`](lesson.md).module_id.

## Indexes

`module_track_id_slug_key` unique

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

insert: `Database["curriculum"]["Tables"]["module"]["Insert"]`; row: `Database["curriculum"]["Tables"]["module"]["Row"]`; update: `Database["curriculum"]["Tables"]["module"]["Update"]`

Defined in: `20260826001300_curriculum.sql`.
