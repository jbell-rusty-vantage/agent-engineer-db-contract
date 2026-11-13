---
id: "fn:retrieval.reject_vector_store_identity_mutation()"
kind: function
schema: retrieval
name: reject_vector_store_identity_mutation
domain: retrieval
lens: machinery
overloads: ["fn:retrieval.reject_vector_store_identity_mutation()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [vector store identity and ownership are immutable]
touches: { reads: [], writes: [] }
tokens: [retrieval, reject_vector_store_identity_mutation, retrieval.reject_vector_store_identity_mutation]
defined_in: ["20260904012000_vector_store_operation_provenance.sql"]
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
---
# retrieval.reject_vector_store_identity_mutation

Domain `retrieval`, lens `machinery`.

## reject_vector_store_identity_mutation() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `vector store identity and ownership are immutable`.

Defined in: `20260904012000_vector_store_operation_provenance.sql`.
