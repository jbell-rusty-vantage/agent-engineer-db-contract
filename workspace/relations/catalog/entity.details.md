---
id: "rel:catalog.entity#details"
kind: details
schema: catalog
name: entity
of: "rel:catalog.entity"
workspace_fingerprint: "sha256:fbf5703bf7a6f6131c452444ee949f1feec1bbe813c78d772fb3886b510815b9"
---
# catalog.entity — details

Spill-over from [the main page](entity.md).

## Columns
| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id); unique (tenant_id, id, kind) |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id); unique (tenant_id, id, kind); unique (tenant_id, kind, slug) |
| 3 | `kind` | `text` | no | — | unique (tenant_id, id, kind); unique (tenant_id, kind, slug); FK → [`taxonomy.entity_kind`](../taxonomy/entity_kind.md).code; _curated:_ FK to taxonomy.entity_kind; selects the attributes_schema and parent_kind. |
| 4 | `display_name` | `text` | no | — | _curated:_ Projection of the entity_name stream, not a unique key. |
| 5 | `slug` | `text` | no | — | unique (tenant_id, kind, slug) |
| 6 | `summary` | `text` | yes | — | — |
| 7 | `lifecycle` | `text` | no | `'active'::text` | _curated:_ active, merged, or retired. Resolve hides merged. |
| 8 | `merged_into_id` | `uuid` | yes | — | FK → [`catalog.entity`](entity.md).id; _curated:_ Set when lifecycle is merged. |
| 9 | `projection_knowledge_seq` | `bigint` | yes | — | _curated:_ Knowledge head at which display_name/slug were last projected (catalog.rebuild_entity_projections). |
| 10 | `created_by_receipt_id` | `uuid` | no | — | FK → [`orchestration.operation_receipt`](../orchestration/operation_receipt.md).id; _curated:_ Required; executor writes the receipt first. |
| 11 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 12 | `updated_at` | `timestamp with time zone` | no | `now()` | — |
| 13 | `attributes` | `jsonb` | no | `'{}'::jsonb` | Kind-specific attributes validated by taxonomy.entity_kind.attributes_schema. Numbers that change over time are fact streams, never attributes.; _curated:_ Kind-specific attributes validated by the kind's JSON Schema; additionalProperties true, so unknown keys pass but should be rare. Never numbers that move. |

## Constraints
- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, id, kind)
- unique (tenant_id, kind, slug)
- check `entity_lifecycle_check`: `(lifecycle = ANY (ARRAY['active'::text, 'merged'::text, 'retired'::text]))`

## Relationships

Outbound: `created_by_receipt_id` → [`orchestration.operation_receipt`](../orchestration/operation_receipt.md)`.id` (deferrable); `kind` → [`taxonomy.entity_kind`](../taxonomy/entity_kind.md)`.code`; `merged_into_id` → [`catalog.entity`](entity.md)`.id` (+tenant).
Inbound: [`authoring.release_item`](../authoring/release_item.md).entity_id, [`authoring.revision_binding`](../authoring/revision_binding.md).entity_id, [`authoring.runtime_requirement`](../authoring/runtime_requirement.md).entity_id, [`catalog.entity`](entity.md).merged_into_id, [`catalog.entity_alias`](entity_alias.md).entity_id, [`catalog.entity_identifier`](entity_identifier.md).entity_id, [`catalog.entity_merge`](entity_merge.md).from_entity_id|to_entity_id, [`catalog.media_platform`](media_platform.md).product_entity_id, [`catalog.relationship`](relationship.md).from_entity_id|to_entity_id, [`catalog.work`](work.md).id|id,kind|venue_entity_id, [`content.digest_item`](../content/digest_item.md).entity_id, [`content.document`](../content/document.md).work_entity_id, [`content.document_about_entity`](../content/document_about_entity.md).entity_id, [`content.document_digest`](../content/document_digest.md).focus_entity_id, [`content.document_node`](../content/document_node.md).speaker_entity_id, [`content.document_summary`](../content/document_summary.md).focus_entity_id, [`content.unit_entity_role`](../content/unit_entity_role.md).entity_id, [`dataset.row`](../dataset/row.md).entity_id, [`evidence.attribution`](../evidence/attribution.md).entity_id, [`evidence.claim_subject`](../evidence/claim_subject.md).entity_id, [`evidence.source`](../evidence/source.md).publisher_entity_id, [`guidance.item_subject`](../guidance/item_subject.md).entity_id, [`orchestration.capability`](../orchestration/capability.md).packages_mcp_server_version_id, [`orchestration.operation_receipt_target`](../orchestration/operation_receipt_target.md).entity_id,entity_kind, [`ranking.leaderboard`](../ranking/leaderboard.md).benchmark_version_id|publisher_entity_id, [`ranking.leaderboard_entry`](../ranking/leaderboard_entry.md).entity_id, [`retrieval.chunk_entity_mention`](../retrieval/chunk_entity_mention.md).entity_id, [`retrieval.projection_target`](../retrieval/projection_target.md).entity_id, [`retrieval.vector_item`](../retrieval/vector_item.md).entity_id,entity_kind, [`staging.candidate`](../staging/candidate.md).resolved_entity_id, [`staging.identity_match`](../staging/identity_match.md).entity_id, [`staging.resolution_decision`](../staging/resolution_decision.md).entity_id, [`taxonomy.assignment`](../taxonomy/assignment.md).target_entity_id, [`temporal.event`](../temporal/event.md).object_entity_id|subject_entity_id, [`temporal.segment`](../temporal/segment.md).ref_entity_id, [`temporal.stream`](../temporal/stream.md).subject_entity_id.
Polymorphic: `kind` selects the typed table via [`taxonomy.entity_kind`](../../vocabularies/taxonomy.entity_kind.md): agent_plugin → [`catalog.entity`](entity.md), agent_skill → [`catalog.entity`](entity.md), ai_model → [`catalog.entity`](entity.md), ai_model_version → [`catalog.entity`](entity.md), ai_protocol → [`catalog.entity`](entity.md), ai_protocol_feature → [`catalog.entity`](entity.md), ai_protocol_version → [`catalog.entity`](entity.md), benchmark → [`catalog.entity`](entity.md), benchmark_run → [`catalog.entity`](entity.md), benchmark_version → [`catalog.entity`](entity.md), case_study → [`catalog.work`](work.md), compute_device → [`catalog.entity`](entity.md), compute_offering → [`catalog.entity`](entity.md), concept → [`catalog.entity`](entity.md), corporate_transaction → [`catalog.entity`](entity.md), dataset → [`catalog.entity`](entity.md), event_series → [`catalog.entity`](entity.md), funding_round → [`catalog.entity`](entity.md), industry_event → [`catalog.entity`](entity.md), library → [`catalog.entity`](entity.md), library_release → [`catalog.entity`](entity.md), mcp_server → [`catalog.entity`](entity.md), media_channel → [`catalog.entity`](entity.md), media_series → [`catalog.entity`](entity.md), media_work → [`catalog.work`](work.md), model_offering → [`catalog.entity`](entity.md), organization → [`catalog.entity`](entity.md), paper → [`catalog.work`](work.md), person → [`catalog.entity`](entity.md), product → [`catalog.entity`](entity.md), product_feature → [`catalog.entity`](entity.md), product_version → [`catalog.entity`](entity.md), registry → [`catalog.entity`](entity.md), repository → [`catalog.entity`](entity.md), security_advisory → [`catalog.entity`](entity.md), story → [`catalog.work`](work.md), talk → [`catalog.work`](work.md), technique → [`catalog.entity`](entity.md) — basis: vocabulary taxonomy.entity_kind.canonical_table + FK entity_kind_fkey.
Polymorphic target of: [`content.document_type`](../content/document_type.md) (vocabulary taxonomy.entity_kind.canonical_table + FK document_type_work_entity_kind_fkey), [`orchestration.operation_receipt_target`](../orchestration/operation_receipt_target.md) (vocabulary taxonomy.entity_kind.canonical_table + FK operation_receipt_target_entity_kind_fkey), [`retrieval.projection_target`](../retrieval/projection_target.md) (check constraint projection_target_exactly_one), [`staging.candidate`](../staging/candidate.md) (vocabulary taxonomy.entity_kind.canonical_table + FK candidate_proposed_kind_fkey), [`taxonomy.assignment`](../taxonomy/assignment.md) (check constraint assignment_one_target_ck), [`taxonomy.entity_kind`](../taxonomy/entity_kind.md) (vocabulary taxonomy.entity_kind.canonical_table + FK entity_kind_parent_kind_fkey), [`taxonomy.term_target_kind`](../taxonomy/term_target_kind.md) (vocabulary taxonomy.entity_kind.canonical_table + FK term_target_kind_entity_kind_code_fkey), [`temporal.stream`](../temporal/stream.md) (check constraint stream_check).

## Indexes

| Index | Definition |
| --- | --- |
| `entity_name_trgm` | `CREATE INDEX entity_name_trgm ON catalog.entity USING gin (display_name gin_trgm_ops)` |
| `entity_tenant_id_id_key` | `CREATE UNIQUE INDEX entity_tenant_id_id_key ON catalog.entity USING btree (tenant_id, id)` |
| `entity_tenant_id_id_kind_key` | `CREATE UNIQUE INDEX entity_tenant_id_id_kind_key ON catalog.entity USING btree (tenant_id, id, kind)` |
| `entity_tenant_id_kind_slug_key` | `CREATE UNIQUE INDEX entity_tenant_id_kind_slug_key ON catalog.entity USING btree (tenant_id, kind, slug)` |

## Triggers

- `entity_attributes_valid` → [`catalog.validate_entity_attributes`](../../functions/catalog/validate_entity_attributes.md): `CREATE TRIGGER entity_attributes_valid BEFORE INSERT OR UPDATE OF attributes, kind ON catalog.entity FOR EACH ROW EXECUTE FUNCTION catalog.validate_entity_attributes()`
- `entity_receipt_tenant` → [`catalog.check_receipt_tenant`](../../functions/catalog/check_receipt_tenant.md) (constraint trigger): `CREATE CONSTRAINT TRIGGER entity_receipt_tenant AFTER INSERT OR UPDATE ON catalog.entity DEFERRABLE INITIALLY IMMEDIATE FOR EACH ROW EXECUTE FUNCTION catalog.check_receipt_tenant()`
- `entity_requires_admission` → [`verification.require_receipt_admission`](../../functions/verification/require_receipt_admission.md) (constraint trigger, deferred): `CREATE CONSTRAINT TRIGGER entity_requires_admission AFTER INSERT OR UPDATE OF created_by_receipt_id ON catalog.entity DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION verification.require_receipt_admission()`

## Row-level security

Enabled.
- `km_tenant_access` (ALL) for `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: using `(tenant_id = util.current_tenant_id())`; with check `(tenant_id = util.current_tenant_id())`
