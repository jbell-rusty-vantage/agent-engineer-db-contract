---
id: "rel:public.research_web_search_event"
kind: table
schema: public
name: research_web_search_event
domain: research-starter-protected
aliases: []
tokens: [public, research_web_search_event, public.research_web_search_event, search_event_id, run_id, subagent, query, provider, searched_at, result_urls, selected_urls, search_purpose]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"public\"][\"Tables\"][\"research_web_search_event\"][\"Row\"]"
defined_in: ["20260815015402_research_pre_research_schema.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# public.research_web_search_event

table in domain `research-starter-protected`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `search_event_id` | `uuid` | no | `gen_random_uuid()` | PK |
| 2 | `run_id` | `uuid` | no | — | FK → [`public.research_pre_research_run`](research_pre_research_run.md).run_id |
| 3 | `subagent` | `text` | no | — | — |
| 4 | `query` | `text` | no | — | — |
| 5 | `provider` | `text` | no | `'exa'::text` | — |
| 6 | `searched_at` | `timestamp with time zone` | no | `timezone('utc'::text, now())` | — |
| 7 | `result_urls` | `jsonb` | no | `'[]'::jsonb` | — |
| 8 | `selected_urls` | `jsonb` | no | `'[]'::jsonb` | — |
| 9 | `search_purpose` | `text` | no | — | — |

## Constraints

- PK (search_event_id)
- check `research_web_search_event_result_urls_check`: `(jsonb_typeof(result_urls) = 'array'::text)`
- check `research_web_search_event_selected_urls_check`: `(jsonb_typeof(selected_urls) = 'array'::text)`

## Relationships

Outbound: `run_id` → [`public.research_pre_research_run`](research_pre_research_run.md)`.run_id` on delete cascade.
Inbound: none.

## Indexes

`research_web_search_event_run_idx`

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

insert: `Database["public"]["Tables"]["research_web_search_event"]["Insert"]`; row: `Database["public"]["Tables"]["research_web_search_event"]["Row"]`; update: `Database["public"]["Tables"]["research_web_search_event"]["Update"]`

Defined in: `20260815015402_research_pre_research_schema.sql`.
