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
workspace_fingerprint: "sha256:94ffe6a458de74a3cfebdee4fb31f371d14c89d7eaa16cfe1ab1cae9dc94743b"
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
