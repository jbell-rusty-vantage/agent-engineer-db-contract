---
id: "rel:taxonomy.assignment_review_requirement"
kind: table
schema: taxonomy
name: assignment_review_requirement
domain: relationships
aliases: []
tokens: [taxonomy, assignment_review_requirement, taxonomy.assignment_review_requirement, facet_id, requires_review, rule, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"taxonomy\"][\"Tables\"][\"assignment_review_requirement\"][\"Row\"]"
defined_in: ["20260826000400_taxonomy_core.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# taxonomy.assignment_review_requirement

table in domain `relationships`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `facet_id` | `uuid` | no | — | PK; FK → [`taxonomy.facet`](facet.md).id |
| 2 | `requires_review` | `boolean` | no | `true` | — |
| 3 | `rule` | `jsonb` | no | `'{}'::jsonb` | — |
| 4 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (facet_id)

## Relationships

Outbound: `facet_id` → [`taxonomy.facet`](facet.md)`.id` on delete cascade.
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

insert: `Database["taxonomy"]["Tables"]["assignment_review_requirement"]["Insert"]`; row: `Database["taxonomy"]["Tables"]["assignment_review_requirement"]["Row"]`; update: `Database["taxonomy"]["Tables"]["assignment_review_requirement"]["Update"]`

Defined in: `20260826000400_taxonomy_core.sql`.
