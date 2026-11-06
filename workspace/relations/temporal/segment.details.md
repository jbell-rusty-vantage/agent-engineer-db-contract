---
id: "rel:temporal.segment#details"
kind: details
schema: temporal
name: segment
of: "rel:temporal.segment"
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# temporal.segment — details

Spill-over from [the main page](segment.md).

## Relationships

Outbound: `caused_by_event_id` → [`temporal.event`](event.md)`.id` (+tenant); `extent_id` → [`temporal.extent`](extent.md)`.id` (+tenant); `primary_claim_id` → [`evidence.claim`](../evidence/claim.md)`.id` (+tenant); `ref_entity_id` → [`corpus.entity`](../corpus/entity.md)`.id` (+tenant); `replaces_segment_id` → [`temporal.segment`](segment.md)`.id` (+tenant); `specification_id` → [`corpus.ai_model_version_spec`](../corpus/ai_model_version_spec.md)`.id` (+tenant); `stream_id` → [`temporal.stream`](stream.md)`.id` (+tenant).
Inbound: [`evidence.segment_support`](../evidence/segment_support.md).segment_id, [`temporal.segment`](segment.md).replaces_segment_id.
Polymorphic target of: [`evidence.segment_support`](../evidence/segment_support.md) (check constraint segment_support_check).

## Indexes

| Index | Definition |
| --- | --- |
| `segment_stream_current_idx` | `CREATE INDEX segment_stream_current_idx ON temporal.segment USING btree (stream_id) WHERE (k_to IS NULL)` |
| `segment_stream_id_valid_during_excl` | `CREATE INDEX segment_stream_id_valid_during_excl ON temporal.segment USING gist (stream_id, valid_during) WHERE (k_to IS NULL)` |
| `segment_tenant_id_id_key` | `CREATE UNIQUE INDEX segment_tenant_id_id_key ON temporal.segment USING btree (tenant_id, id)` |
| `segment_valid_gist` | `CREATE INDEX segment_valid_gist ON temporal.segment USING gist (valid_during) WHERE (k_to IS NULL)` |

## Triggers

- `guard_k` → [`temporal.guard_k`](../../functions/temporal/guard_k.md): `CREATE TRIGGER guard_k BEFORE DELETE OR UPDATE ON temporal.segment FOR EACH ROW EXECUTE FUNCTION temporal.guard_k()`
- `sealed_batch` → [`temporal.require_sealed_batch`](../../functions/temporal/require_sealed_batch.md) (constraint trigger, deferred): `CREATE CONSTRAINT TRIGGER sealed_batch AFTER INSERT OR UPDATE ON temporal.segment DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION temporal.require_sealed_batch()`
- `stamp_k` → [`temporal.stamp_k`](../../functions/temporal/stamp_k.md): `CREATE TRIGGER stamp_k BEFORE INSERT ON temporal.segment FOR EACH ROW EXECUTE FUNCTION temporal.stamp_k()`

## Row-level security

Enabled.
- `km_tenant_access` (ALL) for `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: using `(tenant_id = util.current_tenant_id())`; with check `(tenant_id = util.current_tenant_id())`
