---
id: "fn:research_private.park_pre_research_stage(uuid,text,text,text,bool,timestamptz,text,text)"
kind: function
schema: research_private
name: park_pre_research_stage
domain: research-starter-protected
overloads: ["fn:research_private.park_pre_research_stage(uuid,text,text,text,bool,timestamptz,text,text)"]
security: definer
volatility: volatile
executors: [service_role]
raises: [STAGE_LEASE_INVALID]
touches: { reads: [], writes: [public.research_pre_research_stage_execution] }
tokens: [research_private, park_pre_research_stage, research_private.park_pre_research_stage]
defined_in: ["20260824011000_stateless_pre_research_stage_execution.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# research_private.park_pre_research_stage

Domain `research-starter-protected`.

## park_pre_research_stage(uuid, text, text, text, boolean, timestamp with time zone, text, text) → research_pre_research_stage_execution

function, volatile, security definer, language plpgsql, config `search_path=research_private, public, extensions`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_run_id` | `uuid` | — | — |
| `p_stage` | `text` | — | — |
| `p_worker_id` | `text` | — | — |
| `p_lease_token` | `text` | — | — |
| `p_retryable` | `boolean` | — | — |
| `p_retry_after` | `timestamp with time zone` | — | — |
| `p_error_code` | `text` | — | — |
| `p_error_detail` | `text` | — | — |

Execute: `service_role`.

Raises (mechanically extracted): `STAGE_LEASE_INVALID`.

Touches (best effort): reads —; writes [`public.research_pre_research_stage_execution`](../../relations/public/research_pre_research_stage_execution.md); calls —.

TypeScript: `Database["research_private"]["Functions"]["park_pre_research_stage"]`.

Defined in: `20260824011000_stateless_pre_research_stage_execution.sql`.
