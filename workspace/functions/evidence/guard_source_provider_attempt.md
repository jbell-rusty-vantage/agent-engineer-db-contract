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
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# evidence.guard_source_provider_attempt

Domain `evidence`, lens `machinery`.

## guard_source_provider_attempt() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `original source dispatch is immutable`; `source provider attempt identity is immutable`; `source provider attempt terminal state is immutable`; `source provider attempts are retained`.

Defined in: `20260914010200_source_attempt_accounting.sql`, `20260914010400_source_attempt_recovery.sql`.
