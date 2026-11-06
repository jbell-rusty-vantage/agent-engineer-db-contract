---
id: "rel:public.research_starter_channels"
kind: table
schema: public
name: research_starter_channels
domain: research-starter-protected
aliases: []
tokens: [public, research_starter_channels, public.research_starter_channels, channel_id, handle, title, description, custom_url, channel_url, thumbnail_url, subscriber_count, video_count, uploads_playlist_id, transcript_bucket, transcript_path_prefix, is_primary_research_source, source, catalog_fetched_at, metadata, created_at, updated_at]
summary: YouTube channels whose videos are ingested into research_starter_videos. One channel has many videos. AI Engineer is the primary pre-research source.
summary_basis: comment
rls: enabled
readers: [service_role]
writers: [service_role]
typescript: "Database[\"public\"][\"Tables\"][\"research_starter_channels\"][\"Row\"]"
defined_in: ["20260902010518_research_starter_channels.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# public.research_starter_channels

table in domain `research-starter-protected` — YouTube channels whose videos are ingested into research_starter_videos. One channel has many videos. AI Engineer is the primary pre-research source..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `channel_id` | `text` | no | — | PK; YouTube channel id (UC…). Primary key; research_starter_videos.channel_id references this. |
| 2 | `handle` | `text` | no | — | YouTube handle including leading @, e.g. @aiDotEngineer. |
| 3 | `title` | `text` | no | — | — |
| 4 | `description` | `text` | yes | — | — |
| 5 | `custom_url` | `text` | yes | — | — |
| 6 | `channel_url` | `text` | yes | — | — |
| 7 | `thumbnail_url` | `text` | yes | — | — |
| 8 | `subscriber_count` | `bigint` | yes | — | — |
| 9 | `video_count` | `bigint` | yes | — | — |
| 10 | `uploads_playlist_id` | `text` | yes | — | — |
| 11 | `transcript_bucket` | `text` | no | — | Private Storage bucket for this channel's caption files. |
| 12 | `transcript_path_prefix` | `text` | no | — | Object-key prefix inside the bucket, e.g. ai-dot-engineer or matthew-berman. Path is {prefix}/{video_id}.txt. |
| 13 | `is_primary_research_source` | `boolean` | no | `false` | True only for the AI Engineer Worlds Fair catalog. Pre-research claim still keys off transcript_bucket = ai-engineer-transcripts. |
| 14 | `source` | `text` | yes | — | — |
| 15 | `catalog_fetched_at` | `timestamp with time zone` | yes | — | — |
| 16 | `metadata` | `jsonb` | no | `'{}'::jsonb` | — |
| 17 | `created_at` | `timestamp with time zone` | no | `timezone('utc'::text, now())` | — |
| 18 | `updated_at` | `timestamp with time zone` | no | `timezone('utc'::text, now())` | — |

## Constraints

- PK (channel_id)
- check `research_starter_channels_bucket_nonempty`: `(btrim(transcript_bucket) <> ''::text)`
- check `research_starter_channels_handle_format`: `(handle ~ '^@[^[:space:]]+$'::text)`
- check `research_starter_channels_id_nonempty`: `(btrim(channel_id) <> ''::text)`
- check `research_starter_channels_prefix_nonempty`: `((btrim(transcript_path_prefix) <> ''::text) AND (transcript_path_prefix !~ '^/\|/$'::text))`
- check `research_starter_channels_title_nonempty`: `(btrim(title) <> ''::text)`

## Relationships

Outbound: none.
Inbound: [`public.research_starter_videos`](research_starter_videos.md).channel_id.

## Indexes

`research_starter_channels_handle_lower_idx` unique; `research_starter_channels_one_primary_idx` unique where `is_primary_research_source`

## Triggers

- `set_research_starter_channels_updated_at` → [`public.set_updated_at`](../../functions/public/set_updated_at.md)

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

insert: `Database["public"]["Tables"]["research_starter_channels"]["Insert"]`; row: `Database["public"]["Tables"]["research_starter_channels"]["Row"]`; update: `Database["public"]["Tables"]["research_starter_channels"]["Update"]`

Defined in: `20260902010518_research_starter_channels.sql`.
