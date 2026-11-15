---
id: "rel:api.api_symbols"
kind: view
schema: api
name: api_symbols
domain: api-surface
lens: corpus
aliases: []
tokens: [api, api_symbols, api.api_symbols, node_id, document_id, repository, release_tag, package, qualified_name, symbol_kind, signature, module, is_public, deprecated, docstring_head, path, lineno, release_id, docs_links, overloads, uses_external, released_on, embedded]
summary: "L1: public API symbols per repository release (R3). When a release surface was parsed more than once, only the newest document with units is read."
summary_basis: comment
rls: disabled
readers: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"api\"][\"Views\"][\"api_symbols\"][\"Row\"]"
defined_in: ["20261109130000_build08_loop2_numbers_compute_apis.sql", "20261110140000_build08_loop3_libraries_talks_capabilities.sql", "20261110140100_build08_loop3_fixups.sql", "20261110140200_build08_loop3_fixups2.sql"]
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
---
# api.api_symbols

view in domain `api-surface`, lens `corpus` — L1: public API symbols per repository release (R3). When a release surface was parsed more than once, only the newest document with units is read..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `node_id` | `uuid` | yes | — | — |
| 2 | `document_id` | `uuid` | yes | — | — |
| 3 | `repository` | `text` | yes | — | — |
| 4 | `release_tag` | `text` | yes | — | — |
| 5 | `package` | `text` | yes | — | — |
| 6 | `qualified_name` | `text` | yes | — | — |
| 7 | `symbol_kind` | `text` | yes | — | — |
| 8 | `signature` | `text` | yes | — | — |
| 9 | `module` | `text` | yes | — | — |
| 10 | `is_public` | `boolean` | yes | — | — |
| 11 | `deprecated` | `boolean` | yes | — | — |
| 12 | `docstring_head` | `text` | yes | — | — |
| 13 | `path` | `text` | yes | — | — |
| 14 | `lineno` | `integer` | yes | — | — |
| 15 | `release_id` | `uuid` | yes | — | — |
| 16 | `docs_links` | `bigint` | yes | — | — |
| 17 | `overloads` | `jsonb` | yes | — | — |
| 18 | `uses_external` | `jsonb` | yes | — | — |
| 19 | `released_on` | `text` | yes | — | — |
| 20 | `embedded` | `boolean` | yes | — | — |

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

See [details](api_symbols.details.md).

## TypeScript

row: `Database["api"]["Views"]["api_symbols"]["Row"]`

Defined in: `20261109130000_build08_loop2_numbers_compute_apis.sql`, `20261110140000_build08_loop3_libraries_talks_capabilities.sql`, `20261110140100_build08_loop3_fixups.sql`, `20261110140200_build08_loop3_fixups2.sql`.
