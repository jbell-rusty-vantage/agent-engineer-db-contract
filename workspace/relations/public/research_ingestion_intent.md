---
id: "rel:public.research_ingestion_intent"
kind: table
schema: public
name: research_ingestion_intent
domain: research-starter-protected
aliases: []
tokens: [public, research_ingestion_intent, public.research_ingestion_intent, intent_id, run_id, video_id, schema_version, idempotency_key, storage_bucket, storage_path, content_sha256, status, validated_at, applied_at, rejected_at, error_detail, created_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"public\"][\"Tables\"][\"research_ingestion_intent\"][\"Row\"]"
defined_in: ["20260815015402_research_pre_research_schema.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# public.research_ingestion_intent

table in domain `research-starter-protected`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `intent_id` | `uuid` | no | `gen_random_uuid()` | PK |
| 2 | `run_id` | `uuid` | no | — | unique (run_id); FK → [`public.research_pre_research_run`](research_pre_research_run.md).run_id |
| 3 | `video_id` | `text` | no | — | FK → [`public.research_starter_videos`](research_starter_videos.md).video_id |
| 4 | `schema_version` | `text` | no | — | — |
| 5 | `idempotency_key` | `text` | no | — | unique (idempotency_key) |
| 6 | `storage_bucket` | `text` | no | — | — |
| 7 | `storage_path` | `text` | no | — | — |
| 8 | `content_sha256` | `text` | no | — | — |
| 9 | `status` | `research_intent_status` | no | `'draft'::research_intent_status` | — |
| 10 | `validated_at` | `timestamp with time zone` | yes | — | — |
| 11 | `applied_at` | `timestamp with time zone` | yes | — | — |
| 12 | `rejected_at` | `timestamp with time zone` | yes | — | — |
| 13 | `error_detail` | `text` | yes | — | — |
| 14 | `created_at` | `timestamp with time zone` | no | `timezone('utc'::text, now())` | — |

## Constraints

- PK (intent_id)
- unique (idempotency_key)
- unique (run_id)
- check `research_ingestion_intent_content_sha256_check`: `(content_sha256 ~ '^[0-9a-f]{64}$'::text)`

## Relationships

Outbound: `run_id` → [`public.research_pre_research_run`](research_pre_research_run.md)`.run_id`; `video_id` → [`public.research_starter_videos`](research_starter_videos.md)`.video_id`.
Inbound: [`public.research_ingestion_intent_event`](research_ingestion_intent_event.md).intent_id, [`public.research_pre_research_artifact`](research_pre_research_artifact.md).intent_id, [`public.research_pre_research_video_state`](research_pre_research_video_state.md).finished_intent_id.

## Indexes

`research_ingestion_intent_idempotency_key_key` unique; `research_ingestion_intent_run_id_key` unique; `research_ingestion_intent_video_id_idx`

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

insert: `Database["public"]["Tables"]["research_ingestion_intent"]["Insert"]`; row: `Database["public"]["Tables"]["research_ingestion_intent"]["Row"]`; update: `Database["public"]["Tables"]["research_ingestion_intent"]["Update"]`

Defined in: `20260815015402_research_pre_research_schema.sql`.
