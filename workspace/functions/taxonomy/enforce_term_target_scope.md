---
id: "fn:taxonomy.enforce_term_target_scope()"
kind: function
schema: taxonomy
name: enforce_term_target_scope
domain: relationships
lens: machinery
overloads: ["fn:taxonomy.enforce_term_target_scope()"]
security: invoker
volatility: volatile
executors: []
raises: [taxonomy term does not admit target kind]
touches: { reads: [authoring.work, catalog.entity, guidance.item, taxonomy.term_target_kind], writes: [] }
tokens: [taxonomy, enforce_term_target_scope, taxonomy.enforce_term_target_scope]
defined_in: ["20260829192855_optimize_ai_entity_taxonomy_and_relationships.sql", "20260912010700_km_07_knowledge.sql", "20261105010200_product_curriculum_cutover.sql"]
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# taxonomy.enforce_term_target_scope

Domain `relationships`, lens `machinery`.

## enforce_term_target_scope() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: no configured role.

Raises (mechanically extracted): `taxonomy term does not admit target kind`.

Touches (best effort): reads [`authoring.work`](../../relations/authoring/work.md), [`catalog.entity`](../../relations/catalog/entity.md), [`guidance.item`](../../relations/guidance/item.md), [`taxonomy.term_target_kind`](../../relations/taxonomy/term_target_kind.md); writes —; calls —.

Defined in: `20260829192855_optimize_ai_entity_taxonomy_and_relationships.sql`, `20260912010700_km_07_knowledge.sql`, `20261105010200_product_curriculum_cutover.sql`.
