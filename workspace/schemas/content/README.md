---
id: "sch:content"
kind: schema
name: content
lens: corpus
domains: [content]
relations: 30
functions: 8
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# content

Immutable authored-work identity, representations, structural nodes, transformations and conversion evaluation. Lens `corpus`. Domains: [`content`](../../domains/content.md).

| Relation | Kind | Rows | Summary | Key edges |
| --- | --- | --- | --- | --- |
| [`conversion_evaluation`](../../relations/content/conversion_evaluation.md) | table | unknown | — | → `orchestration.artifact`, → `content.document_representation` |
| [`conversion_finding`](../../relations/content/conversion_finding.md) | table | unknown | — | → `evidence.locator`, → `content.conversion_evaluation`, → `orchestration.artifact`, → `content.document_node` |
| [`digest_item`](../../relations/content/digest_item.md) | table | medium | One digest item — key point, entity role, assertion reference, change, open question, lim… | → `evidence.claim`, → `content.document_digest`, → `catalog.entity`, → `content.unit_change` |
| [`document`](../../relations/content/document.md) | table | small | Identity of a captured work; typed open-world (document_type_code is the initial kind), w… | → `content.document_type`, → `content.source_role`, → `evidence.source`, → `orchestration.attempt` |
| [`document_about_entity`](../../relations/content/document_about_entity.md) | table | small | — | → `content.document`, → `catalog.entity` |
| [`document_digest`](../../relations/content/document_digest.md) | table | small | Structured digest of a version (or section/entity view); items are records anchored to un… | → `catalog.entity`, → `content.document_version`, → `content.document_node`, → `content.transformation_run` |
| [`document_identifier`](../../relations/content/document_identifier.md) | table | unknown | — | → `content.document` |
| [`document_kind_assignment`](../../relations/content/document_kind_assignment.md) | table | small | Append-only kind assignments of a document; the current one has superseded_by_id null. | → `content.document_type`, → `content.document` |
| [`document_node`](../../relations/content/document_node.md) | table | medium | A typed unit of a representation — unit_kind from the grammar, validated attributes, a lo… | → `catalog.entity`, → `orchestration.artifact`, → `content.document_representation`, → `content.unit_kind` |
| [`document_node_edge`](../../relations/content/document_node_edge.md) | table | unknown | — | → `content.document_node` |
| [`document_representation`](../../relations/content/document_representation.md) | table | small | — | → `orchestration.artifact`, → `content.document_version`, → `content.transformation_run` |
| [`document_summary`](../../relations/content/document_summary.md) | table | unknown | Prose rendering of a digest for an audience; never evidence by itself. | → `content.document_representation`, → `content.document_digest`, → `content.document_version`, → `catalog.entity` |
| [`document_summary_source`](../../relations/content/document_summary_source.md) | table | unknown | — | → `content.document_node`, → `content.document_summary` |
| [`document_type`](../../relations/content/document_type.md) | table | unknown | — | → `taxonomy.entity_kind` |
| [`document_version`](../../relations/content/document_version.md) | table | small | — | → `content.format`, → `content.document` |
| [`document_version_source_capture`](../../relations/content/document_version_source_capture.md) | table | small | — | → `content.document_version`, → `evidence.source_capture` |
| [`format`](../../relations/content/format.md) | table | unknown | Media/format axis of a captured version; decides the parser and the locator kinds. | — |
| [`refresh_check`](../../relations/content/refresh_check.md) | table | unknown | Each refresh of a document — unchanged (same bytes), changed (new version) or failed — wr… | → `acquisition.fetch`, → `content.document`, → `content.document_version` |
| [`representation_decision`](../../relations/content/representation_decision.md) | table | unknown | — | → `knowledge_service.operation`, → `knowledge_service.review_decision`, → `content.conversion_evaluation`, → `content.document_representation` |
| [`source_role`](../../relations/content/source_role.md) | table | unknown | Who speaks — first party about itself, filer, academic, registry, third-party editorial, … | — |
| [`structure_census`](../../relations/content/structure_census.md) | table | small | What a representation structurally contains before a kind or grammar is assigned; promoti… | → `content.format`, → `content.document_representation` |
| [`transformation_input`](../../relations/content/transformation_input.md) | table | unknown | — | → `orchestration.artifact`, → `content.document_representation`, → `evidence.source_capture`, → `content.transformation_run` |
| [`transformation_kind`](../../relations/content/transformation_kind.md) | table | unknown | — | — |
| [`transformation_output`](../../relations/content/transformation_output.md) | table | unknown | — | → `orchestration.artifact`, → `content.document_representation`, → `content.transformation_run` |
| [`transformation_run`](../../relations/content/transformation_run.md) | table | unknown | — | → `orchestration.capability_version`, → `orchestration.attempt`, → `content.transformation_kind` |
| [`unit_assertion_mapping`](../../relations/content/unit_assertion_mapping.md) | table | unknown | Declarative act 3 — how a unit kind's attributes become an assertion (stream kind, relati… | → `content.document_type`, → `temporal.event_kind`, → `taxonomy.relationship_kind`, → `content.source_role` |
| [`unit_change`](../../relations/content/unit_change.md) | table | small | Unit-level diff between two versions matched by logical_key; drives update proposals for … | → `content.refresh_check`, → `content.document`, → `content.document_node`, → `content.document_version` |
| [`unit_entity_role`](../../relations/content/unit_entity_role.md) | table | medium | Which entity a unit is about and in what role from the unit kind's role vocabulary; ancho… | → `evidence.claim`, → `catalog.entity`, → `content.document_node` |
| [`unit_kind`](../../relations/content/unit_kind.md) | table | unknown | Grammar as data — the typed units a document kind decomposes into, with JSON Schema, logi… | — |
| [`unit_link`](../../relations/content/unit_link.md) | table | medium | R4: typed edge between two units (a docs section documents an api_symbol; a slide cites a… | → `content.document_node` |

Functions: [`check_document_work`](../../functions/content/check_document_work.md), [`check_summary_lineage`](../../functions/content/check_summary_lineage.md), [`check_summary_sources`](../../functions/content/check_summary_sources.md), [`current_kind`](../../functions/content/current_kind.md), [`guard_summary_content`](../../functions/content/guard_summary_content.md), [`guard_terminal_transformation`](../../functions/content/guard_terminal_transformation.md), [`validate_unit_attributes`](../../functions/content/validate_unit_attributes.md), [`validate_unit_entity_role`](../../functions/content/validate_unit_entity_role.md).

Types: none.

Vocabularies: [`document_type`](../../vocabularies/content.document_type.md), [`format`](../../vocabularies/content.format.md), [`source_role`](../../vocabularies/content.source_role.md), [`unit_kind`](../../vocabularies/content.unit_kind.md).
