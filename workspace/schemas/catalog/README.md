---
id: "sch:catalog"
kind: schema
name: catalog
lens: corpus
domains: [identity, relationships]
relations: 14
functions: 22
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# catalog

Industry identities: one entity row per thing (kind + validated attributes), aliases, identifiers, merges, one relationship table, works (paper/talk/media/story/case study). Lens `corpus`. Domains: [`identity`](../../domains/identity.md), [`relationships`](../../domains/relationships.md).

| Relation | Kind | Rows | Summary | Key edges |
| --- | --- | --- | --- | --- |
| [`distribution_kind`](../../relations/catalog/distribution_kind.md) | table | unknown | — | — |
| [`entity`](../../relations/catalog/entity.md) | table | medium | One row per canonical identity; kind-specific attributes are a jsonb validated by taxonom… | → `orchestration.operation_receipt`, → `taxonomy.entity_kind` |
| [`entity_alias`](../../relations/catalog/entity_alias.md) | table | none | Typed alternate name for one entity; unique per entity, not globally. | → `catalog.entity`, → `evidence.claim` |
| [`entity_identifier`](../../relations/catalog/entity_identifier.md) | table | small | Schemed external identifier; unique per tenant on (scheme, value). | → `catalog.entity` |
| [`entity_merge`](../../relations/catalog/entity_merge.md) | table | unknown | Durable merge of two entities; loser becomes lifecycle merged. | → `catalog.entity`, → `catalog.proposal`, → `temporal.correction_reason`, → `orchestration.operation_receipt` |
| [`entity_split`](../../relations/catalog/entity_split.md) | table | unknown | A split of one record that mixed several things (our mistake, never a split in the world)… | → `catalog.entity`, → `catalog.proposal`, → `temporal.correction_reason`, → `orchestration.operation_receipt` |
| [`entity_split_part`](../../relations/catalog/entity_split_part.md) | table | unknown | One record that a mixed record was split into. | → `catalog.entity_split`, → `catalog.entity` |
| [`identity_move`](../../relations/catalog/identity_move.md) | table | small | One row per row touched by a merge or a split: moved, closed_as_duplicate (the winner alr… | → `catalog.entity_merge`, → `catalog.entity_split` |
| [`license`](../../relations/catalog/license.md) | table | unknown | — | — |
| [`media_platform`](../../relations/catalog/media_platform.md) | table | unknown | — | → `catalog.entity` |
| [`proposal`](../../relations/catalog/proposal.md) | table | unknown | Our own view, never a fact: what a person or an agent proposes about how two things relat… | → `temporal.event`, → `orchestration.operation_receipt`, → `catalog.entity`, → `evidence.claim` |
| [`proposal_basis`](../../relations/catalog/proposal_basis.md) | table | unknown | What a proposal reasons from (basis) or must answer (counter): a claim, a fact, an event … | → `evidence.claim`, → `temporal.event`, → `catalog.proposal`, → `catalog.relationship` |
| [`relationship`](../../relations/catalog/relationship.md) | table | medium | One edge table; kinds constrain endpoints and may be temporal. | → `temporal.event`, → `temporal.correction_reason`, → `catalog.entity`, → `taxonomy.relationship_kind` |
| [`work`](../../relations/catalog/work.md) | table | small | Bibliographic row behind a work entity (paper, talk, media work, story, case study); cont… | → `catalog.entity` |

Functions: [`_carry_relationship_streams`](../../functions/catalog/_carry_relationship_streams.md), [`_ensure_stream`](../../functions/catalog/_ensure_stream.md), [`_log_move`](../../functions/catalog/_log_move.md), [`_move_relationship`](../../functions/catalog/_move_relationship.md), [`_move_segment`](../../functions/catalog/_move_segment.md), [`_reopen_segment`](../../functions/catalog/_reopen_segment.md), [`_repoint_references`](../../functions/catalog/_repoint_references.md), [`_row_key`](../../functions/catalog/_row_key.md), [`caller_is_person`](../../functions/catalog/caller_is_person.md), [`caller_role`](../../functions/catalog/caller_role.md), [`canonical_entity`](../../functions/catalog/canonical_entity.md), [`check_receipt_tenant`](../../functions/catalog/check_receipt_tenant.md), [`check_relationship_kinds`](../../functions/catalog/check_relationship_kinds.md), [`check_relationship_properties`](../../functions/catalog/check_relationship_properties.md), [`entity_references`](../../functions/catalog/entity_references.md), [`import_research_starter_catalog`](../../functions/catalog/import_research_starter_catalog.md), [`merge_entities`](../../functions/catalog/merge_entities.md), [`rebuild_entity_projections`](../../functions/catalog/rebuild_entity_projections.md), [`split_entity`](../../functions/catalog/split_entity.md), [`undo_merge`](../../functions/catalog/undo_merge.md), [`validate_entity_attributes`](../../functions/catalog/validate_entity_attributes.md), [`with_merged`](../../functions/catalog/with_merged.md).

Types: [`types/catalog.md`](../../types/catalog.md).
