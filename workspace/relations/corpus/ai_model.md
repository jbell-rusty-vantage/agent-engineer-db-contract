---
id: "rel:corpus.ai_model"
kind: table
schema: corpus
name: ai_model
domain: identity
aliases: [model family]
tokens: [corpus, ai_model, corpus.ai_model, id, tenant_id, kind, model_family, modality, description]
summary: Typed child for an AI model family (not a version or offering).
summary_basis: curated
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"corpus\"][\"Tables\"][\"ai_model\"][\"Row\"]"
defined_in: ["20260826000500_corpus.sql", "20260912010200_km_02_corpus_identity.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# corpus.ai_model

table in domain `identity`.

> curated (model_assisted, unreviewed) — Typed child for an AI model family (not a version or offering).

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | — | PK; unique (tenant_id, id); FK → [`corpus.entity`](entity.md).id |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id) |
| 3 | `kind` | `text` | no | `'ai_model'::text` | — |
| 4 | `model_family` | `text` | yes | — | — |
| 5 | `modality` | `text[]` | yes | — | _curated:_ text array of modalities. |
| 6 | `description` | `text` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `ai_model_kind_check`: `(kind = 'ai_model'::text)`

## Relationships

Outbound: `id` → [`corpus.entity`](entity.md)`.id` (+tenant); `tenant_id,id,kind` → [`corpus.entity`](entity.md)`.tenant_id,id,kind` (deferrable).
Inbound: [`corpus.ai_model_version`](ai_model_version.md).ai_model_id.
Polymorphic target of: [`content.document_type`](../content/document_type.md) (vocabulary taxonomy.entity_kind.canonical_table + FK document_type_work_entity_kind_fkey), [`corpus.entity`](entity.md) (vocabulary taxonomy.entity_kind.canonical_table + FK entity_kind_fkey), [`orchestration.operation_receipt_target`](../orchestration/operation_receipt_target.md) (vocabulary taxonomy.entity_kind.canonical_table + FK operation_receipt_target_entity_kind_fkey), [`staging.candidate`](../staging/candidate.md) (vocabulary taxonomy.entity_kind.canonical_table + FK candidate_proposed_kind_fkey), [`taxonomy.term_target_kind`](../taxonomy/term_target_kind.md) (vocabulary taxonomy.entity_kind.canonical_table + FK term_target_kind_entity_kind_code_fkey).

## Indexes

`ai_model_tenant_id_id_key` unique

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

insert: `Database["corpus"]["Tables"]["ai_model"]["Insert"]`; row: `Database["corpus"]["Tables"]["ai_model"]["Row"]`; update: `Database["corpus"]["Tables"]["ai_model"]["Update"]`

## Examples

Resolve a model family

```bash
knowledge db query entity.resolve --param text=GPT-5.6
```
Versions and offerings are separate entities linked by offered_as / version_of.

Defined in: `20260826000500_corpus.sql`, `20260912010200_km_02_corpus_identity.sql`.
