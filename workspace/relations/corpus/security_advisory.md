---
id: "rel:corpus.security_advisory"
kind: table
schema: corpus
name: security_advisory
domain: identity
aliases: []
tokens: [corpus, security_advisory, corpus.security_advisory, id, tenant_id, kind, advisory_id, ecosystem, canonical_url, description]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"corpus\"][\"Tables\"][\"security_advisory\"][\"Row\"]"
defined_in: ["20260912010200_km_02_corpus_identity.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# corpus.security_advisory

table in domain `identity`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | — | PK; unique (tenant_id, id); FK → [`corpus.entity`](entity.md).id |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id) |
| 3 | `kind` | `text` | no | `'security_advisory'::text` | — |
| 4 | `advisory_id` | `text` | no | — | — |
| 5 | `ecosystem` | `text` | yes | — | — |
| 6 | `canonical_url` | `text` | yes | — | — |
| 7 | `description` | `text` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `security_advisory_kind_check`: `(kind = 'security_advisory'::text)`

## Relationships

Outbound: `id` → [`corpus.entity`](entity.md)`.id` (+tenant); `tenant_id,id,kind` → [`corpus.entity`](entity.md)`.tenant_id,id,kind` (deferrable).
Inbound: none.
Polymorphic target of: [`content.document_type`](../content/document_type.md) (vocabulary taxonomy.entity_kind.canonical_table + FK document_type_work_entity_kind_fkey), [`corpus.entity`](entity.md) (vocabulary taxonomy.entity_kind.canonical_table + FK entity_kind_fkey), [`orchestration.operation_receipt_target`](../orchestration/operation_receipt_target.md) (vocabulary taxonomy.entity_kind.canonical_table + FK operation_receipt_target_entity_kind_fkey), [`staging.candidate`](../staging/candidate.md) (vocabulary taxonomy.entity_kind.canonical_table + FK candidate_proposed_kind_fkey), [`taxonomy.term_target_kind`](../taxonomy/term_target_kind.md) (vocabulary taxonomy.entity_kind.canonical_table + FK term_target_kind_entity_kind_code_fkey).

## Indexes

`security_advisory_tenant_id_id_key` unique

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

insert: `Database["corpus"]["Tables"]["security_advisory"]["Insert"]`; row: `Database["corpus"]["Tables"]["security_advisory"]["Row"]`; update: `Database["corpus"]["Tables"]["security_advisory"]["Update"]`

Defined in: `20260912010200_km_02_corpus_identity.sql`.
