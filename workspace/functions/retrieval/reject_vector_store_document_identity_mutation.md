---
id: "fn:retrieval.reject_vector_store_document_identity_mutation()"
kind: function
schema: retrieval
name: reject_vector_store_document_identity_mutation
domain: retrieval
overloads: ["fn:retrieval.reject_vector_store_document_identity_mutation()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [vector store document identity is immutable]
touches: { reads: [], writes: [] }
tokens: [retrieval, reject_vector_store_document_identity_mutation, retrieval.reject_vector_store_document_identity_mutation]
defined_in: ["20260904013000_vector_store_document_operation_provenance.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# retrieval.reject_vector_store_document_identity_mutation

Domain `retrieval`.

## reject_vector_store_document_identity_mutation() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `vector store document identity is immutable`.

Defined in: `20260904013000_vector_store_document_operation_provenance.sql`.
