---
id: "fn:retrieval.validate_vector_store_ingestion_operation()"
kind: function
schema: retrieval
name: validate_vector_store_ingestion_operation
domain: retrieval
lens: machinery
overloads: ["fn:retrieval.validate_vector_store_ingestion_operation()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [active vector_store_ingestion operation with matching actor is required]
touches: { reads: [knowledge_service.operation], writes: [] }
tokens: [retrieval, validate_vector_store_ingestion_operation, retrieval.validate_vector_store_ingestion_operation]
defined_in: ["20260904014000_vector_store_ingestion_evidence.sql"]
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
---
# retrieval.validate_vector_store_ingestion_operation

Domain `retrieval`, lens `machinery`.

## validate_vector_store_ingestion_operation() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `active vector_store_ingestion operation with matching actor is required`.

Touches (best effort): reads [`knowledge_service.operation`](../../relations/knowledge_service/operation.md); writes —; calls —.

Defined in: `20260904014000_vector_store_ingestion_evidence.sql`.
