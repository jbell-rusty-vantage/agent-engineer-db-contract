---
id: "rel:orchestration.operation_receipt_target#details"
kind: details
schema: orchestration
name: operation_receipt_target
of: "rel:orchestration.operation_receipt_target"
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# orchestration.operation_receipt_target — details

Spill-over from [the main page](operation_receipt_target.md).

## Relationships

Outbound: `entity_kind` → [`taxonomy.entity_kind`](../taxonomy/entity_kind.md)`.code`; `receipt_id` → [`orchestration.operation_receipt`](operation_receipt.md)`.id`; `tenant_id,claim_id` → [`evidence.claim`](../evidence/claim.md)`.tenant_id,id`; `tenant_id,entity_id,entity_kind` → [`catalog.entity`](../catalog/entity.md)`.tenant_id,id,kind`.
Inbound: none.
Polymorphic: `entity_kind` selects the typed table via [`taxonomy.entity_kind`](../../vocabularies/taxonomy.entity_kind.md): agent_plugin → [`catalog.entity`](../catalog/entity.md), agent_skill → [`catalog.entity`](../catalog/entity.md), ai_model → [`catalog.entity`](../catalog/entity.md), ai_model_version → [`catalog.entity`](../catalog/entity.md), ai_protocol → [`catalog.entity`](../catalog/entity.md), ai_protocol_feature → [`catalog.entity`](../catalog/entity.md), ai_protocol_version → [`catalog.entity`](../catalog/entity.md), benchmark → [`catalog.entity`](../catalog/entity.md), benchmark_version → [`catalog.entity`](../catalog/entity.md), case_study → [`catalog.work`](../catalog/work.md), community_actor → [`catalog.entity`](../catalog/entity.md), compute_device → [`catalog.entity`](../catalog/entity.md), compute_offering → [`catalog.entity`](../catalog/entity.md), concept → [`catalog.entity`](../catalog/entity.md), corporate_transaction → [`catalog.entity`](../catalog/entity.md), dataset → [`catalog.entity`](../catalog/entity.md), event_series → [`catalog.entity`](../catalog/entity.md), funding_round → [`catalog.entity`](../catalog/entity.md), industry_event → [`catalog.entity`](../catalog/entity.md), library → [`catalog.entity`](../catalog/entity.md), library_release → [`catalog.entity`](../catalog/entity.md), mcp_server → [`catalog.entity`](../catalog/entity.md), media_channel → [`catalog.entity`](../catalog/entity.md), media_series → [`catalog.entity`](../catalog/entity.md), media_work → [`catalog.work`](../catalog/work.md), model_offering → [`catalog.entity`](../catalog/entity.md), organization → [`catalog.entity`](../catalog/entity.md), paper → [`catalog.work`](../catalog/work.md), person → [`catalog.entity`](../catalog/entity.md), product → [`catalog.entity`](../catalog/entity.md), product_feature → [`catalog.entity`](../catalog/entity.md), product_version → [`catalog.entity`](../catalog/entity.md), registry → [`catalog.entity`](../catalog/entity.md), repository → [`catalog.entity`](../catalog/entity.md), security_advisory → [`catalog.entity`](../catalog/entity.md), source_channel → [`catalog.entity`](../catalog/entity.md), story → [`catalog.work`](../catalog/work.md), talk → [`catalog.work`](../catalog/work.md), technique → [`catalog.entity`](../catalog/entity.md) — basis: vocabulary taxonomy.entity_kind.canonical_table + FK operation_receipt_target_entity_kind_fkey.

## Indexes

| Index | Definition |
| --- | --- |
| `operation_receipt_target_entity` | `CREATE INDEX operation_receipt_target_entity ON orchestration.operation_receipt_target USING btree (tenant_id, entity_id) WHERE (entity_id IS NOT NULL)` |
| `operation_receipt_target_lookup` | `CREATE INDEX operation_receipt_target_lookup ON orchestration.operation_receipt_target USING btree (tenant_id, target_schema, target_table, target_id)` |
| `operation_receipt_target_tenant_id_receipt_id_target_schema_key` | `CREATE UNIQUE INDEX operation_receipt_target_tenant_id_receipt_id_target_schema_key ON orchestration.operation_receipt_target USING btree (tenant_id, receipt_id, target_schema, target_table, target_id, role)` |

## Triggers

- `receipt_target_guard` → [`orchestration.guard_receipt_target`](../../functions/orchestration/guard_receipt_target.md): `CREATE TRIGGER receipt_target_guard BEFORE INSERT ON orchestration.operation_receipt_target FOR EACH ROW EXECUTE FUNCTION orchestration.guard_receipt_target()`
- `receipt_target_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md): `CREATE TRIGGER receipt_target_immutable BEFORE DELETE OR UPDATE ON orchestration.operation_receipt_target FOR EACH ROW EXECUTE FUNCTION util.reject_mutation()`

## Row-level security

Enabled and forced.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: using `(tenant_id = util.current_tenant_id())`; with check `(tenant_id = util.current_tenant_id())`
