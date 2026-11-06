---
id: "fn:evidence.guard_source_provider_attempt()"
kind: function
schema: evidence
name: guard_source_provider_attempt
domain: evidence
overloads: ["fn:evidence.guard_source_provider_attempt()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [original source dispatch is immutable, source provider attempt identity is immutable, source provider attempt terminal state is immutable, source provider attempts are retained]
touches: { reads: [], writes: [] }
tokens: [evidence, guard_source_provider_attempt, evidence.guard_source_provider_attempt]
defined_in: ["20260914010200_source_attempt_accounting.sql", "20260914010400_source_attempt_recovery.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# evidence.guard_source_provider_attempt

Domain `evidence`.

## guard_source_provider_attempt() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `original source dispatch is immutable`; `source provider attempt identity is immutable`; `source provider attempt terminal state is immutable`; `source provider attempts are retained`.

Defined in: `20260914010200_source_attempt_accounting.sql`, `20260914010400_source_attempt_recovery.sql`.
