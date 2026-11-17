---
id: "rel:api.mission_progress#details"
kind: details
schema: api
name: mission_progress
of: "rel:api.mission_progress"
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# api.mission_progress — details

Spill-over from [the main page](mission_progress.md).

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
SELECT m.id AS mission_id,
    m.slug,
    m.goal,
    m.status,
    m.started_at,
    m.ended_at,
    count(w.id) AS work_items,
    count(w.id) FILTER (WHERE w.status = 'succeeded'::orchestration.work_item_status) AS succeeded,
    count(w.id) FILTER (WHERE w.status = 'failed'::orchestration.work_item_status) AS failed,
    count(w.id) FILTER (WHERE w.status = ANY (ARRAY['pending'::orchestration.work_item_status, 'ready'::orchestration.work_item_status, 'running'::orchestration.work_item_status])) AS outstanding,
    COALESCE(sum(u.cost_usd), 0::numeric) AS cost_usd,
    m.budget_cost_usd
   FROM orchestration.mission m
     LEFT JOIN orchestration.work_item w ON w.mission_id = m.id
     LEFT JOIN observability.usage_rollup u ON u.mission_id = m.id
  GROUP BY m.id;
```
