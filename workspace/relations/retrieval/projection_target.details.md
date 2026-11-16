---
id: "rel:retrieval.projection_target#details"
kind: details
schema: retrieval
name: projection_target
of: "rel:retrieval.projection_target"
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# retrieval.projection_target — details

Spill-over from [the main page](projection_target.md).

## Columns
| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, target_kind, entity_id, record_id, chunk_id, claim_id, summary_id, document_node_id, digest_id, authored_revision_id, passage_id, digest_item_id); unique (tenant_id, id) |
| 3 | `target_kind` | `text` | no | — | unique (tenant_id, target_kind, entity_id, record_id, chunk_id, claim_id, summary_id, document_node_id, digest_id, authored_revision_id, passage_id, digest_item_id); _curated:_ Which of the id columns is set. |
| 4 | `entity_id` | `uuid` | yes | — | unique (tenant_id, target_kind, entity_id, record_id, chunk_id, claim_id, summary_id, document_node_id, digest_id, authored_revision_id, passage_id, digest_item_id); FK → [`catalog.entity`](../catalog/entity.md).id |
| 5 | `record_id` | `uuid` | yes | — | unique (tenant_id, target_kind, entity_id, record_id, chunk_id, claim_id, summary_id, document_node_id, digest_id, authored_revision_id, passage_id, digest_item_id); FK → [`guidance.item`](../guidance/item.md).id; guidance.item (expert knowledge item) when target_kind = record.; _curated:_ guidance.item (expert knowledge item) when target_kind = record. |
| 6 | `chunk_id` | `uuid` | yes | — | unique (tenant_id, target_kind, entity_id, record_id, chunk_id, claim_id, summary_id, document_node_id, digest_id, authored_revision_id, passage_id, digest_item_id); FK → [`retrieval.retrieval_chunk`](retrieval_chunk.md).id |
| 7 | `claim_id` | `uuid` | yes | — | unique (tenant_id, target_kind, entity_id, record_id, chunk_id, claim_id, summary_id, document_node_id, digest_id, authored_revision_id, passage_id, digest_item_id); FK → [`evidence.claim`](../evidence/claim.md).id |
| 8 | `summary_id` | `uuid` | yes | — | unique (tenant_id, target_kind, entity_id, record_id, chunk_id, claim_id, summary_id, document_node_id, digest_id, authored_revision_id, passage_id, digest_item_id); FK → [`content.document_summary`](../content/document_summary.md).id |
| 9 | `admitted_at` | `timestamp with time zone` | no | `now()` | — |
| 10 | `retired_at` | `timestamp with time zone` | yes | — | — |
| 11 | `document_node_id` | `uuid` | yes | — | unique (tenant_id, target_kind, entity_id, record_id, chunk_id, claim_id, summary_id, document_node_id, digest_id, authored_revision_id, passage_id, digest_item_id); _curated:_ content.document_node when the projection is a typed unit. |
| 12 | `digest_id` | `uuid` | yes | — | unique (tenant_id, target_kind, entity_id, record_id, chunk_id, claim_id, summary_id, document_node_id, digest_id, authored_revision_id, passage_id, digest_item_id); FK → [`content.document_digest`](../content/document_digest.md).id; _curated:_ content.document_digest when the projection is a digest. |
| 13 | `authored_revision_id` | `uuid` | yes | — | unique (tenant_id, target_kind, entity_id, record_id, chunk_id, claim_id, summary_id, document_node_id, digest_id, authored_revision_id, passage_id, digest_item_id); FK → [`authoring.work_revision`](../authoring/work_revision.md).id; _curated:_ authoring.work_revision for lens ours items. |
| 14 | `passage_id` | `uuid` | yes | — | unique (tenant_id, target_kind, entity_id, record_id, chunk_id, claim_id, summary_id, document_node_id, digest_id, authored_revision_id, passage_id, digest_item_id); library.passage of a private/own passage; soft reference (passages are re-indexed by deletion) so the retired vector item keeps its target row.; _curated:_ library.passage for private/own passages; soft reference so the retired vector item keeps its target row. |
| 15 | `digest_item_id` | `uuid` | yes | — | unique (tenant_id, target_kind, entity_id, record_id, chunk_id, claim_id, summary_id, document_node_id, digest_id, authored_revision_id, passage_id, digest_item_id); FK → [`content.digest_item`](../content/digest_item.md).id; One digest item is one retrieval target (loop 3, owner refinement 2a.1): the item resolves to its anchor units through content.digest_item.node_ids. |

## Constraints
- PK (id)
- unique (tenant_id, target_kind, entity_id, record_id, chunk_id, claim_id, summary_id, document_node_id, digest_id, authored_revision_id, passage_id, digest_item_id)
- unique (tenant_id, id)
- check `projection_target_exactly_one`: `(num_nonnulls(entity_id, record_id, chunk_id, claim_id, summary_id, document_node_id, digest_id, authored_revision_id, passage_id, digest_item_id) = 1)`
- check `projection_target_kind_matches`: `(((target_kind = 'entity'::text) AND (entity_id IS NOT NULL)) OR ((target_kind = 'record'::text) AND (record_id IS NOT NULL)) OR ((target_kind = 'chunk'::text) AND (chunk_id IS NOT NULL)) OR ((target_kind = 'claim'::text) AND (claim_id IS NOT NULL)) OR ((target_kind = 'summary'::text) AND (summary_id IS NOT NULL)) OR ((target_kind = 'unit'::text) AND (document_node_id IS NOT NULL)) OR ((target_kind = 'digest'::text) AND (digest_id IS NOT NULL)) OR ((target_kind = 'authored'::text) AND (authored_revision_id IS NOT NULL)) OR ((target_kind = 'passage'::text) AND (passage_id IS NOT NULL)) OR ((target_kind = 'digest_item'::text) AND (digest_item_id IS NOT NULL)))`
- check `projection_target_target_kind_check`: `(target_kind = ANY (ARRAY['entity'::text, 'record'::text, 'chunk'::text, 'claim'::text, 'summary'::text, 'unit'::text, 'digest'::text, 'authored'::text, 'passage'::text, 'digest_item'::text]))`

## Relationships

Outbound: `authored_revision_id` → [`authoring.work_revision`](../authoring/work_revision.md)`.id`; `chunk_id` → [`retrieval.retrieval_chunk`](retrieval_chunk.md)`.id` (+tenant); `claim_id` → [`evidence.claim`](../evidence/claim.md)`.id` (+tenant); `digest_id` → [`content.document_digest`](../content/document_digest.md)`.id`; `digest_item_id` → [`content.digest_item`](../content/digest_item.md)`.id`; `entity_id` → [`catalog.entity`](../catalog/entity.md)`.id` (+tenant); `tenant_id,document_node_id` → [`content.document_node`](../content/document_node.md)`.tenant_id,id` (deferrable); `record_id` → [`guidance.item`](../guidance/item.md)`.id` (+tenant); `summary_id` → [`content.document_summary`](../content/document_summary.md)`.id` (+tenant).
Inbound: [`evaluation.eval_case_relevance`](../evaluation/eval_case_relevance.md).projection_target_id, [`retrieval.search_projection`](search_projection.md).projection_target_id, [`retrieval.vector_item`](vector_item.md).projection_target_id.
Polymorphic: exactly one of `entity_id`, `record_id`, `chunk_id`, `claim_id`, `summary_id`, `document_node_id`, `digest_id`, `authored_revision_id`, `passage_id`, `digest_item_id` → [`authoring.work_revision`](../authoring/work_revision.md) | [`catalog.entity`](../catalog/entity.md) | [`content.digest_item`](../content/digest_item.md) | [`content.document_digest`](../content/document_digest.md) | [`content.document_summary`](../content/document_summary.md) | [`evidence.claim`](../evidence/claim.md) | [`guidance.item`](../guidance/item.md) | [`retrieval.retrieval_chunk`](retrieval_chunk.md) — basis: check constraint projection_target_exactly_one.

## Indexes

| Index | Definition |
| --- | --- |
| `projection_target_one_row_per_target` | `CREATE UNIQUE INDEX projection_target_one_row_per_target ON retrieval.projection_target USING btree (tenant_id, target_kind, entity_id, record_id, chunk_id, claim_id, summary_id, document_node_id, digest_id, authored_revision_id, passage_id, digest_item_id) NULLS NOT DISTINCT` |
| `projection_target_tenant_id_id_key` | `CREATE UNIQUE INDEX projection_target_tenant_id_id_key ON retrieval.projection_target USING btree (tenant_id, id)` |

## Triggers

_None._

## Row-level security

Enabled.
- `km_tenant_access` (ALL) for `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: using `(tenant_id = util.current_tenant_id())`; with check `(tenant_id = util.current_tenant_id())`
- `product_private_access` (ALL) for `product_api_owner`: using `true`; with check `(target_kind = ANY (ARRAY['passage'::text, 'authored'::text]))`
