---
id: "fn:product.dispatch_command(uuid,text,uuid,jsonb,uuid,client_grant)"
kind: function
schema: product
name: dispatch_command
domain: product-operations
lens: ours
overloads: ["fn:product.dispatch_command(uuid,text,uuid,jsonb,uuid,client_grant)"]
security: invoker
volatility: volatile
executors: []
raises: []
touches: { reads: [access.provided_credential, authoring.event, authoring.publisher_grant, authoring.revision_binding, curriculum.requirement, curriculum.requirement_option, orchestration.artifact], writes: [access.client_grant, access.guardian_link, access.processing_authorization, authoring.asset_scope, authoring.deployment, authoring.distribution, authoring.distribution_member, authoring.distribution_offer, authoring.file_set, authoring.file_set_entry, authoring.release, authoring.release_item, authoring.work, authoring.work_revision, authoring.workspace, authoring.workspace_member, conversation.context_item, conversation.context_snapshot, conversation.message, conversation.thread, learning.appeal, learning.assessment_result, learning.attempt, learning.enrollment, learning.environment_session, learning.equivalence_request, learning.evidence_grant, learning.evidence_item, learning.release_adoption, learning.submission, library.connected_item, library.connection, library.passage, library.removal, library.resource_control] }
tokens: [product, dispatch_command, product.dispatch_command]
defined_in: ["20261105010300_product_api.sql", "20261108120000_build08_r2_knowledge_continuum.sql", "20261108120100_build08_r2_fixups.sql"]
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# product.dispatch_command

Domain `product-operations`, lens `ours`.

## dispatch_command(uuid, text, uuid, jsonb, uuid, access.client_grant) → jsonb

function, volatile, security invoker, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `ws` | `uuid` | — | — |
| `op` | `text` | — | — |
| `head` | `uuid` | — | — |
| `pl` | `jsonb` | — | — |
| `p` | `uuid` | — | — |
| `g` | `access.client_grant` | — | — |

Execute: no configured role.

Touches (best effort): reads [`access.provided_credential`](../../relations/access/provided_credential.md), [`authoring.event`](../../relations/authoring/event.md), [`authoring.publisher_grant`](../../relations/authoring/publisher_grant.md), [`authoring.revision_binding`](../../relations/authoring/revision_binding.md), [`curriculum.requirement`](../../relations/curriculum/requirement.md), [`curriculum.requirement_option`](../../relations/curriculum/requirement_option.md), [`orchestration.artifact`](../../relations/orchestration/artifact.md); writes [`access.client_grant`](../../relations/access/client_grant.md), [`access.guardian_link`](../../relations/access/guardian_link.md), [`access.processing_authorization`](../../relations/access/processing_authorization.md), [`authoring.asset_scope`](../../relations/authoring/asset_scope.md), [`authoring.deployment`](../../relations/authoring/deployment.md), [`authoring.distribution`](../../relations/authoring/distribution.md), [`authoring.distribution_member`](../../relations/authoring/distribution_member.md), [`authoring.distribution_offer`](../../relations/authoring/distribution_offer.md), [`authoring.file_set`](../../relations/authoring/file_set.md), [`authoring.file_set_entry`](../../relations/authoring/file_set_entry.md), [`authoring.release`](../../relations/authoring/release.md), [`authoring.release_item`](../../relations/authoring/release_item.md), [`authoring.work`](../../relations/authoring/work.md), [`authoring.work_revision`](../../relations/authoring/work_revision.md), [`authoring.workspace`](../../relations/authoring/workspace.md), [`authoring.workspace_member`](../../relations/authoring/workspace_member.md), [`conversation.context_item`](../../relations/conversation/context_item.md), [`conversation.context_snapshot`](../../relations/conversation/context_snapshot.md), [`conversation.message`](../../relations/conversation/message.md), [`conversation.thread`](../../relations/conversation/thread.md), [`learning.appeal`](../../relations/learning/appeal.md), [`learning.assessment_result`](../../relations/learning/assessment_result.md), [`learning.attempt`](../../relations/learning/attempt.md), [`learning.enrollment`](../../relations/learning/enrollment.md), [`learning.environment_session`](../../relations/learning/environment_session.md), [`learning.equivalence_request`](../../relations/learning/equivalence_request.md), [`learning.evidence_grant`](../../relations/learning/evidence_grant.md), [`learning.evidence_item`](../../relations/learning/evidence_item.md), [`learning.release_adoption`](../../relations/learning/release_adoption.md), [`learning.submission`](../../relations/learning/submission.md), [`library.connected_item`](../../relations/library/connected_item.md), [`library.connection`](../../relations/library/connection.md), [`library.passage`](../../relations/library/passage.md), [`library.removal`](../../relations/library/removal.md), [`library.resource_control`](../../relations/library/resource_control.md); calls [`product.band`](band.md), [`product.band_rank`](band_rank.md), [`product.can_read_offer`](can_read_offer.md), [`product.dispatch_research_command`](dispatch_research_command.md), [`product.exposure`](exposure.md), [`product.fail`](fail.md), [`product.finalize`](finalize.md), [`product.insert_revision`](insert_revision.md), [`product.new_event`](new_event.md), [`product.personal_workspace`](personal_workspace.md), [`product.policy`](policy.md), [`product.processing_allowed`](processing_allowed.md), [`product.readable_revision`](readable_revision.md), [`product.register_artifact`](register_artifact.md), [`product.require_role`](require_role.md), [`product.role_in`](role_in.md), [`product.sha256_text`](sha256_text.md), [`product.tenant`](tenant.md), [`retrieval.retire_items_for_passages`](../retrieval/retire_items_for_passages.md), [`util.uuidv7`](../util/uuidv7.md).

TypeScript: `Database["product"]["Functions"]["dispatch_command"]`.

Defined in: `20261105010300_product_api.sql`, `20261108120000_build08_r2_knowledge_continuum.sql`, `20261108120100_build08_r2_fixups.sql`.
