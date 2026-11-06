---
id: "rel:corpus.ai_protocol_version"
kind: table
schema: corpus
name: ai_protocol_version
domain: identity
aliases: []
tokens: [corpus, ai_protocol_version, corpus.ai_protocol_version, id, tenant_id, kind, ai_protocol_id, version_label, specification_url]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"corpus\"][\"Tables\"][\"ai_protocol_version\"][\"Row\"]"
defined_in: ["20260826000500_corpus.sql", "20260912010200_km_02_corpus_identity.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# corpus.ai_protocol_version

table in domain `identity`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | — | PK; unique (tenant_id, id); FK → [`corpus.entity`](entity.md).id |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id) |
| 3 | `kind` | `text` | no | `'ai_protocol_version'::text` | — |
| 4 | `ai_protocol_id` | `uuid` | no | — | FK → [`corpus.ai_protocol`](ai_protocol.md).id |
| 5 | `version_label` | `text` | no | — | — |
| 6 | `specification_url` | `text` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `ai_protocol_version_kind_check`: `(kind = 'ai_protocol_version'::text)`

## Relationships

Outbound: `ai_protocol_id` → [`corpus.ai_protocol`](ai_protocol.md)`.id` (+tenant); `id` → [`corpus.entity`](entity.md)`.id` (+tenant); `tenant_id,id,kind` → [`corpus.entity`](entity.md)`.tenant_id,id,kind` (deferrable).
Inbound: none.
Polymorphic target of: [`content.document_type`](../content/document_type.md) (vocabulary taxonomy.entity_kind.canonical_table + FK document_type_work_entity_kind_fkey), [`corpus.entity`](entity.md) (vocabulary taxonomy.entity_kind.canonical_table + FK entity_kind_fkey), [`orchestration.operation_receipt_target`](../orchestration/operation_receipt_target.md) (vocabulary taxonomy.entity_kind.canonical_table + FK operation_receipt_target_entity_kind_fkey), [`staging.candidate`](../staging/candidate.md) (vocabulary taxonomy.entity_kind.canonical_table + FK candidate_proposed_kind_fkey), [`taxonomy.term_target_kind`](../taxonomy/term_target_kind.md) (vocabulary taxonomy.entity_kind.canonical_table + FK term_target_kind_entity_kind_code_fkey).

## Indexes

`ai_protocol_version_tenant_id_id_key` unique

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

insert: `Database["corpus"]["Tables"]["ai_protocol_version"]["Insert"]`; row: `Database["corpus"]["Tables"]["ai_protocol_version"]["Row"]`; update: `Database["corpus"]["Tables"]["ai_protocol_version"]["Update"]`

Defined in: `20260826000500_corpus.sql`, `20260912010200_km_02_corpus_identity.sql`.
