---
id: "rel:public.research_pre_research_artifact"
kind: table
schema: public
name: research_pre_research_artifact
domain: research-starter-protected
aliases: []
tokens: [public, research_pre_research_artifact, public.research_pre_research_artifact, artifact_id, run_id, intent_id, artifact_kind, schema_version, storage_bucket, storage_path, content_sha256, byte_count, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [service_role]
writers: [service_role]
typescript: "Database[\"public\"][\"Tables\"][\"research_pre_research_artifact\"][\"Row\"]"
defined_in: ["20260816205231_pre_research_v2_schema.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# public.research_pre_research_artifact

table in domain `research-starter-protected`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `artifact_id` | `uuid` | no | `gen_random_uuid()` | PK |
| 2 | `run_id` | `uuid` | no | — | unique (run_id, artifact_kind); FK → [`public.research_pre_research_run`](research_pre_research_run.md).run_id |
| 3 | `intent_id` | `uuid` | yes | — | FK → [`public.research_ingestion_intent`](research_ingestion_intent.md).intent_id |
| 4 | `artifact_kind` | `text` | no | — | unique (run_id, artifact_kind) |
| 5 | `schema_version` | `text` | no | — | — |
| 6 | `storage_bucket` | `text` | no | — | unique (storage_bucket, storage_path) |
| 7 | `storage_path` | `text` | no | — | unique (storage_bucket, storage_path) |
| 8 | `content_sha256` | `text` | no | — | — |
| 9 | `byte_count` | `bigint` | no | — | — |
| 10 | `created_at` | `timestamp with time zone` | no | `timezone('utc'::text, now())` | — |

## Constraints

- PK (artifact_id)
- unique (run_id, artifact_kind)
- unique (storage_bucket, storage_path)
- check `research_pre_research_artifact_byte_count_check`: `(byte_count >= 0)`
- check `research_pre_research_artifact_kind_check`: `(artifact_kind = ANY (ARRAY['run_manifest'::text, 'transcript_analysis'::text, 'taxonomy_classification'::text, 'web_context'::text, 'organ…`
- check `research_pre_research_artifact_sha256_check`: `(content_sha256 ~ '^[0-9a-f]{64}$'::text)`

## Relationships

Outbound: `intent_id` → [`public.research_ingestion_intent`](research_ingestion_intent.md)`.intent_id` on delete cascade; `run_id` → [`public.research_pre_research_run`](research_pre_research_run.md)`.run_id` on delete cascade.
Inbound: none.

## Indexes

`research_pre_research_artifact_run_id_artifact_kind_key` unique; `research_pre_research_artifact_run_idx`; `research_pre_research_artifact_storage_bucket_storage_path_key` unique

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

insert: `Database["public"]["Tables"]["research_pre_research_artifact"]["Insert"]`; row: `Database["public"]["Tables"]["research_pre_research_artifact"]["Row"]`; update: `Database["public"]["Tables"]["research_pre_research_artifact"]["Update"]`

Defined in: `20260816205231_pre_research_v2_schema.sql`.
