---
id: "rel:corpus.library_release"
kind: table
schema: corpus
name: library_release
domain: identity
aliases: []
tokens: [corpus, library_release, corpus.library_release, id, tenant_id, kind, library_id, version_label, registry_id, source_revision_id, license_code, released_on]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"corpus\"][\"Tables\"][\"library_release\"][\"Row\"]"
defined_in: ["20260912010200_km_02_corpus_identity.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# corpus.library_release

table in domain `identity`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | — | PK; unique (tenant_id, id); FK → [`corpus.entity`](entity.md).id |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id) |
| 3 | `kind` | `text` | no | `'library_release'::text` | — |
| 4 | `library_id` | `uuid` | no | — | FK → [`corpus.library`](library.md).id |
| 5 | `version_label` | `text` | no | — | — |
| 6 | `registry_id` | `uuid` | yes | — | FK → [`corpus.registry`](registry.md).id |
| 7 | `source_revision_id` | `uuid` | yes | — | FK → [`corpus.repository_revision`](repository_revision.md).id |
| 8 | `license_code` | `text` | yes | — | FK → [`corpus.license`](license.md).code |
| 9 | `released_on` | `date` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `library_release_kind_check`: `(kind = 'library_release'::text)`

## Relationships

Outbound: `id` → [`corpus.entity`](entity.md)`.id` (+tenant); `library_id` → [`corpus.library`](library.md)`.id` (+tenant); `license_code` → [`corpus.license`](license.md)`.code`; `registry_id` → [`corpus.registry`](registry.md)`.id` (+tenant); `source_revision_id` → [`corpus.repository_revision`](repository_revision.md)`.id` (+tenant); `tenant_id,id,kind` → [`corpus.entity`](entity.md)`.tenant_id,id,kind` (deferrable).
Inbound: none.
Polymorphic target of: [`content.document_type`](../content/document_type.md) (vocabulary taxonomy.entity_kind.canonical_table + FK document_type_work_entity_kind_fkey), [`corpus.entity`](entity.md) (vocabulary taxonomy.entity_kind.canonical_table + FK entity_kind_fkey), [`orchestration.operation_receipt_target`](../orchestration/operation_receipt_target.md) (vocabulary taxonomy.entity_kind.canonical_table + FK operation_receipt_target_entity_kind_fkey), [`staging.candidate`](../staging/candidate.md) (vocabulary taxonomy.entity_kind.canonical_table + FK candidate_proposed_kind_fkey), [`taxonomy.term_target_kind`](../taxonomy/term_target_kind.md) (vocabulary taxonomy.entity_kind.canonical_table + FK term_target_kind_entity_kind_code_fkey).

## Indexes

`library_release_tenant_id_id_key` unique

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

insert: `Database["corpus"]["Tables"]["library_release"]["Insert"]`; row: `Database["corpus"]["Tables"]["library_release"]["Row"]`; update: `Database["corpus"]["Tables"]["library_release"]["Update"]`

Defined in: `20260912010200_km_02_corpus_identity.sql`.
