---
id: "rel:public.research_pre_research_video_state"
kind: table
schema: public
name: research_pre_research_video_state
domain: research-starter-protected
aliases: []
tokens: [public, research_pre_research_video_state, public.research_pre_research_video_state, video_id, transcript_sha256, eligibility_status, ineligibility_reasons, duration_seconds, transcript_object_exists, evaluated_at, latest_run_id, pipeline_status, pre_research_pipeline_finished, pre_research_pipeline_finished_at, finished_transcript_sha256, finished_intent_id, created_at, updated_at]
summary: null
summary_basis: none
rls: enabled
readers: [service_role]
writers: [service_role]
typescript: "Database[\"public\"][\"Tables\"][\"research_pre_research_video_state\"][\"Row\"]"
defined_in: ["20260816205231_pre_research_v2_schema.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# public.research_pre_research_video_state

table in domain `research-starter-protected`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `video_id` | `text` | no | — | PK; FK → [`public.research_starter_videos`](research_starter_videos.md).video_id |
| 2 | `transcript_sha256` | `text` | yes | — | — |
| 3 | `eligibility_status` | `text` | no | `'pending'::text` | — |
| 4 | `ineligibility_reasons` | `text[]` | no | `'{}'::text[]` | — |
| 5 | `duration_seconds` | `integer` | yes | — | — |
| 6 | `transcript_object_exists` | `boolean` | no | `false` | — |
| 7 | `evaluated_at` | `timestamp with time zone` | yes | — | — |
| 8 | `latest_run_id` | `uuid` | yes | — | FK → [`public.research_pre_research_run`](research_pre_research_run.md).run_id |
| 9 | `pipeline_status` | `text` | no | `'not_started'::text` | — |
| 10 | `pre_research_pipeline_finished` | `boolean` | no | `false` | — |
| 11 | `pre_research_pipeline_finished_at` | `timestamp with time zone` | yes | — | — |
| 12 | `finished_transcript_sha256` | `text` | yes | — | — |
| 13 | `finished_intent_id` | `uuid` | yes | — | FK → [`public.research_ingestion_intent`](research_ingestion_intent.md).intent_id |
| 14 | `created_at` | `timestamp with time zone` | no | `timezone('utc'::text, now())` | — |
| 15 | `updated_at` | `timestamp with time zone` | no | `timezone('utc'::text, now())` | — |

## Constraints

- PK (video_id)
- check `research_pre_research_video_state_eligibility_check`: `(eligibility_status = ANY (ARRAY['pending'::text, 'eligible'::text, 'ineligible'::text]))`
- check `research_pre_research_video_state_finished_check`: `((pre_research_pipeline_finished = false) OR ((pre_research_pipeline_finished_at IS NOT NULL) AND (finished_transcript_sha256 IS NOT NULL) …`
- check `research_pre_research_video_state_finished_sha256_check`: `((finished_transcript_sha256 IS NULL) OR (finished_transcript_sha256 ~ '^[0-9a-f]{64}$'::text))`
- check `research_pre_research_video_state_pipeline_check`: `(pipeline_status = ANY (ARRAY['not_started'::text, 'eligible'::text, 'claimed'::text, 'researching'::text, 'research_complete'::text, 'synt…`
- check `research_pre_research_video_state_sha256_check`: `((transcript_sha256 IS NULL) OR (transcript_sha256 ~ '^[0-9a-f]{64}$'::text))`

## Relationships

Outbound: `finished_intent_id` → [`public.research_ingestion_intent`](research_ingestion_intent.md)`.intent_id`; `latest_run_id` → [`public.research_pre_research_run`](research_pre_research_run.md)`.run_id`; `video_id` → [`public.research_starter_videos`](research_starter_videos.md)`.video_id`.
Inbound: none.

## Indexes

`research_pre_research_video_state_eligible_idx`

## Triggers

- `set_research_pre_research_video_state_updated_at` → [`public.set_updated_at`](../../functions/public/set_updated_at.md)

## Row-level security

Enabled.

## Grants

`service_role`: DELETE, INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Read paths

- No agent role may SELECT directly.

## Write path

- No direct DML for any agent role.
- Via functions (best effort): [`research_private.project_pre_research_video_state`](../../functions/research_private/project_pre_research_video_state.md).

## TypeScript

insert: `Database["public"]["Tables"]["research_pre_research_video_state"]["Insert"]`; row: `Database["public"]["Tables"]["research_pre_research_video_state"]["Row"]`; update: `Database["public"]["Tables"]["research_pre_research_video_state"]["Update"]`

Defined in: `20260816205231_pre_research_v2_schema.sql`.
