---
id: "fn:research_private.checkpoint_pre_research_stage_input(uuid,text,text,text,text,text,text,text)"
kind: function
schema: research_private
name: checkpoint_pre_research_stage_input
domain: research-starter-protected
overloads: ["fn:research_private.checkpoint_pre_research_stage_input(uuid,text,text,text,text,text,text,text)"]
security: definer
volatility: volatile
executors: [service_role]
raises: [STAGE_INPUT_CONFLICT, STAGE_LEASE_INVALID]
touches: { reads: [], writes: [public.research_pre_research_stage_execution] }
tokens: [research_private, checkpoint_pre_research_stage_input, research_private.checkpoint_pre_research_stage_input]
defined_in: ["20260824011000_stateless_pre_research_stage_execution.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# research_private.checkpoint_pre_research_stage_input

Domain `research-starter-protected`.

## checkpoint_pre_research_stage_input(uuid, text, text, text, text, text, text, text) → research_pre_research_stage_execution

function, volatile, security definer, language plpgsql, config `search_path=research_private, public, extensions`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_run_id` | `uuid` | — | — |
| `p_stage` | `text` | — | — |
| `p_worker_id` | `text` | — | — |
| `p_lease_token` | `text` | — | — |
| `p_bucket` | `text` | — | — |
| `p_manifest_path` | `text` | — | — |
| `p_input_sha256` | `text` | — | — |
| `p_prompt_bundle_version` | `text` | — | — |

Execute: `service_role`.

Raises (mechanically extracted): `STAGE_INPUT_CONFLICT`; `STAGE_LEASE_INVALID`.

Touches (best effort): reads —; writes [`public.research_pre_research_stage_execution`](../../relations/public/research_pre_research_stage_execution.md); calls —.

TypeScript: `Database["research_private"]["Functions"]["checkpoint_pre_research_stage_input"]`.

Defined in: `20260824011000_stateless_pre_research_stage_execution.sql`.
