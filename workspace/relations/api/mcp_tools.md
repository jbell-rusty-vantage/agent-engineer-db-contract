---
id: "rel:api.mcp_tools"
kind: view
schema: api
name: mcp_tools
domain: api-surface
lens: corpus
aliases: []
tokens: [api, mcp_tools, api.mcp_tools, node_id, document_id, document_version_id, version_label, server, name, description, toolset, input_schema, required, scopes, availability, server_id, custody_level, logical_key]
summary: "L1: tools an MCP server exposes per captured version (from a published manifest). Version diffs: content.unit_change by logical key."
summary_basis: comment
rls: disabled
readers: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"api\"][\"Views\"][\"mcp_tools\"][\"Row\"]"
defined_in: ["20261110140000_build08_loop3_libraries_talks_capabilities.sql"]
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# api.mcp_tools

view in domain `api-surface`, lens `corpus` — L1: tools an MCP server exposes per captured version (from a published manifest). Version diffs: content.unit_change by logical key..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `node_id` | `uuid` | yes | — | — |
| 2 | `document_id` | `uuid` | yes | — | — |
| 3 | `document_version_id` | `uuid` | yes | — | — |
| 4 | `version_label` | `text` | yes | — | — |
| 5 | `server` | `text` | yes | — | — |
| 6 | `name` | `text` | yes | — | — |
| 7 | `description` | `text` | yes | — | — |
| 8 | `toolset` | `text` | yes | — | — |
| 9 | `input_schema` | `jsonb` | yes | — | — |
| 10 | `required` | `jsonb` | yes | — | — |
| 11 | `scopes` | `jsonb` | yes | — | — |
| 12 | `availability` | `text` | yes | — | — |
| 13 | `server_id` | `uuid` | yes | — | — |
| 14 | `custody_level` | `text` | yes | — | — |
| 15 | `logical_key` | `text` | yes | — | — |

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

- Exposed through: [`api.capabilities`](capabilities.md).
- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

Views are not written.

## View definition

See [details](mcp_tools.details.md).

## TypeScript

row: `Database["api"]["Views"]["mcp_tools"]["Row"]`

Defined in: `20261110140000_build08_loop3_libraries_talks_capabilities.sql`.
