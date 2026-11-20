---
id: "rel:orchestration.mission#details"
kind: details
schema: orchestration
name: mission
of: "rel:orchestration.mission"
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# orchestration.mission — details

Spill-over from [the main page](mission.md).

## Relationships

Outbound: `capability_profile_id` → [`orchestration.capability_profile`](capability_profile.md)`.id`.
Inbound: [`acquisition.attention_policy`](../acquisition/attention_policy.md).mission_id, [`acquisition.attention_sweep`](../acquisition/attention_sweep.md).mission_id, [`evaluation.eval_run`](../evaluation/eval_run.md).mission_id, [`knowledge_service.eve_operation_binding`](../knowledge_service/eve_operation_binding.md).mission_id, [`observability.trace`](../observability/trace.md).mission_id, [`observability.usage_rollup`](../observability/usage_rollup.md).mission_id, [`orchestration.agent_session`](agent_session.md).mission_id, [`orchestration.artifact`](artifact.md).mission_id, [`orchestration.artifact_manifest`](artifact_manifest.md).mission_id, [`orchestration.continuation_checkpoint`](continuation_checkpoint.md).mission_id, [`orchestration.mission_event`](mission_event.md).mission_id, [`orchestration.operation_intent`](operation_intent.md).mission_id, [`orchestration.outbox_event`](outbox_event.md).mission_id, [`orchestration.work_item`](work_item.md).mission_id, [`verification.probe_run`](../verification/probe_run.md).mission_id.

## Indexes

| Index | Definition |
| --- | --- |
| `mission_eve_binding_tenant_id_uq` | `CREATE UNIQUE INDEX mission_eve_binding_tenant_id_uq ON orchestration.mission USING btree (tenant_id, id)` |
| `mission_slug_uq` | `CREATE UNIQUE INDEX mission_slug_uq ON orchestration.mission USING btree (tenant_id, slug)` |
| `mission_status_idx` | `CREATE INDEX mission_status_idx ON orchestration.mission USING btree (status, created_at DESC)` |
| `mission_tenant_id_uq` | `CREATE UNIQUE INDEX mission_tenant_id_uq ON orchestration.mission USING btree (tenant_id, id)` |

## Triggers

- `mission_set_updated_at` → [`util.set_updated_at`](../../functions/util/set_updated_at.md): `CREATE TRIGGER mission_set_updated_at BEFORE UPDATE ON orchestration.mission FOR EACH ROW EXECUTE FUNCTION util.set_updated_at()`

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: using `(tenant_id = util.current_tenant_id())`; with check `(tenant_id = util.current_tenant_id())`
