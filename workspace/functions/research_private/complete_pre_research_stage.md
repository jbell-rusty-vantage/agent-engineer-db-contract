---
id: "fn:research_private.complete_pre_research_stage(uuid,text,text,text,jsonb,jsonb,text)"
kind: function
schema: research_private
name: complete_pre_research_stage
domain: research-starter-protected
overloads: ["fn:research_private.complete_pre_research_stage(uuid,text,text,text,jsonb,jsonb,text)"]
security: definer
volatility: volatile
executors: [service_role]
raises: [STAGE_ARTIFACT_HASH_MISMATCH, STAGE_LEASE_INVALID, STAGE_NEXT_STATUS_INVALID]
touches: { reads: [public.research_pre_research_artifact], writes: [public.research_pre_research_run, public.research_pre_research_stage_execution] }
tokens: [research_private, complete_pre_research_stage, research_private.complete_pre_research_stage]
defined_in: ["20260824011000_stateless_pre_research_stage_execution.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# research_private.complete_pre_research_stage

Domain `research-starter-protected`.

## complete_pre_research_stage(uuid, text, text, text, jsonb, jsonb, text) → research_pre_research_stage_execution

function, volatile, security definer, language plpgsql, config `search_path=research_private, public, extensions`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_run_id` | `uuid` | — | — |
| `p_stage` | `text` | — | — |
| `p_worker_id` | `text` | — | — |
| `p_lease_token` | `text` | — | — |
| `p_artifact_sha256s` | `jsonb` | — | — |
| `p_usage_summary` | `jsonb` | `'{}'::jsonb` | — |
| `p_next_status` | `text` | `NULL::text` | — |

Execute: `service_role`.

Raises (mechanically extracted): `STAGE_ARTIFACT_HASH_MISMATCH`; `STAGE_LEASE_INVALID`; `STAGE_NEXT_STATUS_INVALID`.

Touches (best effort): reads [`public.research_pre_research_artifact`](../../relations/public/research_pre_research_artifact.md); writes [`public.research_pre_research_run`](../../relations/public/research_pre_research_run.md), [`public.research_pre_research_stage_execution`](../../relations/public/research_pre_research_stage_execution.md); calls [`research_private.project_pre_research_video_state`](project_pre_research_video_state.md).

TypeScript: `Database["research_private"]["Functions"]["complete_pre_research_stage"]`.

Defined in: `20260824011000_stateless_pre_research_stage_execution.sql`.
