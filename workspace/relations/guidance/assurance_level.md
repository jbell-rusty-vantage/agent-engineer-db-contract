---
id: "rel:guidance.assurance_level"
kind: table
schema: guidance
name: assurance_level
domain: guidance
lens: corpus
aliases: []
tokens: [guidance, assurance_level, guidance.assurance_level, code, rank, description]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"guidance\"][\"Tables\"][\"assurance_level\"][\"Row\"]"
defined_in: []
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# guidance.assurance_level

table in domain `guidance`, lens `corpus`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `code` | `text` | no | — | PK |
| 2 | `rank` | `integer` | no | — | unique (rank) |
| 3 | `description` | `text` | no | — | — |

## Constraints

- PK (code)
- unique (rank)

## Relationships

Outbound: none.
Inbound: [`guidance.item`](item.md).assurance_level.

## Indexes

`assurance_level_rank_key` unique

## Triggers

_None._

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `false`

## Grants

`executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: SELECT; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`, `control_plane`.

## Read paths

- Direct SELECT: `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["guidance"]["Tables"]["assurance_level"]["Insert"]`; row: `Database["guidance"]["Tables"]["assurance_level"]["Row"]`; update: `Database["guidance"]["Tables"]["assurance_level"]["Update"]`

Defined in: unknown.
