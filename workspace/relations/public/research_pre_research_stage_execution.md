---
id: "rel:public.research_pre_research_stage_execution"
kind: table
schema: public
name: research_pre_research_stage_execution
domain: research-starter-protected
aliases: []
tokens: [public, research_pre_research_stage_execution, public.research_pre_research_stage_execution, stage_execution_id, run_id, stage, status, attempt_count, lease_owner, lease_token_hash, lease_expires_at, retry_after, input_manifest_bucket, input_manifest_path, input_sha256, output_artifact_kinds, completed_artifact_sha256s, model_id, prompt_bundle_version, last_error_code, last_error_detail, usage_summary, started_at, updated_at, completed_at]
summary: null
summary_basis: none
rls: enabled
readers: [service_role]
writers: [service_role]
typescript: "Database[\"public\"][\"Tables\"][\"research_pre_research_stage_execution\"][\"Row\"]"
defined_in: ["20260824011000_stateless_pre_research_stage_execution.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# public.research_pre_research_stage_execution

table in domain `research-starter-protected`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `stage_execution_id` | `uuid` | no | `gen_random_uuid()` | PK |
| 2 | `run_id` | `uuid` | no | — | unique (run_id, stage); FK → [`public.research_pre_research_run`](research_pre_research_run.md).run_id |
| 3 | `stage` | `text` | no | — | unique (run_id, stage) |
| 4 | `status` | `text` | no | `'pending'::text` | — |
| 5 | `attempt_count` | `integer` | no | `0` | — |
| 6 | `lease_owner` | `text` | yes | — | — |
| 7 | `lease_token_hash` | `text` | yes | — | — |
| 8 | `lease_expires_at` | `timestamp with time zone` | yes | — | — |
| 9 | `retry_after` | `timestamp with time zone` | yes | — | — |
| 10 | `input_manifest_bucket` | `text` | yes | — | — |
| 11 | `input_manifest_path` | `text` | yes | — | — |
| 12 | `input_sha256` | `text` | yes | — | — |
| 13 | `output_artifact_kinds` | `text[]` | no | `'{}'::text[]` | — |
| 14 | `completed_artifact_sha256s` | `jsonb` | no | `'{}'::jsonb` | — |
| 15 | `model_id` | `text` | no | `'zai/glm-5.2'::text` | — |
| 16 | `prompt_bundle_version` | `text` | no | `'pre-research-v3-stateless-1'::text` | — |
| 17 | `last_error_code` | `text` | yes | — | — |
| 18 | `last_error_detail` | `text` | yes | — | — |
| 19 | `usage_summary` | `jsonb` | no | `'{}'::jsonb` | — |
| 20 | `started_at` | `timestamp with time zone` | yes | — | — |
| 21 | `updated_at` | `timestamp with time zone` | no | `timezone('utc'::text, now())` | — |
| 22 | `completed_at` | `timestamp with time zone` | yes | — | — |

## Constraints

- PK (stage_execution_id)
- unique (run_id, stage)
- check `research_pre_research_stage_execution_attempt_check`: `(attempt_count >= 0)`
- check `research_pre_research_stage_execution_error_detail_check`: `((last_error_detail IS NULL) OR (length(last_error_detail) <= 2000))`
- check `research_pre_research_stage_execution_input_hash_check`: `((input_sha256 IS NULL) OR (input_sha256 ~ '^[0-9a-f]{64}$'::text))`
- check `research_pre_research_stage_execution_lease_hash_check`: `((lease_token_hash IS NULL) OR (lease_token_hash ~ '^[0-9a-f]{64}$'::text))`
- check `research_pre_research_stage_execution_stage_check`: `(stage = ANY (ARRAY['transcript_taxonomy'::text, 'web_context'::text, 'organization_research'::text, 'source_verification'::text, 'curricul…`
- check `research_pre_research_stage_execution_status_check`: `(status = ANY (ARRAY['pending'::text, 'leased'::text, 'retry_wait'::text, 'completed'::text, 'dead_letter'::text]))`

## Relationships

Outbound: `run_id` → [`public.research_pre_research_run`](research_pre_research_run.md)`.run_id` on delete cascade.
Inbound: none.

## Indexes

`research_pre_research_stage_execution_ready_idx`; `research_pre_research_stage_execution_run_idx`; `research_pre_research_stage_execution_run_stage_key` unique

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
- Via functions (best effort): [`research_private.checkpoint_pre_research_stage_input`](../../functions/research_private/checkpoint_pre_research_stage_input.md), [`research_private.claim_pre_research_stage`](../../functions/research_private/claim_pre_research_stage.md), [`research_private.complete_pre_research_stage`](../../functions/research_private/complete_pre_research_stage.md), [`research_private.ensure_pre_research_stage_rows`](../../functions/research_private/ensure_pre_research_stage_rows.md), [`research_private.park_pre_research_stage`](../../functions/research_private/park_pre_research_stage.md), [`research_private.reconcile_pre_research_stage_rows`](../../functions/research_private/reconcile_pre_research_stage_rows.md).

## TypeScript

insert: `Database["public"]["Tables"]["research_pre_research_stage_execution"]["Insert"]`; row: `Database["public"]["Tables"]["research_pre_research_stage_execution"]["Row"]`; update: `Database["public"]["Tables"]["research_pre_research_stage_execution"]["Update"]`

Defined in: `20260824011000_stateless_pre_research_stage_execution.sql`.
