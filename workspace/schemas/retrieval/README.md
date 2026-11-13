---
id: "sch:retrieval"
kind: schema
name: retrieval
lens: corpus
domains: [retrieval]
relations: 37
functions: 35
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
---
# retrieval

Vector spaces, vector catalog, retrieval plans/runs, evidence packets. Lens `corpus`. Domains: [`retrieval`](../../domains/retrieval.md).

| Relation | Kind | Rows | Summary | Key edges |
| --- | --- | --- | --- | --- |
| [`authorized_publication_execution`](../../relations/retrieval/authorized_publication_execution.md) | table | unknown | — | → `retrieval.publication_switch_receipt`, → `knowledge_service.operation` |
| [`chunk_claim_link`](../../relations/retrieval/chunk_claim_link.md) | table | unknown | — | → `retrieval.retrieval_chunk`, → `evidence.claim` |
| [`chunk_edge`](../../relations/retrieval/chunk_edge.md) | table | unknown | — | → `retrieval.retrieval_chunk` |
| [`chunk_entity_mention`](../../relations/retrieval/chunk_entity_mention.md) | table | unknown | — | → `retrieval.retrieval_chunk`, → `catalog.entity` |
| [`chunk_relationship_evidence`](../../relations/retrieval/chunk_relationship_evidence.md) | table | unknown | — | → `retrieval.retrieval_chunk`, → `catalog.relationship` |
| [`chunk_set`](../../relations/retrieval/chunk_set.md) | table | unknown | — | → `retrieval.chunking_procedure_version`, → `content.document_representation` |
| [`chunk_span`](../../relations/retrieval/chunk_span.md) | table | unknown | — | → `evidence.locator`, → `retrieval.retrieval_chunk`, → `content.document_node` |
| [`chunking_procedure_version`](../../relations/retrieval/chunking_procedure_version.md) | table | unknown | — | → `orchestration.capability_version` |
| [`content_promotion_decision`](../../relations/retrieval/content_promotion_decision.md) | table | unknown | — | → `knowledge_service.operation`, → `knowledge_service.review_decision`, → `retrieval.content_promotion_proposal` |
| [`content_promotion_proposal`](../../relations/retrieval/content_promotion_proposal.md) | table | unknown | — | → `knowledge_service.operation` |
| [`embedding_item`](../../relations/retrieval/embedding_item.md) | table | unknown | — | → `retrieval.embedding_run`, → `retrieval.search_projection` |
| [`embedding_run`](../../relations/retrieval/embedding_run.md) | table | unknown | — | → `knowledge_service.operation`, → `retrieval.content_promotion_decision`, → `retrieval.vector_space_version` |
| [`evidence_packet`](../../relations/retrieval/evidence_packet.md) | table | unknown | Assembled evidence bundle for one question. | → `orchestration.artifact`, → `retrieval.retrieval_run` |
| [`packet_member`](../../relations/retrieval/packet_member.md) | table | unknown | One member of an evidence packet — a verified claim, a guidance item or a source-faithful… | → `evidence.claim`, → `guidance.item`, → `retrieval.evidence_packet`, → `retrieval.search_projection` |
| [`projection_procedure`](../../relations/retrieval/projection_procedure.md) | table | unknown | — | — |
| [`projection_target`](../../relations/retrieval/projection_target.md) | table | medium | What a search projection is about — exactly one of entity, guidance item, chunk, claim, s… | → `authoring.work_revision`, → `retrieval.retrieval_chunk`, → `evidence.claim`, → `content.document_digest` |
| [`publication_switch_receipt`](../../relations/retrieval/publication_switch_receipt.md) | table | unknown | — | → `retrieval.space_publication`, → `retrieval.vector_store_space` |
| [`retrieval_candidate`](../../relations/retrieval/retrieval_candidate.md) | table | unknown | — | → `retrieval.retrieval_run`, → `retrieval.vector_item` |
| [`retrieval_candidate_source`](../../relations/retrieval/retrieval_candidate_source.md) | table | unknown | — | → `retrieval.retrieval_candidate`, → `retrieval.search_projection`, → `retrieval.vector_item` |
| [`retrieval_chunk`](../../relations/retrieval/retrieval_chunk.md) | table | unknown | — | → `retrieval.chunk_set` |
| [`retrieval_plan`](../../relations/retrieval/retrieval_plan.md) | table | unknown | — | → `orchestration.attempt` |
| [`retrieval_policy`](../../relations/retrieval/retrieval_policy.md) | table | unknown | — | — |
| [`retrieval_policy_version`](../../relations/retrieval/retrieval_policy_version.md) | table | unknown | — | → `retrieval.retrieval_policy` |
| [`retrieval_run`](../../relations/retrieval/retrieval_run.md) | table | unknown | — | → `knowledge_service.operation`, → `retrieval.retrieval_plan` |
| [`search_projection`](../../relations/retrieval/search_projection.md) | table | medium | Derived text projection that a vector item points at. | → `retrieval.projection_procedure`, → `retrieval.content_promotion_decision`, → `retrieval.projection_target`, → `content.representation_decision` |
| [`search_projection_chunk_support`](../../relations/retrieval/search_projection_chunk_support.md) | table | unknown | Typed, immutable faithful/atomic support for a purpose-specific search projection. | → `retrieval.search_projection`, → `evidence.locator`, → `retrieval.retrieval_chunk` |
| [`space_publication`](../../relations/retrieval/space_publication.md) | table | unknown | Published vector-space version that search may read. | → `evaluation.promotion_gate_result`, → `knowledge_service.operation`, → `retrieval.content_promotion_decision`, → `retrieval.vector_space_version` |
| [`vector_item`](../../relations/retrieval/vector_item.md) | table | medium | One searchable item in one space version with lens, source tier and facets; the one thing… | → `content.document_type`, → `retrieval.embedding_item`, → `evaluation.eval_run`, → `retrieval.search_projection` |
| [`vector_item_embedding_1536`](../../relations/retrieval/vector_item_embedding_1536.md) | partitioned table | unknown | Canonical fixed-dimension pgvector storage; legacy vector_item.embedding is compatibility… | → `retrieval.vector_item`, → `retrieval.vector_space_version` |
| [`vector_space`](../../relations/retrieval/vector_space.md) | table | unknown | Named embedding space (units, digests, entity_cards, assertions, own_content, learner_not… | — |
| [`vector_space_version`](../../relations/retrieval/vector_space_version.md) | table | unknown | Immutable version of a vector space, including dims and publication lifecycle. | → `retrieval.projection_procedure`, → `evaluation.eval_run`, → `retrieval.vector_space` |
| [`vector_store`](../../relations/retrieval/vector_store.md) | table | unknown | — | → `knowledge_service.operation`, → `orchestration.attempt` |
| [`vector_store_document`](../../relations/retrieval/vector_store_document.md) | table | unknown | — | → `knowledge_service.operation`, → `content.document`, → `content.document_version`, → `content.document_representation` |
| [`vector_store_ingestion_checkpoint`](../../relations/retrieval/vector_store_ingestion_checkpoint.md) | table | unknown | — | → `retrieval.vector_store_ingestion_run` |
| [`vector_store_ingestion_run`](../../relations/retrieval/vector_store_ingestion_run.md) | table | unknown | — | → `knowledge_service.operation`, → `retrieval.vector_store` |
| [`vector_store_lifecycle_event`](../../relations/retrieval/vector_store_lifecycle_event.md) | table | unknown | — | → `retrieval.vector_store` |
| [`vector_store_space`](../../relations/retrieval/vector_store_space.md) | table | unknown | — | → `retrieval.vector_space_version`, → `retrieval.vector_space`, → `retrieval.vector_store` |

Functions: [`claim_history_witnesses`](../../functions/retrieval/claim_history_witnesses.md), [`enforce_canonical_source`](../../functions/retrieval/enforce_canonical_source.md), [`enforce_evidence_gate`](../../functions/retrieval/enforce_evidence_gate.md), [`evidence_signal`](../../functions/retrieval/evidence_signal.md), [`guard_space_publication`](../../functions/retrieval/guard_space_publication.md), [`guard_terminal_status`](../../functions/retrieval/guard_terminal_status.md), [`guard_vector_store_lifecycle_transition`](../../functions/retrieval/guard_vector_store_lifecycle_transition.md), [`guard_vector_store_space_pointer`](../../functions/retrieval/guard_vector_store_space_pointer.md), [`history_claim_authorized`](../../functions/retrieval/history_claim_authorized.md), [`history_projection_matches`](../../functions/retrieval/history_projection_matches.md), [`history_publication_authorized`](../../functions/retrieval/history_publication_authorized.md), [`history_receipt_k`](../../functions/retrieval/history_receipt_k.md), [`history_representation_authorized`](../../functions/retrieval/history_representation_authorized.md), [`history_world_matches`](../../functions/retrieval/history_world_matches.md), [`index_text_item`](../../functions/retrieval/index_text_item.md), [`on_release_item_promote`](../../functions/retrieval/on_release_item_promote.md), [`project_entity_timeline`](../../functions/retrieval/project_entity_timeline.md), [`promote_release_passages`](../../functions/retrieval/promote_release_passages.md), [`promote_revision_passages`](../../functions/retrieval/promote_revision_passages.md), [`publish_vector_space`](../../functions/retrieval/publish_vector_space.md), [`reject_new_legacy_governance_provenance`](../../functions/retrieval/reject_new_legacy_governance_provenance.md), [`reject_vector_store_document_identity_mutation`](../../functions/retrieval/reject_vector_store_document_identity_mutation.md), [`reject_vector_store_identity_mutation`](../../functions/retrieval/reject_vector_store_identity_mutation.md), [`require_active_vector_store_reference`](../../functions/retrieval/require_active_vector_store_reference.md), [`retire_deterministic_digest_items`](../../functions/retrieval/retire_deterministic_digest_items.md), [`retire_items_for_passages`](../../functions/retrieval/retire_items_for_passages.md), [`rollback_vector_space`](../../functions/retrieval/rollback_vector_space.md), [`store_embedding`](../../functions/retrieval/store_embedding.md), [`supersede_duplicate_items`](../../functions/retrieval/supersede_duplicate_items.md), [`transition_vector_store_lifecycle`](../../functions/retrieval/transition_vector_store_lifecycle.md), [`validate_chunk_projection_target`](../../functions/retrieval/validate_chunk_projection_target.md), [`validate_embedding_item`](../../functions/retrieval/validate_embedding_item.md), [`validate_vector_store_ingestion_operation`](../../functions/retrieval/validate_vector_store_ingestion_operation.md), [`validate_vector_store_space_authority`](../../functions/retrieval/validate_vector_store_space_authority.md), [`vector_item_guard`](../../functions/retrieval/vector_item_guard.md).

Types: [`types/retrieval.md`](../../types/retrieval.md).
