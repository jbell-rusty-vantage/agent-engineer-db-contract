---
id: "rel:corpus.media_channel"
kind: table
schema: corpus
name: media_channel
domain: identity
aliases: []
tokens: [corpus, media_channel, corpus.media_channel, id, tenant_id, kind, platform_code, external_id, handle, title, url, owner_entity_id, created_at_platform]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"corpus\"][\"Tables\"][\"media_channel\"][\"Row\"]"
defined_in: ["20260912010200_km_02_corpus_identity.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# corpus.media_channel

table in domain `identity`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | — | PK; unique (tenant_id, id); FK → [`corpus.entity`](entity.md).id |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id); unique (tenant_id, platform_code, external_id) |
| 3 | `kind` | `text` | no | `'media_channel'::text` | — |
| 4 | `platform_code` | `text` | no | — | unique (tenant_id, platform_code, external_id); FK → [`corpus.media_platform`](media_platform.md).code |
| 5 | `external_id` | `text` | no | — | unique (tenant_id, platform_code, external_id) |
| 6 | `handle` | `text` | yes | — | — |
| 7 | `title` | `text` | no | — | — |
| 8 | `url` | `text` | yes | — | — |
| 9 | `owner_entity_id` | `uuid` | yes | — | FK → [`corpus.entity`](entity.md).id |
| 10 | `created_at_platform` | `timestamp with time zone` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, platform_code, external_id)
- check `media_channel_kind_check`: `(kind = 'media_channel'::text)`

## Relationships

Outbound: `id` → [`corpus.entity`](entity.md)`.id` (+tenant); `owner_entity_id` → [`corpus.entity`](entity.md)`.id` (+tenant); `platform_code` → [`corpus.media_platform`](media_platform.md)`.code`; `tenant_id,id,kind` → [`corpus.entity`](entity.md)`.tenant_id,id,kind` (deferrable).
Inbound: [`corpus.media_series`](media_series.md).primary_channel_id, [`corpus.media_work`](media_work.md).channel_id.
Polymorphic target of: [`content.document_type`](../content/document_type.md) (vocabulary taxonomy.entity_kind.canonical_table + FK document_type_work_entity_kind_fkey), [`corpus.entity`](entity.md) (vocabulary taxonomy.entity_kind.canonical_table + FK entity_kind_fkey), [`orchestration.operation_receipt_target`](../orchestration/operation_receipt_target.md) (vocabulary taxonomy.entity_kind.canonical_table + FK operation_receipt_target_entity_kind_fkey), [`staging.candidate`](../staging/candidate.md) (vocabulary taxonomy.entity_kind.canonical_table + FK candidate_proposed_kind_fkey), [`taxonomy.term_target_kind`](../taxonomy/term_target_kind.md) (vocabulary taxonomy.entity_kind.canonical_table + FK term_target_kind_entity_kind_code_fkey).

## Indexes

`media_channel_tenant_id_id_key` unique; `media_channel_tenant_id_platform_code_external_id_key` unique

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
- Via functions (best effort): [`corpus.import_research_starter_catalog`](../../functions/corpus/import_research_starter_catalog.md).

## TypeScript

insert: `Database["corpus"]["Tables"]["media_channel"]["Insert"]`; row: `Database["corpus"]["Tables"]["media_channel"]["Row"]`; update: `Database["corpus"]["Tables"]["media_channel"]["Update"]`

Defined in: `20260912010200_km_02_corpus_identity.sql`.
