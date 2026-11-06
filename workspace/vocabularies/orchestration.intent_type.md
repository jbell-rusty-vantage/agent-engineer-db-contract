---
id: "voc:orchestration.intent_type"
kind: vocabulary
schema: orchestration
name: intent_type
rows: 14
rows_sha256: "sha256:a5eed23f657fe227731cbd11ea12730fbf2a28d226e8f90acef59f1c9a1750ab"
codes: [assign_taxonomy_term, content_link, ingest_research_bundle, knowledge_ingestion, link_entities, merge_entities, promote_candidate, publish_report, record_claim, record_metric_observations, retract_record, upsert_entity, upsert_knowledge, verify_claim]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# orchestration.intent_type

Reference data snapshot (14 rows, digest `sha256:a5eed23f657fe227731cbd11ea12730fbf2a28d226e8f90acef59f1c9a1750ab`). Codes are enforced wherever a column has a foreign key to [`orchestration.intent_type`](../relations/orchestration/intent_type.md).

| code | description | schema_version |
| --- | --- | --- |
| `assign_taxonomy_term` | Assign a taxonomy term to a target | 1 |
| `content_link` | content-link-intent.v1: evidence-backed canonical document, chunk, summary and projection links | 1 |
| `ingest_research_bundle` | Register a verified source bundle, claims, candidates, and report | 1 |
| `knowledge_ingestion` | knowledge-ingestion-intent.v1: evidence-backed proposals applied by the knowledge executor as executor_service | 1 |
| `link_entities` | Create a corpus relationship row | 1 |
| `merge_entities` | Merge two canonical entities | 1 |
| `promote_candidate` | Promote a staging candidate to canonical | 1 |
| `publish_report` | Publish an immutable report version | 1 |
| `record_claim` | Register an evidence claim | 1 |
| `record_metric_observations` | Append source-attributed observations for a canonical entity | 1 |
| `retract_record` | Retract a canonical row or record | 1 |
| `upsert_entity` | Create or update a canonical corpus entity | 1 |
| `upsert_knowledge` | Create or update a knowledge record | 1 |
| `verify_claim` | Record a verification outcome | 1 |
