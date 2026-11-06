---
id: "rel:evidence.locator#details"
kind: details
schema: evidence
name: locator
of: "rel:evidence.locator"
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# evidence.locator — details

Spill-over from [the main page](locator.md).

## Relationships

Outbound: `capture_id` → [`evidence.source_capture`](source_capture.md)`.id` (+tenant); `tenant_id,representation_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict.
Inbound: [`content.conversion_finding`](../content/conversion_finding.md).locator_id, [`corpus.media_appearance`](../corpus/media_appearance.md).locator_id, [`evidence.attribution`](attribution.md).locator_id, [`evidence.claim_evidence_link`](claim_evidence_link.md).locator_id, [`evidence.extraction_record`](extraction_record.md).locator_id, [`evidence.extraction_signature`](extraction_signature.md).locator_id, [`evidence.segment_support`](segment_support.md).locator_id, [`ranking.metric_observation`](../ranking/metric_observation.md).locator_id, [`retrieval.chunk_span`](../retrieval/chunk_span.md).locator_id, [`retrieval.search_projection_chunk_support`](../retrieval/search_projection_chunk_support.md).locator_id, [`temporal.extent`](../temporal/extent.md).locator_id.

## Indexes

| Index | Definition |
| --- | --- |
| `locator_capture_idx` | `CREATE INDEX locator_capture_idx ON evidence.locator USING btree (capture_id)` |
| `locator_tenant_id_uq` | `CREATE UNIQUE INDEX locator_tenant_id_uq ON evidence.locator USING btree (tenant_id, id)` |

## Triggers

- `artifact_retirement_d2187e8287b5c5db8a74a8e9` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md): `CREATE TRIGGER artifact_retirement_d2187e8287b5c5db8a74a8e9 BEFORE INSERT OR UPDATE ON evidence.locator FOR EACH ROW EXECUTE FUNCTION orchestration.guard_retired_artifact_reference('[{"local": "tenant_id", "parent": "tenant_id"}, {"local": "representation_artifact_id", "parent": "id"}]')`
- `locator_capture_lineage` → [`evidence.validate_locator_capture_lineage`](../../functions/evidence/validate_locator_capture_lineage.md): `CREATE TRIGGER locator_capture_lineage BEFORE INSERT ON evidence.locator FOR EACH ROW EXECUTE FUNCTION evidence.validate_locator_capture_lineage()`
- `locator_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md): `CREATE TRIGGER locator_immutable BEFORE DELETE OR UPDATE ON evidence.locator FOR EACH ROW EXECUTE FUNCTION util.reject_mutation()`

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: using `(tenant_id = util.current_tenant_id())`; with check `(tenant_id = util.current_tenant_id())`
