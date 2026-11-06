---
id: "rel:api.review_queue#details"
kind: details
schema: api
name: review_queue
of: "rel:api.review_queue"
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# api.review_queue — details

Spill-over from [the main page](review_queue.md).

## Relationships

Outbound: none.
Inbound: none.

## Indexes

_None._

## Triggers

_None._

## Row-level security

Disabled.

## View definition

```sql
SELECT id,
    tenant_id,
    task_kind,
    state,
    priority,
    assignee,
    quorum_required,
    summary,
    detail,
    candidate_id,
    claim_id,
    claim_conflict_id,
    entity_merge_id,
    record_reconciliation_id,
    ranking_result_id,
    operation_intent_id,
    report_version_id,
    capability_version_id,
    vector_space_version_id,
    subject_kind,
    created_at,
    updated_at
   FROM evaluation.review_task;
```
