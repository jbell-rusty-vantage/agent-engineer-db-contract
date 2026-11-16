---
id: "rel:api.protocol_versions"
kind: view
schema: api
name: protocol_versions
domain: api-surface
lens: corpus
aliases: []
tokens: [api, protocol_versions, api.protocol_versions, version_id, version, protocol, version_label, released_on, status, changelog_url, schema_url, deprecates, highlights, implemented_by]
summary: "L1: protocol revisions (MCP) with status, changelog, highlights and the software releases that implement them."
summary_basis: comment
rls: disabled
readers: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"api\"][\"Views\"][\"protocol_versions\"][\"Row\"]"
defined_in: ["20261109130000_build08_loop2_numbers_compute_apis.sql"]
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# api.protocol_versions

view in domain `api-surface`, lens `corpus` — L1: protocol revisions (MCP) with status, changelog, highlights and the software releases that implement them..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `version_id` | `uuid` | yes | — | — |
| 2 | `version` | `text` | yes | — | — |
| 3 | `protocol` | `text` | yes | — | — |
| 4 | `version_label` | `text` | yes | — | — |
| 5 | `released_on` | `text` | yes | — | — |
| 6 | `status` | `text` | yes | — | — |
| 7 | `changelog_url` | `text` | yes | — | — |
| 8 | `schema_url` | `text` | yes | — | — |
| 9 | `deprecates` | `jsonb` | yes | — | — |
| 10 | `highlights` | `jsonb` | yes | — | — |
| 11 | `implemented_by` | `text[]` | yes | — | — |

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

See [details](protocol_versions.details.md).

## TypeScript

row: `Database["api"]["Views"]["protocol_versions"]["Row"]`

Defined in: `20261109130000_build08_loop2_numbers_compute_apis.sql`.
