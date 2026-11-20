---
id: "fn:retrieval.retire_deterministic_digest_items()"
kind: function
schema: retrieval
name: retire_deterministic_digest_items
domain: retrieval
lens: corpus
overloads: ["fn:retrieval.retire_deterministic_digest_items()"]
security: definer
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [content.digest_item, content.document_digest, retrieval.projection_target, retrieval.vector_space, retrieval.vector_space_version], writes: [retrieval.vector_item] }
tokens: [retrieval, retire_deterministic_digest_items, retrieval.retire_deterministic_digest_items]
defined_in: ["20261113120000_build08_loop4_source_intelligence_experiments.sql"]
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# retrieval.retire_deterministic_digest_items

Domain `retrieval`, lens `corpus`.

## retire_deterministic_digest_items() → integer

function, volatile, security definer, language plpgsql, config `search_path=""`. Loop 4 (candidate B): retires deterministic digest items from the digests space so that space holds model-written digests only; the items stay searchable in knowledge_text.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`content.digest_item`](../../relations/content/digest_item.md), [`content.document_digest`](../../relations/content/document_digest.md), [`retrieval.projection_target`](../../relations/retrieval/projection_target.md), [`retrieval.vector_space`](../../relations/retrieval/vector_space.md), [`retrieval.vector_space_version`](../../relations/retrieval/vector_space_version.md); writes [`retrieval.vector_item`](../../relations/retrieval/vector_item.md); calls —.

TypeScript: `Database["retrieval"]["Functions"]["retire_deterministic_digest_items"]`.

Defined in: `20261113120000_build08_loop4_source_intelligence_experiments.sql`.
