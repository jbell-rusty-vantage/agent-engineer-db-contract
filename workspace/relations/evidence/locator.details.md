---
id: "rel:evidence.locator#details"
kind: details
schema: evidence
name: locator
of: "rel:evidence.locator"
workspace_fingerprint: "sha256:fbf5703bf7a6f6131c452444ee949f1feec1bbe813c78d772fb3886b510815b9"
---
# evidence.locator — details

Spill-over from [the main page](locator.md).

## Constraints
- PK (id)
- unique (tenant_id, id)
- check `locator_check`: `((end_ms IS NULL) OR ((start_ms IS NOT NULL) AND (end_ms >= start_ms)))`
- check `locator_check1`: `((selector_kind <> ALL (ARRAY['media_timecode'::text, 'media_region'::text])) OR (start_ms IS NOT NULL))`
- check `locator_occurrence_count_check`: `((occurrence_count IS NULL) OR (occurrence_count >= 0))`
- check `locator_resolution_cardinality_ck`: `((verification_contract_version IS NULL) OR ((tenant_id IS NOT NULL) AND (representation_artifact_id IS NOT NULL) AND (selector_sha256 IS NOT NULL) AND (selected_size_bytes IS NOT NULL) AND (normalization_policy IS NOT NULL) AND (resolution_version IS NOT NULL) AND (resolution_state IS NOT NULL) AND (occurrence_count IS NOT NULL) AND (((resolution_state = 'resolved'::text) AND (occurrence_count = 1) AND (selected_content_sha256 IS NOT NULL)) OR ((resolution_state = 'ambiguous'::text) AND (occurrence_count > 1) AND (selected_content_sha256 IS NULL)) OR ((resolution_state = ANY (ARRAY['not_found'::text, 'invalid'::text, 'parse_error'::text])) AND (occurrence_count = 0) AND (selected_content_sha256 IS NULL)))))`
- check `locator_resolution_state_check`: `((resolution_state IS NULL) OR (resolution_state = ANY (ARRAY['resolved'::text, 'not_found'::text, 'ambiguous'::text, 'invalid'::text, 'parse_error'::text])))`
- check `locator_selected_content_sha256_check`: `(selected_content_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `locator_selected_size_bytes_check`: `((selected_size_bytes IS NULL) OR (selected_size_bytes >= 0))`
- check `locator_selector_kind_check`: `(selector_kind = ANY (ARRAY['text_quote'::text, 'character_position'::text, 'multi_fragment_text'::text, 'json_pointer'::text, 'html'::text, 'pdf_text'::text, 'bounding_box'::text, 'table'::text, 'repository'::text, 'dataset'::text, 'api_record'::text, 'media_timecode'::text, 'media_region'::text]))`
- check `locator_selector_sha256_check`: `((selector_sha256 IS NULL) OR (selector_sha256 ~ '^[0-9a-f]{64}$'::text))`
- check `locator_start_ms_check`: `((start_ms IS NULL) OR (start_ms >= 0))`
- check `locator_verification_contract_version_check`: `((verification_contract_version IS NULL) OR (verification_contract_version = 'verification.v1'::text))`
- check `locator_verification_contract_version_ck`: `((verification_contract_version IS NULL) OR (verification_contract_version = 'verification.v1'::text))`

## Relationships

Outbound: `capture_id` → [`evidence.source_capture`](source_capture.md)`.id` (+tenant); `tenant_id,representation_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict.
Inbound: [`authoring.release_item`](../authoring/release_item.md).locator_id, [`authoring.revision_binding`](../authoring/revision_binding.md).locator_id, [`content.conversion_finding`](../content/conversion_finding.md).locator_id, [`evidence.attribution`](attribution.md).locator_id, [`evidence.claim_evidence_link`](claim_evidence_link.md).locator_id, [`evidence.extraction_record`](extraction_record.md).locator_id, [`evidence.extraction_signature`](extraction_signature.md).locator_id, [`evidence.segment_support`](segment_support.md).locator_id, [`inquiry.support`](../inquiry/support.md).locator_id, [`retrieval.chunk_span`](../retrieval/chunk_span.md).locator_id, [`retrieval.search_projection_chunk_support`](../retrieval/search_projection_chunk_support.md).locator_id, [`temporal.extent`](../temporal/extent.md).locator_id.

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
