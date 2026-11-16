---
id: "rel:guidance.item_kind"
kind: table
schema: guidance
name: item_kind
domain: guidance
lens: corpus
aliases: []
tokens: [guidance, item_kind, guidance.item_kind, code, description, payload_schema]
summary: Vocabulary of guidance item kinds; payload_schema validates guidance.item.payload.
summary_basis: comment
rls: disabled
readers: [app_reader, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"guidance\"][\"Tables\"][\"item_kind\"][\"Row\"]"
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", part1_renames.sql]
workspace_fingerprint: "sha256:216c4ae7230478c8e60934da25c852e10680d6caed71a662962ea3c0ac1676d3"
---
# guidance.item_kind

table in domain `guidance`, lens `corpus` — Vocabulary of guidance item kinds; payload_schema validates guidance.item.payload..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `code` | `text` | no | — | PK |
| 2 | `description` | `text` | no | — | — |
| 3 | `payload_schema` | `jsonb` | no | `'{"type": "object"}'::jsonb` | — |

## Constraints

- PK (code)

## Relationships

Outbound: none.
Inbound: [`guidance.item`](item.md).kind.

## Indexes

_None._

## Triggers

_None._

## Row-level security

Disabled.

## Grants

`app_reader`: SELECT; `control_plane`: SELECT; `executor_service`: SELECT; `pipeline_agent`: SELECT; `service_role`: SELECT; `verifier_agent`: SELECT. None: `anon`, `authenticated`.

## Read paths

- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- No direct DML for any agent role.
- No write path for agents; rows are seeded by migrations or platform tooling.

## TypeScript

insert: `Database["guidance"]["Tables"]["item_kind"]["Insert"]`; row: `Database["guidance"]["Tables"]["item_kind"]["Row"]`; update: `Database["guidance"]["Tables"]["item_kind"]["Update"]`

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `part1_renames.sql`.
