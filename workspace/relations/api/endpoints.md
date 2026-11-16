---
id: "rel:api.endpoints"
kind: view
schema: api
name: endpoints
domain: api-surface
lens: corpus
aliases: []
tokens: [api, endpoints, api.endpoints, node_id, document_id, api_document, version_label, published_at, method, path, operation_id, summary, tags, deprecated, parameter_count, family, logical_key, api_entity_id]
summary: "L1: API operations per captured specification version; diff two versions by logical key (method|path) through content.unit_change or api.changes_since."
summary_basis: comment
rls: disabled
readers: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"api\"][\"Views\"][\"endpoints\"][\"Row\"]"
defined_in: ["20261109130000_build08_loop2_numbers_compute_apis.sql"]
workspace_fingerprint: "sha256:216c4ae7230478c8e60934da25c852e10680d6caed71a662962ea3c0ac1676d3"
---
# api.endpoints

view in domain `api-surface`, lens `corpus` — L1: API operations per captured specification version; diff two versions by logical key (method|path) through content.unit_change or api.changes_since..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `node_id` | `uuid` | yes | — | — |
| 2 | `document_id` | `uuid` | yes | — | — |
| 3 | `api_document` | `text` | yes | — | — |
| 4 | `version_label` | `text` | yes | — | — |
| 5 | `published_at` | `timestamp with time zone` | yes | — | — |
| 6 | `method` | `text` | yes | — | — |
| 7 | `path` | `text` | yes | — | — |
| 8 | `operation_id` | `text` | yes | — | — |
| 9 | `summary` | `text` | yes | — | — |
| 10 | `tags` | `jsonb` | yes | — | — |
| 11 | `deprecated` | `boolean` | yes | — | — |
| 12 | `parameter_count` | `integer` | yes | — | — |
| 13 | `family` | `text` | yes | — | — |
| 14 | `logical_key` | `text` | yes | — | — |
| 15 | `api_entity_id` | `uuid` | yes | — | — |

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

See [details](endpoints.details.md).

## TypeScript

row: `Database["api"]["Views"]["endpoints"]["Row"]`

Defined in: `20261109130000_build08_loop2_numbers_compute_apis.sql`.
