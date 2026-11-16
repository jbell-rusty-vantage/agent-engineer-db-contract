---
id: "fn:retrieval.validate_vector_store_space_authority()"
kind: function
schema: retrieval
name: validate_vector_store_space_authority
domain: retrieval
lens: machinery
overloads: ["fn:retrieval.validate_vector_store_space_authority()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [vector store space authority must match its parent store class]
touches: { reads: [retrieval.vector_store], writes: [] }
tokens: [retrieval, validate_vector_store_space_authority, retrieval.validate_vector_store_space_authority]
defined_in: ["20260903010100_knowledge_retrieval_contract.sql"]
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# retrieval.validate_vector_store_space_authority

Domain `retrieval`, lens `machinery`.

## validate_vector_store_space_authority() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `vector store space authority must match its parent store class`.

Touches (best effort): reads [`retrieval.vector_store`](../../relations/retrieval/vector_store.md); writes —; calls —.

Defined in: `20260903010100_knowledge_retrieval_contract.sql`.
