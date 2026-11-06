---
id: "rel:evidence.source#details"
kind: details
schema: evidence
name: source
of: "rel:evidence.source"
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# evidence.source — details

Spill-over from [the main page](source.md).

## Relationships

Outbound: `last_capture_id` → [`evidence.source_capture`](source_capture.md)`.id`; `publisher_entity_id` → [`corpus.entity`](../corpus/entity.md)`.id`.
Inbound: [`content.document`](../content/document.md).canonical_source_id, [`evidence.attribution`](attribution.md).source_id, [`evidence.degraded_assurance`](degraded_assurance.md).source_id, [`evidence.provider_result`](provider_result.md).source_id, [`evidence.source_capture`](source_capture.md).source_id, [`evidence.source_encounter`](source_encounter.md).source_id, [`staging.candidate`](../staging/candidate.md).source_id.

## Indexes

| Index | Definition |
| --- | --- |
| `source_tenant_canonical_url_uq` | `CREATE UNIQUE INDEX source_tenant_canonical_url_uq ON evidence.source USING btree (tenant_id, canonical_url) WHERE (canonical_url IS NOT NULL)` |
| `source_tenant_id_uq` | `CREATE UNIQUE INDEX source_tenant_id_uq ON evidence.source USING btree (tenant_id, id)` |
| `source_tenant_logical_identity_uq` | `CREATE UNIQUE INDEX source_tenant_logical_identity_uq ON evidence.source USING btree (tenant_id, source_class, logical_identity)` |

## Triggers

- `source_set_updated_at` → [`util.set_updated_at`](../../functions/util/set_updated_at.md): `CREATE TRIGGER source_set_updated_at BEFORE UPDATE ON evidence.source FOR EACH ROW EXECUTE FUNCTION util.set_updated_at()`

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: using `(tenant_id = util.current_tenant_id())`; with check `(tenant_id = util.current_tenant_id())`
