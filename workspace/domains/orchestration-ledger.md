---
id: "dom:orchestration-ledger"
kind: domain
schemas: [orchestration]
aliases: [intents, receipts, artifacts, missions]
relations: [orchestration.mission, orchestration.attempt, orchestration.operation_intent, orchestration.operation_receipt, orchestration.artifact, orchestration.artifact_lineage, orchestration.artifact_type, orchestration.intent_type, orchestration.work_item, orchestration.capability]
functions: [api.submit_intent]
tasks: [check-knowledge-head, publish-report, register-report, verify-ingestion-result]
summary: "Missions, intents, immutable receipts, and content-addressed artifacts."
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# Orchestration ledger

Missions, intents, immutable receipts, and content-addressed artifacts.

> curated (model_assisted, unreviewed) — `orchestration.operation_intent` records intent_type (including knowledge_ingestion),
> schema_version, payload, preconditions, unique `idempotency_key`, optional mission and
> attempt, and approval_state. `orchestration.operation_receipt` is one-to-one with an
> intent and immutable: outcome applied, rejected, noop, or partial, plus
> changes_summary and affected_refs. Facts cannot exist without a receipt id.
> 
> `orchestration.artifact` is content-addressed (sha256, bucket_class, storage_bucket,
> unique object_path) and typed by `orchestration.artifact_type` (knowledge_read_intent,
> knowledge_read_snapshot, knowledge_ingestion_plan, knowledge_ingestion_receipt,
> schema_workspace_manifest, knowledge_report_markdown, and older codes). Lineage
> (`orchestration.artifact_lineage`) records derived_from, supersedes, corrects,
> produced_by, consumed_by.
> 
> pipeline_agent can select intents and artifacts but not receipt rows. `q:receipts.for_intent`
> therefore joins the intent to `temporal.knowledge_batch` on idempotency_key to expose
> receipt_id and knowledge_seq. Missions, attempts, work items, and capabilities are
> the durable envelope; this workspace does not create Mission Control spine objects.
> 
> Invariant: two intents cannot share an idempotency_key. Trap: treating
> `orchestration.operation_receipt` as readable under `pipeline_agent` — it is not;
> use `q:receipts.for_intent` or `q:receipts.recent_for_mission`. Before writing,
> `check-knowledge-head` then `publish-report` for report artifacts. `q:artifacts.by_type`
> lists stored objects; bytes are fetched through the executor, never with bucket
> credentials. A knowledge_ingestion intent is what the executor records when it
> applies a schema-workspace plan.

## Relations that matter

| Relation | Summary | Enforced | Direct writers |
| --- | --- | --- | --- |
| [`orchestration.mission`](../relations/orchestration/mission.md) | table | PK (id); unique (tenant_id, id), (tenant_id, slug), (tenant_id, id); RLS | `control_plane`, `executor_service` |
| [`orchestration.attempt`](../relations/orchestration/attempt.md) | table | PK (id); unique (tenant_id, id), (work_item_id, attempt_no); RLS | `control_plane`, `executor_service` |
| [`orchestration.operation_intent`](../relations/orchestration/operation_intent.md) | Durable proposed operation with unique idempotency_key. | PK (id); unique (idempotency_key), (tenant_id, id); RLS | `control_plane`, `executor_service`, `pipeline_agent` |
| [`orchestration.operation_receipt`](../relations/orchestration/operation_receipt.md) | Immutable outcome of one intent (applied, rejected, noop, partial). | PK (id); unique (intent_id); RLS | `control_plane`, `executor_service` |
| [`orchestration.artifact`](../relations/orchestration/artifact.md) | Content-addressed stored object typed by artifact_type. | PK (id); unique (tenant_id, id); RLS | `control_plane`, `executor_service` |
| [`orchestration.artifact_lineage`](../relations/orchestration/artifact_lineage.md) | Typed edge between artifacts (derived_from, supersedes, corrects, produced_by, consumed_by). | PK (id); unique (tenant_id, from_artifact_id, to_artifact_id, relation_kind); RLS | `control_plane`, `executor_service` |
| [`orchestration.artifact_type`](../relations/orchestration/artifact_type.md) | table | PK (code); RLS | `control_plane`, `executor_service` |
| [`orchestration.intent_type`](../relations/orchestration/intent_type.md) | table | PK (code); RLS | `control_plane`, `executor_service` |
| [`orchestration.work_item`](../relations/orchestration/work_item.md) | table | PK (id); unique (tenant_id, id); RLS | `control_plane`, `executor_service` |
| [`orchestration.capability`](../relations/orchestration/capability.md) | table | PK (id); unique (tenant_id, slug); RLS | `control_plane`, `executor_service` |

## Functions

[`api.submit_intent`](../functions/api/submit_intent.md)

## Named queries

[`q:artifacts.by_type`](../queries/README.md), [`q:receipts.for_intent`](../queries/README.md), [`q:receipts.recent_for_mission`](../queries/README.md)

## Tasks

[`check-knowledge-head`](../tasks/check-knowledge-head.md), [`publish-report`](../tasks/publish-report.md), [`register-report`](../tasks/register-report.md), [`verify-ingestion-result`](../tasks/verify-ingestion-result.md)

Schemas: [`orchestration`](../schemas/orchestration/README.md).
