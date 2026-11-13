---
id: "rel:api.capabilities"
kind: view
schema: api
name: capabilities
domain: api-surface
lens: corpus
aliases: []
tokens: [api, capabilities, api.capabilities, capability_id, kind, capability, slug, identifiers, custody_level, manifest_document_id, commit, version_label, description, files, executable_files, tools, hooks, bundles, bundled_in, compatible_with, listed_in, repositories]
summary: "L1: researched capabilities (skills, MCP servers, plugins) with shared upstream identifiers and the custody level of the latest manifest (C0 reference, C1 manifest, C2 bundle; recorded on the manifest document like ingestion_level)."
summary_basis: comment
rls: disabled
readers: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"api\"][\"Views\"][\"capabilities\"][\"Row\"]"
defined_in: ["20261110140000_build08_loop3_libraries_talks_capabilities.sql"]
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
---
# api.capabilities

view in domain `api-surface`, lens `corpus` — L1: researched capabilities (skills, MCP servers, plugins) with shared upstream identifiers and the custody level of the latest manifest (C0 reference, C1 manifest, C2 bundle; recorded on the manifest document like ingestion_level)..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `capability_id` | `uuid` | yes | — | — |
| 2 | `kind` | `text` | yes | — | — |
| 3 | `capability` | `text` | yes | — | — |
| 4 | `slug` | `text` | yes | — | — |
| 5 | `identifiers` | `jsonb` | yes | — | — |
| 6 | `custody_level` | `text` | yes | — | — |
| 7 | `manifest_document_id` | `uuid` | yes | — | — |
| 8 | `commit` | `text` | yes | — | — |
| 9 | `version_label` | `text` | yes | — | — |
| 10 | `description` | `text` | yes | — | — |
| 11 | `files` | `bigint` | yes | — | — |
| 12 | `executable_files` | `bigint` | yes | — | — |
| 13 | `tools` | `bigint` | yes | — | — |
| 14 | `hooks` | `bigint` | yes | — | — |
| 15 | `bundles` | `text[]` | yes | — | — |
| 16 | `bundled_in` | `text[]` | yes | — | — |
| 17 | `compatible_with` | `text[]` | yes | — | — |
| 18 | `listed_in` | `text[]` | yes | — | — |
| 19 | `repositories` | `text[]` | yes | — | — |

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

See [details](capabilities.details.md).

## TypeScript

row: `Database["api"]["Views"]["capabilities"]["Row"]`

Defined in: `20261110140000_build08_loop3_libraries_talks_capabilities.sql`.
