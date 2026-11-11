---
id: "rel:api.benchmark_scores"
kind: view
schema: api
name: benchmark_scores
domain: api-surface
lens: corpus
aliases: []
tokens: [api, benchmark_scores, api.benchmark_scores, segment_id, subject_id, subject, subject_kind, benchmark_version_id, benchmark_version, benchmark_id, benchmark, score, unit, harness, setting, reported_by, source_kind, cost_usd, run_date, n_tasks, reasoning_effort, conditions, valid_from, learned_k, observed_at, claim_id, belief, scope_key]
summary: "L1: current conditioned benchmark scores: subject, benchmark version and parent benchmark, harness, who measured (reported_by), cost, run date, with the claim locator id."
summary_basis: comment
rls: disabled
readers: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"api\"][\"Views\"][\"benchmark_scores\"][\"Row\"]"
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", "20261109130000_build08_loop2_numbers_compute_apis.sql", part4_views_seeds.sql]
workspace_fingerprint: "sha256:fbf5703bf7a6f6131c452444ee949f1feec1bbe813c78d772fb3886b510815b9"
---
# api.benchmark_scores

view in domain `api-surface`, lens `corpus` — L1: current conditioned benchmark scores: subject, benchmark version and parent benchmark, harness, who measured (reported_by), cost, run date, with the claim locator id..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `segment_id` | `uuid` | yes | — | — |
| 2 | `subject_id` | `uuid` | yes | — | — |
| 3 | `subject` | `text` | yes | — | — |
| 4 | `subject_kind` | `text` | yes | — | — |
| 5 | `benchmark_version_id` | `uuid` | yes | — | — |
| 6 | `benchmark_version` | `text` | yes | — | — |
| 7 | `benchmark_id` | `uuid` | yes | — | — |
| 8 | `benchmark` | `text` | yes | — | — |
| 9 | `score` | `numeric(20,6)` | yes | — | — |
| 10 | `unit` | `text` | yes | — | — |
| 11 | `harness` | `text` | yes | — | — |
| 12 | `setting` | `text` | yes | — | — |
| 13 | `reported_by` | `text` | yes | — | — |
| 14 | `source_kind` | `text` | yes | — | — |
| 15 | `cost_usd` | `numeric` | yes | — | — |
| 16 | `run_date` | `text` | yes | — | — |
| 17 | `n_tasks` | `integer` | yes | — | — |
| 18 | `reasoning_effort` | `text` | yes | — | — |
| 19 | `conditions` | `jsonb` | yes | — | — |
| 20 | `valid_from` | `timestamp with time zone` | yes | — | — |
| 21 | `learned_k` | `bigint` | yes | — | — |
| 22 | `observed_at` | `timestamp with time zone` | yes | — | — |
| 23 | `claim_id` | `uuid` | yes | — | — |
| 24 | `belief` | `text` | yes | — | — |
| 25 | `scope_key` | `text` | yes | — | — |

## Constraints

_None._

## Relationships

Outbound: none.
Inbound: none.

## Indexes

_None._

## Triggers

_None._

## Row-level security

Disabled.

## Grants

`app_reader`: SELECT; `authenticated`: SELECT; `control_plane`: SELECT; `executor_service`: SELECT; `pipeline_agent`: SELECT; `service_role`: SELECT; `verifier_agent`: SELECT. None: `anon`.

## Read paths

- Named queries: `q:catalog.benchmark_scores`.
- Exposed through: [`api.benchmarks`](benchmarks.md).
- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

Views are not written.

## View definition

See [details](benchmark_scores.details.md).

## TypeScript

row: `Database["api"]["Views"]["benchmark_scores"]["Row"]`

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `20261109130000_build08_loop2_numbers_compute_apis.sql`, `part4_views_seeds.sql`.
