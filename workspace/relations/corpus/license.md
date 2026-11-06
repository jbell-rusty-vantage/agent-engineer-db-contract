---
id: "rel:corpus.license"
kind: table
schema: corpus
name: license
domain: identity
aliases: []
tokens: [corpus, license, corpus.license, code, name, spdx_id, url]
summary: null
summary_basis: none
rls: disabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"corpus\"][\"Tables\"][\"license\"][\"Row\"]"
defined_in: ["20260912010100_km_01_vocabularies.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# corpus.license

table in domain `identity`.

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
Inbound: [`corpus.dataset`](dataset.md).license_code, [`corpus.library_release`](library_release.md).license_code.

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

insert: `Database["corpus"]["Tables"]["license"]["Insert"]`; row: `Database["corpus"]["Tables"]["license"]["Row"]`; update: `Database["corpus"]["Tables"]["license"]["Update"]`

Defined in: `20260912010100_km_01_vocabularies.sql`.
