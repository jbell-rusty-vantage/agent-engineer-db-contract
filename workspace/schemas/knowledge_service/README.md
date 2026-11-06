---
id: "sch:knowledge_service"
kind: schema
name: knowledge_service
domains: [knowledge-service-runtime]
relations: 15
functions: 10
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# knowledge_service

Restart-safe standalone operations, steps, events, leases, receipts, outbox and guarded review decisions. Domains: [`knowledge-service-runtime`](../../domains/knowledge-service-runtime.md).

| Relation | Kind | Rows | Summary | Key edges |
| --- | --- | --- | --- | --- |
| [`callback_delivery`](../../relations/knowledge_service/callback_delivery.md) | table | unknown | Append-only authenticated A2A callback receipt and cross-restart replay ledger; payloads … | → `knowledge_service.operation` |
| [`checkpoint_artifact_reference`](../../relations/knowledge_service/checkpoint_artifact_reference.md) | table | unknown | — | → `orchestration.artifact`, → `knowledge_service.scoped_checkpoint` |
| [`checkpoint_scope`](../../relations/knowledge_service/checkpoint_scope.md) | table | unknown | — | → `knowledge_service.scoped_checkpoint` |
| [`eve_operation_binding`](../../relations/knowledge_service/eve_operation_binding.md) | table | unknown | Immutable first-lineage binding for API-verified Eve verification requests. It grants no … | → `orchestration.attempt`, → `orchestration.mission`, → `orchestration.work_item` |
| [`eve_operation_invocation`](../../relations/knowledge_service/eve_operation_invocation.md) | table | unknown | Append-only full public Eve attestation envelopes, including signature, for offline autho… | → `knowledge_service.eve_operation_binding` |
| [`lease`](../../relations/knowledge_service/lease.md) | table | unknown | — | → `knowledge_service.operation_step` |
| [`operation`](../../relations/knowledge_service/operation.md) | table | small | Durable knowledge-service operation with ownership_mode and idempotency_key. | → `orchestration.capability_version`, → `orchestration.attempt`, → `orchestration.work_item` |
| [`operation_event`](../../relations/knowledge_service/operation_event.md) | table | small | — | → `knowledge_service.operation`, → `knowledge_service.operation_step` |
| [`operation_step`](../../relations/knowledge_service/operation_step.md) | table | unknown | — | → `knowledge_service.operation` |
| [`outbox`](../../relations/knowledge_service/outbox.md) | table | small | — | → `knowledge_service.operation_event`, → `knowledge_service.operation` |
| [`receipt`](../../relations/knowledge_service/receipt.md) | table | unknown | — | → `knowledge_service.operation`, → `knowledge_service.operation_step` |
| [`review_decision`](../../relations/knowledge_service/review_decision.md) | table | unknown | — | → `knowledge_service.operation`, → `knowledge_service.review_subject` |
| [`review_subject`](../../relations/knowledge_service/review_subject.md) | table | unknown | — | → `knowledge_service.operation` |
| [`scoped_checkpoint`](../../relations/knowledge_service/scoped_checkpoint.md) | table | unknown | Standalone KS durable workspace custody; no mission workflow acceptance or scheduler owne… | → `orchestration.artifact`, → `knowledge_service.checkpoint_scope` |
| [`verification_component_binding`](../../relations/knowledge_service/verification_component_binding.md) | table | unknown | The common verification component this AI Engineer binding consumes (Sprint V): the insta… | — |

Functions: [`ack_outbox`](../../functions/knowledge_service/ack_outbox.md), [`claim_outbox`](../../functions/knowledge_service/claim_outbox.md), [`extend_outbox_claim`](../../functions/knowledge_service/extend_outbox_claim.md), [`guard_checkpoint_reference`](../../functions/knowledge_service/guard_checkpoint_reference.md), [`guard_checkpoint_scope`](../../functions/knowledge_service/guard_checkpoint_scope.md), [`guard_operation_terminal`](../../functions/knowledge_service/guard_operation_terminal.md), [`guard_outbox_mutation`](../../functions/knowledge_service/guard_outbox_mutation.md), [`guard_scoped_checkpoint`](../../functions/knowledge_service/guard_scoped_checkpoint.md), [`nack_outbox`](../../functions/knowledge_service/nack_outbox.md), [`require_checkpoint_commit`](../../functions/knowledge_service/require_checkpoint_commit.md).

Types: none.
