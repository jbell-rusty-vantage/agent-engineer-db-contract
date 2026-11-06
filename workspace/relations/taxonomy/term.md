---
id: "rel:taxonomy.term"
kind: table
schema: taxonomy
name: term
domain: relationships
aliases: []
tokens: [taxonomy, term, taxonomy.term, id, facet_version_id, slug, label, definition, parent_term_id, sort_order, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"taxonomy\"][\"Tables\"][\"term\"][\"Row\"]"
defined_in: ["20260826000400_taxonomy_core.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# taxonomy.term

table in domain `relationships`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `facet_version_id` | `uuid` | no | — | unique (facet_version_id, slug); FK → [`taxonomy.facet_version`](facet_version.md).id |
| 3 | `slug` | `text` | no | — | unique (facet_version_id, slug) |
| 4 | `label` | `text` | no | — | — |
| 5 | `definition` | `text` | yes | — | — |
| 6 | `parent_term_id` | `uuid` | yes | — | FK → [`taxonomy.term`](term.md).id |
| 7 | `sort_order` | `integer` | no | `0` | — |
| 8 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (facet_version_id, slug)

## Relationships

Outbound: `facet_version_id` → [`taxonomy.facet_version`](facet_version.md)`.id` on delete cascade; `parent_term_id` → [`taxonomy.term`](term.md)`.id`.
Inbound: [`curriculum.module`](../curriculum/module.md).learning_level_term_id, [`taxonomy.assignment`](assignment.md).term_id, [`taxonomy.term`](term.md).parent_term_id, [`taxonomy.term_relation`](term_relation.md).from_term_id|to_term_id, [`taxonomy.term_target_kind`](term_target_kind.md).term_id.

## Indexes

`term_facet_version_id_slug_key` unique; `term_parent_idx`

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

insert: `Database["taxonomy"]["Tables"]["term"]["Insert"]`; row: `Database["taxonomy"]["Tables"]["term"]["Row"]`; update: `Database["taxonomy"]["Tables"]["term"]["Update"]`

Defined in: `20260826000400_taxonomy_core.sql`.
