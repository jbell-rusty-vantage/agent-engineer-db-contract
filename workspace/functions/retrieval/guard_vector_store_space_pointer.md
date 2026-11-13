---
id: "fn:retrieval.guard_vector_store_space_pointer()"
kind: function
schema: retrieval
name: guard_vector_store_space_pointer
domain: retrieval
lens: machinery
overloads: ["fn:retrieval.guard_vector_store_space_pointer()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [only the active vector-space pointer may change, vector store spaces cannot be deleted]
touches: { reads: [], writes: [] }
tokens: [retrieval, guard_vector_store_space_pointer, retrieval.guard_vector_store_space_pointer]
defined_in: ["20260903010400_atomic_publication_and_hybrid_retrieval.sql"]
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
---
# retrieval.guard_vector_store_space_pointer

Domain `retrieval`, lens `machinery`.

## guard_vector_store_space_pointer() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `only the active vector-space pointer may change`; `vector store spaces cannot be deleted`.

Defined in: `20260903010400_atomic_publication_and_hybrid_retrieval.sql`.
