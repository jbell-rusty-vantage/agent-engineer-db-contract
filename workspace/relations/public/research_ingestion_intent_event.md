---
id: "rel:public.research_ingestion_intent_event"
kind: table
schema: public
name: research_ingestion_intent_event
domain: research-starter-protected
aliases: []
tokens: [public, research_ingestion_intent_event, public.research_ingestion_intent_event, event_id, intent_id, operation_index, operation_kind, status, affected_table, affected_key, error_detail, created_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"public\"][\"Tables\"][\"research_ingestion_intent_event\"][\"Row\"]"
defined_in: ["20260815015402_research_pre_research_schema.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# public.research_ingestion_intent_event

table in domain `research-starter-protected`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `event_id` | `uuid` | no | `gen_random_uuid()` | PK |
| 2 | `intent_id` | `uuid` | no | — | FK → [`public.research_ingestion_intent`](research_ingestion_intent.md).intent_id |
| 3 | `operation_index` | `integer` | no | — | — |
| 4 | `operation_kind` | `text` | no | — | — |
| 5 | `status` | `research_intent_event_status` | no | — | — |
| 6 | `affected_table` | `text` | yes | — | — |
| 7 | `affected_key` | `text` | yes | — | — |
| 8 | `error_detail` | `text` | yes | — | — |
| 9 | `created_at` | `timestamp with time zone` | no | `timezone('utc'::text, now())` | — |

## Constraints

- PK (event_id)
- check `research_ingestion_intent_event_operation_index_check`: `(operation_index >= 0)`

## Relationships

Outbound: `intent_id` → [`public.research_ingestion_intent`](research_ingestion_intent.md)`.intent_id` on delete cascade.
Inbound: none.

## Indexes

`research_ingestion_intent_event_intent_idx`

## Triggers

_None._

## Row-level security

Enabled.

## Grants

No role has privileges. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

## Read paths

- No agent role may SELECT directly.

## Write path

- No direct DML for any agent role.
- No write path for agents; rows are seeded by migrations or platform tooling.

## TypeScript

insert: `Database["public"]["Tables"]["research_ingestion_intent_event"]["Insert"]`; row: `Database["public"]["Tables"]["research_ingestion_intent_event"]["Row"]`; update: `Database["public"]["Tables"]["research_ingestion_intent_event"]["Update"]`

Defined in: `20260815015402_research_pre_research_schema.sql`.
