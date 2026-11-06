---
id: "fn:retrieval.guard_vector_store_lifecycle_transition()"
kind: function
schema: retrieval
name: guard_vector_store_lifecycle_transition
domain: retrieval
overloads: ["fn:retrieval.guard_vector_store_lifecycle_transition()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: ["illegal vector store lifecycle transition % -> %", vector store lifecycle transition requires the control-plane function]
touches: { reads: [], writes: [] }
tokens: [retrieval, guard_vector_store_lifecycle_transition, retrieval.guard_vector_store_lifecycle_transition]
defined_in: ["20260904015000_vector_store_lifecycle_control_plane.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# retrieval.guard_vector_store_lifecycle_transition

Domain `retrieval`.

## guard_vector_store_lifecycle_transition() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `illegal vector store lifecycle transition % -> %`; `vector store lifecycle transition requires the control-plane function`.

Defined in: `20260904015000_vector_store_lifecycle_control_plane.sql`.
