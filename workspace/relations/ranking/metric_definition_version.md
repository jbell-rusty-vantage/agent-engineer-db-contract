---
id: "rel:ranking.metric_definition_version"
kind: table
schema: ranking
name: metric_definition_version
domain: ranking
aliases: []
tokens: [ranking, metric_definition_version, ranking.metric_definition_version, id, tenant_id, metric_definition_id, version, definition]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"ranking\"][\"Tables\"][\"metric_definition_version\"][\"Row\"]"
defined_in: ["20260826000800_ranking.sql", "20260912010900_km_09_ranking_staging.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# ranking.metric_definition_version

table in domain `ranking`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id); unique (tenant_id, metric_definition_id, version) |
| 3 | `metric_definition_id` | `uuid` | no | — | unique (tenant_id, metric_definition_id, version); FK → [`ranking.metric_definition`](metric_definition.md).id |
| 4 | `version` | `integer` | no | — | unique (tenant_id, metric_definition_id, version) |
| 5 | `definition` | `jsonb` | no | `'{}'::jsonb` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, metric_definition_id, version)

## Relationships

Outbound: `metric_definition_id` → [`ranking.metric_definition`](metric_definition.md)`.id` (+tenant).
Inbound: [`evaluation.eval_run`](../evaluation/eval_run.md).metric_definition_version_id, [`ranking.metric_observation`](metric_observation.md).metric_definition_version_id.
Polymorphic target of: [`evaluation.eval_run`](../evaluation/eval_run.md) (check constraint eval_run_exactly_one_target).

## Indexes

`metric_definition_version_tenant_id_id_key` unique; `metric_definition_version_tenant_id_metric_definition_id_ve_key` unique

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

insert: `Database["ranking"]["Tables"]["metric_definition_version"]["Insert"]`; row: `Database["ranking"]["Tables"]["metric_definition_version"]["Row"]`; update: `Database["ranking"]["Tables"]["metric_definition_version"]["Update"]`

Defined in: `20260826000800_ranking.sql`, `20260912010900_km_09_ranking_staging.sql`.
