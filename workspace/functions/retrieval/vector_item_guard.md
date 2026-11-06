---
id: "fn:retrieval.vector_item_guard()"
kind: function
schema: retrieval
name: vector_item_guard
domain: retrieval
overloads: ["fn:retrieval.vector_item_guard()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [retrieval.vector_item is append-only, vector successor must be newer and same-tenant]
touches: { reads: [retrieval.vector_item], writes: [] }
tokens: [retrieval, vector_item_guard, retrieval.vector_item_guard]
defined_in: ["20260826001000_retrieval.sql", "20260903010200_knowledge_runtime_security.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# retrieval.vector_item_guard

Domain `retrieval`.

## vector_item_guard() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `retrieval.vector_item is append-only`; `vector successor must be newer and same-tenant`.

Touches (best effort): reads [`retrieval.vector_item`](../../relations/retrieval/vector_item.md); writes —; calls —.

Defined in: `20260826001000_retrieval.sql`, `20260903010200_knowledge_runtime_security.sql`.
