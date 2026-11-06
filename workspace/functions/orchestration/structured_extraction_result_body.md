---
id: "fn:orchestration.structured_extraction_result_body(uuid,uuid)"
kind: function
schema: orchestration
name: structured_extraction_result_body
domain: orchestration-ledger
overloads: ["fn:orchestration.structured_extraction_result_body(uuid,uuid)"]
security: invoker
volatility: stable
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [orchestration.artifact, orchestration.verification_artifact_metadata, orchestration.verification_structured_extraction, orchestration.verification_structured_extraction_execution, orchestration.verification_structured_extraction_publication], writes: [] }
tokens: [orchestration, structured_extraction_result_body, orchestration.structured_extraction_result_body]
defined_in: ["20260906032100_verification_structured_extraction_terminal.sql", "20260914010000_artifact_logical_custody.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# orchestration.structured_extraction_result_body

Domain `orchestration-ledger`.

## structured_extraction_result_body(uuid, uuid) → jsonb

function, stable, security invoker, language sql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `tenant` | `uuid` | — | — |
| `operation` | `uuid` | — | — |

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`orchestration.artifact`](../../relations/orchestration/artifact.md), [`orchestration.verification_artifact_metadata`](../../relations/orchestration/verification_artifact_metadata.md), [`orchestration.verification_structured_extraction`](../../relations/orchestration/verification_structured_extraction.md), [`orchestration.verification_structured_extraction_execution`](../../relations/orchestration/verification_structured_extraction_execution.md), [`orchestration.verification_structured_extraction_publication`](../../relations/orchestration/verification_structured_extraction_publication.md); writes —; calls —.

TypeScript: `Database["orchestration"]["Functions"]["structured_extraction_result_body"]`.

Defined in: `20260906032100_verification_structured_extraction_terminal.sql`, `20260914010000_artifact_logical_custody.sql`.
