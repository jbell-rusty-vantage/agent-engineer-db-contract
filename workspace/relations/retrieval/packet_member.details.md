---
id: "rel:retrieval.packet_member#details"
kind: details
schema: retrieval
name: packet_member
of: "rel:retrieval.packet_member"
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# retrieval.packet_member — details

Spill-over from [the main page](packet_member.md).

## Relationships

Outbound: `tenant_id,claim_id` → [`evidence.claim`](../evidence/claim.md)`.tenant_id,id` on delete restrict; `guidance_item_id` → [`guidance.item`](../guidance/item.md)`.id`; `tenant_id,packet_id` → [`retrieval.evidence_packet`](evidence_packet.md)`.tenant_id,id` on delete restrict; `tenant_id,search_projection_id` → [`retrieval.search_projection`](search_projection.md)`.tenant_id,id` on delete restrict; `tenant_id,source_representation_id,source_document_node_id` → [`content.document_node`](../content/document_node.md)`.tenant_id,representation_id,id` on delete restrict; `tenant_id,source_representation_id` → [`content.document_representation`](../content/document_representation.md)`.tenant_id,id` on delete restrict; `tenant_id,packet_id` → [`retrieval.evidence_packet`](evidence_packet.md)`.tenant_id,id` on delete restrict; `tenant_id,vector_item_id` → [`retrieval.vector_item`](vector_item.md)`.tenant_id,id` on delete restrict.
Inbound: none.

## Indexes

| Index | Definition |
| --- | --- |
| `packet_member_packet_idx` | `CREATE INDEX packet_member_packet_idx ON retrieval.packet_member USING btree (packet_id)` |
| `packet_member_projection_idx` | `CREATE INDEX packet_member_projection_idx ON retrieval.packet_member USING btree (tenant_id, search_projection_id) WHERE (search_projection_id IS NOT NULL)` |
| `packet_member_source_document_node_idx` | `CREATE INDEX packet_member_source_document_node_idx ON retrieval.packet_member USING btree (tenant_id, source_document_node_id) WHERE (source_document_node_id IS NOT NULL)` |
| `packet_member_source_representation_idx` | `CREATE INDEX packet_member_source_representation_idx ON retrieval.packet_member USING btree (tenant_id, source_representation_id) WHERE (source_representation_id IS NOT NULL)` |
| `packet_member_tenant_id_uq` | `CREATE UNIQUE INDEX packet_member_tenant_id_uq ON retrieval.packet_member USING btree (tenant_id, id)` |
| `packet_member_vector_item_idx` | `CREATE INDEX packet_member_vector_item_idx ON retrieval.packet_member USING btree (tenant_id, vector_item_id) WHERE (vector_item_id IS NOT NULL)` |

## Triggers

- `packet_member_evidence_gate` → [`retrieval.enforce_evidence_gate`](../../functions/retrieval/enforce_evidence_gate.md): `CREATE TRIGGER packet_member_evidence_gate BEFORE INSERT OR UPDATE ON retrieval.packet_member FOR EACH ROW EXECUTE FUNCTION retrieval.enforce_evidence_gate()`
- `packet_member_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md): `CREATE TRIGGER packet_member_immutable BEFORE DELETE OR UPDATE ON retrieval.packet_member FOR EACH ROW EXECUTE FUNCTION util.reject_mutation()`

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: using `false`; with check `false`
