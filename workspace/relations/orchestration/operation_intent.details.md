---
id: "rel:orchestration.operation_intent#details"
kind: details
schema: orchestration
name: operation_intent
of: "rel:orchestration.operation_intent"
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# orchestration.operation_intent — details

Spill-over from [the main page](operation_intent.md).

## Relationships

Outbound: `intent_type` → [`orchestration.intent_type`](intent_type.md)`.code`; `mission_id` → [`orchestration.mission`](mission.md)`.id` on delete set null; `proposed_by_attempt` → [`orchestration.attempt`](attempt.md)`.id`.
Inbound: [`evaluation.review_task`](../evaluation/review_task.md).operation_intent_id, [`orchestration.operation_receipt`](operation_receipt.md).intent_id, [`research.report_v2_ingestion`](../research/report_v2_ingestion.md).intent_id.
Polymorphic target of: [`evaluation.review_task`](../evaluation/review_task.md) (check constraint review_task_exactly_one_subject).

## Indexes

| Index | Definition |
| --- | --- |
| `operation_intent_idempotency_key_key` | `CREATE UNIQUE INDEX operation_intent_idempotency_key_key ON orchestration.operation_intent USING btree (idempotency_key)` |
| `operation_intent_mc_run_idx` | `CREATE INDEX operation_intent_mc_run_idx ON orchestration.operation_intent USING btree (tenant_id, mc_run_id) WHERE (mc_run_id IS NOT NULL)` |
| `operation_intent_mission_idx` | `CREATE INDEX operation_intent_mission_idx ON orchestration.operation_intent USING btree (mission_id)` |
| `operation_intent_origin_idx` | `CREATE INDEX operation_intent_origin_idx ON orchestration.operation_intent USING btree (tenant_id, origin_digest) WHERE (origin_digest IS NOT NULL)` |
| `operation_intent_state_idx` | `CREATE INDEX operation_intent_state_idx ON orchestration.operation_intent USING btree (approval_state, created_at)` |
| `operation_intent_tenant_identity` | `CREATE UNIQUE INDEX operation_intent_tenant_identity ON orchestration.operation_intent USING btree (tenant_id, id)` |

## Triggers

- `operation_intent_origin_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md): `CREATE TRIGGER operation_intent_origin_immutable BEFORE UPDATE OF tenant_id, origin_digest, origin_kind, mc_mission_id, mc_run_id, mc_activation_id, mc_operation_id, mc_operation_attempt, mc_execution_generation, mc_lane ON orchestration.operation_intent FOR EACH ROW EXECUTE FUNCTION util.reject_mutation()`

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: using `(tenant_id = util.current_tenant_id())`; with check `(tenant_id = util.current_tenant_id())`
