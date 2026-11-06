---
id: "rel:ranking.ranking_result"
kind: table
schema: ranking
name: ranking_result
domain: ranking
aliases: []
tokens: [ranking, ranking_result, ranking.ranking_result, id, tenant_id, subject_entity_id, ranking_run_id, rank, score, explanation]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"ranking\"][\"Tables\"][\"ranking_result\"][\"Row\"]"
defined_in: ["20260826000800_ranking.sql", "20260912010900_km_09_ranking_staging.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# ranking.ranking_result

table in domain `ranking`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id) |
| 3 | `subject_entity_id` | `uuid` | no | — | FK → [`corpus.entity`](../corpus/entity.md).id |
| 4 | `ranking_run_id` | `uuid` | yes | — | FK → [`ranking.ranking_run`](ranking_run.md).id |
| 5 | `rank` | `integer` | no | — | — |
| 6 | `score` | `numeric` | yes | — | — |
| 7 | `explanation` | `jsonb` | no | `'{}'::jsonb` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `ranking_result_rank_check`: `(rank > 0)`

## Relationships

Outbound: `ranking_run_id` → [`ranking.ranking_run`](ranking_run.md)`.id`; `subject_entity_id` → [`corpus.entity`](../corpus/entity.md)`.id` (+tenant).
Inbound: [`evaluation.review_task`](../evaluation/review_task.md).ranking_result_id.
Polymorphic target of: [`evaluation.review_task`](../evaluation/review_task.md) (check constraint review_task_exactly_one_subject).

## Indexes

`ranking_result_tenant_id_id_key` unique

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

insert: `Database["ranking"]["Tables"]["ranking_result"]["Insert"]`; row: `Database["ranking"]["Tables"]["ranking_result"]["Row"]`; update: `Database["ranking"]["Tables"]["ranking_result"]["Update"]`

Defined in: `20260826000800_ranking.sql`, `20260912010900_km_09_ranking_staging.sql`.
