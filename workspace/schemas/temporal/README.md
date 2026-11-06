---
id: "sch:temporal"
kind: schema
name: temporal
domains: [temporal-facts]
relations: 9
functions: 17
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# temporal

Domains: [`temporal-facts`](../../domains/temporal-facts.md).

| Relation | Kind | Rows | Summary | Key edges |
| --- | --- | --- | --- | --- |
| [`event`](../../relations/temporal/event.md) | table | unknown | Event identity (kind, subject, optional object/relationship, dedupe_key). | → `temporal.event_kind`, → `corpus.entity`, → `corpus.relationship` |
| [`event_kind`](../../relations/temporal/event_kind.md) | table | unknown | Event vocabulary with subject and object kinds and optional start/end stream kinds. | → `temporal.stream_kind` |
| [`event_occurrence`](../../relations/temporal/event_occurrence.md) | table | unknown | K-stamped occurrence of an event (actual, scheduled, or cancelled). | → `temporal.event`, → `temporal.extent`, → `evidence.claim` |
| [`extent`](../../relations/temporal/extent.md) | table | unknown | Source text for a date with precision and optional earliest/latest bounds. | → `evidence.locator` |
| [`knowledge_batch`](../../relations/temporal/knowledge_batch.md) | table | small | One sealed admission transaction with receipt, idempotency key, and input digest. | → `knowledge_service.operation`, → `orchestration.operation_receipt` |
| [`knowledge_head`](../../relations/temporal/knowledge_head.md) | table | small | One row per tenant; knowledge_seq is the sealed-batch clock and open_xid/open_k mark an o… | — |
| [`segment`](../../relations/temporal/segment.md) | table | small | A fact on a stream: world interval valid_during, knowledge interval [k_from,k_to). | → `temporal.event`, → `temporal.extent`, → `evidence.claim`, → `corpus.entity` |
| [`stream`](../../relations/temporal/stream.md) | table | small | Identity of a fact series, unique on kind, subject, and scope_key. | → `temporal.stream_kind`, → `corpus.entity`, → `corpus.relationship` |
| [`stream_kind`](../../relations/temporal/stream_kind.md) | table | unknown | Slot rules for a fact series (subject kinds, status values, units, payload schema). | — |

Functions: [`admit_support`](../../functions/temporal/admit_support.md), [`assert_event`](../../functions/temporal/assert_event.md), [`assert_relationship`](../../functions/temporal/assert_relationship.md), [`assert_state`](../../functions/temporal/assert_state.md), [`begin_batch`](../../functions/temporal/begin_batch.md), [`close_segment`](../../functions/temporal/close_segment.md), [`commit_batch`](../../functions/temporal/commit_batch.md), [`current_k`](../../functions/temporal/current_k.md), [`emit_outbox`](../../functions/temporal/emit_outbox.md), [`guard_k`](../../functions/temporal/guard_k.md), [`lock_knowledge_head`](../../functions/temporal/lock_knowledge_head.md), [`make_extent`](../../functions/temporal/make_extent.md), [`payload_valid`](../../functions/temporal/payload_valid.md), [`require_closed_head`](../../functions/temporal/require_closed_head.md), [`require_sealed_batch`](../../functions/temporal/require_sealed_batch.md), [`stamp_k`](../../functions/temporal/stamp_k.md), [`withdraw_support`](../../functions/temporal/withdraw_support.md).

Types: none.

Vocabularies: [`event_kind`](../../vocabularies/temporal.event_kind.md), [`stream_kind`](../../vocabularies/temporal.stream_kind.md).
