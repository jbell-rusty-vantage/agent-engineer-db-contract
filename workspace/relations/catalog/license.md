---
id: "rel:catalog.license"
kind: table
schema: catalog
name: license
domain: identity
lens: corpus
aliases: []
tokens: [catalog, license, catalog.license, code, name, spdx_id, url]
summary: null
summary_basis: none
rls: disabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"catalog\"][\"Tables\"][\"license\"][\"Row\"]"
defined_in: []
workspace_fingerprint: "sha256:94ffe6a458de74a3cfebdee4fb31f371d14c89d7eaa16cfe1ab1cae9dc94743b"
---
# catalog.license

table in domain `identity`, lens `corpus`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `code` | `text` | no | — | PK |
| 2 | `name` | `text` | no | — | — |
| 3 | `spdx_id` | `text` | yes | — | — |
| 4 | `url` | `text` | yes | — | — |

## Constraints

- PK (code)

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

`control_plane`: SELECT; `executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: SELECT; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["catalog"]["Tables"]["license"]["Insert"]`; row: `Database["catalog"]["Tables"]["license"]["Row"]`; update: `Database["catalog"]["Tables"]["license"]["Update"]`

Defined in: unknown.
