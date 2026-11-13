---
id: "fn:orchestration.structured_extraction_receipt_json(jsonb)"
kind: function
schema: orchestration
name: structured_extraction_receipt_json
domain: orchestration-ledger
lens: machinery
overloads: ["fn:orchestration.structured_extraction_receipt_json(jsonb)"]
security: invoker
volatility: immutable
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [structured extraction receipt requires safe integers]
touches: { reads: [], writes: [] }
tokens: [orchestration, structured_extraction_receipt_json, orchestration.structured_extraction_receipt_json]
defined_in: ["20260906032100_verification_structured_extraction_terminal.sql"]
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# orchestration.structured_extraction_receipt_json

Domain `orchestration-ledger`, lens `machinery`.

## structured_extraction_receipt_json(jsonb) → text

function, immutable, security invoker, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `value` | `jsonb` | — | — |

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `structured extraction receipt requires safe integers`.

Touches (best effort): reads —; writes —; calls [`orchestration.structured_extraction_receipt_json`](structured_extraction_receipt_json.md).

TypeScript: `Database["orchestration"]["Functions"]["structured_extraction_receipt_json"]`.

Defined in: `20260906032100_verification_structured_extraction_terminal.sql`.
