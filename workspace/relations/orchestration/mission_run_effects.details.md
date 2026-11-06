---
id: "rel:orchestration.mission_run_effects#details"
kind: details
schema: orchestration
name: mission_run_effects
of: "rel:orchestration.mission_run_effects"
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# orchestration.mission_run_effects — details

Spill-over from [the main page](mission_run_effects.md).

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
SELECT i.tenant_id,
    i.mc_run_id,
    i.mc_mission_id,
    i.mc_activation_id,
    i.mc_operation_id,
    i.mc_operation_attempt,
    i.mc_execution_generation,
    i.mc_lane,
    i.origin_digest,
    i.id AS intent_id,
    r.id AS receipt_id,
    r.outcome AS receipt_outcome,
    r.applied_at,
    r.use_decision_id,
    t.ordinal,
    t.target_schema,
    t.target_table,
    t.target_id,
    t.entity_id,
    t.entity_kind,
    t.role,
    t.action,
    t.proposal_id,
    t.claim_id
   FROM orchestration.operation_intent i
     JOIN orchestration.operation_receipt r ON r.intent_id = i.id
     JOIN orchestration.operation_receipt_target t ON t.tenant_id = i.tenant_id AND t.receipt_id = r.id
  WHERE i.mc_run_id IS NOT NULL;
```
