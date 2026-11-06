---
id: "rel:public.research_video_technology_summary"
kind: table
schema: public
name: research_video_technology_summary
domain: research-starter-protected
aliases: []
tokens: [public, research_video_technology_summary, public.research_video_technology_summary, technology_summary_id, analysis_id, video_id, family_rank, family_label, primary_technology, primary_technology_kind, related_technologies, implementations, summary, relationship_rationale, role_in_video, current_status, temporal_status, video_published_at, research_as_of, official_urls, evidence_ids, confidence, generated_at]
summary: null
summary_basis: none
rls: enabled
readers: [service_role]
writers: [service_role]
typescript: "Database[\"public\"][\"Tables\"][\"research_video_technology_summary\"][\"Row\"]"
defined_in: ["20260816205231_pre_research_v2_schema.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# public.research_video_technology_summary

table in domain `research-starter-protected`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `technology_summary_id` | `uuid` | no | `gen_random_uuid()` | PK |
| 2 | `analysis_id` | `uuid` | no | — | unique (analysis_id, family_rank); FK → [`public.research_video_analysis`](research_video_analysis.md).analysis_id |
| 3 | `video_id` | `text` | no | — | FK → [`public.research_starter_videos`](research_starter_videos.md).video_id |
| 4 | `family_rank` | `integer` | no | — | unique (analysis_id, family_rank) |
| 5 | `family_label` | `text` | no | — | — |
| 6 | `primary_technology` | `text` | no | — | — |
| 7 | `primary_technology_kind` | `text` | no | — | — |
| 8 | `related_technologies` | `jsonb` | no | `'[]'::jsonb` | — |
| 9 | `implementations` | `jsonb` | no | `'[]'::jsonb` | — |
| 10 | `summary` | `text` | no | — | — |
| 11 | `relationship_rationale` | `text` | no | — | — |
| 12 | `role_in_video` | `text` | no | — | — |
| 13 | `current_status` | `text` | no | — | — |
| 14 | `temporal_status` | `text` | no | — | — |
| 15 | `video_published_at` | `timestamp with time zone` | yes | — | — |
| 16 | `research_as_of` | `date` | no | — | — |
| 17 | `official_urls` | `jsonb` | no | `'[]'::jsonb` | — |
| 18 | `evidence_ids` | `uuid[]` | no | `'{}'::uuid[]` | — |
| 19 | `confidence` | `numeric(4,3)` | no | — | — |
| 20 | `generated_at` | `timestamp with time zone` | no | `timezone('utc'::text, now())` | — |

## Constraints

- PK (technology_summary_id)
- unique (analysis_id, family_rank)
- check `research_video_technology_summary_confidence_check`: `((confidence >= (0)::numeric) AND (confidence <= (1)::numeric))`
- check `research_video_technology_summary_impl_check`: `(jsonb_typeof(implementations) = 'array'::text)`
- check `research_video_technology_summary_kind_check`: `(primary_technology_kind = ANY (ARRAY['architecture'::text, 'technique'::text, 'protocol'::text, 'model_family'::text, 'platform_capability…`
- check `research_video_technology_summary_rank_check`: `(family_rank >= 1)`
- check `research_video_technology_summary_related_check`: `(jsonb_typeof(related_technologies) = 'array'::text)`
- check `research_video_technology_summary_temporal_check`: `(temporal_status = ANY (ARRAY['current'::text, 'changed_since_publication'::text, 'historical'::text, 'uncertain'::text]))`
- check `research_video_technology_summary_urls_check`: `(jsonb_typeof(official_urls) = 'array'::text)`

## Relationships

Outbound: `analysis_id` → [`public.research_video_analysis`](research_video_analysis.md)`.analysis_id` on delete cascade; `video_id` → [`public.research_starter_videos`](research_starter_videos.md)`.video_id`.
Inbound: none.

## Indexes

`research_video_technology_summary_analysis_id_family_rank_key` unique; `research_video_technology_summary_analysis_idx`

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

insert: `Database["public"]["Tables"]["research_video_technology_summary"]["Insert"]`; row: `Database["public"]["Tables"]["research_video_technology_summary"]["Row"]`; update: `Database["public"]["Tables"]["research_video_technology_summary"]["Update"]`

Defined in: `20260816205231_pre_research_v2_schema.sql`.
