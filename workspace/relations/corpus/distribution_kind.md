---
id: "rel:corpus.distribution_kind"
kind: table
schema: corpus
name: distribution_kind
domain: identity
aliases: []
tokens: [corpus, distribution_kind, corpus.distribution_kind, code, description]
summary: null
summary_basis: none
rls: disabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"corpus\"][\"Tables\"][\"distribution_kind\"][\"Row\"]"
defined_in: ["20260826000500_corpus.sql", "20260912010100_km_01_vocabularies.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# corpus.distribution_kind

table in domain `identity`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `code` | `text` | no | — | PK |
| 2 | `description` | `text` | no | — | — |

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

insert: `Database["corpus"]["Tables"]["distribution_kind"]["Insert"]`; row: `Database["corpus"]["Tables"]["distribution_kind"]["Row"]`; update: `Database["corpus"]["Tables"]["distribution_kind"]["Update"]`

Defined in: `20260826000500_corpus.sql`, `20260912010100_km_01_vocabularies.sql`.
