---
id: "rel:ranking.ranking_policy"
kind: table
schema: ranking
name: ranking_policy
domain: ranking
aliases: []
tokens: [ranking, ranking_policy, ranking.ranking_policy, id, tenant_id, slug, purpose, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role]
writers: []
typescript: "Database[\"ranking\"][\"Tables\"][\"ranking_policy\"][\"Row\"]"
defined_in: ["20260826000800_ranking.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# ranking.ranking_policy

table in domain `ranking`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, slug) |
| 3 | `slug` | `text` | no | — | unique (tenant_id, slug) |
| 4 | `purpose` | `text` | no | — | — |
| 5 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, slug)
- check `ranking_policy_purpose_check`: `(purpose = ANY (ARRAY['research_priority'::text, 'curriculum_value'::text, 'production_readiness'::text, 'frontier_monitoring'::text, 'chal…`

## Relationships

Outbound: none.
Inbound: [`ranking.ranking_policy_version`](ranking_policy_version.md).ranking_policy_id.

## Indexes

`ranking_policy_tenant_id_slug_key` unique

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

insert: `Database["ranking"]["Tables"]["ranking_policy"]["Insert"]`; row: `Database["ranking"]["Tables"]["ranking_policy"]["Row"]`; update: `Database["ranking"]["Tables"]["ranking_policy"]["Update"]`

Defined in: `20260826000800_ranking.sql`.
