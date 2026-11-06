---
id: "rel:taxonomy.term_target_kind"
kind: table
schema: taxonomy
name: term_target_kind
domain: relationships
aliases: []
tokens: [taxonomy, term_target_kind, taxonomy.term_target_kind, term_id, entity_kind_code, created_at]
summary: Restricts secondary taxonomy terms to compatible primary entity kinds.
summary_basis: comment
rls: enabled
readers: [app_reader, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"taxonomy\"][\"Tables\"][\"term_target_kind\"][\"Row\"]"
defined_in: ["20260829192855_optimize_ai_entity_taxonomy_and_relationships.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# taxonomy.term_target_kind

table in domain `relationships` — Restricts secondary taxonomy terms to compatible primary entity kinds..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `term_id` | `uuid` | no | — | PK; FK → [`taxonomy.term`](term.md).id |
| 2 | `entity_kind_code` | `text` | no | — | PK; FK → [`taxonomy.entity_kind`](entity_kind.md).code |
| 3 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (term_id, entity_kind_code)

## Relationships

Outbound: `entity_kind_code` → [`taxonomy.entity_kind`](entity_kind.md)`.code` on delete cascade; `term_id` → [`taxonomy.term`](term.md)`.id` on delete cascade.
Inbound: none.
Polymorphic: `entity_kind_code` selects one of 36 typed tables listed in [`taxonomy.entity_kind`](../../vocabularies/taxonomy.entity_kind.md) (`canonical_table`) — basis: vocabulary taxonomy.entity_kind.canonical_table + FK term_target_kind_entity_kind_code_fkey.

## Indexes

_None._

## Triggers

_None._

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `false`

## Grants

`app_reader`: SELECT; `executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: SELECT; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `authenticated`, `control_plane`.

## Read paths

- Direct SELECT: `app_reader`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["taxonomy"]["Tables"]["term_target_kind"]["Insert"]`; row: `Database["taxonomy"]["Tables"]["term_target_kind"]["Row"]`; update: `Database["taxonomy"]["Tables"]["term_target_kind"]["Update"]`

Defined in: `20260829192855_optimize_ai_entity_taxonomy_and_relationships.sql`.
