---
id: "rel:api.bundle_files"
kind: view
schema: api
name: bundle_files
domain: api-surface
lens: corpus
aliases: []
tokens: [api, bundle_files, api.bundle_files, node_id, document_id, version_label, capability_id, capability, path, size, mode, executable, git_blob_id, sha256, file_role, commit, custody_level]
summary: "L1: the C1 file manifest of a capability bundle at a pinned commit (path, size, mode, executable, git blob id; sha256 only when bytes were fetched). A later materialize can verify fetched bytes against git_blob_id."
summary_basis: comment
rls: disabled
readers: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"api\"][\"Views\"][\"bundle_files\"][\"Row\"]"
defined_in: ["20261110140000_build08_loop3_libraries_talks_capabilities.sql"]
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
---
# api.bundle_files

view in domain `api-surface`, lens `corpus` — L1: the C1 file manifest of a capability bundle at a pinned commit (path, size, mode, executable, git blob id; sha256 only when bytes were fetched). A later materialize can verify fetched bytes against git_blob_id..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `node_id` | `uuid` | yes | — | — |
| 2 | `document_id` | `uuid` | yes | — | — |
| 3 | `version_label` | `text` | yes | — | — |
| 4 | `capability_id` | `uuid` | yes | — | — |
| 5 | `capability` | `text` | yes | — | — |
| 6 | `path` | `text` | yes | — | — |
| 7 | `size` | `bigint` | yes | — | — |
| 8 | `mode` | `text` | yes | — | — |
| 9 | `executable` | `boolean` | yes | — | — |
| 10 | `git_blob_id` | `text` | yes | — | — |
| 11 | `sha256` | `text` | yes | — | — |
| 12 | `file_role` | `text` | yes | — | — |
| 13 | `commit` | `text` | yes | — | — |
| 14 | `custody_level` | `text` | yes | — | — |

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

See [details](bundle_files.details.md).

## TypeScript

row: `Database["api"]["Views"]["bundle_files"]["Row"]`

Defined in: `20261110140000_build08_loop3_libraries_talks_capabilities.sql`.
