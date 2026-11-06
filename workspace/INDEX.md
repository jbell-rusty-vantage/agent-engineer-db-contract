---
id: index
kind: entry
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
migration_head: "20261031010000"
---
# Index

## Domains

| Domain | Schemas | #Relations | #Functions | Start with |
| --- | --- | ---: | ---: | --- |
| [api-surface](domains/api-surface.md) | api | 8 | 25 | [`domains/api-surface.md`](domains/api-surface.md) |
| [content](domains/content.md) | content | 18 | 5 | [`domains/content.md`](domains/content.md) |
| [curriculum](domains/curriculum.md) | curriculum | 13 | 1 | [`domains/curriculum.md`](domains/curriculum.md) |
| [evaluation](domains/evaluation.md) | evaluation | 30 | 20 | [`domains/evaluation.md`](domains/evaluation.md) |
| [evidence](domains/evidence.md) | evidence | 26 | 11 | [`domains/evidence.md`](domains/evidence.md), [`tasks/admit-support-for-claim.md`](tasks/admit-support-for-claim.md), [`tasks/build-evidence-packet.md`](tasks/build-evidence-packet.md) |
| [identity](domains/identity.md) | corpus, taxonomy | 50 | 5 | [`domains/identity.md`](domains/identity.md), [`tasks/compose-ingestion-intent.md`](tasks/compose-ingestion-intent.md), [`tasks/find-entity-by-identifier.md`](tasks/find-entity-by-identifier.md) |
| [knowledge-records](domains/knowledge-records.md) | knowledge | 13 | 0 | [`domains/knowledge-records.md`](domains/knowledge-records.md) |
| [knowledge-service-runtime](domains/knowledge-service-runtime.md) | knowledge_service | 15 | 11 | [`domains/knowledge-service-runtime.md`](domains/knowledge-service-runtime.md) |
| [observability](domains/observability.md) | observability | 7 | 0 | [`domains/observability.md`](domains/observability.md) |
| [orchestration-ledger](domains/orchestration-ledger.md) | orchestration | 37 | 49 | [`domains/orchestration-ledger.md`](domains/orchestration-ledger.md), [`tasks/publish-report.md`](tasks/publish-report.md), [`tasks/register-report.md`](tasks/register-report.md) |
| [provenance](domains/provenance.md) | provenance | 4 | 0 | [`domains/provenance.md`](domains/provenance.md) |
| [ranking](domains/ranking.md) | ranking | 16 | 0 | [`domains/ranking.md`](domains/ranking.md) |
| [relationships](domains/relationships.md) | corpus, taxonomy | 10 | 3 | [`domains/relationships.md`](domains/relationships.md), [`tasks/assert-relationship.md`](tasks/assert-relationship.md), [`tasks/compose-ingestion-intent.md`](tasks/compose-ingestion-intent.md) |
| [research](domains/research.md) | research | 17 | 1 | [`domains/research.md`](domains/research.md), [`tasks/navigate-report.md`](tasks/navigate-report.md), [`tasks/publish-report.md`](tasks/publish-report.md) |
| [research-starter-protected](domains/research-starter-protected.md) | public | 41 | 21 | [`domains/research-starter-protected.md`](domains/research-starter-protected.md) |
| [research-v2](domains/research-v2.md) | research | 4 | 8 | [`domains/research-v2.md`](domains/research-v2.md) |
| [retrieval](domains/retrieval.md) | retrieval | 37 | 26 | [`domains/retrieval.md`](domains/retrieval.md), [`tasks/build-evidence-packet.md`](tasks/build-evidence-packet.md), [`tasks/run-hybrid-search.md`](tasks/run-hybrid-search.md) |
| [staging](domains/staging.md) | staging | 4 | 0 | [`domains/staging.md`](domains/staging.md), [`tasks/compose-ingestion-intent.md`](tasks/compose-ingestion-intent.md), [`tasks/resolve-or-create-entity.md`](tasks/resolve-or-create-entity.md) |
| [temporal-facts](domains/temporal-facts.md) | temporal | 9 | 13 | [`domains/temporal-facts.md`](domains/temporal-facts.md), [`tasks/admit-support-for-claim.md`](tasks/admit-support-for-claim.md), [`tasks/check-knowledge-head.md`](tasks/check-knowledge-head.md) |

## Schemas

| Schema | #Relations | #Functions | Default domain |
| --- | ---: | ---: | --- |
| [`api`](schemas/api/README.md) | 8 | 19 | api-surface |
| [`content`](schemas/content/README.md) | 18 | 5 | content |
| [`corpus`](schemas/corpus/README.md) | 51 | 6 | identity |
| [`curriculum`](schemas/curriculum/README.md) | 13 | 1 | curriculum |
| [`evaluation`](schemas/evaluation/README.md) | 30 | 20 | evaluation |
| [`evidence`](schemas/evidence/README.md) | 26 | 9 | evidence |
| [`knowledge`](schemas/knowledge/README.md) | 13 | 0 | knowledge-records |
| [`knowledge_service`](schemas/knowledge_service/README.md) | 15 | 10 | knowledge-service-runtime |
| [`observability`](schemas/observability/README.md) | 7 | 0 | observability |
| [`orchestration`](schemas/orchestration/README.md) | 37 | 48 | orchestration-ledger |
| [`provenance`](schemas/provenance/README.md) | 4 | 0 | provenance |
| [`public`](schemas/public/README.md) | 41 | 3 | research-starter-protected |
| [`ranking`](schemas/ranking/README.md) | 16 | 0 | ranking |
| [`research`](schemas/research/README.md) | 21 | 9 | research |
| [`research_private`](schemas/research_private/README.md) | 0 | 17 | research-starter-protected |
| [`retrieval`](schemas/retrieval/README.md) | 37 | 26 | retrieval |
| [`staging`](schemas/staging/README.md) | 4 | 0 | staging |
| [`taxonomy`](schemas/taxonomy/README.md) | 9 | 2 | relationships |
| [`temporal`](schemas/temporal/README.md) | 9 | 17 | temporal-facts |
| [`util`](schemas/util/README.md) | 0 | 7 | api-surface |

Counts at head `20261031010000`: 359 relations (child partitions folded into their parents), 199 function overloads, 19 tasks, 33 named queries. Vocabularies: [`content.document_type`](vocabularies/content.document_type.md), [`corpus.distribution_kind`](vocabularies/corpus.distribution_kind.md), [`corpus.license`](vocabularies/corpus.license.md), [`corpus.media_platform`](vocabularies/corpus.media_platform.md), [`evidence.capture_method`](vocabularies/evidence.capture_method.md), [`evidence.search_provider`](vocabularies/evidence.search_provider.md), [`orchestration.artifact_type`](vocabularies/orchestration.artifact_type.md), [`orchestration.intent_type`](vocabularies/orchestration.intent_type.md), [`taxonomy.entity_kind`](vocabularies/taxonomy.entity_kind.md), [`taxonomy.relationship_kind`](vocabularies/taxonomy.relationship_kind.md), [`temporal.event_kind`](vocabularies/temporal.event_kind.md), [`temporal.stream_kind`](vocabularies/temporal.stream_kind.md).
