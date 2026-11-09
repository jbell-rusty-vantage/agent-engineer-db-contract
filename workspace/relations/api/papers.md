---
id: "rel:api.papers"
kind: view
schema: api
name: papers
domain: api-surface
lens: corpus
aliases: []
tokens: [api, papers, api.papers, paper_id, title, arxiv_id, doi, published_at, canonical_url, authors, publishers, repositories, techniques, talks_about, citations, abstract]
summary: "L1: papers with identifiers, authors, code repositories, techniques introduced and the talks that discuss them."
summary_basis: comment
rls: disabled
readers: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"api\"][\"Views\"][\"papers\"][\"Row\"]"
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", part4_views_seeds.sql]
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
---
# api.papers

view in domain `api-surface`, lens `corpus` — L1: papers with identifiers, authors, code repositories, techniques introduced and the talks that discuss them..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `paper_id` | `uuid` | yes | — | — |
| 2 | `title` | `text` | yes | — | — |
| 3 | `arxiv_id` | `text` | yes | — | — |
| 4 | `doi` | `text` | yes | — | — |
| 5 | `published_at` | `timestamp with time zone` | yes | — | — |
| 6 | `canonical_url` | `text` | yes | — | — |
| 7 | `authors` | `text[]` | yes | — | — |
| 8 | `publishers` | `text[]` | yes | — | — |
| 9 | `repositories` | `text[]` | yes | — | — |
| 10 | `techniques` | `text[]` | yes | — | — |
| 11 | `talks_about` | `bigint` | yes | — | — |
| 12 | `citations` | `numeric` | yes | — | — |
| 13 | `abstract` | `text` | yes | — | — |

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

- Named queries: `q:catalog.papers`.
- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

Views are not written.

## View definition

See [details](papers.details.md).

## TypeScript

row: `Database["api"]["Views"]["papers"]["Row"]`

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `part4_views_seeds.sql`.
