---
id: "rel:corpus.person"
kind: table
schema: corpus
name: person
domain: identity
aliases: [people]
tokens: [corpus, person, corpus.person, id, tenant_id, kind, given_name, family_name, orcid]
summary: Typed child of corpus.entity for kind person.
summary_basis: curated
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"corpus\"][\"Tables\"][\"person\"][\"Row\"]"
defined_in: ["20260826000500_corpus.sql", "20260912010200_km_02_corpus_identity.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# corpus.person

table in domain `identity`.

> curated (model_assisted, unreviewed) — Typed child of corpus.entity for kind person.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | — | PK; unique (tenant_id, id); FK → [`corpus.entity`](entity.md).id |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id) |
| 3 | `kind` | `text` | no | `'person'::text` | — |
| 4 | `given_name` | `text` | yes | — | — |
| 5 | `family_name` | `text` | yes | — | — |
| 6 | `orcid` | `text` | yes | — | _curated:_ Optional; also store scheme orcid on entity_identifier when known. |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `person_kind_check`: `(kind = 'person'::text)`

## Relationships

Outbound: `id` → [`corpus.entity`](entity.md)`.id` (+tenant); `tenant_id,id,kind` → [`corpus.entity`](entity.md)`.tenant_id,id,kind` (deferrable).
Inbound: none.
Polymorphic target of: [`content.document_type`](../content/document_type.md) (vocabulary taxonomy.entity_kind.canonical_table + FK document_type_work_entity_kind_fkey), [`corpus.entity`](entity.md) (vocabulary taxonomy.entity_kind.canonical_table + FK entity_kind_fkey), [`orchestration.operation_receipt_target`](../orchestration/operation_receipt_target.md) (vocabulary taxonomy.entity_kind.canonical_table + FK operation_receipt_target_entity_kind_fkey), [`staging.candidate`](../staging/candidate.md) (vocabulary taxonomy.entity_kind.canonical_table + FK candidate_proposed_kind_fkey), [`taxonomy.term_target_kind`](../taxonomy/term_target_kind.md) (vocabulary taxonomy.entity_kind.canonical_table + FK term_target_kind_entity_kind_code_fkey).

## Indexes

`person_tenant_id_id_key` unique

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

insert: `Database["corpus"]["Tables"]["person"]["Insert"]`; row: `Database["corpus"]["Tables"]["person"]["Row"]`; update: `Database["corpus"]["Tables"]["person"]["Update"]`

## Examples

Resolve a person name

```bash
knowledge db query entity.resolve --param text=Sam Altman
```
Then load entity.typed_row with kind person.

Defined in: `20260826000500_corpus.sql`, `20260912010200_km_02_corpus_identity.sql`.
