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
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# retrieval.reject_vector_store_identity_mutation

Domain `retrieval`, lens `machinery`.

## reject_vector_store_identity_mutation() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `vector store identity and ownership are immutable`.

Defined in: `20260904012000_vector_store_operation_provenance.sql`.
