---
id: "rel:ranking.metric_definition"
kind: table
schema: ranking
name: metric_definition
domain: ranking
aliases: []
tokens: [ranking, metric_definition, ranking.metric_definition, id, tenant_id, slug, name, unit, description]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"ranking\"][\"Tables\"][\"metric_definition\"][\"Row\"]"
defined_in: ["20260826000800_ranking.sql", "20260912010900_km_09_ranking_staging.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# ranking.metric_definition

table in domain `ranking`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id); unique (tenant_id, slug) |
| 3 | `slug` | `text` | no | — | unique (tenant_id, slug) |
| 4 | `name` | `text` | no | — | — |
| 5 | `unit` | `text` | yes | — | — |
| 6 | `description` | `text` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, slug)

## Relationships

Outbound: none.
Inbound: [`ranking.metric_definition_version`](metric_definition_version.md).metric_definition_id.

## Indexes

`metric_definition_tenant_id_id_key` unique; `metric_definition_tenant_id_slug_key` unique

## Triggers

_None._

## Row-level security

Enabled.
- `km_tenant_access` (ALL) for `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: SELECT; `executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: SELECT; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["ranking"]["Tables"]["metric_definition"]["Insert"]`; row: `Database["ranking"]["Tables"]["metric_definition"]["Row"]`; update: `Database["ranking"]["Tables"]["metric_definition"]["Update"]`

Defined in: `20260826000800_ranking.sql`, `20260912010900_km_09_ranking_staging.sql`.
