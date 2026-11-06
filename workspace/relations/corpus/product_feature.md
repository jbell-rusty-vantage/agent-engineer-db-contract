---
id: "rel:corpus.product_feature"
kind: table
schema: corpus
name: product_feature
domain: identity
aliases: []
tokens: [corpus, product_feature, corpus.product_feature, id, tenant_id, kind, product_id, feature_key, description]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"corpus\"][\"Tables\"][\"product_feature\"][\"Row\"]"
defined_in: ["20260829192855_optimize_ai_entity_taxonomy_and_relationships.sql", "20260912010200_km_02_corpus_identity.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# corpus.product_feature

table in domain `identity`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | — | PK; unique (tenant_id, id); FK → [`corpus.entity`](entity.md).id |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id) |
| 3 | `kind` | `text` | no | `'product_feature'::text` | — |
| 4 | `product_id` | `uuid` | no | — | FK → [`corpus.product`](product.md).id |
| 5 | `feature_key` | `text` | no | — | — |
| 6 | `description` | `text` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `product_feature_kind_check`: `(kind = 'product_feature'::text)`

## Relationships

Outbound: `id` → [`corpus.entity`](entity.md)`.id` (+tenant); `product_id` → [`corpus.product`](product.md)`.id` (+tenant); `tenant_id,id,kind` → [`corpus.entity`](entity.md)`.tenant_id,id,kind` (deferrable).
Inbound: none.
Polymorphic target of: [`content.document_type`](../content/document_type.md) (vocabulary taxonomy.entity_kind.canonical_table + FK document_type_work_entity_kind_fkey), [`corpus.entity`](entity.md) (vocabulary taxonomy.entity_kind.canonical_table + FK entity_kind_fkey), [`orchestration.operation_receipt_target`](../orchestration/operation_receipt_target.md) (vocabulary taxonomy.entity_kind.canonical_table + FK operation_receipt_target_entity_kind_fkey), [`staging.candidate`](../staging/candidate.md) (vocabulary taxonomy.entity_kind.canonical_table + FK candidate_proposed_kind_fkey), [`taxonomy.term_target_kind`](../taxonomy/term_target_kind.md) (vocabulary taxonomy.entity_kind.canonical_table + FK term_target_kind_entity_kind_code_fkey).

## Indexes

`product_feature_tenant_id_id_key` unique

## Triggers

_None._

## Row-level security

Enabled.
- `km_tenant_access` (ALL) for `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: SELECT; `executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: SELECT; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Named queries: `q:entity.typed_row`.
- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["corpus"]["Tables"]["product_feature"]["Insert"]`; row: `Database["corpus"]["Tables"]["product_feature"]["Row"]`; update: `Database["corpus"]["Tables"]["product_feature"]["Update"]`

Defined in: `20260829192855_optimize_ai_entity_taxonomy_and_relationships.sql`, `20260912010200_km_02_corpus_identity.sql`.
