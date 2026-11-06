---
id: "fn:retrieval.require_active_vector_store_reference()"
kind: function
schema: retrieval
name: require_active_vector_store_reference
domain: retrieval
overloads: ["fn:retrieval.require_active_vector_store_reference()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [active vector store is required]
touches: { reads: [retrieval.vector_store], writes: [] }
tokens: [retrieval, require_active_vector_store_reference, retrieval.require_active_vector_store_reference]
defined_in: ["20260904015000_vector_store_lifecycle_control_plane.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# retrieval.require_active_vector_store_reference

Domain `retrieval`.

## require_active_vector_store_reference() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `active vector store is required`.

Touches (best effort): reads [`retrieval.vector_store`](../../relations/retrieval/vector_store.md); writes —; calls —.

Defined in: `20260904015000_vector_store_lifecycle_control_plane.sql`.
