---
id: "rel:content.transformation_kind"
kind: table
schema: content
name: transformation_kind
domain: content
aliases: []
tokens: [content, transformation_kind, content.transformation_kind, code, description]
summary: null
summary_basis: none
rls: disabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, pipeline_agent, service_role]
typescript: "Database[\"content\"][\"Tables\"][\"transformation_kind\"][\"Row\"]"
defined_in: ["20260912010100_km_01_vocabularies.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# content.transformation_kind

table in domain `content`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `code` | `text` | no | — | PK |
| 2 | `description` | `text` | no | — | — |

## Constraints

- PK (code)

## Relationships

Outbound: none.
Inbound: [`content.transformation_run`](transformation_run.md).transformation_kind.

## Indexes

_None._

## Triggers

_None._

## Row-level security

Disabled.

## Grants

`control_plane`: SELECT; `executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`, `pipeline_agent`.

## TypeScript

insert: `Database["content"]["Tables"]["transformation_kind"]["Insert"]`; row: `Database["content"]["Tables"]["transformation_kind"]["Row"]`; update: `Database["content"]["Tables"]["transformation_kind"]["Update"]`

Defined in: `20260912010100_km_01_vocabularies.sql`.
