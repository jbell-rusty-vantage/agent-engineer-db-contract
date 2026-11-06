---
id: "fn:orchestration.structured_extraction_receipt_json(jsonb)"
kind: function
schema: orchestration
name: structured_extraction_receipt_json
domain: orchestration-ledger
overloads: ["fn:orchestration.structured_extraction_receipt_json(jsonb)"]
security: invoker
volatility: immutable
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [structured extraction receipt requires safe integers]
touches: { reads: [], writes: [] }
tokens: [orchestration, structured_extraction_receipt_json, orchestration.structured_extraction_receipt_json]
defined_in: ["20260906032100_verification_structured_extraction_terminal.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# orchestration.structured_extraction_receipt_json

Domain `orchestration-ledger`.

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
