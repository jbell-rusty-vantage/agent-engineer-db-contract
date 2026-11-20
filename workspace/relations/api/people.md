---
id: "rel:api.people"
kind: view
schema: api
name: people
domain: api-surface
lens: corpus
aliases: []
tokens: [api, people, api.people, person_id, person, slug, title, profile_url, affiliations, talk_count, work_count]
summary: "L1: people with current affiliations (employed_by, as of now) and how many talks/works they presented or authored."
summary_basis: comment
rls: disabled
readers: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"api\"][\"Views\"][\"people\"][\"Row\"]"
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", part4_views_seeds.sql]
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# api.people

view in domain `api-surface`, lens `corpus` — L1: people with current affiliations (employed_by, as of now) and how many talks/works they presented or authored..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `person_id` | `uuid` | yes | — | — |
| 2 | `person` | `text` | yes | — | — |
| 3 | `slug` | `text` | yes | — | — |
| 4 | `title` | `text` | yes | — | — |
| 5 | `profile_url` | `text` | yes | — | — |
| 6 | `affiliations` | `text[]` | yes | — | — |
| 7 | `talk_count` | `bigint` | yes | — | — |
| 8 | `work_count` | `bigint` | yes | — | — |

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

- Named queries: `q:catalog.people`.
- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

Views are not written.

## View definition

See [details](people.details.md).

## TypeScript

row: `Database["api"]["Views"]["people"]["Row"]`

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `part4_views_seeds.sql`.
