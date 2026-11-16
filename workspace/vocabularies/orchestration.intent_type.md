---
id: "voc:orchestration.intent_type"
kind: vocabulary
schema: orchestration
name: intent_type
rows: 16
rows_sha256: "sha256:f5783103b6978c5c22219d6e1f213274f92b7a012e2f7aac9ccd6fc04a0d8aed"
codes: [assign_taxonomy_term, claim_verification, content_link, governed_chain_write, ingest_research_bundle, knowledge_ingestion, link_entities, merge_entities, promote_candidate, publish_report, record_claim, record_metric_observations, retract_record, upsert_entity, upsert_knowledge, verify_claim]
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# orchestration.intent_type

Reference data snapshot (16 rows, digest `sha256:f5783103b6978c5c22219d6e1f213274f92b7a012e2f7aac9ccd6fc04a0d8aed`). Codes are enforced wherever a column has a foreign key to [`orchestration.intent_type`](../relations/orchestration/intent_type.md).

| code | description | schema_version |
| --- | --- | --- |
| `assign_taxonomy_term` | Assign a taxonomy term to a target | 1 |
| `claim_verification` | Verify an existing claim under a Knowledge Services admitted exact-use decision (verification.record_admitted_claim_ver… | 1 |
| `content_link` | content-link-intent.v1: evidence-backed canonical document, chunk, summary and projection links | 1 |
| `governed_chain_write` | A write of the research verification chain made through a governed api function (api.record_claim, api.restate_claim, a… | 1 |
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
