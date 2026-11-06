---
id: "rel:public.research_pre_research_run"
kind: table
schema: public
name: research_pre_research_run
domain: research-starter-protected
aliases: []
tokens: [public, research_pre_research_run, public.research_pre_research_run, run_id, video_id, taxonomy_version_id, status, attempt, lease_token, lease_expires_at, transcript_sha256, prompt_bundle_version, model_id, workflow_session_id, started_at, completed_at, error_code, error_detail, intent_path, intent_sha256, created_at, updated_at, research_as_of, packet_schema_version, packet_storage_prefix, packet_sha256, research_session_id, synthesis_session_id, research_completed_at, synthesis_started_at]
summary: One claimable orchestration row per video+transcript-hash attempt.
summary_basis: comment
rls: enabled
readers: []
writers: []
typescript: "Database[\"public\"][\"Tables\"][\"research_pre_research_run\"][\"Row\"]"
defined_in: ["20260815015402_research_pre_research_schema.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# public.research_pre_research_run

table in domain `research-starter-protected` — One claimable orchestration row per video+transcript-hash attempt..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `run_id` | `uuid` | no | `gen_random_uuid()` | PK |
| 2 | `video_id` | `text` | no | — | FK → [`public.research_starter_videos`](research_starter_videos.md).video_id |
| 3 | `taxonomy_version_id` | `uuid` | no | — | FK → [`public.research_taxonomy_version`](research_taxonomy_version.md).taxonomy_version_id |
| 4 | `status` | `research_pre_research_run_status` | no | `'queued'::research_pre_research_run_status` | — |
| 5 | `attempt` | `integer` | no | `1` | — |
| 6 | `lease_token` | `uuid` | yes | — | — |
| 7 | `lease_expires_at` | `timestamp with time zone` | yes | — | — |
| 8 | `transcript_sha256` | `text` | no | — | — |
| 9 | `prompt_bundle_version` | `text` | no | — | — |
| 10 | `model_id` | `text` | no | — | — |
| 11 | `workflow_session_id` | `text` | yes | — | — |
| 12 | `started_at` | `timestamp with time zone` | yes | — | — |
| 13 | `completed_at` | `timestamp with time zone` | yes | — | — |
| 14 | `error_code` | `text` | yes | — | — |
| 15 | `error_detail` | `text` | yes | — | — |
| 16 | `intent_path` | `text` | yes | — | — |
| 17 | `intent_sha256` | `text` | yes | — | — |
| 18 | `created_at` | `timestamp with time zone` | no | `timezone('utc'::text, now())` | — |
| 19 | `updated_at` | `timestamp with time zone` | no | `timezone('utc'::text, now())` | — |
| 20 | `research_as_of` | `date` | no | `(timezone('utc'::text, now()))::date` | — |
| 21 | `packet_schema_version` | `text` | no | `'1.0.0'::text` | — |
| 22 | `packet_storage_prefix` | `text` | yes | — | — |
| 23 | `packet_sha256` | `text` | yes | — | — |
| 24 | `research_session_id` | `text` | yes | — | — |
| 25 | `synthesis_session_id` | `text` | yes | — | — |
| 26 | `research_completed_at` | `timestamp with time zone` | yes | — | — |
| 27 | `synthesis_started_at` | `timestamp with time zone` | yes | — | — |

## Constraints

- PK (run_id)
- check `research_pre_research_run_attempt_check`: `(attempt >= 1)`
- check `research_pre_research_run_intent_sha256_check`: `((intent_sha256 IS NULL) OR (intent_sha256 ~ '^[0-9a-f]{64}$'::text))`
- check `research_pre_research_run_packet_sha256_check`: `((packet_sha256 IS NULL) OR (packet_sha256 ~ '^[0-9a-f]{64}$'::text))`
- check `research_pre_research_run_transcript_sha256_check`: `(transcript_sha256 ~ '^[0-9a-f]{64}$'::text)`

## Relationships

2 outbound and 7 inbound foreign keys; full list in [details](research_pre_research_run.details.md).

## Indexes

5 indexes; see [details](research_pre_research_run.details.md).

## Triggers

1 triggers; see [details](research_pre_research_run.details.md).

## Row-level security

Enabled; 0 policies in [details](research_pre_research_run.details.md).

## Grants

No role has privileges. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

## Read paths

- No agent role may SELECT directly.

## Write path

- No direct DML for any agent role.
- Via functions (best effort): [`research_private.begin_research_session`](../../functions/research_private/begin_research_session.md), [`research_private.begin_synthesis_session`](../../functions/research_private/begin_synthesis_session.md), [`research_private.claim_pre_research_stage`](../../functions/research_private/claim_pre_research_stage.md), [`research_private.claim_pre_research_video`](../../functions/research_private/claim_pre_research_video.md), [`research_private.complete_pre_research_stage`](../../functions/research_private/complete_pre_research_stage.md), [`research_private.complete_research_phase`](../../functions/research_private/complete_research_phase.md), [`research_private.complete_synthesis_phase`](../../functions/research_private/complete_synthesis_phase.md), [`research_private.touch_pre_research_run`](../../functions/research_private/touch_pre_research_run.md).

## TypeScript

insert: `Database["public"]["Tables"]["research_pre_research_run"]["Insert"]`; row: `Database["public"]["Tables"]["research_pre_research_run"]["Row"]`; update: `Database["public"]["Tables"]["research_pre_research_run"]["Update"]`

Defined in: `20260815015402_research_pre_research_schema.sql`.
