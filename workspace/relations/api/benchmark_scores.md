---
id: "rel:api.benchmark_scores"
kind: view
schema: api
name: benchmark_scores
domain: api-surface
lens: corpus
aliases: []
tokens: [api, benchmark_scores, api.benchmark_scores, segment_id, subject_id, subject, subject_kind, benchmark_id, benchmark, score, unit, setting, source_kind, valid_from, learned_k, observed_at, claim_id, belief]
summary: "L1: benchmark results as facts (one home for numbers): subject version, benchmark, score/unit, setting, who measured it, when it holds and when we learned it."
summary_basis: comment
rls: disabled
readers: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"api\"][\"Views\"][\"benchmark_scores\"][\"Row\"]"
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", part4_views_seeds.sql]
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
---
# api.benchmark_scores

view in domain `api-surface`, lens `corpus` — L1: benchmark results as facts (one home for numbers): subject version, benchmark, score/unit, setting, who measured it, when it holds and when we learned it..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `segment_id` | `uuid` | yes | — | — |
| 2 | `subject_id` | `uuid` | yes | — | — |
| 3 | `subject` | `text` | yes | — | — |
| 4 | `subject_kind` | `text` | yes | — | — |
| 5 | `benchmark_id` | `uuid` | yes | — | — |
| 6 | `benchmark` | `text` | yes | — | — |
| 7 | `score` | `numeric(20,6)` | yes | — | — |
| 8 | `unit` | `text` | yes | — | — |
| 9 | `setting` | `text` | yes | — | — |
| 10 | `source_kind` | `text` | yes | — | — |
| 11 | `valid_from` | `timestamp with time zone` | yes | — | — |
| 12 | `learned_k` | `bigint` | yes | — | — |
| 13 | `observed_at` | `timestamp with time zone` | yes | — | — |
| 14 | `claim_id` | `uuid` | yes | — | — |
| 15 | `belief` | `text` | yes | — | — |

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
- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

Views are not written.

## View definition

See [details](benchmark_scores.details.md).

## TypeScript

row: `Database["api"]["Views"]["benchmark_scores"]["Row"]`

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `part4_views_seeds.sql`.
