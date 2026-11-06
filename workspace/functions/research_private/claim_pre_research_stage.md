---
id: "fn:research_private.claim_pre_research_stage(text,int4,uuid)"
kind: function
schema: research_private
name: claim_pre_research_stage
domain: research-starter-protected
overloads: ["fn:research_private.claim_pre_research_stage(text,int4,uuid)"]
security: definer
volatility: volatile
executors: [service_role]
raises: [STAGE_LEASE_SECONDS_OUT_OF_RANGE, STAGE_WORKER_REQUIRED]
touches: { reads: [], writes: [public.research_pre_research_run, public.research_pre_research_stage_execution] }
tokens: [research_private, claim_pre_research_stage, research_private.claim_pre_research_stage]
defined_in: ["20260824011000_stateless_pre_research_stage_execution.sql", "20260825022000_pre_research_stage_dependency_guard.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# research_private.claim_pre_research_stage

Domain `research-starter-protected`.

## claim_pre_research_stage(text, integer, uuid) → TABLE(stage_execution_id uuid, run_id uuid, stage text, attempt_count integer, lease_token text, lease_expires_at timestamp with time zone, output_artifact_kinds text[])

function, volatile, security definer, language plpgsql, config `search_path=research_private, public, extensions`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_worker_id` | `text` | — | — |
| `p_lease_seconds` | `integer` | `360` | — |
| `p_run_id` | `uuid` | `NULL::uuid` | — |

Execute: `service_role`.

Raises (mechanically extracted): `STAGE_LEASE_SECONDS_OUT_OF_RANGE`; `STAGE_WORKER_REQUIRED`.

Touches (best effort): reads —; writes [`public.research_pre_research_run`](../../relations/public/research_pre_research_run.md), [`public.research_pre_research_stage_execution`](../../relations/public/research_pre_research_stage_execution.md); calls [`research_private.reconcile_pre_research_stage_rows`](reconcile_pre_research_stage_rows.md).

TypeScript: `Database["research_private"]["Functions"]["claim_pre_research_stage"]`.

Defined in: `20260824011000_stateless_pre_research_stage_execution.sql`, `20260825022000_pre_research_stage_dependency_guard.sql`.
