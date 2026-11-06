---
id: "fn:research_private.complete_research_phase(uuid,text)"
kind: function
schema: research_private
name: complete_research_phase
domain: research-starter-protected
overloads: ["fn:research_private.complete_research_phase(uuid,text)"]
security: definer
volatility: volatile
executors: [service_role]
raises: ["ILLEGAL_PHASE_TRANSITION: % %", "RESEARCH_CHECKPOINT_INCOMPLETE: %", "RUN_NOT_FOUND: %", "SESSION_BINDING_PENDING: %", "SESSION_MISMATCH: %", "TRANSCRIPT_HASH_MISMATCH: %"]
touches: { reads: [public.research_pre_research_artifact], writes: [public.research_pre_research_run, public.research_pre_research_session] }
tokens: [research_private, complete_research_phase, research_private.complete_research_phase]
defined_in: ["20260816205231_pre_research_v2_schema.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# research_private.complete_research_phase

Domain `research-starter-protected`.

## complete_research_phase(uuid, text) → jsonb

function, volatile, security definer, language plpgsql, config `search_path=research_private, public, extensions`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_run_id` | `uuid` | — | — |
| `p_eve_session_id` | `text` | — | — |

Execute: `service_role`.

Raises (mechanically extracted): `ILLEGAL_PHASE_TRANSITION: % %`; `RESEARCH_CHECKPOINT_INCOMPLETE: %`; `RUN_NOT_FOUND: %`; `SESSION_BINDING_PENDING: %`; `SESSION_MISMATCH: %`; `TRANSCRIPT_HASH_MISMATCH: %`.

Touches (best effort): reads [`public.research_pre_research_artifact`](../../relations/public/research_pre_research_artifact.md); writes [`public.research_pre_research_run`](../../relations/public/research_pre_research_run.md), [`public.research_pre_research_session`](../../relations/public/research_pre_research_session.md); calls [`research_private.current_transcript_hash`](current_transcript_hash.md), [`research_private.project_pre_research_video_state`](project_pre_research_video_state.md).

TypeScript: `Database["research_private"]["Functions"]["complete_research_phase"]`.

Defined in: `20260816205231_pre_research_v2_schema.sql`.
