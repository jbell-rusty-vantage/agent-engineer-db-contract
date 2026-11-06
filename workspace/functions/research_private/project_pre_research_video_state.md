---
id: "fn:research_private.project_pre_research_video_state(text,uuid,text)"
kind: function
schema: research_private
name: project_pre_research_video_state
domain: research-starter-protected
overloads: ["fn:research_private.project_pre_research_video_state(text,uuid,text)"]
security: definer
volatility: volatile
executors: [service_role]
raises: ["VIDEO_NOT_FOUND: %"]
touches: { reads: [public.research_starter_videos], writes: [public.research_pre_research_video_state] }
tokens: [research_private, project_pre_research_video_state, research_private.project_pre_research_video_state]
defined_in: ["20260816205231_pre_research_v2_schema.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# research_private.project_pre_research_video_state

Domain `research-starter-protected`.

## project_pre_research_video_state(text, uuid, text) → research_pre_research_video_state

function, volatile, security definer, language plpgsql, config `search_path=research_private, public, extensions`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_video_id` | `text` | — | — |
| `p_latest_run_id` | `uuid` | `NULL::uuid` | — |
| `p_pipeline_status` | `text` | `NULL::text` | — |

Execute: `service_role`.

Raises (mechanically extracted): `VIDEO_NOT_FOUND: %`.

Touches (best effort): reads [`public.research_starter_videos`](../../relations/public/research_starter_videos.md); writes [`public.research_pre_research_video_state`](../../relations/public/research_pre_research_video_state.md); calls [`research_private.evaluate_pre_research_qualification`](evaluate_pre_research_qualification.md).

TypeScript: `Database["research_private"]["Functions"]["project_pre_research_video_state"]`.

Defined in: `20260816205231_pre_research_v2_schema.sql`.
