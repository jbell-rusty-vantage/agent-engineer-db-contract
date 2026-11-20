---
id: "rel:api.model_offerings"
kind: view
schema: api
name: model_offerings
domain: api-surface
lens: corpus
aliases: [offerings table, prices, price table]
tokens: [api, model_offerings, api.model_offerings, offering_id, offering, offering_key, model_version_id, model, provider_id, provider, region, tier, input_usd_per_1m, output_usd_per_1m, cached_input_usd_per_1m, batch_input_usd_per_1m, availability, pricing_url, price_valid_from, price_observed_at, price_claim_id, price_locator_id, as_of_knowledge_seq]
summary: "L1 — one row per offering with normalized USD per 1M tokens for input/output/cached/batch, availability and the exact claim + locator behind the input price."
summary_basis: curated
rls: disabled
readers: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"api\"][\"Views\"][\"model_offerings\"][\"Row\"]"
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", part4_views_seeds.sql]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# api.model_offerings

view in domain `api-surface`, lens `corpus` — L1: one row per offering (model as sold by a provider) with normalized USD per 1M tokens for input/output/cached/batch, availability and the exact claim + locator behind the input price..

> curated (model_assisted, unreviewed) — L1 — one row per offering with normalized USD per 1M tokens for input/output/cached/batch, availability and the exact claim + locator behind the input price.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `offering_id` | `uuid` | yes | — | — |
| 2 | `offering` | `text` | yes | — | — |
| 3 | `offering_key` | `text` | yes | — | — |
| 4 | `model_version_id` | `uuid` | yes | — | — |
| 5 | `model` | `text` | yes | — | — |
| 6 | `provider_id` | `uuid` | yes | — | — |
| 7 | `provider` | `text` | yes | — | — |
| 8 | `region` | `text` | yes | — | — |
| 9 | `tier` | `text` | yes | — | — |
| 10 | `input_usd_per_1m` | `numeric` | yes | — | _curated:_ Current offering_price fact for meter input_tokens, normalized. |
| 11 | `output_usd_per_1m` | `numeric` | yes | — | — |
| 12 | `cached_input_usd_per_1m` | `numeric` | yes | — | — |
| 13 | `batch_input_usd_per_1m` | `numeric` | yes | — | — |
| 14 | `availability` | `text` | yes | — | — |
| 15 | `pricing_url` | `text` | yes | — | — |
| 16 | `price_valid_from` | `timestamp with time zone` | yes | — | _curated:_ World clock: since when the price holds. |
| 17 | `price_observed_at` | `timestamp with time zone` | yes | — | _curated:_ When the capture that proved it was taken. |
| 18 | `price_claim_id` | `uuid` | yes | — | _curated:_ evidence.claim behind the input price. |
| 19 | `price_locator_id` | `uuid` | yes | — | _curated:_ evidence.locator behind the input price; api.fact_locators expands it. |
| 20 | `as_of_knowledge_seq` | `bigint` | yes | — | — |

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

- Named queries: `q:catalog.model_offerings`.
- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

Views are not written.

## View definition

See [details](model_offerings.details.md).

## TypeScript

row: `Database["api"]["Views"]["model_offerings"]["Row"]`

## Examples

Offerings by price

```bash
knowledge db query catalog.model_offerings --param limit=50 --param model_version_id=null --param text=null
```
Cheapest input first.

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `part4_views_seeds.sql`.
