---
id: "rel:api.organizations"
kind: view
schema: api
name: organizations
domain: api-surface
lens: corpus
aliases: []
tokens: [api, organizations, api.organizations, organization_id, organization, slug, org_kind, website_url, country_code, founded_on, summary, developed_count, offering_count, people_count, headcount]
summary: "L1: organizations with kind, site, country, founding date and counts of what they develop, sell and employ."
summary_basis: comment
rls: disabled
readers: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"api\"][\"Views\"][\"organizations\"][\"Row\"]"
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", part4_views_seeds.sql]
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
---
# api.organizations

view in domain `api-surface`, lens `corpus` — L1: organizations with kind, site, country, founding date and counts of what they develop, sell and employ..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `organization_id` | `uuid` | yes | — | — |
| 2 | `organization` | `text` | yes | — | — |
| 3 | `slug` | `text` | yes | — | — |
| 4 | `org_kind` | `text` | yes | — | — |
| 5 | `website_url` | `text` | yes | — | — |
| 6 | `country_code` | `text` | yes | — | — |
| 7 | `founded_on` | `text` | yes | — | — |
| 8 | `summary` | `text` | yes | — | — |
| 9 | `developed_count` | `bigint` | yes | — | — |
| 10 | `offering_count` | `bigint` | yes | — | — |
| 11 | `people_count` | `bigint` | yes | — | — |
| 12 | `headcount` | `numeric` | yes | — | — |

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

- Named queries: `q:catalog.organizations`.
- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

Views are not written.

## View definition

See [details](organizations.details.md).

## TypeScript

row: `Database["api"]["Views"]["organizations"]["Row"]`

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `part4_views_seeds.sql`.
