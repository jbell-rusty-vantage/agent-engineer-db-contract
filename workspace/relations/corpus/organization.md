---
id: "rel:corpus.organization"
kind: table
schema: corpus
name: organization
domain: identity
aliases: [org, company]
tokens: [corpus, organization, corpus.organization, id, tenant_id, kind, legal_name, website_url, country_code, founded_on]
summary: Typed child of corpus.entity for kind organization.
summary_basis: curated
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"corpus\"][\"Tables\"][\"organization\"][\"Row\"]"
defined_in: ["20260826000500_corpus.sql", "20260912010200_km_02_corpus_identity.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# corpus.organization

table in domain `identity`.

> curated (model_assisted, unreviewed) — Typed child of corpus.entity for kind organization.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | — | PK; unique (tenant_id, id); FK → [`corpus.entity`](entity.md).id |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id) |
| 3 | `kind` | `text` | no | `'organization'::text` | — |
| 4 | `legal_name` | `text` | yes | — | _curated:_ Optional legal name; display_name stays on corpus.entity. |
| 5 | `website_url` | `text` | yes | — | — |
| 6 | `country_code` | `text` | yes | — | _curated:_ Optional ISO country. |
| 7 | `founded_on` | `date` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `organization_kind_check`: `(kind = 'organization'::text)`

## Relationships

Outbound: `id` → [`corpus.entity`](entity.md)`.id` (+tenant); `tenant_id,id,kind` → [`corpus.entity`](entity.md)`.tenant_id,id,kind` (deferrable).
Inbound: none.
Polymorphic target of: [`content.document_type`](../content/document_type.md) (vocabulary taxonomy.entity_kind.canonical_table + FK document_type_work_entity_kind_fkey), [`corpus.entity`](entity.md) (vocabulary taxonomy.entity_kind.canonical_table + FK entity_kind_fkey), [`orchestration.operation_receipt_target`](../orchestration/operation_receipt_target.md) (vocabulary taxonomy.entity_kind.canonical_table + FK operation_receipt_target_entity_kind_fkey), [`staging.candidate`](../staging/candidate.md) (vocabulary taxonomy.entity_kind.canonical_table + FK candidate_proposed_kind_fkey), [`taxonomy.term_target_kind`](../taxonomy/term_target_kind.md) (vocabulary taxonomy.entity_kind.canonical_table + FK term_target_kind_entity_kind_code_fkey).

## Indexes

`organization_tenant_id_id_key` unique

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

insert: `Database["corpus"]["Tables"]["organization"]["Insert"]`; row: `Database["corpus"]["Tables"]["organization"]["Row"]`; update: `Database["corpus"]["Tables"]["organization"]["Update"]`

## Examples

Typed row for an organization

```bash
knowledge db query entity.typed_row --param entity_id=0192b000-0000-7000-8000-000000000001 --param kind=organization
```
typed_row is to_jsonb of this table when kind matches.

Defined in: `20260826000500_corpus.sql`, `20260912010200_km_02_corpus_identity.sql`.
