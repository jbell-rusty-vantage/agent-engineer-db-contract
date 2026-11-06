---
id: "sch:content"
kind: schema
name: content
domains: [content]
relations: 18
functions: 5
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# content

Immutable authored-work identity, representations, structural nodes, transformations and conversion evaluation. Domains: [`content`](../../domains/content.md).

| Relation | Kind | Rows | Summary | Key edges |
| --- | --- | --- | --- | --- |
| [`conversion_evaluation`](../../relations/content/conversion_evaluation.md) | table | unknown | — | → `orchestration.artifact`, → `content.document_representation` |
| [`conversion_finding`](../../relations/content/conversion_finding.md) | table | unknown | — | → `evidence.locator`, → `content.conversion_evaluation`, → `orchestration.artifact`, → `content.document_node` |
| [`document`](../../relations/content/document.md) | table | unknown | — | → `content.document_type`, → `corpus.repository_file`, → `evidence.source`, → `orchestration.attempt` |
| [`document_about_entity`](../../relations/content/document_about_entity.md) | table | unknown | — | → `content.document`, → `corpus.entity` |
| [`document_identifier`](../../relations/content/document_identifier.md) | table | unknown | — | → `content.document` |
| [`document_node`](../../relations/content/document_node.md) | table | unknown | — | → `corpus.entity`, → `orchestration.artifact`, → `content.document_representation` |
| [`document_node_edge`](../../relations/content/document_node_edge.md) | table | unknown | — | → `content.document_node` |
| [`document_representation`](../../relations/content/document_representation.md) | table | unknown | — | → `orchestration.artifact`, → `content.document_version`, → `content.transformation_run` |
| [`document_summary`](../../relations/content/document_summary.md) | table | unknown | — | → `content.document_representation`, → `content.document_version`, → `corpus.entity`, → `content.document_node` |
| [`document_summary_source`](../../relations/content/document_summary_source.md) | table | unknown | — | → `content.document_node`, → `content.document_summary` |
| [`document_type`](../../relations/content/document_type.md) | table | small | — | → `taxonomy.entity_kind` |
| [`document_version`](../../relations/content/document_version.md) | table | unknown | — | → `content.document` |
| [`document_version_source_capture`](../../relations/content/document_version_source_capture.md) | table | unknown | — | → `content.document_version`, → `evidence.source_capture` |
| [`representation_decision`](../../relations/content/representation_decision.md) | table | unknown | — | → `knowledge_service.operation`, → `knowledge_service.review_decision`, → `content.conversion_evaluation`, → `content.document_representation` |
| [`transformation_input`](../../relations/content/transformation_input.md) | table | unknown | — | → `orchestration.artifact`, → `content.document_representation`, → `evidence.source_capture`, → `content.transformation_run` |
| [`transformation_kind`](../../relations/content/transformation_kind.md) | table | unknown | — | — |
| [`transformation_output`](../../relations/content/transformation_output.md) | table | unknown | — | → `orchestration.artifact`, → `content.document_representation`, → `content.transformation_run` |
| [`transformation_run`](../../relations/content/transformation_run.md) | table | unknown | — | → `orchestration.capability_version`, → `orchestration.attempt`, → `content.transformation_kind` |

Functions: [`check_document_work`](../../functions/content/check_document_work.md), [`check_summary_lineage`](../../functions/content/check_summary_lineage.md), [`check_summary_sources`](../../functions/content/check_summary_sources.md), [`guard_summary_content`](../../functions/content/guard_summary_content.md), [`guard_terminal_transformation`](../../functions/content/guard_terminal_transformation.md).

Types: none.

Vocabularies: [`document_type`](../../vocabularies/content.document_type.md).
