---
id: "fn:retrieval.guard_vector_store_lifecycle_transition()"
kind: function
schema: retrieval
name: guard_vector_store_lifecycle_transition
domain: retrieval
lens: machinery
overloads: ["fn:retrieval.guard_vector_store_lifecycle_transition()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: ["illegal vector store lifecycle transition % -> %", vector store lifecycle transition requires the control-plane function]
touches: { reads: [], writes: [] }
tokens: [retrieval, guard_vector_store_lifecycle_transition, retrieval.guard_vector_store_lifecycle_transition]
defined_in: ["20260904015000_vector_store_lifecycle_control_plane.sql"]
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
---
# retrieval.guard_vector_store_lifecycle_transition

Domain `retrieval`, lens `machinery`.

## guard_vector_store_lifecycle_transition() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `illegal vector store lifecycle transition % -> %`; `vector store lifecycle transition requires the control-plane function`.

Defined in: `20260904015000_vector_store_lifecycle_control_plane.sql`.
