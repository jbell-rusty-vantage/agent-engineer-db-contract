---
id: "fn:taxonomy.enforce_term_target_scope()"
kind: function
schema: taxonomy
name: enforce_term_target_scope
domain: relationships
overloads: ["fn:taxonomy.enforce_term_target_scope()"]
security: invoker
volatility: volatile
executors: []
raises: [taxonomy term does not admit target kind]
touches: { reads: [corpus.entity, knowledge.record, taxonomy.term_target_kind], writes: [] }
tokens: [taxonomy, enforce_term_target_scope, taxonomy.enforce_term_target_scope]
defined_in: ["20260829192855_optimize_ai_entity_taxonomy_and_relationships.sql", "20260912010700_km_07_knowledge.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# taxonomy.enforce_term_target_scope

Domain `relationships`.

## enforce_term_target_scope() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: no configured role.

Raises (mechanically extracted): `taxonomy term does not admit target kind`.

Touches (best effort): reads [`corpus.entity`](../../relations/corpus/entity.md), [`knowledge.record`](../../relations/knowledge/record.md), [`taxonomy.term_target_kind`](../../relations/taxonomy/term_target_kind.md); writes —; calls —.

Defined in: `20260829192855_optimize_ai_entity_taxonomy_and_relationships.sql`, `20260912010700_km_07_knowledge.sql`.
