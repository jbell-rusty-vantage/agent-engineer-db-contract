---
id: "sch:taxonomy"
kind: schema
name: taxonomy
lens: corpus
domains: [identity, relationships]
relations: 9
functions: 2
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# taxonomy

Versioned multi-facet taxonomies and their enforced assignments. Lens `corpus`. Domains: [`identity`](../../domains/identity.md), [`relationships`](../../domains/relationships.md).

| Relation | Kind | Rows | Summary | Key edges |
| --- | --- | --- | --- | --- |
| [`assignment`](../../relations/taxonomy/assignment.md) | table | unknown | — | → `orchestration.operation_receipt`, → `evidence.claim`, → `evaluation.review_task`, → `catalog.entity` |
| [`assignment_review_requirement`](../../relations/taxonomy/assignment_review_requirement.md) | table | unknown | — | → `taxonomy.facet` |
| [`entity_kind`](../../relations/taxonomy/entity_kind.md) | table | small | Closed list of entity kinds with the JSON Schema that validates catalog.entity.attributes… | — |
| [`facet`](../../relations/taxonomy/facet.md) | table | unknown | — | — |
| [`facet_version`](../../relations/taxonomy/facet_version.md) | table | unknown | — | → `taxonomy.facet`, → `evaluation.review_task` |
| [`relationship_kind`](../../relations/taxonomy/relationship_kind.md) | table | unknown | Edge vocabulary with endpoint kinds, temporal flag, and property schema. | — |
| [`term`](../../relations/taxonomy/term.md) | table | unknown | — | → `taxonomy.facet_version` |
| [`term_relation`](../../relations/taxonomy/term_relation.md) | table | unknown | — | → `taxonomy.term` |
| [`term_target_kind`](../../relations/taxonomy/term_target_kind.md) | table | unknown | Restricts secondary taxonomy terms to compatible primary entity kinds. | → `taxonomy.entity_kind`, → `taxonomy.term` |

Functions: [`enforce_facet_cardinality`](../../functions/taxonomy/enforce_facet_cardinality.md), [`enforce_term_target_scope`](../../functions/taxonomy/enforce_term_target_scope.md).

Types: [`types/taxonomy.md`](../../types/taxonomy.md).

Vocabularies: [`entity_kind`](../../vocabularies/taxonomy.entity_kind.md), [`relationship_kind`](../../vocabularies/taxonomy.relationship_kind.md).
