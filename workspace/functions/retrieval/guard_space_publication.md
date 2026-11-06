---
id: "fn:retrieval.guard_space_publication()"
kind: function
schema: retrieval
name: guard_space_publication
domain: retrieval
overloads: ["fn:retrieval.guard_space_publication()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: ["publication gate failed (dims %, precision %, decision %, gate %, embeddings %/%)", publications cannot be deleted, published rows may only transition to superseded or withdrawn, terminal publication is immutable]
touches: { reads: [evaluation.promotion_gate_result, retrieval.content_promotion_decision, retrieval.vector_item_embedding_1536, retrieval.vector_space_version], writes: [] }
tokens: [retrieval, guard_space_publication, retrieval.guard_space_publication]
defined_in: ["20260903010200_knowledge_runtime_security.sql", "20260903010400_atomic_publication_and_hybrid_retrieval.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# retrieval.guard_space_publication

Domain `retrieval`.

## guard_space_publication() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `publication gate failed (dims %, precision %, decision %, gate %, embeddings %/%)`; `publications cannot be deleted`; `published rows may only transition to superseded or withdrawn`; `terminal publication is immutable`.

Touches (best effort): reads [`evaluation.promotion_gate_result`](../../relations/evaluation/promotion_gate_result.md), [`retrieval.content_promotion_decision`](../../relations/retrieval/content_promotion_decision.md), [`retrieval.vector_item_embedding_1536`](../../relations/retrieval/vector_item_embedding_1536.md), [`retrieval.vector_space_version`](../../relations/retrieval/vector_space_version.md); writes —; calls —.

Defined in: `20260903010200_knowledge_runtime_security.sql`, `20260903010400_atomic_publication_and_hybrid_retrieval.sql`.
