---
id: "rel:api.concepts"
kind: view
schema: api
name: concepts
domain: api-surface
lens: corpus
aliases: []
tokens: [api, concepts, api.concepts, concept_id, kind, concept, slug, component, level, description, works_about, instances, implementations, guidance_items, modules_covering]
summary: "L1: concepts and techniques (RAG, context engineering, harness, sandbox, MCP, skills ...) with how many works discuss them, software implements them, guidance items explain them and our modules cover them."
summary_basis: comment
rls: disabled
readers: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"api\"][\"Views\"][\"concepts\"][\"Row\"]"
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", part4_views_seeds.sql]
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# api.concepts

view in domain `api-surface`, lens `corpus` — L1: concepts and techniques (RAG, context engineering, harness, sandbox, MCP, skills ...) with how many works discuss them, software implements them, guidance items explain them and our modules cover them..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `concept_id` | `uuid` | yes | — | — |
| 2 | `kind` | `text` | yes | — | — |
| 3 | `concept` | `text` | yes | — | — |
| 4 | `slug` | `text` | yes | — | — |
| 5 | `component` | `text` | yes | — | — |
| 6 | `level` | `text` | yes | — | — |
| 7 | `description` | `text` | yes | — | — |
| 8 | `works_about` | `bigint` | yes | — | — |
| 9 | `instances` | `bigint` | yes | — | — |
| 10 | `implementations` | `bigint` | yes | — | — |
| 11 | `guidance_items` | `bigint` | yes | — | — |
| 12 | `modules_covering` | `bigint` | yes | — | — |

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

- Named queries: `q:catalog.concepts`.
- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

Views are not written.

## View definition

See [details](concepts.details.md).

## TypeScript

row: `Database["api"]["Views"]["concepts"]["Row"]`

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `part4_views_seeds.sql`.
