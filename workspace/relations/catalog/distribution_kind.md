---
id: "rel:catalog.distribution_kind"
kind: table
schema: catalog
name: distribution_kind
domain: identity
lens: corpus
aliases: []
tokens: [catalog, distribution_kind, catalog.distribution_kind, code, description]
summary: null
summary_basis: none
rls: disabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"catalog\"][\"Tables\"][\"distribution_kind\"][\"Row\"]"
defined_in: []
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# catalog.distribution_kind

table in domain `identity`, lens `corpus`.

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

insert: `Database["catalog"]["Tables"]["distribution_kind"]["Insert"]`; row: `Database["catalog"]["Tables"]["distribution_kind"]["Row"]`; update: `Database["catalog"]["Tables"]["distribution_kind"]["Update"]`

Defined in: unknown.
