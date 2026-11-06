---
id: "fn:research_private.touch_pre_research_run(uuid,uuid,research_pre_research_run_status,int4,text,text,text,text,text)"
kind: function
schema: research_private
name: touch_pre_research_run
domain: research-starter-protected
overloads: ["fn:research_private.touch_pre_research_run(uuid,uuid,research_pre_research_run_status,int4,text,text,text,text,text)"]
security: definer
volatility: volatile
executors: [service_role]
raises: ["LEASE_TOKEN_MISMATCH: %", "RUN_NOT_FOUND: %", "RUN_NOT_MUTABLE: % %"]
touches: { reads: [], writes: [public.research_pre_research_run] }
tokens: [research_private, touch_pre_research_run, research_private.touch_pre_research_run]
defined_in: ["20260815015402_research_pre_research_schema.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# research_private.touch_pre_research_run

Domain `research-starter-protected`.

## touch_pre_research_run(uuid, uuid, research_pre_research_run_status, integer, text, text, text, text, text) → research_pre_research_run

function, volatile, security definer, language plpgsql, config `search_path=research_private, public`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_run_id` | `uuid` | — | — |
| `p_lease_token` | `uuid` | — | — |
| `p_status` | `research_pre_research_run_status` | `NULL::research_pre_research_run_status` | — |
| `p_lease_seconds` | `integer` | `1800` | — |
| `p_workflow_session_id` | `text` | `NULL::text` | — |
| `p_intent_path` | `text` | `NULL::text` | — |
| `p_intent_sha256` | `text` | `NULL::text` | — |
| `p_error_code` | `text` | `NULL::text` | — |
| `p_error_detail` | `text` | `NULL::text` | — |

Execute: `service_role`.

Raises (mechanically extracted): `LEASE_TOKEN_MISMATCH: %`; `RUN_NOT_FOUND: %`; `RUN_NOT_MUTABLE: % %`.

Touches (best effort): reads —; writes [`public.research_pre_research_run`](../../relations/public/research_pre_research_run.md); calls —.

TypeScript: `Database["research_private"]["Functions"]["touch_pre_research_run"]`.

Defined in: `20260815015402_research_pre_research_schema.sql`.
