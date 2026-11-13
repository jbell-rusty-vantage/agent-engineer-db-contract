---
id: "rel:orchestration.intent_type"
kind: table
schema: orchestration
name: intent_type
domain: orchestration-ledger
lens: machinery
aliases: []
tokens: [orchestration, intent_type, orchestration.intent_type, code, description, schema_version, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role]
writers: [control_plane, executor_service, service_role]
typescript: "Database[\"orchestration\"][\"Tables\"][\"intent_type\"][\"Row\"]"
defined_in: ["20260826000200_orchestration.sql"]
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
---
# orchestration.intent_type

table in domain `orchestration-ledger`, lens `machinery`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `code` | `text` | no | — | PK |
| 2 | `description` | `text` | no | — | — |
| 3 | `schema_version` | `integer` | no | `1` | — |
| 4 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (code)

## Relationships

Outbound: none.
Inbound: [`orchestration.operation_intent`](operation_intent.md).intent_type.

## Indexes

_None._

## Triggers

_None._

## Row-level security

Enabled.
- `global_vocabulary_read` (SELECT) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `true`

## Grants

`control_plane`: INSERT, SELECT, UPDATE; `executor_service`: INSERT, SELECT; `pipeline_agent`: SELECT; `service_role`: INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `verifier_agent`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`.

## Write path

- Direct DML: `control_plane`, `executor_service`.

## TypeScript

insert: `Database["orchestration"]["Tables"]["intent_type"]["Insert"]`; row: `Database["orchestration"]["Tables"]["intent_type"]["Row"]`; update: `Database["orchestration"]["Tables"]["intent_type"]["Update"]`

Defined in: `20260826000200_orchestration.sql`.
