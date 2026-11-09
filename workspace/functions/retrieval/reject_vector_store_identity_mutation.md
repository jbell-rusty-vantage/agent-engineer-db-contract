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
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
---
# retrieval.reject_vector_store_identity_mutation

Domain `retrieval`, lens `machinery`.

## reject_vector_store_identity_mutation() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `vector store identity and ownership are immutable`.

Defined in: `20260904012000_vector_store_operation_provenance.sql`.
