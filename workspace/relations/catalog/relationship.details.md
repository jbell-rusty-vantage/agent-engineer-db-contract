---
id: "rel:catalog.relationship#details"
kind: details
schema: catalog
name: relationship
of: "rel:catalog.relationship"
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# catalog.relationship — details

Spill-over from [the main page](relationship.md).

## Relationships

Outbound: `closed_by_event_id` → [`temporal.event`](../temporal/event.md)`.id`; `closed_reason` → [`temporal.correction_reason`](../temporal/correction_reason.md)`.code`; `from_entity_id` → [`catalog.entity`](entity.md)`.id` (+tenant); `kind` → [`taxonomy.relationship_kind`](../taxonomy/relationship_kind.md)`.code`; `primary_claim_id` → [`evidence.claim`](../evidence/claim.md)`.id` (+tenant); `to_entity_id` → [`catalog.entity`](entity.md)`.id` (+tenant).
Inbound: [`catalog.proposal`](proposal.md).target_relationship_id, [`catalog.proposal_basis`](proposal_basis.md).relationship_id, [`evidence.claim`](../evidence/claim.md).relationship_id, [`retrieval.chunk_relationship_evidence`](../retrieval/chunk_relationship_evidence.md).relationship_id, [`temporal.event`](../temporal/event.md).relationship_id, [`temporal.stream`](../temporal/stream.md).subject_relationship_id.
Polymorphic target of: [`catalog.proposal`](proposal.md) (check constraint proposal_cause_shape), [`catalog.proposal_basis`](proposal_basis.md) (check constraint proposal_basis_one_target), [`temporal.stream`](../temporal/stream.md) (check constraint stream_check).

## Indexes

| Index | Definition |
| --- | --- |
| `relationship_current_uq` | `CREATE UNIQUE INDEX relationship_current_uq ON catalog.relationship USING btree (tenant_id, kind, from_entity_id, to_entity_id, qualifier, episode) WHERE (k_to IS NULL)` |
| `relationship_from_idx` | `CREATE INDEX relationship_from_idx ON catalog.relationship USING btree (tenant_id, from_entity_id, kind) WHERE (k_to IS NULL)` |
| `relationship_tenant_id_id_key` | `CREATE UNIQUE INDEX relationship_tenant_id_id_key ON catalog.relationship USING btree (tenant_id, id)` |
| `relationship_to_idx` | `CREATE INDEX relationship_to_idx ON catalog.relationship USING btree (tenant_id, to_entity_id, kind) WHERE (k_to IS NULL)` |

## Triggers

- `guard_k` → [`temporal.guard_k`](../../functions/temporal/guard_k.md): `CREATE TRIGGER guard_k BEFORE DELETE OR UPDATE ON catalog.relationship FOR EACH ROW EXECUTE FUNCTION temporal.guard_k()`
- `relationship_kinds` → [`catalog.check_relationship_kinds`](../../functions/catalog/check_relationship_kinds.md): `CREATE TRIGGER relationship_kinds BEFORE INSERT OR UPDATE ON catalog.relationship FOR EACH ROW EXECUTE FUNCTION catalog.check_relationship_kinds()`
- `relationship_properties` → [`catalog.check_relationship_properties`](../../functions/catalog/check_relationship_properties.md): `CREATE TRIGGER relationship_properties BEFORE INSERT OR UPDATE ON catalog.relationship FOR EACH ROW EXECUTE FUNCTION catalog.check_relationship_properties()`
- `sealed_batch` → [`temporal.require_sealed_batch`](../../functions/temporal/require_sealed_batch.md) (constraint trigger, deferred): `CREATE CONSTRAINT TRIGGER sealed_batch AFTER INSERT OR UPDATE ON catalog.relationship DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION temporal.require_sealed_batch()`
- `stamp_k` → [`temporal.stamp_k`](../../functions/temporal/stamp_k.md): `CREATE TRIGGER stamp_k BEFORE INSERT ON catalog.relationship FOR EACH ROW EXECUTE FUNCTION temporal.stamp_k()`

## Row-level security

Enabled.
- `km_tenant_access` (ALL) for `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: using `(tenant_id = util.current_tenant_id())`; with check `(tenant_id = util.current_tenant_id())`
