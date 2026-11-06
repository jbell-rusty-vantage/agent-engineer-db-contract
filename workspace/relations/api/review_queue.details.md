---
id: "rel:api.review_queue#details"
kind: details
schema: api
name: review_queue
of: "rel:api.review_queue"
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
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
