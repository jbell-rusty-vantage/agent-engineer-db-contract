---
id: "fn:research_private.ensure_pre_research_stage_rows(uuid)"
kind: function
schema: research_private
name: ensure_pre_research_stage_rows
domain: research-starter-protected
overloads: ["fn:research_private.ensure_pre_research_stage_rows(uuid)"]
security: definer
volatility: volatile
executors: [service_role]
raises: []
touches: { reads: [], writes: [public.research_pre_research_stage_execution] }
tokens: [research_private, ensure_pre_research_stage_rows, research_private.ensure_pre_research_stage_rows]
defined_in: ["20260824011000_stateless_pre_research_stage_execution.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# research_private.ensure_pre_research_stage_rows

Domain `research-starter-protected`.

## ensure_pre_research_stage_rows(uuid) → void

function, volatile, security definer, language sql, config `search_path=research_private, public, extensions`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_run_id` | `uuid` | — | — |

Execute: `service_role`.

Touches (best effort): reads —; writes [`public.research_pre_research_stage_execution`](../../relations/public/research_pre_research_stage_execution.md); calls —.

TypeScript: `Database["research_private"]["Functions"]["ensure_pre_research_stage_rows"]`.

Defined in: `20260824011000_stateless_pre_research_stage_execution.sql`.
