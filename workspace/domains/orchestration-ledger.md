---
id: "dom:orchestration-ledger"
kind: domain
lens: machinery
schemas: [orchestration]
aliases: [intents, receipts, artifacts, missions]
relations: [orchestration.mission, orchestration.attempt, orchestration.operation_intent, orchestration.operation_receipt, orchestration.artifact, orchestration.artifact_lineage, orchestration.artifact_type, orchestration.intent_type, orchestration.work_item, orchestration.capability]
functions: [api.submit_intent]
tasks: [check-knowledge-head, verify-ingestion-result, write-verification-chain]
summary: "Missions, intents, immutable receipts, and content-addressed artifacts (machinery lens)."
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:216c4ae7230478c8e60934da25c852e10680d6caed71a662962ea3c0ac1676d3"
---
# Orchestration ledger

Missions, intents, immutable receipts, and content-addressed artifacts (machinery lens).

> curated (model_assisted, unreviewed) — `orchestration.operation_intent` records intent_type (including knowledge_ingestion),
> schema_version, payload, preconditions, unique `idempotency_key`, optional mission and
> attempt, and approval_state. `orchestration.operation_receipt` is one-to-one with an
> intent and immutable: outcome applied, rejected, noop, or partial, plus
> changes_summary and affected_refs. Facts cannot exist without a receipt id.
> 
> `orchestration.artifact` is content-addressed (sha256, bucket_class, storage_bucket,
> unique object_path) and typed by `orchestration.artifact_type`. Lineage
> (`orchestration.artifact_lineage`) records derived_from, supersedes, corrects,
> produced_by, consumed_by. Authored-work assets and uploaded sources from the product
> also register here (`authored_work_asset`, `uploaded_document`, `file_set_file`).
> 
> pipeline_agent can select intents and artifacts but not receipt rows. `q:receipts.for_intent`
> therefore joins the intent to `temporal.knowledge_batch` on idempotency_key to expose
> receipt_id and knowledge_seq. Missions, attempts, work items, and capabilities are
> the durable envelope; this workspace does not create Mission Control spine objects.
> Most of this schema is verification plumbing (`orchestration.verification_*`), hidden from
> START_HERE and MAP as machinery.

## Relations that matter

| Relation | Summary | Enforced | Direct writers |
| --- | --- | --- | --- |
| [`orchestration.mission`](../relations/orchestration/mission.md) | table | PK (id); unique (tenant_id, id), (tenant_id, slug), (tenant_id, id); RLS | `control_plane`, `executor_service` |
| [`orchestration.attempt`](../relations/orchestration/attempt.md) | table | PK (id); unique (tenant_id, id), (work_item_id, attempt_no); RLS | `control_plane`, `executor_service` |
| [`orchestration.operation_intent`](../relations/orchestration/operation_intent.md) | Durable proposed operation with unique idempotency_key. | PK (id); unique (idempotency_key), (tenant_id, id); RLS | `control_plane`, `executor_service`, `pipeline_agent` |
| [`orchestration.operation_receipt`](../relations/orchestration/operation_receipt.md) | Immutable outcome of one intent (applied, rejected, noop, partial). | PK (id); unique (intent_id); RLS | `control_plane`, `executor_service` |
| [`orchestration.artifact`](../relations/orchestration/artifact.md) | Content-addressed stored object typed by artifact_type; product uploads and course assets register here too. | PK (id); unique (tenant_id, id); RLS | `control_plane`, `executor_service` |
| [`orchestration.artifact_lineage`](../relations/orchestration/artifact_lineage.md) | Typed edge between artifacts (derived_from, supersedes, corrects, produced_by, consumed_by). | PK (id); unique (tenant_id, from_artifact_id, to_artifact_id, relation_kind); RLS | `control_plane`, `executor_service` |
| [`orchestration.artifact_type`](../relations/orchestration/artifact_type.md) | table | PK (code); RLS | `control_plane`, `executor_service` |
| [`orchestration.intent_type`](../relations/orchestration/intent_type.md) | table | PK (code); RLS | `control_plane`, `executor_service` |
| [`orchestration.work_item`](../relations/orchestration/work_item.md) | table | PK (id); unique (tenant_id, id); RLS | `control_plane`, `executor_service` |
| [`orchestration.capability`](../relations/orchestration/capability.md) | table | PK (id); unique (tenant_id, slug); RLS | `control_plane`, `executor_service` |

## Functions

[`api.submit_intent`](../functions/api/submit_intent.md)

## Named queries

[`q:artifacts.by_type`](../queries/README.md), [`q:chain.governed_writes`](../queries/README.md), [`q:receipts.for_intent`](../queries/README.md), [`q:receipts.recent_for_mission`](../queries/README.md)

## Tasks

[`check-knowledge-head`](../tasks/check-knowledge-head.md), [`verify-ingestion-result`](../tasks/verify-ingestion-result.md), [`write-verification-chain`](../tasks/write-verification-chain.md)

Schemas: [`orchestration`](../schemas/orchestration/README.md).
