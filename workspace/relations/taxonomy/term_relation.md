---
id: "rel:taxonomy.term_relation"
kind: table
schema: taxonomy
name: term_relation
domain: relationships
aliases: []
tokens: [taxonomy, term_relation, taxonomy.term_relation, from_term_id, to_term_id, relation_kind, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"taxonomy\"][\"Tables\"][\"term_relation\"][\"Row\"]"
defined_in: ["20260826000400_taxonomy_core.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# taxonomy.term_relation

table in domain `relationships`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `from_term_id` | `uuid` | no | — | PK; FK → [`taxonomy.term`](term.md).id |
| 2 | `to_term_id` | `uuid` | no | — | PK; FK → [`taxonomy.term`](term.md).id |
| 3 | `relation_kind` | `text` | no | — | PK |
| 4 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (from_term_id, to_term_id, relation_kind)
- check `term_relation_no_self`: `(from_term_id <> to_term_id)`
- check `term_relation_relation_kind_check`: `(relation_kind = ANY (ARRAY['broader'::text, 'narrower'::text, 'related'::text, 'replaced_by'::text]))`

## Relationships

Outbound: `from_term_id` → [`taxonomy.term`](term.md)`.id` on delete cascade; `to_term_id` → [`taxonomy.term`](term.md)`.id` on delete cascade.
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

insert: `Database["taxonomy"]["Tables"]["term_relation"]["Insert"]`; row: `Database["taxonomy"]["Tables"]["term_relation"]["Row"]`; update: `Database["taxonomy"]["Tables"]["term_relation"]["Update"]`

Defined in: `20260826000400_taxonomy_core.sql`.
