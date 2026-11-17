---
id: "fn:evidence.guard_source_provider_attempt()"
kind: function
schema: evidence
name: guard_source_provider_attempt
domain: evidence
lens: machinery
overloads: ["fn:evidence.guard_source_provider_attempt()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [original source dispatch is immutable, source provider attempt identity is immutable, source provider attempt terminal state is immutable, source provider attempts are retained]
touches: { reads: [], writes: [] }
tokens: [evidence, guard_source_provider_attempt, evidence.guard_source_provider_attempt]
defined_in: ["20260914010200_source_attempt_accounting.sql", "20260914010400_source_attempt_recovery.sql"]
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# evidence.guard_source_provider_attempt

Domain `evidence`, lens `machinery`.

## guard_source_provider_attempt() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `original source dispatch is immutable`; `source provider attempt identity is immutable`; `source provider attempt terminal state is immutable`; `source provider attempts are retained`.

Defined in: `20260914010200_source_attempt_accounting.sql`, `20260914010400_source_attempt_recovery.sql`.
