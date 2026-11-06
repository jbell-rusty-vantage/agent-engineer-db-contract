---
id: "fn:research_private.list_finished_pre_research_videos()"
kind: function
schema: research_private
name: list_finished_pre_research_videos
domain: research-starter-protected
overloads: ["fn:research_private.list_finished_pre_research_videos()"]
security: definer
volatility: stable
executors: [service_role]
raises: []
touches: { reads: [public.research_organization_candidate, public.research_organization_source, public.research_pre_research_run, public.research_pre_research_video_state, public.research_starter_videos, public.research_video_analysis, public.research_video_initial_summary, public.research_video_technology_summary], writes: [] }
tokens: [research_private, list_finished_pre_research_videos, research_private.list_finished_pre_research_videos]
defined_in: ["20260816205231_pre_research_v2_schema.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# research_private.list_finished_pre_research_videos

Domain `research-starter-protected`.

## list_finished_pre_research_videos() → TABLE(video_id text, title text, published_at timestamp with time zone, duration_seconds integer, transcript_bucket text, transcript_path text, transcript_sha256 text, run_id uuid, intent_id uuid, packet_storage_prefix text, research_as_of date, analysis_id uuid, initial_summary jsonb, technology_summaries jsonb, organization_candidates jsonb)

function, stable, security definer, language sql, config `search_path=research_private, public`.

No arguments.

Execute: `service_role`.

Touches (best effort): reads [`public.research_organization_candidate`](../../relations/public/research_organization_candidate.md), [`public.research_organization_source`](../../relations/public/research_organization_source.md), [`public.research_pre_research_run`](../../relations/public/research_pre_research_run.md), [`public.research_pre_research_video_state`](../../relations/public/research_pre_research_video_state.md), [`public.research_starter_videos`](../../relations/public/research_starter_videos.md), [`public.research_video_analysis`](../../relations/public/research_video_analysis.md), [`public.research_video_initial_summary`](../../relations/public/research_video_initial_summary.md), [`public.research_video_technology_summary`](../../relations/public/research_video_technology_summary.md); writes —; calls —.

TypeScript: `Database["research_private"]["Functions"]["list_finished_pre_research_videos"]`.

Defined in: `20260816205231_pre_research_v2_schema.sql`.
