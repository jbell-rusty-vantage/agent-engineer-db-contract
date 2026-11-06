---
id: "rel:retrieval.packet_member#details"
kind: details
schema: retrieval
name: packet_member
of: "rel:retrieval.packet_member"
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# retrieval.packet_member — details

Spill-over from [the main page](packet_member.md).

## Columns
| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `packet_id` | `uuid` | no | — | — |
| 3 | `claim_id` | `uuid` | yes | — | — |
| 4 | `technical_problem_id` | `uuid` | yes | — | — |
| 5 | `solution_pattern_id` | `uuid` | yes | — | — |
| 6 | `advanced_usage_pattern_id` | `uuid` | yes | — | — |
| 7 | `implementation_example_id` | `uuid` | yes | — | — |
| 8 | `failure_mode_id` | `uuid` | yes | — | — |
| 9 | `benchmark_result_id` | `uuid` | yes | — | — |
| 10 | `compatibility_constraint_id` | `uuid` | yes | — | — |
| 11 | `operational_practice_id` | `uuid` | yes | — | — |
| 12 | `security_consideration_id` | `uuid` | yes | — | — |
| 14 | `locators` | `jsonb` | no | `'[]'::jsonb` | — |
| 15 | `verification_state` | `text` | yes | — | — |
| 16 | `freshness` | `text` | yes | — | — |
| 17 | `contradiction_flags` | `jsonb` | no | `'[]'::jsonb` | — |
| 18 | `coverage_role` | `text` | yes | — | — |
| 19 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 20 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id) |
| 21 | `vector_item_id` | `uuid` | yes | — | — |
| 22 | `search_projection_id` | `uuid` | yes | — | — |
| 23 | `scores` | `jsonb` | no | `'{}'::jsonb` | — |
| 24 | `channel_explanations` | `text[]` | no | `'{}'::text[]` | — |
| 25 | `graph_paths` | `jsonb` | no | `'[]'::jsonb` | — |
| 26 | `authority` | `text` | yes | — | — |
| 27 | `assurance` | `text` | yes | — | — |
| 28 | `fresh_at` | `timestamp with time zone` | yes | — | — |
| 29 | `contradiction_ids` | `uuid[]` | no | `'{}'::uuid[]` | — |
| 30 | `supersedes_ids` | `uuid[]` | no | `'{}'::uuid[]` | — |
| 31 | `covered_subquery_ids` | `text[]` | no | `'{}'::text[]` | — |
| 32 | `artifact_references` | `jsonb` | no | `'[]'::jsonb` | — |
| 33 | `member_payload` | `jsonb` | no | `'{}'::jsonb` | — |
| 34 | `member_sha256` | `text` | yes | — | generated: `encode(digest((member_payload)::text, 'sha256'::text), 'hex'::text)` |
| 35 | `source_representation_id` | `uuid` | yes | — | Tenant-scoped authoritative source-only member target. The evidence gate accepts faithful_normalization or byte-identical source_native representations in the accepted state. |
| 36 | `source_document_node_id` | `uuid` | yes | — | Optional section identity; the composite FK requires this node to belong to source_representation_id.; _curated:_ Joined for start_ms/end_ms in api.evidence_packet. |
| 37 | `member_kind` | `text` | yes | — | generated: ` CASE     WHEN (claim_id IS NOT NULL) THEN 'claim'::text     WHEN (technical_problem_id IS NOT NULL) THEN 'technical_problem'::text     WHEN (solution_pattern_id IS NOT NULL) THEN 'solution_pattern'::text     WHEN (advanced_usage_pattern_id IS NOT NULL) THEN 'advanced_usage_pattern'::text     WHEN (implementation_example_id IS NOT NULL) THEN 'implementation_example'::text     WHEN (failure_mode_id IS NOT NULL) THEN 'failure_mode'::text     WHEN (benchmark_result_id IS NOT NULL) THEN 'benchmark_result'::text     WHEN (compatibility_constraint_id IS NOT NULL) THEN 'compatibility_constraint'::text     WHEN (operational_practice_id IS NOT NULL) THEN 'operational_practice'::text     WHEN (security_consideration_id IS NOT NULL) THEN 'security_consideration'::text     WHEN (source_representation_id IS NOT NULL) THEN 'source_representation'::text     ELSE NULL::text END`; _curated:_ What kind of object this member is. |

## Constraints
- PK (id)
- unique (tenant_id, id)
- check `packet_member_exactly_one`: `(num_nonnulls(claim_id, technical_problem_id, solution_pattern_id, advanced_usage_pattern_id, implementation_example_id, failure_mode_id, benchmark_result_id, compatibility_constraint_id, operational_practice_id, security_consideration_id, source_representation_id) = 1)`
- check `packet_member_sha256_ck`: `(member_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `packet_member_source_node_requires_representation_ck`: `((source_document_node_id IS NULL) OR (source_representation_id IS NOT NULL))`

## Relationships

Outbound: `tenant_id,advanced_usage_pattern_id` → [`knowledge.advanced_usage_pattern`](../knowledge/advanced_usage_pattern.md)`.tenant_id,id` on delete restrict; `tenant_id,benchmark_result_id` → [`knowledge.benchmark_result`](../knowledge/benchmark_result.md)`.tenant_id,id` on delete restrict; `tenant_id,claim_id` → [`evidence.claim`](../evidence/claim.md)`.tenant_id,id` on delete restrict; `tenant_id,compatibility_constraint_id` → [`knowledge.compatibility_constraint`](../knowledge/compatibility_constraint.md)`.tenant_id,id` on delete restrict; `tenant_id,failure_mode_id` → [`knowledge.failure_mode`](../knowledge/failure_mode.md)`.tenant_id,id` on delete restrict; `tenant_id,implementation_example_id` → [`knowledge.implementation_example`](../knowledge/implementation_example.md)`.tenant_id,id` on delete restrict; `tenant_id,operational_practice_id` → [`knowledge.operational_practice`](../knowledge/operational_practice.md)`.tenant_id,id` on delete restrict; `tenant_id,packet_id` → [`retrieval.evidence_packet`](evidence_packet.md)`.tenant_id,id` on delete restrict; `tenant_id,search_projection_id` → [`retrieval.search_projection`](search_projection.md)`.tenant_id,id` on delete restrict; `tenant_id,security_consideration_id` → [`knowledge.security_consideration`](../knowledge/security_consideration.md)`.tenant_id,id` on delete restrict; `tenant_id,solution_pattern_id` → [`knowledge.solution_pattern`](../knowledge/solution_pattern.md)`.tenant_id,id` on delete restrict; `tenant_id,source_representation_id,source_document_node_id` → [`content.document_node`](../content/document_node.md)`.tenant_id,representation_id,id` on delete restrict; `tenant_id,source_representation_id` → [`content.document_representation`](../content/document_representation.md)`.tenant_id,id` on delete restrict; `tenant_id,technical_problem_id` → [`knowledge.technical_problem`](../knowledge/technical_problem.md)`.tenant_id,id` on delete restrict; `tenant_id,packet_id` → [`retrieval.evidence_packet`](evidence_packet.md)`.tenant_id,id` on delete restrict; `tenant_id,vector_item_id` → [`retrieval.vector_item`](vector_item.md)`.tenant_id,id` on delete restrict.
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
