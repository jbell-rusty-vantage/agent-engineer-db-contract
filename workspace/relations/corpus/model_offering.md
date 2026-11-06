---
id: "rel:corpus.model_offering"
kind: table
schema: corpus
name: model_offering
domain: identity
aliases: [offering, API SKU]
tokens: [corpus, model_offering, corpus.model_offering, id, tenant_id, kind, model_version_id, provider_entity_id, offering_key]
summary: "A priced, deployable offering of an ai_model_version from a provider."
summary_basis: curated
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"corpus\"][\"Tables\"][\"model_offering\"][\"Row\"]"
defined_in: ["20260912010200_km_02_corpus_identity.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# corpus.model_offering

table in domain `identity`.

> curated (model_assisted, unreviewed) — A priced, deployable offering of an ai_model_version from a provider.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | — | PK; unique (tenant_id, id); FK → [`corpus.entity`](entity.md).id |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id) |
| 3 | `kind` | `text` | no | `'model_offering'::text` | — |
| 4 | `model_version_id` | `uuid` | no | — | FK → [`corpus.ai_model_version`](ai_model_version.md).id |
| 5 | `provider_entity_id` | `uuid` | no | — | FK → [`corpus.entity`](entity.md).id; _curated:_ Organization that offers it. |
| 6 | `offering_key` | `text` | no | — | _curated:_ Provider-side SKU or API model id. |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `model_offering_kind_check`: `(kind = 'model_offering'::text)`

## Relationships

Outbound: `id` → [`corpus.entity`](entity.md)`.id` (+tenant); `model_version_id` → [`corpus.ai_model_version`](ai_model_version.md)`.id` (+tenant); `provider_entity_id` → [`corpus.entity`](entity.md)`.id` (+tenant); `tenant_id,id,kind` → [`corpus.entity`](entity.md)`.tenant_id,id,kind` (deferrable).
Inbound: none.
Polymorphic target of: [`content.document_type`](../content/document_type.md) (vocabulary taxonomy.entity_kind.canonical_table + FK document_type_work_entity_kind_fkey), [`corpus.entity`](entity.md) (vocabulary taxonomy.entity_kind.canonical_table + FK entity_kind_fkey), [`orchestration.operation_receipt_target`](../orchestration/operation_receipt_target.md) (vocabulary taxonomy.entity_kind.canonical_table + FK operation_receipt_target_entity_kind_fkey), [`staging.candidate`](../staging/candidate.md) (vocabulary taxonomy.entity_kind.canonical_table + FK candidate_proposed_kind_fkey), [`taxonomy.term_target_kind`](../taxonomy/term_target_kind.md) (vocabulary taxonomy.entity_kind.canonical_table + FK term_target_kind_entity_kind_code_fkey).

## Indexes

`model_offering_tenant_id_id_key` unique

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

insert: `Database["corpus"]["Tables"]["model_offering"]["Insert"]`; row: `Database["corpus"]["Tables"]["model_offering"]["Row"]`; update: `Database["corpus"]["Tables"]["model_offering"]["Update"]`

## Examples

Current prices for an offering

```bash
knowledge db query facts.current_by_stream --param entity_id=0192b000-0000-7000-8000-000000000001 --param limit=50 --param stream_kind=model_offering_price
```
Each price series is its own stream via scope_key; reuse the scope_key shown here when correcting a price.

Defined in: `20260912010200_km_02_corpus_identity.sql`.
