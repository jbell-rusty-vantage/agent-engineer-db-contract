---
id: "rel:api.events"
kind: view
schema: api
name: events
domain: api-surface
lens: corpus
aliases: []
tokens: [api, events, api.events, event_id, event, slug, edition_label, starts_on, ends_on, city, country, website_url, series, organizers, talk_count, tracks]
summary: "L1: industry events (conference editions) with dates, place, series, organizers, tracks and talk counts."
summary_basis: comment
rls: disabled
readers: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"api\"][\"Views\"][\"events\"][\"Row\"]"
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", part4_views_seeds.sql]
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
---
# api.events

view in domain `api-surface`, lens `corpus` — L1: industry events (conference editions) with dates, place, series, organizers, tracks and talk counts..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `event_id` | `uuid` | yes | — | — |
| 2 | `event` | `text` | yes | — | — |
| 3 | `slug` | `text` | yes | — | — |
| 4 | `edition_label` | `text` | yes | — | — |
| 5 | `starts_on` | `text` | yes | — | — |
| 6 | `ends_on` | `text` | yes | — | — |
| 7 | `city` | `text` | yes | — | — |
| 8 | `country` | `text` | yes | — | — |
| 9 | `website_url` | `text` | yes | — | — |
| 10 | `series` | `text[]` | yes | — | — |
| 11 | `organizers` | `text[]` | yes | — | — |
| 12 | `talk_count` | `bigint` | yes | — | — |
| 13 | `tracks` | `text[]` | yes | — | — |

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

- Named queries: `q:catalog.events`.
- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

Views are not written.

## View definition

See [details](events.details.md).

## TypeScript

row: `Database["api"]["Views"]["events"]["Row"]`

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `part4_views_seeds.sql`.
