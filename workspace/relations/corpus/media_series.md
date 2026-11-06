---
id: "rel:corpus.media_series"
kind: table
schema: corpus
name: media_series
domain: identity
aliases: []
tokens: [corpus, media_series, corpus.media_series, id, tenant_id, kind, series_kind, platform_code, external_id, title, description, primary_channel_id, industry_event_id]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"corpus\"][\"Tables\"][\"media_series\"][\"Row\"]"
defined_in: ["20260912010200_km_02_corpus_identity.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# corpus.media_series

table in domain `identity`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | — | PK; unique (tenant_id, id); FK → [`corpus.entity`](entity.md).id |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id) |
| 3 | `kind` | `text` | no | `'media_series'::text` | — |
| 4 | `series_kind` | `text` | no | — | — |
| 5 | `platform_code` | `text` | yes | — | FK → [`corpus.media_platform`](media_platform.md).code |
| 6 | `external_id` | `text` | yes | — | — |
| 7 | `title` | `text` | no | — | — |
| 8 | `description` | `text` | yes | — | — |
| 9 | `primary_channel_id` | `uuid` | yes | — | FK → [`corpus.media_channel`](media_channel.md).id |
| 10 | `industry_event_id` | `uuid` | yes | — | FK → [`corpus.industry_event`](industry_event.md).id |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `media_series_kind_check`: `(kind = 'media_series'::text)`
- check `media_series_series_kind_check`: `(series_kind = ANY (ARRAY['playlist'::text, 'podcast_show'::text, 'recurring_show'::text, 'conference_recordings'::text, 'course'::text, 'l…`

## Relationships

Outbound: `id` → [`corpus.entity`](entity.md)`.id` (+tenant); `industry_event_id` → [`corpus.industry_event`](industry_event.md)`.id` (+tenant); `platform_code` → [`corpus.media_platform`](media_platform.md)`.code`; `primary_channel_id` → [`corpus.media_channel`](media_channel.md)`.id` (+tenant); `tenant_id,id,kind` → [`corpus.entity`](entity.md)`.tenant_id,id,kind` (deferrable).
Inbound: none.
Polymorphic target of: [`content.document_type`](../content/document_type.md) (vocabulary taxonomy.entity_kind.canonical_table + FK document_type_work_entity_kind_fkey), [`corpus.entity`](entity.md) (vocabulary taxonomy.entity_kind.canonical_table + FK entity_kind_fkey), [`orchestration.operation_receipt_target`](../orchestration/operation_receipt_target.md) (vocabulary taxonomy.entity_kind.canonical_table + FK operation_receipt_target_entity_kind_fkey), [`staging.candidate`](../staging/candidate.md) (vocabulary taxonomy.entity_kind.canonical_table + FK candidate_proposed_kind_fkey), [`taxonomy.term_target_kind`](../taxonomy/term_target_kind.md) (vocabulary taxonomy.entity_kind.canonical_table + FK term_target_kind_entity_kind_code_fkey).

## Indexes

`media_series_tenant_id_id_key` unique

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

insert: `Database["corpus"]["Tables"]["media_series"]["Insert"]`; row: `Database["corpus"]["Tables"]["media_series"]["Row"]`; update: `Database["corpus"]["Tables"]["media_series"]["Update"]`

Defined in: `20260912010200_km_02_corpus_identity.sql`.
