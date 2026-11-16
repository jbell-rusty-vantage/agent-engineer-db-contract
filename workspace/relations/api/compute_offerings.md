---
id: "rel:api.compute_offerings"
kind: view
schema: api
name: compute_offerings
domain: api-surface
lens: corpus
aliases: []
tokens: [api, compute_offerings, api.compute_offerings, offering_id, offering, slug, offering_class, provider_slug, providers, devices, gpu_count, vcpu, memory_gb, pricing_url, meter, commitment, region, amount, currency, unit, per, usd_per_gpu_hour, valid_from, learned_k, claim_id]
summary: "L1: compute offerings (instance types, serverless GPUs, sandboxes, TPU slices) with every current price row (meter × commitment × region) normalised to USD per GPU-hour where a GPU count is known."
summary_basis: comment
rls: disabled
readers: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"api\"][\"Views\"][\"compute_offerings\"][\"Row\"]"
defined_in: ["20261109130000_build08_loop2_numbers_compute_apis.sql"]
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# api.compute_offerings

view in domain `api-surface`, lens `corpus` — L1: compute offerings (instance types, serverless GPUs, sandboxes, TPU slices) with every current price row (meter × commitment × region) normalised to USD per GPU-hour where a GPU count is known..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `offering_id` | `uuid` | yes | — | — |
| 2 | `offering` | `text` | yes | — | — |
| 3 | `slug` | `text` | yes | — | — |
| 4 | `offering_class` | `text` | yes | — | — |
| 5 | `provider_slug` | `text` | yes | — | — |
| 6 | `providers` | `text[]` | yes | — | — |
| 7 | `devices` | `text[]` | yes | — | — |
| 8 | `gpu_count` | `integer` | yes | — | — |
| 9 | `vcpu` | `numeric` | yes | — | — |
| 10 | `memory_gb` | `numeric` | yes | — | — |
| 11 | `pricing_url` | `text` | yes | — | — |
| 12 | `meter` | `text` | yes | — | — |
| 13 | `commitment` | `text` | yes | — | — |
| 14 | `region` | `text` | yes | — | — |
| 15 | `amount` | `numeric(20,6)` | yes | — | — |
| 16 | `currency` | `character(3)` | yes | — | — |
| 17 | `unit` | `text` | yes | — | — |
| 18 | `per` | `text` | yes | — | — |
| 19 | `usd_per_gpu_hour` | `numeric` | yes | — | — |
| 20 | `valid_from` | `timestamp with time zone` | yes | — | — |
| 21 | `learned_k` | `bigint` | yes | — | — |
| 22 | `claim_id` | `uuid` | yes | — | — |

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

See [details](compute_offerings.details.md).

## TypeScript

row: `Database["api"]["Views"]["compute_offerings"]["Row"]`

Defined in: `20261109130000_build08_loop2_numbers_compute_apis.sql`.
