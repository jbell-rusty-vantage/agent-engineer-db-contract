---
id: "rel:api.benchmarks"
kind: view
schema: api
name: benchmarks
domain: api-surface
lens: corpus
aliases: []
tokens: [api, benchmarks, api.benchmarks, benchmark_id, benchmark, slug, organizer, metric, score_type, domain, agentic, canonical_url, versions, score_count, reported_by_kinds]
summary: "L1: benchmarks with their versions, organizer, metric/score type and how many conditioned scores we hold from which reporters."
summary_basis: comment
rls: disabled
readers: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"api\"][\"Views\"][\"benchmarks\"][\"Row\"]"
defined_in: ["20261109130000_build08_loop2_numbers_compute_apis.sql"]
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# api.benchmarks

view in domain `api-surface`, lens `corpus` — L1: benchmarks with their versions, organizer, metric/score type and how many conditioned scores we hold from which reporters..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `benchmark_id` | `uuid` | yes | — | — |
| 2 | `benchmark` | `text` | yes | — | — |
| 3 | `slug` | `text` | yes | — | — |
| 4 | `organizer` | `text` | yes | — | — |
| 5 | `metric` | `text` | yes | — | — |
| 6 | `score_type` | `text` | yes | — | — |
| 7 | `domain` | `text` | yes | — | — |
| 8 | `agentic` | `boolean` | yes | — | — |
| 9 | `canonical_url` | `text` | yes | — | — |
| 10 | `versions` | `text[]` | yes | — | — |
| 11 | `score_count` | `bigint` | yes | — | — |
| 12 | `reported_by_kinds` | `text[]` | yes | — | — |

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

- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

Views are not written.

## View definition

See [details](benchmarks.details.md).

## TypeScript

row: `Database["api"]["Views"]["benchmarks"]["Row"]`

Defined in: `20261109130000_build08_loop2_numbers_compute_apis.sql`.
