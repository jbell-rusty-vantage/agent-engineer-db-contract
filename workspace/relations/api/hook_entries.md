---
id: "rel:api.hook_entries"
kind: view
schema: api
name: hook_entries
domain: api-surface
lens: corpus
aliases: []
tokens: [api, hook_entries, api.hook_entries, node_id, document_id, version_label, plugin_id, plugin, event, matcher, hook_type, command, config_path]
summary: null
summary_basis: none
rls: disabled
readers: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"api\"][\"Views\"][\"hook_entries\"][\"Row\"]"
defined_in: ["20261110140000_build08_loop3_libraries_talks_capabilities.sql"]
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# api.hook_entries

view in domain `api-surface`, lens `corpus`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `node_id` | `uuid` | yes | — | — |
| 2 | `document_id` | `uuid` | yes | — | — |
| 3 | `version_label` | `text` | yes | — | — |
| 4 | `plugin_id` | `uuid` | yes | — | — |
| 5 | `plugin` | `text` | yes | — | — |
| 6 | `event` | `text` | yes | — | — |
| 7 | `matcher` | `text` | yes | — | — |
| 8 | `hook_type` | `text` | yes | — | — |
| 9 | `command` | `text` | yes | — | — |
| 10 | `config_path` | `text` | yes | — | — |

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

See [details](hook_entries.details.md).

## TypeScript

row: `Database["api"]["Views"]["hook_entries"]["Row"]`

Defined in: `20261110140000_build08_loop3_libraries_talks_capabilities.sql`.
