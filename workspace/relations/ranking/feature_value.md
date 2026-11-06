---
id: "rel:ranking.feature_value"
kind: table
schema: ranking
name: feature_value
domain: ranking
aliases: []
tokens: [ranking, feature_value, ranking.feature_value, id, tenant_id, subject_entity_id, feature_definition_id, value, computed_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"ranking\"][\"Tables\"][\"feature_value\"][\"Row\"]"
defined_in: ["20260826000800_ranking.sql", "20260912010900_km_09_ranking_staging.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# ranking.feature_value

table in domain `ranking`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id) |
| 3 | `subject_entity_id` | `uuid` | no | — | FK → [`corpus.entity`](../corpus/entity.md).id |
| 4 | `feature_definition_id` | `uuid` | yes | — | FK → [`ranking.feature_definition`](feature_definition.md).id |
| 5 | `value` | `numeric` | no | — | — |
| 6 | `computed_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)

## Relationships

Outbound: `feature_definition_id` → [`ranking.feature_definition`](feature_definition.md)`.id`; `subject_entity_id` → [`corpus.entity`](../corpus/entity.md)`.id` (+tenant).
Inbound: none.

## Indexes

`feature_value_tenant_id_id_key` unique

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

insert: `Database["ranking"]["Tables"]["feature_value"]["Insert"]`; row: `Database["ranking"]["Tables"]["feature_value"]["Row"]`; update: `Database["ranking"]["Tables"]["feature_value"]["Update"]`

Defined in: `20260826000800_ranking.sql`, `20260912010900_km_09_ranking_staging.sql`.
