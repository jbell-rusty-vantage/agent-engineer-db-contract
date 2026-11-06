---
id: "fn:research_private.evaluate_pre_research_qualification(research_starter_videos)"
kind: function
schema: research_private
name: evaluate_pre_research_qualification
domain: research-starter-protected
overloads: ["fn:research_private.evaluate_pre_research_qualification(research_starter_videos)"]
security: definer
volatility: stable
executors: [service_role]
raises: []
touches: { reads: [public.research_pre_research_run, public.research_pre_research_video_state], writes: [] }
tokens: [research_private, evaluate_pre_research_qualification, research_private.evaluate_pre_research_qualification]
defined_in: ["20260816205231_pre_research_v2_schema.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# research_private.evaluate_pre_research_qualification

Domain `research-starter-protected`.

## evaluate_pre_research_qualification(research_starter_videos) → TABLE(transcript_sha256 text, duration_seconds integer, transcript_object_exists boolean, eligibility_status text, ineligibility_reasons text[], already_live boolean, already_finished boolean)

function, stable, security definer, language plpgsql, config `search_path=research_private, public, extensions`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_video` | `research_starter_videos` | — | — |

Execute: `service_role`.

Touches (best effort): reads [`public.research_pre_research_run`](../../relations/public/research_pre_research_run.md), [`public.research_pre_research_video_state`](../../relations/public/research_pre_research_video_state.md); writes —; calls —.

TypeScript: `Database["research_private"]["Functions"]["evaluate_pre_research_qualification"]`.

Defined in: `20260816205231_pre_research_v2_schema.sql`.
