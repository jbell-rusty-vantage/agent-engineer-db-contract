---
id: "sch:catalog"
kind: schema
name: catalog
lens: corpus
domains: [identity, relationships]
relations: 9
functions: 6
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# catalog

Industry identities: one entity row per thing (kind + validated attributes), aliases, identifiers, merges, one relationship table, works (paper/talk/media/story/case study). Lens `corpus`. Domains: [`identity`](../../domains/identity.md), [`relationships`](../../domains/relationships.md).

| Relation | Kind | Rows | Summary | Key edges |
| --- | --- | --- | --- | --- |
| [`distribution_kind`](../../relations/catalog/distribution_kind.md) | table | unknown | — | — |
| [`entity`](../../relations/catalog/entity.md) | table | medium | One row per canonical identity; kind-specific attributes are a jsonb validated by taxonom… | → `orchestration.operation_receipt`, → `taxonomy.entity_kind` |
| [`entity_alias`](../../relations/catalog/entity_alias.md) | table | unknown | Typed alternate name for one entity; unique per entity, not globally. | → `catalog.entity`, → `evidence.claim` |
| [`entity_identifier`](../../relations/catalog/entity_identifier.md) | table | small | Schemed external identifier; unique per tenant on (scheme, value). | → `catalog.entity` |
| [`entity_merge`](../../relations/catalog/entity_merge.md) | table | unknown | Durable merge of two entities; loser becomes lifecycle merged. | → `catalog.entity`, → `orchestration.operation_receipt` |
| [`license`](../../relations/catalog/license.md) | table | unknown | — | — |
| [`media_platform`](../../relations/catalog/media_platform.md) | table | unknown | — | → `catalog.entity` |
| [`relationship`](../../relations/catalog/relationship.md) | table | medium | One edge table; kinds constrain endpoints and may be temporal. | → `catalog.entity`, → `taxonomy.relationship_kind`, → `evidence.claim` |
| [`work`](../../relations/catalog/work.md) | table | small | Bibliographic row behind a work entity (paper, talk, media work, story, case study); cont… | → `catalog.entity` |

Functions: [`check_receipt_tenant`](../../functions/catalog/check_receipt_tenant.md), [`check_relationship_kinds`](../../functions/catalog/check_relationship_kinds.md), [`check_relationship_properties`](../../functions/catalog/check_relationship_properties.md), [`import_research_starter_catalog`](../../functions/catalog/import_research_starter_catalog.md), [`rebuild_entity_projections`](../../functions/catalog/rebuild_entity_projections.md), [`validate_entity_attributes`](../../functions/catalog/validate_entity_attributes.md).

Types: [`types/catalog.md`](../../types/catalog.md).
