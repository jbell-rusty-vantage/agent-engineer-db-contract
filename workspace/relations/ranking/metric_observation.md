---
id: "rel:ranking.metric_observation"
kind: table
schema: ranking
name: metric_observation
domain: ranking
aliases: []
tokens: [ranking, metric_observation, ranking.metric_observation, id, tenant_id, metric_definition_version_id, subject_entity_id, benchmark_run_id, value, unit, observed_at, claim_id, locator_id]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"ranking\"][\"Tables\"][\"metric_observation\"][\"Row\"]"
defined_in: ["20260826000800_ranking.sql", "20260912010900_km_09_ranking_staging.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# ranking.metric_observation

table in domain `ranking`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id) |
| 3 | `metric_definition_version_id` | `uuid` | no | — | FK → [`ranking.metric_definition_version`](metric_definition_version.md).id |
| 4 | `subject_entity_id` | `uuid` | no | — | FK → [`corpus.entity`](../corpus/entity.md).id |
| 5 | `benchmark_run_id` | `uuid` | yes | — | FK → [`corpus.benchmark_run`](../corpus/benchmark_run.md).id |
| 6 | `value` | `numeric` | no | — | — |
| 7 | `unit` | `text` | yes | — | — |
| 8 | `observed_at` | `timestamp with time zone` | no | — | — |
| 9 | `claim_id` | `uuid` | yes | — | FK → [`evidence.claim`](../evidence/claim.md).id |
| 10 | `locator_id` | `uuid` | yes | — | FK → [`evidence.locator`](../evidence/locator.md).id |

## Constraints

- PK (id)
- unique (tenant_id, id)

## Relationships

Outbound: `benchmark_run_id` → [`corpus.benchmark_run`](../corpus/benchmark_run.md)`.id` (+tenant); `claim_id` → [`evidence.claim`](../evidence/claim.md)`.id` (+tenant); `locator_id` → [`evidence.locator`](../evidence/locator.md)`.id` (+tenant); `metric_definition_version_id` → [`ranking.metric_definition_version`](metric_definition_version.md)`.id` (+tenant); `subject_entity_id` → [`corpus.entity`](../corpus/entity.md)`.id` (+tenant).
Inbound: none.

## Indexes

`metric_observation_tenant_id_id_key` unique

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

insert: `Database["ranking"]["Tables"]["metric_observation"]["Insert"]`; row: `Database["ranking"]["Tables"]["metric_observation"]["Row"]`; update: `Database["ranking"]["Tables"]["metric_observation"]["Update"]`

Defined in: `20260826000800_ranking.sql`, `20260912010900_km_09_ranking_staging.sql`.
