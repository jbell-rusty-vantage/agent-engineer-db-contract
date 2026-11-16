---
id: "rel:api.mcp_prompts"
kind: view
schema: api
name: mcp_prompts
domain: api-surface
lens: corpus
aliases: []
tokens: [api, mcp_prompts, api.mcp_prompts, node_id, document_id, version_label, server, name, description, arguments, server_id]
summary: null
summary_basis: none
rls: disabled
readers: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"api\"][\"Views\"][\"mcp_prompts\"][\"Row\"]"
defined_in: ["20261110140000_build08_loop3_libraries_talks_capabilities.sql"]
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# api.mcp_prompts

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
| 7 | `arguments` | `jsonb` | yes | — | — |
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

See [details](mcp_prompts.details.md).

## TypeScript

row: `Database["api"]["Views"]["mcp_prompts"]["Row"]`

Defined in: `20261110140000_build08_loop3_libraries_talks_capabilities.sql`.
