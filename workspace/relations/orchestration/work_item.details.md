---
id: "rel:orchestration.work_item#details"
kind: details
schema: orchestration
name: work_item
of: "rel:orchestration.work_item"
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# orchestration.work_item — details

Spill-over from [the main page](work_item.md).

## Relationships

Outbound: `capability_profile_id` → [`orchestration.capability_profile`](capability_profile.md)`.id`; `kind` → [`orchestration.work_item_kind`](work_item_kind.md)`.code`; `mission_id` → [`orchestration.mission`](mission.md)`.id` on delete cascade.
Inbound: [`evaluation.eval_run`](../evaluation/eval_run.md).work_item_id, [`evaluation.gate_result`](../evaluation/gate_result.md).spawned_work_item_id, [`evidence.revalidation_event`](../evidence/revalidation_event.md).work_item_id, [`knowledge_service.eve_operation_binding`](../knowledge_service/eve_operation_binding.md).work_item_id, [`knowledge_service.operation`](../knowledge_service/operation.md).work_item_id, [`observability.trace`](../observability/trace.md).work_item_id, [`orchestration.artifact_manifest`](artifact_manifest.md).work_item_id, [`orchestration.attempt`](attempt.md).work_item_id, [`orchestration.work_item_artifact`](work_item_artifact.md).work_item_id, [`orchestration.work_item_dependency`](work_item_dependency.md).depends_on_id|work_item_id, [`orchestration.work_item_event`](work_item_event.md).work_item_id, [`ranking.ranking_run`](../ranking/ranking_run.md).work_item_id, [`research.downstream_handoff`](../research/downstream_handoff.md).consumed_by_work_item_id.

## Indexes

| Index | Definition |
| --- | --- |
| `work_item_idempotency_uq` | `CREATE UNIQUE INDEX work_item_idempotency_uq ON orchestration.work_item USING btree (tenant_id, idempotency_key) WHERE (idempotency_key IS NOT NULL)` |
| `work_item_lease_idx` | `CREATE INDEX work_item_lease_idx ON orchestration.work_item USING btree (status, lease_expires_at, created_at) WHERE (status = ANY (ARRAY['pending'::orchestration.work_item_status, 'ready'::orchestration.work_item_status, 'running'::orchestration.work_item_status]))` |
| `work_item_mission_idx` | `CREATE INDEX work_item_mission_idx ON orchestration.work_item USING btree (mission_id, status)` |
| `work_item_ready_idx` | `CREATE INDEX work_item_ready_idx ON orchestration.work_item USING btree (status, created_at) WHERE (status = ANY (ARRAY['pending'::orchestration.work_item_status, 'ready'::orchestration.work_item_status]))` |
| `work_item_tenant_id_uq` | `CREATE UNIQUE INDEX work_item_tenant_id_uq ON orchestration.work_item USING btree (tenant_id, id)` |

## Triggers

- `work_item_set_updated_at` → [`util.set_updated_at`](../../functions/util/set_updated_at.md): `CREATE TRIGGER work_item_set_updated_at BEFORE UPDATE ON orchestration.work_item FOR EACH ROW EXECUTE FUNCTION util.set_updated_at()`

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: using `(tenant_id = util.current_tenant_id())`; with check `(tenant_id = util.current_tenant_id())`
