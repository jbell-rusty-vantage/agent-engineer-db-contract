---
id: "fn:util.validate_predecessor()"
kind: function
schema: util
name: validate_predecessor
domain: api-surface
lens: machinery
overloads: ["fn:util.validate_predecessor()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [supersession must point one-way to an older row, supersession predecessor must exist in the same tenant]
touches: { reads: [], writes: [] }
tokens: [util, validate_predecessor, util.validate_predecessor]
defined_in: ["20260903010200_knowledge_runtime_security.sql"]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# util.validate_predecessor

Domain `api-surface`, lens `machinery`.

## validate_predecessor() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `supersession must point one-way to an older row`; `supersession predecessor must exist in the same tenant`.

Defined in: `20260903010200_knowledge_runtime_security.sql`.
