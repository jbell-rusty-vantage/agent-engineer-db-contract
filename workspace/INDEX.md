---
id: index
kind: entry
workspace_fingerprint: "sha256:216c4ae7230478c8e60934da25c852e10680d6caed71a662962ea3c0ac1676d3"
migration_head: "20261116140000"
---
# Index

Lenses: `ours`, `private`, `corpus`, `evidence`, `machinery`, `legacy`. [MAP.md](MAP.md) shows the visible lenses only; this page lists everything, including `machinery` and `legacy`.

## Domains

| Domain | Lens | Schemas | #Relations | #Functions | Start with |
| --- | --- | --- | ---: | ---: | --- |
| [access](domains/access.md) | ours | access | 7 | 6 | [`domains/access.md`](domains/access.md), [`tasks/search-my-notes.md`](tasks/search-my-notes.md) |
| [acquisition](domains/acquisition.md) | corpus | acquisition | 1 | 0 | [`domains/acquisition.md`](domains/acquisition.md), [`tasks/what-changed-since.md`](tasks/what-changed-since.md) |
| [api-surface](domains/api-surface.md) | corpus | api | 37 | 51 | [`domains/api-surface.md`](domains/api-surface.md), [`tasks/cheapest-qualified-model.md`](tasks/cheapest-qualified-model.md), [`tasks/compare-models.md`](tasks/compare-models.md) |
| [authoring](domains/authoring.md) | ours | api, authoring | 21 | 4 | [`domains/authoring.md`](domains/authoring.md), [`tasks/hand-over-for-review.md`](tasks/hand-over-for-review.md), [`tasks/modules-affected-by-release.md`](tasks/modules-affected-by-release.md) |
| [content](domains/content.md) | corpus | content | 30 | 13 | [`domains/content.md`](domains/content.md), [`tasks/build-evidence-packet.md`](tasks/build-evidence-packet.md), [`tasks/find-stale-facts.md`](tasks/find-stale-facts.md) |
| [curriculum](domains/curriculum.md) | machinery | curriculum | 8 | 0 | [`domains/curriculum.md`](domains/curriculum.md), [`tasks/read-back-saved-revision.md`](tasks/read-back-saved-revision.md) |
| [evaluation](domains/evaluation.md) | machinery | evaluation | 30 | 20 | [`domains/evaluation.md`](domains/evaluation.md) |
| [evidence](domains/evidence.md) | evidence | evidence, verification | 26 | 27 | [`domains/evidence.md`](domains/evidence.md), [`tasks/admit-support-for-claim.md`](tasks/admit-support-for-claim.md), [`tasks/build-evidence-packet.md`](tasks/build-evidence-packet.md) |
| [guidance](domains/guidance.md) | corpus | api, guidance | 5 | 0 | [`domains/guidance.md`](domains/guidance.md), [`tasks/modules-covering-concept.md`](tasks/modules-covering-concept.md), [`tasks/what-do-we-know-about-entity.md`](tasks/what-do-we-know-about-entity.md) |
| [identity](domains/identity.md) | corpus | catalog, taxonomy | 9 | 4 | [`domains/identity.md`](domains/identity.md), [`tasks/compose-ingestion-intent.md`](tasks/compose-ingestion-intent.md), [`tasks/find-entity-by-identifier.md`](tasks/find-entity-by-identifier.md) |
| [inquiry](domains/inquiry.md) | ours | dataset, inquiry | 10 | 7 | [`domains/inquiry.md`](domains/inquiry.md) |
| [knowledge-service-runtime](domains/knowledge-service-runtime.md) | machinery | knowledge_service | 15 | 11 | [`domains/knowledge-service-runtime.md`](domains/knowledge-service-runtime.md) |
| [learning](domains/learning.md) | ours | learning | 14 | 4 | [`domains/learning.md`](domains/learning.md) |
| [legacy](domains/legacy.md) | machinery | — | 0 | 2 | [`domains/legacy.md`](domains/legacy.md) |
| [library](domains/library.md) | private | conversation, library | 10 | 3 | [`domains/library.md`](domains/library.md), [`tasks/search-my-notes.md`](tasks/search-my-notes.md) |
| [observability](domains/observability.md) | machinery | observability | 7 | 0 | [`domains/observability.md`](domains/observability.md) |
| [orchestration-ledger](domains/orchestration-ledger.md) | machinery | orchestration | 37 | 49 | [`domains/orchestration-ledger.md`](domains/orchestration-ledger.md), [`tasks/verify-ingestion-result.md`](tasks/verify-ingestion-result.md), [`tasks/write-verification-chain.md`](tasks/write-verification-chain.md) |
| [product-operations](domains/product-operations.md) | ours | — | 0 | 29 | [`domains/product-operations.md`](domains/product-operations.md) |
| [ranking](domains/ranking.md) | corpus | ranking | 3 | 1 | [`domains/ranking.md`](domains/ranking.md), [`tasks/cheapest-qualified-model.md`](tasks/cheapest-qualified-model.md), [`tasks/compare-models.md`](tasks/compare-models.md) |
| [relationships](domains/relationships.md) | corpus | catalog, taxonomy | 9 | 6 | [`domains/relationships.md`](domains/relationships.md), [`tasks/assert-relationship.md`](tasks/assert-relationship.md), [`tasks/compose-ingestion-intent.md`](tasks/compose-ingestion-intent.md) |
| [retrieval](domains/retrieval.md) | corpus | retrieval | 37 | 34 | [`domains/retrieval.md`](domains/retrieval.md), [`tasks/build-evidence-packet.md`](tasks/build-evidence-packet.md), [`tasks/modules-covering-concept.md`](tasks/modules-covering-concept.md) |
| [source-intelligence](domains/source-intelligence.md) | evidence | acquisition, api, evidence | 6 | 4 | [`domains/source-intelligence.md`](domains/source-intelligence.md), [`tasks/how-trusted-is-source.md`](tasks/how-trusted-is-source.md), [`tasks/run-attention-sweep.md`](tasks/run-attention-sweep.md) |
| [staging](domains/staging.md) | corpus | staging | 4 | 0 | [`domains/staging.md`](domains/staging.md), [`tasks/compose-ingestion-intent.md`](tasks/compose-ingestion-intent.md), [`tasks/resolve-or-create-entity.md`](tasks/resolve-or-create-entity.md) |
| [temporal-facts](domains/temporal-facts.md) | corpus | temporal | 9 | 13 | [`domains/temporal-facts.md`](domains/temporal-facts.md), [`tasks/admit-support-for-claim.md`](tasks/admit-support-for-claim.md), [`tasks/check-knowledge-head.md`](tasks/check-knowledge-head.md) |
| [verified-knowledge](domains/verified-knowledge.md) | evidence | api, evidence, verification | 15 | 11 | [`domains/verified-knowledge.md`](domains/verified-knowledge.md), [`tasks/propose-verdict-from-probe.md`](tasks/propose-verdict-from-probe.md), [`tasks/read-claim-with-evidence.md`](tasks/read-claim-with-evidence.md) |

## Schemas

| Schema | Lens | #Relations | #Functions | Default domain |
| --- | --- | ---: | ---: | --- |
| [`access`](schemas/access/README.md) | ours | 7 | 0 | access |
| [`acquisition`](schemas/acquisition/README.md) | corpus | 3 | 0 | acquisition |
| [`api`](schemas/api/README.md) | corpus | 51 | 68 | api-surface |
| [`authoring`](schemas/authoring/README.md) | ours | 20 | 0 | authoring |
| [`catalog`](schemas/catalog/README.md) | corpus | 9 | 6 | identity |
| [`content`](schemas/content/README.md) | corpus | 30 | 8 | content |
| [`conversation`](schemas/conversation/README.md) | private | 4 | 0 | library |
| [`curriculum`](schemas/curriculum/README.md) | machinery | 8 | 0 | curriculum |
| [`dataset`](schemas/dataset/README.md) | ours | 4 | 0 | inquiry |
| [`evaluation`](schemas/evaluation/README.md) | machinery | 30 | 20 | evaluation |
| [`evidence`](schemas/evidence/README.md) | evidence | 27 | 11 | evidence |
| [`guidance`](schemas/guidance/README.md) | corpus | 4 | 0 | guidance |
| [`inquiry`](schemas/inquiry/README.md) | ours | 6 | 0 | inquiry |
| [`knowledge_service`](schemas/knowledge_service/README.md) | machinery | 15 | 10 | knowledge-service-runtime |
| [`learning`](schemas/learning/README.md) | ours | 14 | 0 | learning |
| [`library`](schemas/library/README.md) | ours | 6 | 0 | library |
| [`observability`](schemas/observability/README.md) | machinery | 7 | 0 | observability |
| [`orchestration`](schemas/orchestration/README.md) | machinery | 37 | 48 | orchestration-ledger |
| [`product`](schemas/product/README.md) | ours | 0 | 51 | product-operations |
| [`public`](schemas/public/README.md) | legacy | 0 | 2 | legacy |
| [`ranking`](schemas/ranking/README.md) | corpus | 3 | 0 | ranking |
| [`retrieval`](schemas/retrieval/README.md) | corpus | 37 | 35 | retrieval |
| [`staging`](schemas/staging/README.md) | corpus | 4 | 0 | staging |
| [`taxonomy`](schemas/taxonomy/README.md) | corpus | 9 | 2 | relationships |
| [`temporal`](schemas/temporal/README.md) | corpus | 9 | 17 | temporal-facts |
| [`util`](schemas/util/README.md) | machinery | 0 | 7 | api-surface |
| [`verification`](schemas/verification/README.md) | evidence | 6 | 14 | evidence |

## Operations

Product operations dispatched by `product.dispatch_*`; call them through `api.product_command` / `api.product_read` / `api.product_worker`. One page each under `ops/`.

| Operation | Dispatcher | Call | Relations touched (best effort) |
| --- | --- | --- | --- |
| [`accept_research`](ops/accept_research.md) | research | `api.product_command` | `authoring.event`, `authoring.work_revision`, `inquiry.acceptance`, `inquiry.obligation` |
| [`add_policy_version`](ops/add_policy_version.md) | worker | `api.product_worker` | `access.policy_version` |
| [`add_support`](ops/add_support.md) | research | `api.product_command` | `authoring.work`, `authoring.work_revision`, `dataset.cell`, `inquiry.assertion`, `inquiry.support` |
| [`adopt_release`](ops/adopt_release.md) | command | `api.product_command` | `authoring.distribution_offer`, `learning.enrollment`, `learning.release_adoption` |
| [`append_message`](ops/append_message.md) | command | `api.product_command` | `authoring.distribution_offer`, `authoring.release_item`, `authoring.work_revision`, `conversation.context_item`, `conversation.context_snapshot`, `conversation.message`, `conversation.thread` |
| [`authorize_processing`](ops/authorize_processing.md) | command | `api.product_command` | `access.guardian_link`, `access.processing_authorization` |
| [`commit_dataset_revision`](ops/commit_dataset_revision.md) | research | `api.product_command` | `dataset.proposal` |
| [`complete_asset`](ops/complete_asset.md) | worker | `api.product_worker` | `orchestration.artifact` |
| [`confirm_removal`](ops/confirm_removal.md) | command | `api.product_command` | `authoring.work_revision`, `learning.evidence_item`, `library.connected_item`, `library.passage`, `library.removal` |
| [`consent_guardian`](ops/consent_guardian.md) | command | `api.product_command` | `access.guardian_link` |
| [`create_client_grant`](ops/create_client_grant.md) | command | `api.product_command` | `access.client_grant` |
| [`create_connection`](ops/create_connection.md) | command | `api.product_command` | `library.connection` |
| [`create_dataset`](ops/create_dataset.md) | research | `api.product_command` | `authoring.work` |
| [`create_thread`](ops/create_thread.md) | command | `api.product_command` | `conversation.thread` |
| [`create_watch`](ops/create_watch.md) | research | `api.product_command` | `authoring.work`, `inquiry.watch` |
| [`create_workspace`](ops/create_workspace.md) | command | `api.product_command` | `authoring.workspace`, `authoring.workspace_member` |
| [`create_work`](ops/create_work.md) | command | `api.product_command` | `authoring.work` |
| [`decide_dataset_change`](ops/decide_dataset_change.md) | research | `api.product_command` | `dataset.cell`, `dataset.proposal`, `dataset.row` |
| [`decide_delivery`](ops/decide_delivery.md) | research | `api.product_command` | `inquiry.acceptance`, `inquiry.delivery`, `inquiry.obligation` |
| [`decide_equivalence`](ops/decide_equivalence.md) | command | `api.product_command` | `learning.enrollment`, `learning.equivalence_request` |
| [`deliver_output`](ops/deliver_output.md) | research | `api.product_command` | `authoring.asset_scope`, `authoring.file_set`, `authoring.work`, `authoring.work_revision`, `inquiry.acceptance`, `inquiry.delivery`, `inquiry.obligation` |
| [`edit_dataset`](ops/edit_dataset.md) | research | `api.product_command` | — |
| [`end_offer`](ops/end_offer.md) | command | `api.product_command` | `authoring.distribution_offer` |
| [`enroll`](ops/enroll.md) | command | `api.product_command` | `authoring.distribution`, `authoring.distribution_offer`, `authoring.work`, `authoring.workspace`, `learning.enrollment` |
| [`ensure_personal_workspace`](ops/ensure_personal_workspace.md) | command | `api.product_command` | — |
| [`finalize_result`](ops/finalize_result.md) | command | `api.product_command` | `learning.assessment_result`, `learning.attempt`, `learning.enrollment`, `learning.submission` |
| [`freeze_release`](ops/freeze_release.md) | command | `api.product_command` | `authoring.event`, `authoring.release`, `authoring.release_item`, `authoring.work`, `authoring.work_revision`, `orchestration.artifact` |
| [`get_acceptance`](ops/get_acceptance.md) | research | `api.product_read` | `inquiry.acceptance`, `inquiry.delivery`, `inquiry.obligation` |
| [`get_dataset_diff`](ops/get_dataset_diff.md) | research | `api.product_read` | `authoring.work`, `authoring.work_revision`, `dataset.cell`, `dataset.proposal`, `dataset.row` |
| [`get_dataset`](ops/get_dataset.md) | research | `api.product_read` | `authoring.work`, `authoring.work_revision`, `inquiry.support` |
| [`get_lesson_view`](ops/get_lesson_view.md) | read | `api.product_read` | `authoring.release_item`, `authoring.revision_binding`, `authoring.revision_block`, `authoring.work`, `authoring.work_revision`, `authoring.workspace` |
| [`get_offer`](ops/get_offer.md) | read | `api.product_read` | `authoring.distribution_offer`, `authoring.release_item` |
| [`get_report`](ops/get_report.md) | research | `api.product_read` | `authoring.revision_binding`, `authoring.revision_block`, `authoring.work`, `authoring.work_revision`, `inquiry.assertion` |
| [`get_result`](ops/get_result.md) | read | `api.product_read` | `learning.assessment_result`, `learning.criterion_result`, `learning.evidence_grant`, `learning.grading_run`, `learning.submission` |
| [`get_revision_structure`](ops/get_revision_structure.md) | authoring | `api.product_read` | `authoring.revision_binding`, `authoring.runtime_requirement`, `authoring.work`, `authoring.work_revision`, `curriculum.outcome`, `curriculum.outcome_alignment`, `curriculum.part`, `curriculum.prerequisite`, `curriculum.requirement`, `curriculum.requirement_option`, `inquiry.assertion` |
| [`get_revision`](ops/get_revision.md) | read | `api.product_read` | `authoring.work_revision` |
| [`get_support`](ops/get_support.md) | research | `api.product_read` | `dataset.cell`, `inquiry.assertion`, `inquiry.support` |
| [`get_thread`](ops/get_thread.md) | read | `api.product_read` | `conversation.message`, `conversation.thread` |
| [`grant_evidence`](ops/grant_evidence.md) | command | `api.product_command` | `access.guardian_link`, `learning.evidence_grant` |
| [`grant_member`](ops/grant_member.md) | command | `api.product_command` | `authoring.workspace_member` |
| [`grant_publisher`](ops/grant_publisher.md) | worker | `api.product_worker` | `authoring.publisher_grant` |
| [`grant_reader`](ops/grant_reader.md) | command | `api.product_command` | `authoring.distribution`, `authoring.distribution_member` |
| [`index_passages`](ops/index_passages.md) | worker | `api.product_worker` | `authoring.release_item`, `library.passage`, `library.preparation` |
| [`invite_guardian`](ops/invite_guardian.md) | command | `api.product_command` | `access.guardian_link` |
| [`issue_provided_credential`](ops/issue_provided_credential.md) | worker | `api.product_worker` | `access.provided_credential` |
| [`list_library`](ops/list_library.md) | read | `api.product_read` | `authoring.distribution`, `authoring.distribution_offer` |
| [`list_reviews`](ops/list_reviews.md) | authoring | `api.product_read` | `authoring.event`, `authoring.work`, `authoring.work_revision`, `conversation.message`, `conversation.thread` |
| [`list_watches`](ops/list_watches.md) | research | `api.product_read` | `inquiry.acceptance`, `inquiry.watch` |
| [`list_workspaces`](ops/list_workspaces.md) | authoring | `api.product_read` | `authoring.workspace`, `authoring.workspace_member` |
| [`list_works`](ops/list_works.md) | read | `api.product_read` | `authoring.work` |
| [`mark_ready_for_review`](ops/mark_ready_for_review.md) | authoring | `api.product_command` | `authoring.event`, `authoring.work_revision`, `conversation.message`, `conversation.thread` |
| [`offer_release`](ops/offer_release.md) | command | `api.product_command` | `authoring.distribution`, `authoring.distribution_offer`, `authoring.event`, `authoring.publisher_grant`, `authoring.release`, `orchestration.artifact` |
| [`open_appeal`](ops/open_appeal.md) | command | `api.product_command` | `learning.appeal`, `learning.assessment_result`, `learning.submission` |
| [`open_distribution`](ops/open_distribution.md) | command | `api.product_command` | `authoring.distribution` |
| [`preview_exposure`](ops/preview_exposure.md) | read | `api.product_read` | `authoring.work_revision` |
| [`preview_removal`](ops/preview_removal.md) | command | `api.product_command` | `authoring.distribution_offer`, `authoring.release_item`, `authoring.revision_binding`, `authoring.work`, `authoring.work_revision`, `conversation.context_item`, `learning.evidence_item`, `library.passage`, `library.removal` |
| [`progress`](ops/progress.md) | read | `api.product_read` | `authoring.distribution_offer`, `authoring.release_item`, `curriculum.requirement`, `learning.credit`, `learning.enrollment`, `learning.evidence_grant`, `learning.release_adoption` |
| [`propose_dataset_change`](ops/propose_dataset_change.md) | research | `api.product_command` | `dataset.cell`, `dataset.field`, `dataset.proposal`, `dataset.row` |
| [`propose_equivalence`](ops/propose_equivalence.md) | command | `api.product_command` | `authoring.work_revision`, `learning.enrollment`, `learning.equivalence_request` |
| [`propose_research`](ops/propose_research.md) | research | `api.product_command` | `authoring.event`, `authoring.work`, `authoring.work_revision` |
| [`record_deployment`](ops/record_deployment.md) | command | `api.product_command` | `authoring.deployment` |
| [`record_embeddings`](ops/record_embeddings.md) | worker | `api.product_worker` | `authoring.work_revision`, `library.passage`, `library.resource_control`, `retrieval.projection_target`, `retrieval.vector_item` |
| [`record_equivalence_check`](ops/record_equivalence_check.md) | worker | `api.product_worker` | `learning.equivalence_request` |
| [`record_grading`](ops/record_grading.md) | worker | `api.product_worker` | `authoring.work_revision`, `learning.assessment_result`, `learning.criterion_result`, `learning.grading_run`, `learning.submission`, `orchestration.artifact` |
| [`register_asset`](ops/register_asset.md) | command | `api.product_command` | `orchestration.artifact` |
| [`register_file_set`](ops/register_file_set.md) | command | `api.product_command` | `authoring.asset_scope`, `authoring.file_set`, `authoring.file_set_entry`, `orchestration.artifact` |
| [`request_environment`](ops/request_environment.md) | command | `api.product_command` | `access.provided_credential`, `learning.environment_session` |
| [`resolve_appeal`](ops/resolve_appeal.md) | command | `api.product_command` | `learning.appeal`, `learning.assessment_result`, `learning.attempt`, `learning.enrollment`, `learning.submission` |
| [`restrict_source`](ops/restrict_source.md) | worker | `api.product_worker` | `access.source_restriction` |
| [`review_revision`](ops/review_revision.md) | command | `api.product_command` | `authoring.publisher_grant` |
| [`revise_work`](ops/revise_work.md) | command | `api.product_command` | `authoring.work` |
| [`revoke_asset`](ops/revoke_asset.md) | command | `api.product_command` | `authoring.asset_scope` |
| [`revoke_client_grant`](ops/revoke_client_grant.md) | command | `api.product_command` | `access.client_grant` |
| [`revoke_member`](ops/revoke_member.md) | command | `api.product_command` | `authoring.workspace_member` |
| [`search`](ops/search.md) | read | `api.product_read` | `authoring.asset_scope`, `authoring.distribution_offer`, `authoring.release_item`, `authoring.work`, `authoring.work_revision`, `authoring.workspace_member`, `conversation.message`, `conversation.thread`, `library.passage`, `library.resource_control` |
| [`set_acceptance_state`](ops/set_acceptance_state.md) | research | `api.product_command` | `inquiry.acceptance`, `inquiry.delivery`, `inquiry.obligation` |
| [`set_account_profile`](ops/set_account_profile.md) | worker | `api.product_worker` | `access.account_profile` |
| [`set_control`](ops/set_control.md) | command | `api.product_command` | `library.resource_control` |
| [`set_deployment_status`](ops/set_deployment_status.md) | worker | `api.product_worker` | `authoring.deployment` |
| [`set_watch_state`](ops/set_watch_state.md) | research | `api.product_command` | `inquiry.watch` |
| [`start_attempt`](ops/start_attempt.md) | command | `api.product_command` | `authoring.distribution_offer`, `authoring.release_item`, `curriculum.requirement`, `curriculum.requirement_option`, `learning.attempt`, `learning.enrollment`, `learning.environment_session`, `learning.equivalence_request`, `learning.release_adoption` |
| [`submit_attempt`](ops/submit_attempt.md) | command | `api.product_command` | `authoring.work_revision`, `learning.attempt`, `learning.evidence_item`, `learning.submission`, `orchestration.artifact` |
| [`trace_assertion`](ops/trace_assertion.md) | research | `api.product_read` | `inquiry.assertion`, `inquiry.support` |
| [`trace_reverse`](ops/trace_reverse.md) | research | `api.product_read` | `authoring.revision_binding`, `authoring.work`, `authoring.work_revision`, `dataset.cell`, `dataset.row`, `inquiry.assertion`, `inquiry.delivery`, `inquiry.obligation`, `inquiry.support` |
| [`withdraw_acceptance`](ops/withdraw_acceptance.md) | research | `api.product_command` | `inquiry.acceptance` |

Counts at head `20261116140000`: 350 relations (child partitions folded into their parents), 299 function overloads, 85 operations, 41 tasks, 71 named queries. Vocabularies: [`content.document_type`](vocabularies/content.document_type.md), [`content.format`](vocabularies/content.format.md), [`content.source_role`](vocabularies/content.source_role.md), [`content.unit_kind`](vocabularies/content.unit_kind.md), [`evidence.capture_method`](vocabularies/evidence.capture_method.md), [`evidence.search_provider`](vocabularies/evidence.search_provider.md), [`guidance.item_kind`](vocabularies/guidance.item_kind.md), [`orchestration.artifact_type`](vocabularies/orchestration.artifact_type.md), [`orchestration.intent_type`](vocabularies/orchestration.intent_type.md), [`taxonomy.entity_kind`](vocabularies/taxonomy.entity_kind.md), [`taxonomy.relationship_kind`](vocabularies/taxonomy.relationship_kind.md), [`temporal.event_kind`](vocabularies/temporal.event_kind.md), [`temporal.stream_kind`](vocabularies/temporal.stream_kind.md).
