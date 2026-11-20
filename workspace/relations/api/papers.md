---
id: "rel:api.papers"
kind: view
schema: api
name: papers
domain: api-surface
lens: corpus
aliases: []
tokens: [api, papers, api.papers, paper_id, title, arxiv_id, doi, published_at, canonical_url, authors, publishers, repositories, techniques, talks_about, cited_by_count, cites_count, citations, abstract, ingestion_level, promotion, document_id, document_type_code, publication_form]
summary: "L1: papers with authors, code, citing talks/papers, cited papers and the ingestion level (P0 reference / P1 digest / P2 full) with its recorded promotion decision (document linked through document_about_entity role primary)."
summary_basis: comment
rls: disabled
readers: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"api\"][\"Views\"][\"papers\"][\"Row\"]"
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", "20261109130000_build08_loop2_numbers_compute_apis.sql", "20261109130100_build08_loop2_fixups.sql", "20261109130200_build08_loop2_fixups2.sql", part4_views_seeds.sql]
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# api.papers

view in domain `api-surface`, lens `corpus` — L1: papers with authors, code, citing talks/papers, cited papers and the ingestion level (P0 reference / P1 digest / P2 full) with its recorded promotion decision (document linked through document_about_entity role primary)..

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
| 12 | `cited_by_count` | `bigint` | yes | — | — |
| 13 | `cites_count` | `bigint` | yes | — | — |
| 14 | `citations` | `numeric` | yes | — | — |
| 15 | `abstract` | `text` | yes | — | — |
| 16 | `ingestion_level` | `text` | yes | — | — |
| 17 | `promotion` | `jsonb` | yes | — | — |
| 18 | `document_id` | `uuid` | yes | — | — |
| 19 | `document_type_code` | `text` | yes | — | — |
| 20 | `publication_form` | `text` | yes | — | — |

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

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `20261109130000_build08_loop2_numbers_compute_apis.sql`, `20261109130100_build08_loop2_fixups.sql`, `20261109130200_build08_loop2_fixups2.sql`, `part4_views_seeds.sql`.
