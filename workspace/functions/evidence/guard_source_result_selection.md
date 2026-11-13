---
id: "fn:evidence.guard_source_result_selection()"
kind: function
schema: evidence
name: guard_source_result_selection
domain: evidence
lens: machinery
overloads: ["fn:evidence.guard_source_result_selection()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [selection requires a successful result and available parent-bound receipt]
touches: { reads: [evidence.provider_result, evidence.source_provider_attempt, orchestration.artifact, orchestration.verification_artifact_metadata], writes: [] }
tokens: [evidence, guard_source_result_selection, evidence.guard_source_result_selection]
defined_in: ["20260914010400_source_attempt_recovery.sql"]
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# evidence.guard_source_result_selection

Domain `evidence`, lens `machinery`.

## guard_source_result_selection() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `selection requires a successful result and available parent-bound receipt`.

Touches (best effort): reads [`evidence.provider_result`](../../relations/evidence/provider_result.md), [`evidence.source_provider_attempt`](../../relations/evidence/source_provider_attempt.md), [`orchestration.artifact`](../../relations/orchestration/artifact.md), [`orchestration.verification_artifact_metadata`](../../relations/orchestration/verification_artifact_metadata.md); writes —; calls —.

Defined in: `20260914010400_source_attempt_recovery.sql`.
