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
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# retrieval.guard_vector_store_lifecycle_transition

Domain `retrieval`.

## guard_vector_store_lifecycle_transition() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `illegal vector store lifecycle transition % -> %`; `vector store lifecycle transition requires the control-plane function`.

Defined in: `20260904015000_vector_store_lifecycle_control_plane.sql`.
