---
id: "rel:corpus.repository"
kind: table
schema: corpus
name: repository
domain: identity
aliases: []
tokens: [corpus, repository, corpus.repository, id, tenant_id, kind, host, owner, name, provider_native_id, created_at_host, is_fork, fork_of_repository_id]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"corpus\"][\"Tables\"][\"repository\"][\"Row\"]"
defined_in: ["20260826000500_corpus.sql", "20260912010200_km_02_corpus_identity.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# corpus.repository

table in domain `identity`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | — | PK; unique (tenant_id, id); FK → [`corpus.entity`](entity.md).id |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, host, owner, name); unique (tenant_id, id) |
| 3 | `kind` | `text` | no | `'repository'::text` | — |
| 4 | `host` | `text` | no | — | unique (tenant_id, host, owner, name) |
| 5 | `owner` | `text` | no | — | unique (tenant_id, host, owner, name) |
| 6 | `name` | `text` | no | — | unique (tenant_id, host, owner, name) |
| 7 | `provider_native_id` | `text` | yes | — | — |
| 8 | `created_at_host` | `timestamp with time zone` | yes | — | — |
| 9 | `is_fork` | `boolean` | no | `false` | — |
| 10 | `fork_of_repository_id` | `uuid` | yes | — | FK → [`corpus.repository`](repository.md).id |

## Constraints

- PK (id)
- unique (tenant_id, host, owner, name)
- unique (tenant_id, id)
- check `repository_kind_check`: `(kind = 'repository'::text)`

## Relationships

Outbound: `fork_of_repository_id` → [`corpus.repository`](repository.md)`.id` (+tenant); `id` → [`corpus.entity`](entity.md)`.id` (+tenant); `tenant_id,id,kind` → [`corpus.entity`](entity.md)`.tenant_id,id,kind` (deferrable).
Inbound: [`corpus.repository`](repository.md).fork_of_repository_id, [`corpus.repository_file`](repository_file.md).repository_id, [`corpus.repository_module`](repository_module.md).repository_id, [`corpus.repository_revision`](repository_revision.md).repository_id.
Polymorphic target of: [`content.document_type`](../content/document_type.md) (vocabulary taxonomy.entity_kind.canonical_table + FK document_type_work_entity_kind_fkey), [`corpus.entity`](entity.md) (vocabulary taxonomy.entity_kind.canonical_table + FK entity_kind_fkey), [`orchestration.operation_receipt_target`](../orchestration/operation_receipt_target.md) (vocabulary taxonomy.entity_kind.canonical_table + FK operation_receipt_target_entity_kind_fkey), [`staging.candidate`](../staging/candidate.md) (vocabulary taxonomy.entity_kind.canonical_table + FK candidate_proposed_kind_fkey), [`taxonomy.term_target_kind`](../taxonomy/term_target_kind.md) (vocabulary taxonomy.entity_kind.canonical_table + FK term_target_kind_entity_kind_code_fkey).

## Indexes

`repository_tenant_id_host_owner_name_key` unique; `repository_tenant_id_id_key` unique

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

insert: `Database["corpus"]["Tables"]["repository"]["Insert"]`; row: `Database["corpus"]["Tables"]["repository"]["Row"]`; update: `Database["corpus"]["Tables"]["repository"]["Update"]`

Defined in: `20260826000500_corpus.sql`, `20260912010200_km_02_corpus_identity.sql`.
