---
id: "fn:util.validate_predecessor()"
kind: function
schema: util
name: validate_predecessor
domain: api-surface
overloads: ["fn:util.validate_predecessor()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [supersession must point one-way to an older row, supersession predecessor must exist in the same tenant]
touches: { reads: [], writes: [] }
tokens: [util, validate_predecessor, util.validate_predecessor]
defined_in: ["20260903010200_knowledge_runtime_security.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# util.validate_predecessor

Domain `api-surface`.

## validate_predecessor() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `supersession must point one-way to an older row`; `supersession predecessor must exist in the same tenant`.

Defined in: `20260903010200_knowledge_runtime_security.sql`.
