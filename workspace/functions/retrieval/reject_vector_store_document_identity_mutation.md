---
id: "fn:retrieval.reject_vector_store_document_identity_mutation()"
kind: function
schema: retrieval
name: reject_vector_store_document_identity_mutation
domain: retrieval
lens: machinery
overloads: ["fn:retrieval.reject_vector_store_document_identity_mutation()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [vector store document identity is immutable]
touches: { reads: [], writes: [] }
tokens: [retrieval, reject_vector_store_document_identity_mutation, retrieval.reject_vector_store_document_identity_mutation]
defined_in: ["20260904013000_vector_store_document_operation_provenance.sql"]
workspace_fingerprint: "sha256:fbf5703bf7a6f6131c452444ee949f1feec1bbe813c78d772fb3886b510815b9"
---
# retrieval.reject_vector_store_document_identity_mutation

Domain `retrieval`, lens `machinery`.

## reject_vector_store_document_identity_mutation() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `vector store document identity is immutable`.

Defined in: `20260904013000_vector_store_document_operation_provenance.sql`.
