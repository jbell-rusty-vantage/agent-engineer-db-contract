---
id: "rel:retrieval.vector_item#details"
kind: details
schema: retrieval
name: vector_item
of: "rel:retrieval.vector_item"
workspace_fingerprint: "sha256:216c4ae7230478c8e60934da25c852e10680d6caed71a662962ea3c0ac1676d3"
---
# retrieval.vector_item — details

Spill-over from [the main page](vector_item.md).

## Columns
| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id) |
| 3 | `space_version_id` | `uuid` | no | — | FK → [`retrieval.vector_space_version`](vector_space_version.md).id |
| 18 | `source_version_hash` | `text` | yes | — | — |
| 19 | `content_sha256` | `text` | no | — | — |
| 20 | `chunk_index` | `integer` | no | `0` | — |
| 21 | `backend_location` | `text` | yes | — | — |
| 23 | `generation_run_id` | `uuid` | yes | — | FK → [`evaluation.eval_run`](../evaluation/eval_run.md).id |
| 24 | `receipt_id` | `uuid` | yes | — | FK → [`orchestration.operation_receipt`](../orchestration/operation_receipt.md).id |
| 25 | `verification_state` | `text` | no | `'pending'::text` | — |
| 26 | `superseded_by_id` | `uuid` | yes | — | FK → [`retrieval.vector_item`](vector_item.md).id |
| 27 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 28 | `search_projection_id` | `uuid` | yes | — | — |
| 29 | `embedding_item_id` | `uuid` | yes | — | — |
| 30 | `language` | `text` | yes | — | — |
| 31 | `visibility` | `text` | yes | — | — |
| 32 | `classification` | `text` | yes | — | — |
| 33 | `lifecycle` | `text` | no | `'active'::text` | _curated:_ Only active items are searchable. |
| 34 | `authority_level` | `text` | yes | — | — |
| 35 | `freshness_at` | `timestamp with time zone` | yes | — | — |
| 36 | `search_text` | `text` | yes | — | — |
| 37 | `search_tsv` | `tsvector` | yes | — | generated: `to_tsvector('simple'::regconfig, COALESCE(search_text, ''::text))` |
| 38 | `retrieval_chunk_id` | `uuid` | yes | — | — |
| 40 | `projection_target_id` | `uuid` | yes | — | FK → [`retrieval.projection_target`](projection_target.md).id |
| 41 | `entity_id` | `uuid` | yes | — | — |
| 42 | `entity_kind` | `text` | yes | — | — |
| 43 | `secondary_entity_ids` | `uuid[]` | no | `'{}'::uuid[]` | — |
| 44 | `document_type_code` | `text` | yes | — | FK → [`content.document_type`](../content/document_type.md).code; _curated:_ Facet copied from the document kind. |
| 45 | `content_kind` | `text` | no | `'chunk'::text` | — |
| 46 | `valid_during` | `tstzrange` | yes | — | — |
| 47 | `knowledge_seq` | `bigint` | yes | — | _curated:_ Upper bound filter for as-of-knowledge reads. |
| 48 | `assurance_rank` | `smallint` | yes | — | — |
| 49 | `start_ms` | `integer` | yes | — | — |
| 50 | `end_ms` | `integer` | yes | — | — |
| 51 | `lens` | `text` | no | `'corpus'::text` | Whose knowledge: corpus (ingested sources), ours (our courses/guides/reports), private (one workspace's notes, RLS-isolated), evidence (assertions/claims).; _curated:_ Whose knowledge: corpus (ingested sources), ours (our courses/guides/reports), private (one workspace's notes, RLS-isolated), evidence (assertions/claims). |
| 52 | `source_tier` | `smallint` | yes | — | T0 verified assertions, T1 our content, T2 primary corpus, T3 third-party corpus, T4 live web; a filter and a boost, never a truth claim.; _curated:_ T0 verified assertions, T1 our content, T2 primary corpus, T3 third-party corpus, T4 live web; a filter and a boost, never a truth claim. |
| 53 | `workspace_id` | `uuid` | yes | — | _curated:_ Set for lens private; search_unified returns the item only when this id is in p_workspace_ids. |
| 54 | `unit_kind` | `text` | yes | — | _curated:_ Facet copied from the typed unit the item projects (transcript_segment, price_row, …). |
| 55 | `document_id` | `uuid` | yes | — | — |
| 56 | `document_version_id` | `uuid` | yes | — | — |
| 57 | `source_role_code` | `text` | yes | — | FK → [`content.source_role`](../content/source_role.md).code |
| 58 | `observed_at` | `timestamp with time zone` | yes | — | — |
| 59 | `search_tsv_en` | `tsvector` | yes | — | generated: `to_tsvector('english'::regconfig, COALESCE(search_text, ''::text))` |

## Constraints
- PK (id)
- unique (tenant_id, id)
- check `vector_item_content_kind_check`: `(content_kind = ANY (ARRAY['chunk'::text, 'summary'::text, 'claim'::text, 'record'::text, 'profile'::text, 'timeline'::text, 'measurement'::text, 'unit'::text, 'digest'::text, 'passage'::text, 'authored'::text, 'guidance'::text]))`
- check `vector_item_content_sha256_check`: `(content_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `vector_item_lens_check`: `(lens = ANY (ARRAY['corpus'::text, 'ours'::text, 'private'::text, 'evidence'::text]))`
- check `vector_item_private_has_workspace`: `((lens <> 'private'::text) OR (workspace_id IS NOT NULL))`
- check `vector_item_source_tier_check`: `((source_tier >= 0) AND (source_tier <= 4))`
- check `vector_item_verification_state_check`: `(verification_state = ANY (ARRAY['pending'::text, 'verified'::text, 'failed'::text]))`

## Relationships

Outbound: `document_type_code` → [`content.document_type`](../content/document_type.md)`.code`; `tenant_id,embedding_item_id` → [`retrieval.embedding_item`](embedding_item.md)`.tenant_id,id` on delete restrict; `generation_run_id` → [`evaluation.eval_run`](../evaluation/eval_run.md)`.id`; `tenant_id,search_projection_id` → [`retrieval.search_projection`](search_projection.md)`.tenant_id,id` on delete restrict; `projection_target_id` → [`retrieval.projection_target`](projection_target.md)`.id`; `receipt_id` → [`orchestration.operation_receipt`](../orchestration/operation_receipt.md)`.id`; `tenant_id,retrieval_chunk_id` → [`retrieval.retrieval_chunk`](retrieval_chunk.md)`.tenant_id,id` on delete restrict; `source_role_code` → [`content.source_role`](../content/source_role.md)`.code`; `space_version_id` → [`retrieval.vector_space_version`](vector_space_version.md)`.id` (+tenant); `superseded_by_id` → [`retrieval.vector_item`](vector_item.md)`.id` (+tenant); `tenant_id,entity_id,entity_kind` → [`catalog.entity`](../catalog/entity.md)`.tenant_id,id,kind`.
Inbound: [`retrieval.packet_member`](packet_member.md).vector_item_id, [`retrieval.retrieval_candidate`](retrieval_candidate.md).vector_item_id, [`retrieval.retrieval_candidate_source`](retrieval_candidate_source.md).vector_item_id, [`retrieval.vector_item`](vector_item.md).superseded_by_id, [`retrieval.vector_item_embedding_1536`](vector_item_embedding_1536.md).vector_item_id.

## Indexes

| Index | Definition |
| --- | --- |
| `vector_item_current_idx` | `CREATE INDEX vector_item_current_idx ON retrieval.vector_item USING btree (space_version_id) WHERE (superseded_by_id IS NULL)` |
| `vector_item_document_idx` | `CREATE INDEX vector_item_document_idx ON retrieval.vector_item USING btree (tenant_id, document_id) WHERE (lifecycle = 'active'::text)` |
| `vector_item_entity_idx` | `CREATE INDEX vector_item_entity_idx ON retrieval.vector_item USING btree (tenant_id, entity_id) WHERE (lifecycle = 'active'::text)` |
| `vector_item_lens_tier_idx` | `CREATE INDEX vector_item_lens_tier_idx ON retrieval.vector_item USING btree (tenant_id, lens, source_tier) WHERE (lifecycle = 'active'::text)` |
| `vector_item_search_exact_idx` | `CREATE INDEX vector_item_search_exact_idx ON retrieval.vector_item USING btree (tenant_id, space_version_id, lower(search_text), id) WHERE (lifecycle = 'active'::text)` |
| `vector_item_search_trgm_idx` | `CREATE INDEX vector_item_search_trgm_idx ON retrieval.vector_item USING gin (search_text gin_trgm_ops) WHERE (lifecycle = 'active'::text)` |
| `vector_item_search_tsv_idx` | `CREATE INDEX vector_item_search_tsv_idx ON retrieval.vector_item USING gin (search_tsv)` |
| `vector_item_secondary_gin` | `CREATE INDEX vector_item_secondary_gin ON retrieval.vector_item USING gin (secondary_entity_ids) WHERE (lifecycle = 'active'::text)` |
| `vector_item_tenant_id_uq` | `CREATE UNIQUE INDEX vector_item_tenant_id_uq ON retrieval.vector_item USING btree (tenant_id, id)` |
| `vector_item_tsv_en_idx` | `CREATE INDEX vector_item_tsv_en_idx ON retrieval.vector_item USING gin (search_tsv_en)` |
| `vector_item_type_kind_idx` | `CREATE INDEX vector_item_type_kind_idx ON retrieval.vector_item USING btree (tenant_id, document_type_code, content_kind) WHERE (lifecycle = 'active'::text)` |
| `vector_item_valid_gist` | `CREATE INDEX vector_item_valid_gist ON retrieval.vector_item USING gist (valid_during) WHERE (lifecycle = 'active'::text)` |
| `vector_item_workspace_idx` | `CREATE INDEX vector_item_workspace_idx ON retrieval.vector_item USING btree (tenant_id, workspace_id) WHERE ((lens = 'private'::text) AND (lifecycle = 'active'::text))` |

## Triggers

- `vector_item_canonical_source` → [`retrieval.enforce_canonical_source`](../../functions/retrieval/enforce_canonical_source.md): `CREATE TRIGGER vector_item_canonical_source BEFORE INSERT ON retrieval.vector_item FOR EACH ROW EXECUTE FUNCTION retrieval.enforce_canonical_source()`
- `vector_item_immutable` → [`retrieval.vector_item_guard`](../../functions/retrieval/vector_item_guard.md): `CREATE TRIGGER vector_item_immutable BEFORE DELETE OR UPDATE ON retrieval.vector_item FOR EACH ROW EXECUTE FUNCTION retrieval.vector_item_guard()`

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: using `((tenant_id = util.current_tenant_id()) AND (lens <> 'private'::text))`; with check `((tenant_id = util.current_tenant_id()) AND (lens <> 'private'::text))`
- `product_private_access` (ALL) for `product_api_owner`: using `(lens = ANY (ARRAY['private'::text, 'ours'::text]))`; with check `(lens = ANY (ARRAY['private'::text, 'ours'::text]))`
