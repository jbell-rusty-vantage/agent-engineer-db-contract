---
id: "rel:ranking.feature_definition"
kind: table
schema: ranking
name: feature_definition
domain: ranking
aliases: []
tokens: [ranking, feature_definition, ranking.feature_definition, id, slug, version, expression, inputs, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role]
writers: []
typescript: "Database[\"ranking\"][\"Tables\"][\"feature_definition\"][\"Row\"]"
defined_in: ["20260826000800_ranking.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# ranking.feature_definition

table in domain `ranking`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `slug` | `text` | no | — | unique (slug) |
| 3 | `version` | `integer` | no | `1` | — |
| 4 | `expression` | `text` | no | — | — |
| 5 | `inputs` | `jsonb` | no | `'[]'::jsonb` | — |
| 6 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (slug)

## Relationships

Outbound: none.
Inbound: [`ranking.feature_value`](feature_value.md).feature_definition_id.

## Indexes

`feature_definition_slug_key` unique

## Triggers

_None._

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `false`

## Grants

`executor_service`: SELECT; `service_role`: SELECT. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `executor_service`.

## Write path

- No direct DML for any agent role.
- No write path for agents; rows are seeded by migrations or platform tooling.

## TypeScript

insert: `Database["ranking"]["Tables"]["feature_definition"]["Insert"]`; row: `Database["ranking"]["Tables"]["feature_definition"]["Row"]`; update: `Database["ranking"]["Tables"]["feature_definition"]["Update"]`

Defined in: `20260826000800_ranking.sql`.
