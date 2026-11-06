---
id: "rel:public.research_pre_research_run#details"
kind: details
schema: public
name: research_pre_research_run
of: "rel:public.research_pre_research_run"
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# public.research_pre_research_run — details

Spill-over from [the main page](research_pre_research_run.md).

## Relationships

Outbound: `taxonomy_version_id` → [`public.research_taxonomy_version`](research_taxonomy_version.md)`.taxonomy_version_id`; `video_id` → [`public.research_starter_videos`](research_starter_videos.md)`.video_id`.
Inbound: [`public.research_ingestion_intent`](research_ingestion_intent.md).run_id, [`public.research_pre_research_artifact`](research_pre_research_artifact.md).run_id, [`public.research_pre_research_session`](research_pre_research_session.md).run_id, [`public.research_pre_research_stage_execution`](research_pre_research_stage_execution.md).run_id, [`public.research_pre_research_video_state`](research_pre_research_video_state.md).latest_run_id, [`public.research_video_analysis`](research_video_analysis.md).run_id, [`public.research_web_search_event`](research_web_search_event.md).run_id.

## Indexes

| Index | Definition |
| --- | --- |
| `research_pre_research_run_applied_video_hash_uidx` | `CREATE UNIQUE INDEX research_pre_research_run_applied_video_hash_uidx ON public.research_pre_research_run USING btree (video_id, transcript_sha256) WHERE (status = 'applied'::research_pre_research_run_status)` |
| `research_pre_research_run_lease_idx` | `CREATE INDEX research_pre_research_run_lease_idx ON public.research_pre_research_run USING btree (status, lease_expires_at) WHERE (status = ANY (ARRAY['claimed'::research_pre_research_run_status, 'analyzing'::research_pre_research_run_status]))` |
| `research_pre_research_run_live_video_hash_uidx` | `CREATE UNIQUE INDEX research_pre_research_run_live_video_hash_uidx ON public.research_pre_research_run USING btree (video_id, transcript_sha256) WHERE (status = ANY (ARRAY['queued'::research_pre_research_run_status, 'claimed'::research_pre_research_run_status, 'analyzing'::research_pre_research_run_status, 'research_complete'::research_pre_research_run_status, 'synthesizing'::research_pre_research_run_status, 'intent_ready'::research_pre_research_run_status, 'applying'::research_pre_research_run_status]))` |
| `research_pre_research_run_status_idx` | `CREATE INDEX research_pre_research_run_status_idx ON public.research_pre_research_run USING btree (status, created_at DESC)` |
| `research_pre_research_run_video_id_idx` | `CREATE INDEX research_pre_research_run_video_id_idx ON public.research_pre_research_run USING btree (video_id, created_at DESC)` |

## Triggers

- `set_research_pre_research_run_updated_at` → [`public.set_updated_at`](../../functions/public/set_updated_at.md): `CREATE TRIGGER set_research_pre_research_run_updated_at BEFORE UPDATE ON research_pre_research_run FOR EACH ROW EXECUTE FUNCTION set_updated_at()`

## Row-level security

Enabled.
