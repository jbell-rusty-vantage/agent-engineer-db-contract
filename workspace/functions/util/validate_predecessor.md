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
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# util.validate_predecessor

Domain `api-surface`, lens `machinery`.

## validate_predecessor() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `supersession must point one-way to an older row`; `supersession predecessor must exist in the same tenant`.

Defined in: `20260903010200_knowledge_runtime_security.sql`.
