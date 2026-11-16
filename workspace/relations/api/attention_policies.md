---
id: "rel:api.attention_policies"
kind: view
schema: api
name: attention_policies
domain: api-surface
lens: corpus
aliases: []
tokens: [api, attention_policies, api.attention_policies, policy_id, slug, title, scope_kind, watch_level, cadence, depth, selection, triggers, budget_usd_per_run, budget_credits_per_run, state, rationale, decided_by, channels, subjects, mission, designed_in_thread_id, last_sweep_at, last_outcome, last_seen, last_selected, sweeps, spend_usd]
summary: null
summary_basis: none
rls: disabled
readers: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"api\"][\"Views\"][\"attention_policies\"][\"Row\"]"
defined_in: ["20261113120000_build08_loop4_source_intelligence_experiments.sql"]
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# api.attention_policies

view in domain `api-surface`, lens `corpus`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `policy_id` | `uuid` | yes | — | — |
| 2 | `slug` | `text` | yes | — | — |
| 3 | `title` | `text` | yes | — | — |
| 4 | `scope_kind` | `text` | yes | — | — |
| 5 | `watch_level` | `text` | yes | — | — |
| 6 | `cadence` | `text` | yes | — | — |
| 7 | `depth` | `jsonb` | yes | — | — |
| 8 | `selection` | `jsonb` | yes | — | — |
| 9 | `triggers` | `jsonb` | yes | — | — |
| 10 | `budget_usd_per_run` | `numeric(10,4)` | yes | — | — |
| 11 | `budget_credits_per_run` | `integer` | yes | — | — |
| 12 | `state` | `text` | yes | — | — |
| 13 | `rationale` | `text` | yes | — | — |
| 14 | `decided_by` | `text` | yes | — | — |
| 15 | `channels` | `text[]` | yes | — | — |
| 16 | `subjects` | `text[]` | yes | — | — |
| 17 | `mission` | `text` | yes | — | — |
| 18 | `designed_in_thread_id` | `uuid` | yes | — | — |
| 19 | `last_sweep_at` | `timestamp with time zone` | yes | — | — |
| 20 | `last_outcome` | `text` | yes | — | — |
| 21 | `last_seen` | `integer` | yes | — | — |
| 22 | `last_selected` | `integer` | yes | — | — |
| 23 | `sweeps` | `bigint` | yes | — | — |
| 24 | `spend_usd` | `numeric` | yes | — | — |

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

See [details](attention_policies.details.md).

## TypeScript

row: `Database["api"]["Views"]["attention_policies"]["Row"]`

Defined in: `20261113120000_build08_loop4_source_intelligence_experiments.sql`.
