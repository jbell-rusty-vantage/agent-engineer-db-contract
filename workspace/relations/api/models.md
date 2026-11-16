---
id: "rel:api.models"
kind: view
schema: api
name: models
domain: api-surface
lens: corpus
aliases: [models table, model versions, compare models]
tokens: [api, models, api.models, model_version_id, model, slug, version_label, provider_model_id, model_family_id, model_family, developer_id, developer, released_on, context_tokens, max_output_tokens, modalities, tool_use, structured_output, reasoning, vision, open_weights, knowledge_cutoff, availability, min_input_usd_per_1m, min_output_usd_per_1m, offering_count, observed_at, as_of_knowledge_seq]
summary: "L1 — one row per model version with developer, release date, context, modalities, capability statuses, cutoff, availability and the minimum current price per 1M tokens."
summary_basis: curated
rls: disabled
readers: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"api\"][\"Views\"][\"models\"][\"Row\"]"
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", part4_views_seeds.sql]
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# api.models

view in domain `api-surface`, lens `corpus` — L1: one row per model version with developer, release date, context, modalities, capability statuses, knowledge cutoff, availability and the minimum current price per 1M tokens across offerings. Filter/compare/rank here; no embeddings..

> curated (model_assisted, unreviewed) — L1 — one row per model version with developer, release date, context, modalities, capability statuses, cutoff, availability and the minimum current price per 1M tokens.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `model_version_id` | `uuid` | yes | — | _curated:_ The ai_model_version entity id; join to api.model_offerings.model_version_id. |
| 2 | `model` | `text` | yes | — | — |
| 3 | `slug` | `text` | yes | — | — |
| 4 | `version_label` | `text` | yes | — | — |
| 5 | `provider_model_id` | `text` | yes | — | — |
| 6 | `model_family_id` | `uuid` | yes | — | — |
| 7 | `model_family` | `text` | yes | — | — |
| 8 | `developer_id` | `uuid` | yes | — | — |
| 9 | `developer` | `text` | yes | — | — |
| 10 | `released_on` | `date` | yes | — | — |
| 11 | `context_tokens` | `numeric` | yes | — | — |
| 12 | `max_output_tokens` | `numeric` | yes | — | — |
| 13 | `modalities` | `text[]` | yes | — | — |
| 14 | `tool_use` | `text` | yes | — | _curated:_ Status of the model_capability stream for tool use (supported, partial, unsupported); null means no fact. |
| 15 | `structured_output` | `text` | yes | — | — |
| 16 | `reasoning` | `text` | yes | — | — |
| 17 | `vision` | `text` | yes | — | — |
| 18 | `open_weights` | `boolean` | yes | — | — |
| 19 | `knowledge_cutoff` | `text` | yes | — | — |
| 20 | `availability` | `text` | yes | — | — |
| 21 | `min_input_usd_per_1m` | `numeric` | yes | — | _curated:_ Minimum current input price across offerings; the offering itself is in api.model_offerings. |
| 22 | `min_output_usd_per_1m` | `numeric` | yes | — | — |
| 23 | `offering_count` | `bigint` | yes | — | — |
| 24 | `observed_at` | `timestamp with time zone` | yes | — | — |
| 25 | `as_of_knowledge_seq` | `bigint` | yes | — | _curated:_ Knowledge head the row reflects; cite it. |

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

- Named queries: `q:catalog.models`.
- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

Views are not written.

## View definition

See [details](models.details.md).

## TypeScript

row: `Database["api"]["Views"]["models"]["Row"]`

## Examples

GA models

```bash
knowledge db query catalog.models --param availability=ga --param limit=50 --param text=null
```
Order is newest release first.

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `part4_views_seeds.sql`.
