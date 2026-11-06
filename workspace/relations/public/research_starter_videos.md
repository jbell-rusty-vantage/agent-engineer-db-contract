---
id: "rel:public.research_starter_videos"
kind: table
schema: public
name: research_starter_videos
domain: research-starter-protected
aliases: []
tokens: [public, research_starter_videos, public.research_starter_videos, video_id, title, description, published_at, channel_id, channel_handle, channel_title, duration, duration_seconds, view_count, like_count, comment_count, thumbnail_url, url, source, catalog_fetched_at, transcript_status, transcript_bucket, transcript_path, transcript_language, transcript_char_count, transcript_error, transcript_fetched_at, transcript_text, metadata, created_at, updated_at, pre_research_complete]
summary: "YouTube videos for the research starter catalog. Each video belongs to one research_starter_channels row. Transcript bytes live in the channel's Storage bucket."
summary_basis: comment
rls: enabled
readers: []
writers: []
typescript: "Database[\"public\"][\"Tables\"][\"research_starter_videos\"][\"Row\"]"
defined_in: ["20260814025347_research_starter_videos.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# public.research_starter_videos

table in domain `research-starter-protected` — YouTube videos for the research starter catalog. Each video belongs to one research_starter_channels row. Transcript bytes live in the channel's Storage bucket..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `video_id` | `text` | no | — | PK |
| 2 | `title` | `text` | no | — | — |
| 3 | `description` | `text` | yes | — | — |
| 4 | `published_at` | `timestamp with time zone` | yes | — | — |
| 5 | `channel_id` | `text` | yes | — | FK → [`public.research_starter_channels`](research_starter_channels.md).channel_id; YouTube channel id. FK to research_starter_channels.channel_id (Channel 1—* Video). |
| 6 | `channel_handle` | `text` | yes | — | — |
| 7 | `channel_title` | `text` | yes | — | — |
| 8 | `duration` | `text` | yes | — | — |
| 9 | `duration_seconds` | `integer` | yes | — | — |
| 10 | `view_count` | `bigint` | yes | — | — |
| 11 | `like_count` | `bigint` | yes | — | — |
| 12 | `comment_count` | `bigint` | yes | — | — |
| 13 | `thumbnail_url` | `text` | yes | — | — |
| 14 | `url` | `text` | yes | — | — |
| 15 | `source` | `text` | yes | — | — |
| 16 | `catalog_fetched_at` | `timestamp with time zone` | yes | — | — |
| 17 | `transcript_status` | `text` | no | `'none'::text` | — |
| 18 | `transcript_bucket` | `text` | yes | — | — |
| 19 | `transcript_path` | `text` | yes | — | Object key in the ai-engineer-transcripts bucket, e.g. ai-dot-engineer/<video_id>.txt. |
| 20 | `transcript_language` | `text` | yes | — | — |
| 21 | `transcript_char_count` | `integer` | yes | — | — |
| 22 | `transcript_error` | `text` | yes | — | — |
| 23 | `transcript_fetched_at` | `timestamp with time zone` | yes | — | — |
| 24 | `transcript_text` | `text` | yes | — | Full caption text when fetched. Canonical file also lives in transcript_bucket/transcript_path. |
| 25 | `metadata` | `jsonb` | no | `'{}'::jsonb` | — |
| 26 | `created_at` | `timestamp with time zone` | no | `timezone('utc'::text, now())` | — |
| 27 | `updated_at` | `timestamp with time zone` | no | `timezone('utc'::text, now())` | — |
| 28 | `pre_research_complete` | `boolean` | no | `false` | True only after the Eve pre-research pipeline has been transactionally applied and finalized for this video. |

## Constraints

- PK (video_id)
- check `research_starter_videos_transcript_status_check`: `(transcript_status = ANY (ARRAY['none'::text, 'pending'::text, 'stored'::text, 'missing'::text, 'error'::text]))`

## Relationships

Outbound: `channel_id` → [`public.research_starter_channels`](research_starter_channels.md)`.channel_id` on delete restrict.
Inbound: [`public.research_ingestion_intent`](research_ingestion_intent.md).video_id, [`public.research_organization_candidate`](research_organization_candidate.md).video_id, [`public.research_pre_research_run`](research_pre_research_run.md).video_id, [`public.research_pre_research_video_state`](research_pre_research_video_state.md).video_id, [`public.research_video_analysis`](research_video_analysis.md).video_id, [`public.research_video_initial_summary`](research_video_initial_summary.md).video_id, [`public.research_video_technology_summary`](research_video_technology_summary.md).video_id.

## Indexes

`research_starter_videos_channel_id_idx`; `research_starter_videos_pre_research_eligible_idx` where `((transcript_status = 'stored'::text) AND (duration_seconds…`; `research_starter_videos_published_at_idx`; `research_starter_videos_transcript_status_idx`

## Triggers

- `set_research_starter_videos_updated_at` → [`public.set_updated_at`](../../functions/public/set_updated_at.md)

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

insert: `Database["public"]["Tables"]["research_starter_videos"]["Insert"]`; row: `Database["public"]["Tables"]["research_starter_videos"]["Row"]`; update: `Database["public"]["Tables"]["research_starter_videos"]["Update"]`

Defined in: `20260814025347_research_starter_videos.sql`.
