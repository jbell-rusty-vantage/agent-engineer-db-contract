---
id: "sch:corpus"
kind: schema
name: corpus
domains: [identity, relationships]
relations: 51
functions: 6
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# corpus

Canonical typed entities and property-bearing relationships. Domains: [`identity`](../../domains/identity.md), [`relationships`](../../domains/relationships.md).

| Relation | Kind | Rows | Summary | Key edges |
| --- | --- | --- | --- | --- |
| [`agent_skill`](../../relations/corpus/agent_skill.md) | table | unknown | — | → `corpus.entity` |
| [`ai_model`](../../relations/corpus/ai_model.md) | table | unknown | Typed child for an AI model family (not a version or offering). | → `corpus.entity` |
| [`ai_model_version`](../../relations/corpus/ai_model_version.md) | table | unknown | Typed child for one version of an ai_model. | → `corpus.ai_model`, → `corpus.entity` |
| [`ai_model_version_spec`](../../relations/corpus/ai_model_version_spec.md) | table | unknown | — | → `corpus.ai_model_version`, → `evidence.claim` |
| [`ai_protocol`](../../relations/corpus/ai_protocol.md) | table | unknown | — | → `corpus.entity` |
| [`ai_protocol_feature`](../../relations/corpus/ai_protocol_feature.md) | table | unknown | — | → `corpus.ai_protocol`, → `corpus.entity` |
| [`ai_protocol_version`](../../relations/corpus/ai_protocol_version.md) | table | unknown | — | → `corpus.ai_protocol`, → `corpus.entity` |
| [`benchmark`](../../relations/corpus/benchmark.md) | table | unknown | — | → `corpus.entity` |
| [`benchmark_run`](../../relations/corpus/benchmark_run.md) | table | unknown | — | → `orchestration.artifact`, → `corpus.benchmark`, → `corpus.entity` |
| [`case_study`](../../relations/corpus/case_study.md) | table | unknown | — | → `corpus.entity` |
| [`compute_device`](../../relations/corpus/compute_device.md) | table | unknown | — | → `corpus.entity` |
| [`compute_offering`](../../relations/corpus/compute_offering.md) | table | unknown | — | → `corpus.entity` |
| [`concept`](../../relations/corpus/concept.md) | table | unknown | — | → `corpus.entity` |
| [`corporate_transaction`](../../relations/corpus/corporate_transaction.md) | table | unknown | — | → `corpus.entity` |
| [`dataset`](../../relations/corpus/dataset.md) | table | unknown | — | → `corpus.entity`, → `corpus.license` |
| [`distribution_kind`](../../relations/corpus/distribution_kind.md) | table | unknown | — | — |
| [`entity`](../../relations/corpus/entity.md) | table | small | One row per canonical identity; typed attributes live in corpus.<kind>. | → `orchestration.operation_receipt`, → `taxonomy.entity_kind` |
| [`entity_alias`](../../relations/corpus/entity_alias.md) | table | unknown | Typed alternate name for one entity; unique per entity, not globally. | → `corpus.entity`, → `evidence.claim` |
| [`entity_identifier`](../../relations/corpus/entity_identifier.md) | table | unknown | Schemed external identifier; unique per tenant on (scheme, value). | → `corpus.entity` |
| [`entity_merge`](../../relations/corpus/entity_merge.md) | table | unknown | Durable merge of two entities; loser becomes lifecycle merged. | → `corpus.entity`, → `orchestration.operation_receipt` |
| [`event_series`](../../relations/corpus/event_series.md) | table | unknown | — | → `corpus.entity` |
| [`funding_round`](../../relations/corpus/funding_round.md) | table | unknown | — | → `corpus.entity` |
| [`industry_event`](../../relations/corpus/industry_event.md) | table | unknown | — | → `corpus.entity`, → `corpus.event_series` |
| [`library`](../../relations/corpus/library.md) | table | unknown | — | → `corpus.entity` |
| [`library_release`](../../relations/corpus/library_release.md) | table | unknown | — | → `corpus.entity`, → `corpus.library`, → `corpus.license`, → `corpus.registry` |
| [`license`](../../relations/corpus/license.md) | table | unknown | — | — |
| [`mcp_server`](../../relations/corpus/mcp_server.md) | table | unknown | — | → `corpus.entity` |
| [`mcp_server_surface`](../../relations/corpus/mcp_server_surface.md) | table | unknown | — | → `orchestration.artifact`, → `corpus.mcp_server` |
| [`media_appearance`](../../relations/corpus/media_appearance.md) | table | unknown | — | → `corpus.entity`, → `evidence.locator`, → `corpus.media_work`, → `evidence.claim` |
| [`media_channel`](../../relations/corpus/media_channel.md) | table | unknown | — | → `corpus.entity`, → `corpus.media_platform` |
| [`media_platform`](../../relations/corpus/media_platform.md) | table | unknown | — | → `corpus.entity` |
| [`media_series`](../../relations/corpus/media_series.md) | table | unknown | — | → `corpus.entity`, → `corpus.industry_event`, → `corpus.media_platform`, → `corpus.media_channel` |
| [`media_work`](../../relations/corpus/media_work.md) | table | unknown | — | → `corpus.media_channel`, → `corpus.entity`, → `corpus.media_platform` |
| [`model_offering`](../../relations/corpus/model_offering.md) | table | unknown | A priced, deployable offering of an ai_model_version from a provider. | → `corpus.entity`, → `corpus.ai_model_version` |
| [`organization`](../../relations/corpus/organization.md) | table | small | Typed child of corpus.entity for kind organization. | → `corpus.entity` |
| [`paper`](../../relations/corpus/paper.md) | table | unknown | — | → `corpus.entity` |
| [`person`](../../relations/corpus/person.md) | table | unknown | Typed child of corpus.entity for kind person. | → `corpus.entity` |
| [`product`](../../relations/corpus/product.md) | table | unknown | — | → `corpus.entity` |
| [`product_feature`](../../relations/corpus/product_feature.md) | table | unknown | — | → `corpus.entity`, → `corpus.product` |
| [`product_version`](../../relations/corpus/product_version.md) | table | unknown | — | → `corpus.entity`, → `corpus.product` |
| [`registry`](../../relations/corpus/registry.md) | table | unknown | — | → `corpus.entity` |
| [`registry_listing`](../../relations/corpus/registry_listing.md) | table | unknown | — | → `corpus.entity`, → `corpus.registry` |
| [`relationship`](../../relations/corpus/relationship.md) | table | unknown | One edge table; kinds constrain endpoints and may be temporal. | → `corpus.entity`, → `taxonomy.relationship_kind`, → `evidence.claim` |
| [`repository`](../../relations/corpus/repository.md) | table | unknown | — | → `corpus.entity` |
| [`repository_file`](../../relations/corpus/repository_file.md) | table | unknown | — | → `evidence.source_capture`, → `corpus.repository_module`, → `corpus.repository`, → `corpus.repository_revision` |
| [`repository_module`](../../relations/corpus/repository_module.md) | table | unknown | — | → `corpus.repository_revision`, → `corpus.library`, → `corpus.repository` |
| [`repository_revision`](../../relations/corpus/repository_revision.md) | table | unknown | — | → `evidence.source_capture`, → `corpus.repository`, → `orchestration.artifact` |
| [`security_advisory`](../../relations/corpus/security_advisory.md) | table | unknown | — | → `corpus.entity` |
| [`story`](../../relations/corpus/story.md) | table | unknown | — | → `corpus.entity` |
| [`talk`](../../relations/corpus/talk.md) | table | unknown | — | → `corpus.entity` |
| [`technique`](../../relations/corpus/technique.md) | table | unknown | — | → `corpus.entity` |

Functions: [`check_receipt_tenant`](../../functions/corpus/check_receipt_tenant.md), [`check_relationship_kinds`](../../functions/corpus/check_relationship_kinds.md), [`check_relationship_properties`](../../functions/corpus/check_relationship_properties.md), [`check_repository_lineage`](../../functions/corpus/check_repository_lineage.md), [`import_research_starter_catalog`](../../functions/corpus/import_research_starter_catalog.md), [`rebuild_entity_projections`](../../functions/corpus/rebuild_entity_projections.md).

Types: [`types/corpus.md`](../../types/corpus.md).

Vocabularies: [`distribution_kind`](../../vocabularies/corpus.distribution_kind.md), [`license`](../../vocabularies/corpus.license.md), [`media_platform`](../../vocabularies/corpus.media_platform.md).
