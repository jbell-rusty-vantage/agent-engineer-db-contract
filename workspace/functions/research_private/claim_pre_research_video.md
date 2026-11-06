---
id: "fn:research_private.claim_pre_research_video(int4,text,text,text,text,text)"
kind: function
schema: research_private
name: claim_pre_research_video
domain: research-starter-protected
overloads: ["fn:research_private.claim_pre_research_video(int4,text,text,text,text,text)"]
security: definer
volatility: volatile
executors: [service_role]
raises: ["ACTIVE_TAXONOMY_NOT_FOUND: %", "INVALID_LEASE_SECONDS: %"]
touches: { reads: [public.research_pre_research_video_state, public.research_starter_videos, public.research_taxonomy_version], writes: [public.research_pre_research_run] }
tokens: [research_private, claim_pre_research_video, research_private.claim_pre_research_video]
defined_in: ["20260815015402_research_pre_research_schema.sql", "20260815020333_claim_pre_research_video_by_id.sql", "20260816205231_pre_research_v2_schema.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# research_private.claim_pre_research_video

Domain `research-starter-protected`.

## claim_pre_research_video(integer, text, text, text, text, text) → jsonb

function, volatile, security definer, language plpgsql, config `search_path=research_private, public, extensions`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_lease_seconds` | `integer` | `1800` | — |
| `p_taxonomy_version` | `text` | `'1.0.0'::text` | — |
| `p_prompt_bundle_version` | `text` | `'pre-research-2.0.0'::text` | — |
| `p_model_id` | `text` | `'zai/glm-5.2'::text` | — |
| `p_packet_schema_version` | `text` | `'2.0.0'::text` | — |
| `p_video_id` | `text` | `NULL::text` | — |

Execute: `service_role`.

Raises (mechanically extracted): `ACTIVE_TAXONOMY_NOT_FOUND: %`; `INVALID_LEASE_SECONDS: %`.

Touches (best effort): reads [`public.research_pre_research_video_state`](../../relations/public/research_pre_research_video_state.md), [`public.research_starter_videos`](../../relations/public/research_starter_videos.md), [`public.research_taxonomy_version`](../../relations/public/research_taxonomy_version.md); writes [`public.research_pre_research_run`](../../relations/public/research_pre_research_run.md); calls [`research_private.evaluate_pre_research_qualification`](evaluate_pre_research_qualification.md), [`research_private.project_pre_research_video_state`](project_pre_research_video_state.md).

TypeScript: `Database["research_private"]["Functions"]["claim_pre_research_video"]`.

Defined in: `20260815015402_research_pre_research_schema.sql`, `20260815020333_claim_pre_research_video_by_id.sql`, `20260816205231_pre_research_v2_schema.sql`.
