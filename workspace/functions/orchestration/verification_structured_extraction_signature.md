---
id: "fn:orchestration.verification_structured_extraction_signature(verification_structured_extraction,text,text,uuid[])"
kind: function
schema: orchestration
name: verification_structured_extraction_signature
domain: orchestration-ledger
lens: machinery
overloads: ["fn:orchestration.verification_structured_extraction_signature(verification_structured_extraction,text,text,uuid[])"]
security: invoker
volatility: immutable
executors: [control_plane, executor_service, service_role, verifier_agent]
raises: []
touches: { reads: [], writes: [] }
tokens: [orchestration, verification_structured_extraction_signature, orchestration.verification_structured_extraction_signature]
defined_in: ["20260906031700_verification_structured_extraction_lifecycle.sql"]
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# orchestration.verification_structured_extraction_signature

Domain `orchestration-ledger`, lens `machinery`.

## verification_structured_extraction_signature(orchestration.verification_structured_extraction, text, text, uuid[]) → text

function, immutable, security invoker, language sql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `lifecycle` | `orchestration.verification_structured_extraction` | — | — |
| `artifact_type` | `text` | — | — |
| `artifact_sha256` | `text` | — | — |
| `parents` | `uuid[]` | — | — |

Execute: `control_plane`, `executor_service`, `service_role`, `verifier_agent`.

TypeScript: `Database["orchestration"]["Functions"]["verification_structured_extraction_signature"]`.

Defined in: `20260906031700_verification_structured_extraction_lifecycle.sql`.
