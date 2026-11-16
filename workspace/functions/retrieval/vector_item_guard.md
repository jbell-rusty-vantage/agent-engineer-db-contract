---
id: "fn:retrieval.vector_item_guard()"
kind: function
schema: retrieval
name: vector_item_guard
domain: retrieval
lens: machinery
overloads: ["fn:retrieval.vector_item_guard()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [retrieval.vector_item is append-only, vector successor must be newer and same-tenant]
touches: { reads: [retrieval.vector_item], writes: [] }
tokens: [retrieval, vector_item_guard, retrieval.vector_item_guard]
defined_in: ["20260826001000_retrieval.sql", "20260903010200_knowledge_runtime_security.sql", "20261108120000_build08_r2_knowledge_continuum.sql", "20261108120200_build08_r2_fixups2.sql", part3_retrieval.sql]
workspace_fingerprint: "sha256:216c4ae7230478c8e60934da25c852e10680d6caed71a662962ea3c0ac1676d3"
---
# retrieval.vector_item_guard

Domain `retrieval`, lens `machinery`.

## vector_item_guard() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `retrieval.vector_item is append-only`; `vector successor must be newer and same-tenant`.

Touches (best effort): reads [`retrieval.vector_item`](../../relations/retrieval/vector_item.md); writes —; calls —.

Defined in: `20260826001000_retrieval.sql`, `20260903010200_knowledge_runtime_security.sql`, `20261108120000_build08_r2_knowledge_continuum.sql`, `20261108120200_build08_r2_fixups2.sql`, `part3_retrieval.sql`.
