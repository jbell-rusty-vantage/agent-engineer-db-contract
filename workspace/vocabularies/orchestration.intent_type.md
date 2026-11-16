---
id: "voc:orchestration.intent_type"
kind: vocabulary
schema: orchestration
name: intent_type
rows: 15
rows_sha256: "sha256:afa462af44ac0c65a020e94fc08a843a309a4758344d053b2e25bb1b13461b31"
codes: [assign_taxonomy_term, claim_verification, content_link, ingest_research_bundle, knowledge_ingestion, link_entities, merge_entities, promote_candidate, publish_report, record_claim, record_metric_observations, retract_record, upsert_entity, upsert_knowledge, verify_claim]
workspace_fingerprint: "sha256:94ffe6a458de74a3cfebdee4fb31f371d14c89d7eaa16cfe1ab1cae9dc94743b"
---
# orchestration.intent_type

Reference data snapshot (15 rows, digest `sha256:afa462af44ac0c65a020e94fc08a843a309a4758344d053b2e25bb1b13461b31`). Codes are enforced wherever a column has a foreign key to [`orchestration.intent_type`](../relations/orchestration/intent_type.md).

| code | description | schema_version |
| --- | --- | --- |
| `assign_taxonomy_term` | Assign a taxonomy term to a target | 1 |
| `claim_verification` | Verify an existing claim under a Knowledge Services admitted exact-use decision (verification.record_admitted_claim_ver… | 1 |
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
