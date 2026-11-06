---
id: "fn:evidence.guard_source_result_selection()"
kind: function
schema: evidence
name: guard_source_result_selection
domain: evidence
overloads: ["fn:evidence.guard_source_result_selection()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [selection requires a successful result and available parent-bound receipt]
touches: { reads: [evidence.provider_result, evidence.source_provider_attempt, orchestration.artifact, orchestration.verification_artifact_metadata], writes: [] }
tokens: [evidence, guard_source_result_selection, evidence.guard_source_result_selection]
defined_in: ["20260914010400_source_attempt_recovery.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# evidence.guard_source_result_selection

Domain `evidence`.

## guard_source_result_selection() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `selection requires a successful result and available parent-bound receipt`.

Touches (best effort): reads [`evidence.provider_result`](../../relations/evidence/provider_result.md), [`evidence.source_provider_attempt`](../../relations/evidence/source_provider_attempt.md), [`orchestration.artifact`](../../relations/orchestration/artifact.md), [`orchestration.verification_artifact_metadata`](../../relations/orchestration/verification_artifact_metadata.md); writes —; calls —.

Defined in: `20260914010400_source_attempt_recovery.sql`.
