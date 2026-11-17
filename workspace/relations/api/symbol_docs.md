---
id: "rel:api.symbol_docs"
kind: view
schema: api
name: symbol_docs
domain: api-surface
lens: corpus
aliases: []
tokens: [api, symbol_docs, api.symbol_docs, symbol_node_id, repository, release_tag, package, qualified_name, symbol_kind, link_kind, link_method, confidence, docs_node_id, docs_unit_kind, heading, section_path, excerpt, document_id, document_title, document_type_code, url, version_label, version_note]
summary: "L3: the docs sections and code examples that document or mention a public API symbol (R4), one call: filter by qualified_name or repository."
summary_basis: comment
rls: disabled
readers: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"api\"][\"Views\"][\"symbol_docs\"][\"Row\"]"
defined_in: ["20261110140000_build08_loop3_libraries_talks_capabilities.sql"]
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# api.symbol_docs

view in domain `api-surface`, lens `corpus` — L3: the docs sections and code examples that document or mention a public API symbol (R4), one call: filter by qualified_name or repository..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `symbol_node_id` | `uuid` | yes | — | — |
| 2 | `repository` | `text` | yes | — | — |
| 3 | `release_tag` | `text` | yes | — | — |
| 4 | `package` | `text` | yes | — | — |
| 5 | `qualified_name` | `text` | yes | — | — |
| 6 | `symbol_kind` | `text` | yes | — | — |
| 7 | `link_kind` | `text` | yes | — | — |
| 8 | `link_method` | `text` | yes | — | — |
| 9 | `confidence` | `numeric(5,4)` | yes | — | — |
| 10 | `docs_node_id` | `uuid` | yes | — | — |
| 11 | `docs_unit_kind` | `text` | yes | — | — |
| 12 | `heading` | `text` | yes | — | — |
| 13 | `section_path` | `text` | yes | — | — |
| 14 | `excerpt` | `text` | yes | — | — |
| 15 | `document_id` | `uuid` | yes | — | — |
| 16 | `document_title` | `text` | yes | — | — |
| 17 | `document_type_code` | `text` | yes | — | — |
| 18 | `url` | `text` | yes | — | — |
| 19 | `version_label` | `text` | yes | — | — |
| 20 | `version_note` | `text` | yes | — | — |

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

See [details](symbol_docs.details.md).

## TypeScript

row: `Database["api"]["Views"]["symbol_docs"]["Row"]`

Defined in: `20261110140000_build08_loop3_libraries_talks_capabilities.sql`.
