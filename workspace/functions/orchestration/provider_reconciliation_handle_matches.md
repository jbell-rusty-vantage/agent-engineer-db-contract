---
id: "fn:orchestration.provider_reconciliation_handle_matches(uuid,jsonb)"
kind: function
schema: orchestration
name: provider_reconciliation_handle_matches
domain: orchestration-ledger
overloads: ["fn:orchestration.provider_reconciliation_handle_matches(uuid,jsonb)"]
security: invoker
volatility: stable
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [orchestration.artifact, orchestration.verification_artifact_metadata], writes: [] }
tokens: [orchestration, provider_reconciliation_handle_matches, orchestration.provider_reconciliation_handle_matches]
defined_in: ["20260906032800_verification_provider_reconciliation_ledger.sql", "20260914010000_artifact_logical_custody.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# orchestration.provider_reconciliation_handle_matches

Domain `orchestration-ledger`.

## provider_reconciliation_handle_matches(uuid, jsonb) → boolean

function, stable, security invoker, language sql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `tenant` | `uuid` | — | — |
| `handle` | `jsonb` | — | — |

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`orchestration.artifact`](../../relations/orchestration/artifact.md), [`orchestration.verification_artifact_metadata`](../../relations/orchestration/verification_artifact_metadata.md); writes —; calls —.

TypeScript: `Database["orchestration"]["Functions"]["provider_reconciliation_handle_matches"]`.

Defined in: `20260906032800_verification_provider_reconciliation_ledger.sql`, `20260914010000_artifact_logical_custody.sql`.
