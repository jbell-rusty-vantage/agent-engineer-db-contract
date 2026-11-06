---
id: "fn:retrieval.validate_vector_store_ingestion_operation()"
kind: function
schema: retrieval
name: validate_vector_store_ingestion_operation
domain: retrieval
overloads: ["fn:retrieval.validate_vector_store_ingestion_operation()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [active vector_store_ingestion operation with matching actor is required]
touches: { reads: [knowledge_service.operation], writes: [] }
tokens: [retrieval, validate_vector_store_ingestion_operation, retrieval.validate_vector_store_ingestion_operation]
defined_in: ["20260904014000_vector_store_ingestion_evidence.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# retrieval.validate_vector_store_ingestion_operation

Domain `retrieval`.

## validate_vector_store_ingestion_operation() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `active vector_store_ingestion operation with matching actor is required`.

Touches (best effort): reads [`knowledge_service.operation`](../../relations/knowledge_service/operation.md); writes —; calls —.

Defined in: `20260904014000_vector_store_ingestion_evidence.sql`.
