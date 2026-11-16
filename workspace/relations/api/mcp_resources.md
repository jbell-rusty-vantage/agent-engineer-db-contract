---
id: "rel:api.mcp_resources"
kind: view
schema: api
name: mcp_resources
domain: api-surface
lens: corpus
aliases: []
tokens: [api, mcp_resources, api.mcp_resources, node_id, document_id, version_label, server, name, description, uri_template, server_id]
summary: null
summary_basis: none
rls: disabled
readers: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"api\"][\"Views\"][\"mcp_resources\"][\"Row\"]"
defined_in: ["20261110140000_build08_loop3_libraries_talks_capabilities.sql"]
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# api.mcp_resources

view in domain `api-surface`, lens `corpus`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `node_id` | `uuid` | yes | — | — |
| 2 | `document_id` | `uuid` | yes | — | — |
| 3 | `version_label` | `text` | yes | — | — |
| 4 | `server` | `text` | yes | — | — |
| 5 | `name` | `text` | yes | — | — |
| 6 | `description` | `text` | yes | — | — |
| 7 | `uri_template` | `text` | yes | — | — |
| 8 | `server_id` | `uuid` | yes | — | — |

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

See [details](mcp_resources.details.md).

## TypeScript

row: `Database["api"]["Views"]["mcp_resources"]["Row"]`

Defined in: `20261110140000_build08_loop3_libraries_talks_capabilities.sql`.
