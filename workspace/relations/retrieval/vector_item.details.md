---
id: "rel:retrieval.vector_item#details"
kind: details
schema: retrieval
name: vector_item
of: "rel:retrieval.vector_item"
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# retrieval.vector_item — details

Spill-over from [the main page](vector_item.md).

## Relationships

Outbound: `document_type_code` → [`content.document_type`](../content/document_type.md)`.code`; `tenant_id,embedding_item_id` → [`retrieval.embedding_item`](embedding_item.md)`.tenant_id,id` on delete restrict; `generation_run_id` → [`evaluation.eval_run`](../evaluation/eval_run.md)`.id`; `tenant_id,search_projection_id` → [`retrieval.search_projection`](search_projection.md)`.tenant_id,id` on delete restrict; `projection_target_id` → [`retrieval.projection_target`](projection_target.md)`.id`; `receipt_id` → [`orchestration.operation_receipt`](../orchestration/operation_receipt.md)`.id`; `tenant_id,retrieval_chunk_id` → [`retrieval.retrieval_chunk`](retrieval_chunk.md)`.tenant_id,id` on delete restrict; `space_version_id` → [`retrieval.vector_space_version`](vector_space_version.md)`.id` (+tenant); `superseded_by_id` → [`retrieval.vector_item`](vector_item.md)`.id` (+tenant); `tenant_id,entity_id,entity_kind` → [`corpus.entity`](../corpus/entity.md)`.tenant_id,id,kind`.
Inbound: [`retrieval.packet_member`](packet_member.md).vector_item_id, [`retrieval.retrieval_candidate`](retrieval_candidate.md).vector_item_id, [`retrieval.retrieval_candidate_source`](retrieval_candidate_source.md).vector_item_id, [`retrieval.vector_item`](vector_item.md).superseded_by_id, [`retrieval.vector_item_embedding_1536`](vector_item_embedding_1536.md).vector_item_id.

## Indexes

| Index | Definition |
| --- | --- |
| `vector_item_current_idx` | `CREATE INDEX vector_item_current_idx ON retrieval.vector_item USING btree (space_version_id) WHERE (superseded_by_id IS NULL)` |
| `vector_item_entity_idx` | `CREATE INDEX vector_item_entity_idx ON retrieval.vector_item USING btree (tenant_id, entity_id) WHERE (lifecycle = 'active'::text)` |
| `vector_item_search_exact_idx` | `CREATE INDEX vector_item_search_exact_idx ON retrieval.vector_item USING btree (tenant_id, space_version_id, lower(search_text), id) WHERE (lifecycle = 'active'::text)` |
| `vector_item_search_trgm_idx` | `CREATE INDEX vector_item_search_trgm_idx ON retrieval.vector_item USING gin (search_text gin_trgm_ops) WHERE (lifecycle = 'active'::text)` |
| `vector_item_search_tsv_idx` | `CREATE INDEX vector_item_search_tsv_idx ON retrieval.vector_item USING gin (search_tsv)` |
| `vector_item_secondary_gin` | `CREATE INDEX vector_item_secondary_gin ON retrieval.vector_item USING gin (secondary_entity_ids) WHERE (lifecycle = 'active'::text)` |
| `vector_item_tenant_id_uq` | `CREATE UNIQUE INDEX vector_item_tenant_id_uq ON retrieval.vector_item USING btree (tenant_id, id)` |
| `vector_item_type_kind_idx` | `CREATE INDEX vector_item_type_kind_idx ON retrieval.vector_item USING btree (tenant_id, document_type_code, content_kind) WHERE (lifecycle = 'active'::text)` |
| `vector_item_valid_gist` | `CREATE INDEX vector_item_valid_gist ON retrieval.vector_item USING gist (valid_during) WHERE (lifecycle = 'active'::text)` |

## Triggers

- `vector_item_canonical_source` → [`retrieval.enforce_canonical_source`](../../functions/retrieval/enforce_canonical_source.md): `CREATE TRIGGER vector_item_canonical_source BEFORE INSERT ON retrieval.vector_item FOR EACH ROW EXECUTE FUNCTION retrieval.enforce_canonical_source()`
- `vector_item_immutable` → [`retrieval.vector_item_guard`](../../functions/retrieval/vector_item_guard.md): `CREATE TRIGGER vector_item_immutable BEFORE DELETE OR UPDATE ON retrieval.vector_item FOR EACH ROW EXECUTE FUNCTION retrieval.vector_item_guard()`

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: using `(tenant_id = util.current_tenant_id())`; with check `(tenant_id = util.current_tenant_id())`
