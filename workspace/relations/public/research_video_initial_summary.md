---
id: "rel:public.research_video_initial_summary"
kind: table
schema: public
name: research_video_initial_summary
domain: research-starter-protected
aliases: []
tokens: [public, research_video_initial_summary, public.research_video_initial_summary, analysis_id, video_id, transcript_summary, software_engineering_concepts, ai_concepts, external_context_notes, temporal_context, research_as_of, evidence_ids, generated_at]
summary: null
summary_basis: none
rls: enabled
readers: [service_role]
writers: [service_role]
typescript: "Database[\"public\"][\"Tables\"][\"research_video_initial_summary\"][\"Row\"]"
defined_in: ["20260816205231_pre_research_v2_schema.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# public.research_video_initial_summary

table in domain `research-starter-protected`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `analysis_id` | `uuid` | no | — | PK; FK → [`public.research_video_analysis`](research_video_analysis.md).analysis_id |
| 2 | `video_id` | `text` | no | — | FK → [`public.research_starter_videos`](research_starter_videos.md).video_id |
| 3 | `transcript_summary` | `text` | no | — | — |
| 4 | `software_engineering_concepts` | `jsonb` | no | `'[]'::jsonb` | — |
| 5 | `ai_concepts` | `jsonb` | no | `'[]'::jsonb` | — |
| 6 | `external_context_notes` | `jsonb` | no | `'[]'::jsonb` | — |
| 7 | `temporal_context` | `text` | no | — | — |
| 8 | `research_as_of` | `date` | no | — | — |
| 9 | `evidence_ids` | `uuid[]` | no | `'{}'::uuid[]` | — |
| 10 | `generated_at` | `timestamp with time zone` | no | `timezone('utc'::text, now())` | — |

## Constraints

- PK (analysis_id)
- check `research_video_initial_summary_ai_concepts_check`: `(jsonb_typeof(ai_concepts) = 'array'::text)`
- check `research_video_initial_summary_notes_check`: `(jsonb_typeof(external_context_notes) = 'array'::text)`
- check `research_video_initial_summary_se_concepts_check`: `(jsonb_typeof(software_engineering_concepts) = 'array'::text)`

## Relationships

Outbound: `analysis_id` → [`public.research_video_analysis`](research_video_analysis.md)`.analysis_id` on delete cascade; `video_id` → [`public.research_starter_videos`](research_starter_videos.md)`.video_id`.
Inbound: none.

## Indexes

`research_video_initial_summary_video_idx`

## Triggers

_None._

## Row-level security

Enabled.

## Grants

`service_role`: DELETE, INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Read paths

- No agent role may SELECT directly.

## Write path

- No direct DML for any agent role.
- No write path for agents; rows are seeded by migrations or platform tooling.

## TypeScript

insert: `Database["public"]["Tables"]["research_video_initial_summary"]["Insert"]`; row: `Database["public"]["Tables"]["research_video_initial_summary"]["Row"]`; update: `Database["public"]["Tables"]["research_video_initial_summary"]["Update"]`

Defined in: `20260816205231_pre_research_v2_schema.sql`.
