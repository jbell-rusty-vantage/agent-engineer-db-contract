---
id: "fn:retrieval.enforce_canonical_source()"
kind: function
schema: retrieval
name: enforce_canonical_source
domain: retrieval
overloads: ["fn:retrieval.enforce_canonical_source()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [canonical vector space requires its current typed projection target, embedding item dimensions or space binding differ from vector space version, vector space version is missing or belongs to another tenant]
touches: { reads: [evidence.claim, retrieval.embedding_item, retrieval.embedding_run, retrieval.projection_target, retrieval.search_projection, retrieval.vector_space, retrieval.vector_space_version], writes: [] }
tokens: [retrieval, enforce_canonical_source, retrieval.enforce_canonical_source]
defined_in: ["20260826001000_retrieval.sql", "20260914011001_vector_item_canonical_source.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# retrieval.enforce_canonical_source

Domain `retrieval`.

## enforce_canonical_source() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `canonical vector space requires its current typed projection target`; `embedding item dimensions or space binding differ from vector space version`; `vector space version is missing or belongs to another tenant`.

Touches (best effort): reads [`evidence.claim`](../../relations/evidence/claim.md), [`retrieval.embedding_item`](../../relations/retrieval/embedding_item.md), [`retrieval.embedding_run`](../../relations/retrieval/embedding_run.md), [`retrieval.projection_target`](../../relations/retrieval/projection_target.md), [`retrieval.search_projection`](../../relations/retrieval/search_projection.md), [`retrieval.vector_space`](../../relations/retrieval/vector_space.md), [`retrieval.vector_space_version`](../../relations/retrieval/vector_space_version.md); writes —; calls —.

Defined in: `20260826001000_retrieval.sql`, `20260914011001_vector_item_canonical_source.sql`.
