---
id: "rel:ranking.entity_group"
kind: table
schema: ranking
name: entity_group
domain: ranking
aliases: []
tokens: [ranking, entity_group, ranking.entity_group, id, tenant_id, slug, entity_kind, purpose, definition, inclusion_rules, exclusion_rules, review_state, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role]
writers: []
typescript: "Database[\"ranking\"][\"Tables\"][\"entity_group\"][\"Row\"]"
defined_in: ["20260826000800_ranking.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# ranking.entity_group

table in domain `ranking`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, slug) |
| 3 | `slug` | `text` | no | — | unique (tenant_id, slug) |
| 4 | `entity_kind` | `text` | no | — | — |
| 5 | `purpose` | `text` | no | — | — |
| 6 | `definition` | `text` | yes | — | — |
| 7 | `inclusion_rules` | `jsonb` | no | `'{}'::jsonb` | — |
| 8 | `exclusion_rules` | `jsonb` | no | `'{}'::jsonb` | — |
| 9 | `review_state` | `ranking.approval_state` | no | `'draft'::ranking.approval_state` | — |
| 10 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, slug)

## Relationships

Outbound: none.
Inbound: [`ranking.entity_group_version`](entity_group_version.md).entity_group_id.

## Indexes

`entity_group_tenant_id_slug_key` unique

## Triggers

_None._

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`executor_service`: SELECT; `service_role`: SELECT. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `executor_service`.

## Write path

- No direct DML for any agent role.
- No write path for agents; rows are seeded by migrations or platform tooling.

## TypeScript

insert: `Database["ranking"]["Tables"]["entity_group"]["Insert"]`; row: `Database["ranking"]["Tables"]["entity_group"]["Row"]`; update: `Database["ranking"]["Tables"]["entity_group"]["Update"]`

Defined in: `20260826000800_ranking.sql`.
