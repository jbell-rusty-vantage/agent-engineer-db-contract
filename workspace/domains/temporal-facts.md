---
id: "dom:temporal-facts"
kind: domain
lens: corpus
schemas: [temporal]
aliases: [facts, two-clock, bitemporal, history, timeline, knowledge head, batch, changes since]
relations: [temporal.knowledge_head, temporal.knowledge_batch, temporal.extent, temporal.stream, temporal.segment, temporal.event, temporal.event_occurrence, temporal.stream_kind, temporal.event_kind]
functions: [api.changes_since, api.entity_at, api.entity_timeline, api.knowledge_head, api.model_offerings_at, api.models_at, api.price_history, api.what_changed, temporal.admit_support, temporal.assert_event, temporal.assert_relationship, temporal.assert_state, temporal.begin_batch, temporal.close_segment, temporal.commit_batch, temporal.current_k, temporal.make_extent, temporal.withdraw_support]
tasks: [admit-support-for-claim, check-knowledge-head, compare-models, compose-ingestion-intent, find-stale-facts, price-with-locator, record-availability-change, record-price-change, release-history, supersede-stale-fact, verify-ingestion-result, what-changed-since, what-changed-since-head, what-do-we-know-about-entity]
summary: A fact is a segment on a stream with a world interval and a knowledge interval; one home for every number.
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# Temporal facts (two clocks)

A fact is a segment on a stream with a world interval and a knowledge interval; one home for every number.

> curated (model_assisted, unreviewed) — A fact is a `temporal.segment` on a `temporal.stream`. The stream is
> `(kind, subject_entity_id | subject_relationship_id, scope_key)`. The segment carries
> world interval `valid_during` and knowledge interval `[k_from, k_to)`. Current means
> `k_to is null`. "As the world was at T, as we knew at K" is `q:entity.at`; the L1 tables
> replayed at T are `q:catalog.models_at` and `q:catalog.model_offerings_at`.
> 
> Build 08 makes `temporal` the one home for numbers: `offering_price` (payload meter|tier|region,
> amount+currency+unit), `benchmark_score`, `model_context_window`, `repository_stars`,
> `organization_headcount`, `package_downloads` and so on are streams; `ranking` and the
> L1 views only read them. `q:facts.price_history` shows every price belief of an offering
> and meter with both clocks; `q:facts.changes_since` lists what changed since a date as
> facts opened/replaced (with the old value), events and unit-level document diffs, with
> `learned_at` (knowledge clock) beside `world_from` (world clock).
> 
> `temporal.knowledge_head` is one row per tenant. `q:knowledge.head` reads it as
> `app_reader`. Writes open a batch with `temporal.begin_batch(p_expected_head)`; a mismatch
> raises `rebase_required` (40001). `temporal.commit_batch` seals the batch against a receipt,
> unique idempotency key and SHA-256 input digest, then validates stream slot rules (status,
> amount, unit, currency, payload JSON Schema).
> 
> `temporal.assert_state` is a no-op when an identical current segment exists. Overlap closes
> the old segment and re-inserts unaffected fragments with `replaces_segment_id`. Two
> overlapping assertions in one batch are an error. `temporal_basis` explicit or
> carry_forward requires a `temporal.extent`. Events are `temporal.event` plus a current
> `temporal.event_occurrence`.
> 
> Traps: `api.current_facts` hides intervals that do not contain now() — use `q:entity.at`
> for history and `q:entity.timeline` for unknown gaps. A new price series defaults its
> scope_key to meter|tier|region; an existing series keeps its own scope_key, so read
> `q:facts.price_history` before asserting a correction. Agents never DML temporal tables;
> they submit fact.assert_state / event.assert intents.

## Relations that matter

| Relation | Summary | Enforced | Direct writers |
| --- | --- | --- | --- |
| [`temporal.knowledge_head`](../relations/temporal/knowledge_head.md) | One row per tenant; knowledge_seq is the sealed-batch clock and open_xid/open_k mark an open batch. | PK (tenant_id); RLS | helpers only |
| [`temporal.knowledge_batch`](../relations/temporal/knowledge_batch.md) | One sealed admission transaction with receipt, idempotency key, and input digest. | PK (tenant_id, knowledge_seq); unique (tenant_id, idempotency_key); RLS | helpers only |
| [`temporal.extent`](../relations/temporal/extent.md) | Source text for a date with precision and optional earliest/latest bounds. | PK (id); unique (tenant_id, id); RLS | helpers only |
| [`temporal.stream`](../relations/temporal/stream.md) | Identity of a fact series, unique on kind, subject, and scope_key. | PK (id); unique (tenant_id, id), (tenant_id, kind, subject_entity_id, subject_relationship_id, scope_key); RLS | helpers only |
| [`temporal.segment`](../relations/temporal/segment.md) | A fact on a stream: world interval valid_during, knowledge interval [k_from,k_to). One home for every number. | PK (id); unique (tenant_id, id); 1 exclusion; RLS | helpers only |
| [`temporal.event`](../relations/temporal/event.md) | Event identity (kind, subject, optional object/relationship, dedupe_key). | PK (id); unique (tenant_id, id), (tenant_id, kind, subject_entity_id, object_entity_id, relationship_id, dedupe_key); RLS | helpers only |
| [`temporal.event_occurrence`](../relations/temporal/event_occurrence.md) | K-stamped occurrence of an event (actual, scheduled, or cancelled). | PK (id); unique (tenant_id, id); RLS | helpers only |
| [`temporal.stream_kind`](../relations/temporal/stream_kind.md) | Slot rules for a fact series (subject kinds, status values, units, payload schema); offering_price and benchm… | PK (code) | helpers only |
| [`temporal.event_kind`](../relations/temporal/event_kind.md) | Event vocabulary with subject and object kinds and optional start/end stream kinds. | PK (code) | helpers only |

## Functions

[`api.changes_since`](../functions/api/changes_since.md), [`api.entity_at`](../functions/api/entity_at.md), [`api.entity_timeline`](../functions/api/entity_timeline.md), [`api.knowledge_head`](../functions/api/knowledge_head.md), [`api.model_offerings_at`](../functions/api/model_offerings_at.md), [`api.models_at`](../functions/api/models_at.md), [`api.price_history`](../functions/api/price_history.md), [`api.what_changed`](../functions/api/what_changed.md), [`temporal.admit_support`](../functions/temporal/admit_support.md), [`temporal.assert_event`](../functions/temporal/assert_event.md), [`temporal.assert_relationship`](../functions/temporal/assert_relationship.md), [`temporal.assert_state`](../functions/temporal/assert_state.md), [`temporal.begin_batch`](../functions/temporal/begin_batch.md), [`temporal.close_segment`](../functions/temporal/close_segment.md), [`temporal.commit_batch`](../functions/temporal/commit_batch.md), [`temporal.current_k`](../functions/temporal/current_k.md), [`temporal.make_extent`](../functions/temporal/make_extent.md), [`temporal.withdraw_support`](../functions/temporal/withdraw_support.md)

## Named queries

[`q:catalog.model_offerings_at`](../queries/README.md), [`q:catalog.models_at`](../queries/README.md), [`q:entity.at`](../queries/README.md), [`q:entity.timeline`](../queries/README.md), [`q:entity.what_changed`](../queries/README.md), [`q:events.current_for_entity`](../queries/README.md), [`q:facts.changes_since`](../queries/README.md), [`q:facts.current_by_stream`](../queries/README.md), [`q:facts.history_for_stream`](../queries/README.md), [`q:facts.price_history`](../queries/README.md), [`q:knowledge.head`](../queries/README.md), [`q:vocab.event_kind`](../queries/README.md), [`q:vocab.stream_kind`](../queries/README.md)

## Tasks

[`admit-support-for-claim`](../tasks/admit-support-for-claim.md), [`check-knowledge-head`](../tasks/check-knowledge-head.md), [`compare-models`](../tasks/compare-models.md), [`compose-ingestion-intent`](../tasks/compose-ingestion-intent.md), [`find-stale-facts`](../tasks/find-stale-facts.md), [`price-with-locator`](../tasks/price-with-locator.md), [`record-availability-change`](../tasks/record-availability-change.md), [`record-price-change`](../tasks/record-price-change.md), [`release-history`](../tasks/release-history.md), [`supersede-stale-fact`](../tasks/supersede-stale-fact.md), [`verify-ingestion-result`](../tasks/verify-ingestion-result.md), [`what-changed-since`](../tasks/what-changed-since.md), [`what-changed-since-head`](../tasks/what-changed-since-head.md), [`what-do-we-know-about-entity`](../tasks/what-do-we-know-about-entity.md)

Schemas: [`temporal`](../schemas/temporal/README.md).
