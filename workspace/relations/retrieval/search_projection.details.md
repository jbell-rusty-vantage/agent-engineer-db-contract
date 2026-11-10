---
id: "rel:retrieval.search_projection#details"
kind: details
schema: retrieval
name: search_projection
of: "rel:retrieval.search_projection"
workspace_fingerprint: "sha256:027ab2b6133d5d59318c478f06d832d89f937e563c387539f37fb3d7668818a8"
---
# retrieval.search_projection — details

Spill-over from [the main page](search_projection.md).

## Relationships

Outbound: `projection_procedure_id` → [`retrieval.projection_procedure`](projection_procedure.md)`.id` on delete restrict; `tenant_id,content_promotion_decision_id` → [`retrieval.content_promotion_decision`](content_promotion_decision.md)`.tenant_id,id` on delete restrict; `tenant_id,projection_target_id` → [`retrieval.projection_target`](projection_target.md)`.tenant_id,id` on delete restrict; `tenant_id,representation_decision_id` → [`content.representation_decision`](../content/representation_decision.md)`.tenant_id,id` on delete restrict.
Inbound: [`retrieval.embedding_item`](embedding_item.md).search_projection_id, [`retrieval.packet_member`](packet_member.md).search_projection_id, [`retrieval.retrieval_candidate_source`](retrieval_candidate_source.md).search_projection_id, [`retrieval.search_projection_chunk_support`](search_projection_chunk_support.md).search_projection_id, [`retrieval.vector_item`](vector_item.md).search_projection_id.

## Indexes

| Index | Definition |
| --- | --- |
| `search_projection_target_idx` | `CREATE INDEX search_projection_target_idx ON retrieval.search_projection USING btree (tenant_id, projection_target_id, purpose)` |
| `search_projection_tenant_id_id_key` | `CREATE UNIQUE INDEX search_projection_tenant_id_id_key ON retrieval.search_projection USING btree (tenant_id, id)` |
| `search_projection_tenant_id_projection_target_id_projection_key` | `CREATE UNIQUE INDEX search_projection_tenant_id_projection_target_id_projection_key ON retrieval.search_projection USING btree (tenant_id, projection_target_id, projection_procedure_id, purpose, embedding_text_sha256)` |

## Triggers

- `search_projection_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md): `CREATE TRIGGER search_projection_immutable BEFORE DELETE OR UPDATE ON retrieval.search_projection FOR EACH ROW EXECUTE FUNCTION util.reject_mutation()`

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: using `(tenant_id = util.current_tenant_id())`; with check `(tenant_id = util.current_tenant_id())`
- `product_private_access` (ALL) for `product_api_owner`: using `true`; with check `(visibility = ANY (ARRAY['private'::text, 'workspace'::text, 'tenant'::text]))`
