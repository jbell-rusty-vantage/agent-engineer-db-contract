---
id: "rel:retrieval.retrieval_chunk#details"
kind: details
schema: retrieval
name: retrieval_chunk
of: "rel:retrieval.retrieval_chunk"
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# retrieval.retrieval_chunk — details

Spill-over from [the main page](retrieval_chunk.md).

## Relationships

Outbound: `tenant_id,chunk_set_id` → [`retrieval.chunk_set`](chunk_set.md)`.tenant_id,id` on delete restrict; `tenant_id,parent_chunk_id` → [`retrieval.retrieval_chunk`](retrieval_chunk.md)`.tenant_id,id` on delete restrict.
Inbound: [`retrieval.chunk_claim_link`](chunk_claim_link.md).chunk_id, [`retrieval.chunk_edge`](chunk_edge.md).from_chunk_id|to_chunk_id, [`retrieval.chunk_entity_mention`](chunk_entity_mention.md).chunk_id, [`retrieval.chunk_relationship_evidence`](chunk_relationship_evidence.md).chunk_id, [`retrieval.chunk_span`](chunk_span.md).chunk_id, [`retrieval.projection_target`](projection_target.md).chunk_id, [`retrieval.retrieval_chunk`](retrieval_chunk.md).parent_chunk_id, [`retrieval.search_projection_chunk_support`](search_projection_chunk_support.md).chunk_id, [`retrieval.vector_item`](vector_item.md).retrieval_chunk_id.
Polymorphic target of: [`retrieval.projection_target`](projection_target.md) (check constraint projection_target_check).

## Indexes

| Index | Definition |
| --- | --- |
| `retrieval_chunk_set_idx` | `CREATE INDEX retrieval_chunk_set_idx ON retrieval.retrieval_chunk USING btree (tenant_id, chunk_set_id, ordinal)` |
| `retrieval_chunk_tenant_id_chunk_set_id_ordinal_key` | `CREATE UNIQUE INDEX retrieval_chunk_tenant_id_chunk_set_id_ordinal_key ON retrieval.retrieval_chunk USING btree (tenant_id, chunk_set_id, ordinal)` |
| `retrieval_chunk_tenant_id_id_key` | `CREATE UNIQUE INDEX retrieval_chunk_tenant_id_id_key ON retrieval.retrieval_chunk USING btree (tenant_id, id)` |

## Triggers

- `retrieval_chunk_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md): `CREATE TRIGGER retrieval_chunk_immutable BEFORE DELETE OR UPDATE ON retrieval.retrieval_chunk FOR EACH ROW EXECUTE FUNCTION util.reject_mutation()`

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: using `(tenant_id = util.current_tenant_id())`; with check `(tenant_id = util.current_tenant_id())`
