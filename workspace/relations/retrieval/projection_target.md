---
id: "rel:retrieval.projection_target"
kind: table
schema: retrieval
name: projection_target
domain: retrieval
lens: corpus
aliases: [projection target]
tokens: [retrieval, projection_target, retrieval.projection_target, id, tenant_id, target_kind, entity_id, record_id, chunk_id, claim_id, summary_id, admitted_at, retired_at, document_node_id, digest_id, authored_revision_id, passage_id, digest_item_id]
summary: "What a search projection is about — exactly one of entity, guidance item, chunk, claim, summary, typed unit, digest, authored revision or private passage."
summary_basis: curated
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, pipeline_agent, service_role]
typescript: "Database[\"retrieval\"][\"Tables\"][\"projection_target\"][\"Row\"]"
defined_in: ["20260903010100_knowledge_retrieval_contract.sql", "20260912010800_km_08_retrieval.sql"]
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# retrieval.projection_target

table in domain `retrieval`, lens `corpus` — What a search projection is about: an entity card, a guidance item, a chunk, a claim, a summary, a typed unit, a digest, one of our authored revisions or a private passage. Exactly one target per row..

> curated (model_assisted, unreviewed) — What a search projection is about — exactly one of entity, guidance item, chunk, claim, summary, typed unit, digest, authored revision or private passage.

## Columns

`id` uuid not null, `tenant_id` uuid not null, `target_kind` text not null, `entity_id` uuid, `record_id` uuid, `chunk_id` uuid, `claim_id` uuid, `summary_id` uuid, `admitted_at` timestamp with time zone not null, `retired_at` timestamp with time zone, `document_node_id` uuid, `digest_id` uuid, `authored_revision_id` uuid, `passage_id` uuid, `digest_item_id` uuid

Full column table: [details](projection_target.details.md).

## Constraints

- PK (id)
- unique (tenant_id, target_kind, entity_id, record_id, chunk_id, claim_id, summary_id, document_node_id, digest_id, authored_revision_id, passage_id, digest_item_id)
- unique (tenant_id, id)
- 3 check constraints; see [details](projection_target.details.md)

## Relationships

14 outbound and 3 inbound foreign keys; full list in [details](projection_target.details.md).

## Indexes

2 indexes; see [details](projection_target.details.md).

## Triggers

0 triggers; see [details](projection_target.details.md).

## Row-level security

Enabled; 2 policies in [details](projection_target.details.md).

## Grants

`control_plane`: SELECT; `executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Named queries: `q:retrieval.search_unified`.
- Exposed through: [`api.api_symbols`](../api/api_symbols.md).
- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`, `pipeline_agent`.
- Via functions (best effort): [`retrieval.index_text_item`](../../functions/retrieval/index_text_item.md), [`retrieval.project_entity_timeline`](../../functions/retrieval/project_entity_timeline.md).

## TypeScript

insert: `Database["retrieval"]["Tables"]["projection_target"]["Insert"]`; row: `Database["retrieval"]["Tables"]["projection_target"]["Row"]`; update: `Database["retrieval"]["Tables"]["projection_target"]["Update"]`

## Examples

Search results carry target_kind and target_id

```bash
knowledge db query retrieval.search_unified --param lenses=["corpus"] --param limit=20 --param query=pricing
```
target_kind passage rows resolve to library.passage; unit rows to content.document_node.

Defined in: `20260903010100_knowledge_retrieval_contract.sql`, `20260912010800_km_08_retrieval.sql`.
