---
id: "fn:evidence.require_source_selection_decisions()"
kind: function
schema: evidence
name: require_source_selection_decisions
domain: evidence
lens: machinery
overloads: ["fn:evidence.require_source_selection_decisions()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [selection revision requires at least one admitted decision]
touches: { reads: [evidence.source_result_selection], writes: [] }
tokens: [evidence, require_source_selection_decisions, evidence.require_source_selection_decisions]
defined_in: ["20260914010400_source_attempt_recovery.sql"]
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# evidence.require_source_selection_decisions

Domain `evidence`, lens `machinery`.

## require_source_selection_decisions() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `selection revision requires at least one admitted decision`.

Touches (best effort): reads [`evidence.source_result_selection`](../../relations/evidence/source_result_selection.md); writes —; calls —.

Defined in: `20260914010400_source_attempt_recovery.sql`.
