---
id: "rel:api.probes"
kind: view
schema: api
name: probes
domain: api-surface
lens: corpus
aliases: []
tokens: [api, probes, api.probes, probe_id, slug, title, kind, hypothesis, model_policy, matrix, script_path, designed_by, designed_in_thread_id, subjects, claims, runs, last_run_at, verdicts]
summary: null
summary_basis: none
rls: disabled
readers: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"api\"][\"Views\"][\"probes\"][\"Row\"]"
defined_in: ["20261113120000_build08_loop4_source_intelligence_experiments.sql"]
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# api.probes

view in domain `api-surface`, lens `corpus`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `probe_id` | `uuid` | yes | — | — |
| 2 | `slug` | `text` | yes | — | — |
| 3 | `title` | `text` | yes | — | — |
| 4 | `kind` | `text` | yes | — | — |
| 5 | `hypothesis` | `text` | yes | — | — |
| 6 | `model_policy` | `text` | yes | — | — |
| 7 | `matrix` | `jsonb` | yes | — | — |
| 8 | `script_path` | `text` | yes | — | — |
| 9 | `designed_by` | `text` | yes | — | — |
| 10 | `designed_in_thread_id` | `uuid` | yes | — | — |
| 11 | `subjects` | `text[]` | yes | — | — |
| 12 | `claims` | `bigint` | yes | — | — |
| 13 | `runs` | `bigint` | yes | — | — |
| 14 | `last_run_at` | `timestamp with time zone` | yes | — | — |
| 15 | `verdicts` | `jsonb` | yes | — | — |

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

See [details](probes.details.md).

## TypeScript

row: `Database["api"]["Views"]["probes"]["Row"]`

Defined in: `20261113120000_build08_loop4_source_intelligence_experiments.sql`.
