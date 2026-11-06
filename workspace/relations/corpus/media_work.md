---
id: "rel:corpus.media_work"
kind: table
schema: corpus
name: media_work
domain: identity
aliases: []
tokens: [corpus, media_work, corpus.media_work, id, tenant_id, kind, media_kind, platform_code, external_id, url, title, channel_id, published_at, duration_ms, width, height, language]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"corpus\"][\"Tables\"][\"media_work\"][\"Row\"]"
defined_in: ["20260912010200_km_02_corpus_identity.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# corpus.media_work

table in domain `identity`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | — | PK; unique (tenant_id, id); FK → [`corpus.entity`](entity.md).id |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id) |
| 3 | `kind` | `text` | no | `'media_work'::text` | — |
| 4 | `media_kind` | `text` | no | — | — |
| 5 | `platform_code` | `text` | no | — | FK → [`corpus.media_platform`](media_platform.md).code |
| 6 | `external_id` | `text` | yes | — | — |
| 7 | `url` | `text` | yes | — | — |
| 8 | `title` | `text` | no | — | — |
| 9 | `channel_id` | `uuid` | yes | — | FK → [`corpus.media_channel`](media_channel.md).id |
| 10 | `published_at` | `timestamp with time zone` | yes | — | — |
| 11 | `duration_ms` | `integer` | yes | — | — |
| 12 | `width` | `integer` | yes | — | — |
| 13 | `height` | `integer` | yes | — | — |
| 14 | `language` | `text` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `media_work_duration_ms_check`: `((duration_ms IS NULL) OR (duration_ms >= 0))`
- check `media_work_kind_check`: `(kind = 'media_work'::text)`
- check `media_work_media_kind_check`: `(media_kind = ANY (ARRAY['video'::text, 'audio'::text, 'image'::text, 'slide_deck'::text, 'livestream'::text, 'screencast'::text]))`

## Relationships

Outbound: `channel_id` → [`corpus.media_channel`](media_channel.md)`.id` (+tenant); `id` → [`corpus.entity`](entity.md)`.id` (+tenant); `platform_code` → [`corpus.media_platform`](media_platform.md)`.code`; `tenant_id,id,kind` → [`corpus.entity`](entity.md)`.tenant_id,id,kind` (deferrable).
Inbound: [`corpus.media_appearance`](media_appearance.md).media_work_id.
Polymorphic target of: [`content.document_type`](../content/document_type.md) (vocabulary taxonomy.entity_kind.canonical_table + FK document_type_work_entity_kind_fkey), [`corpus.entity`](entity.md) (vocabulary taxonomy.entity_kind.canonical_table + FK entity_kind_fkey), [`orchestration.operation_receipt_target`](../orchestration/operation_receipt_target.md) (vocabulary taxonomy.entity_kind.canonical_table + FK operation_receipt_target_entity_kind_fkey), [`staging.candidate`](../staging/candidate.md) (vocabulary taxonomy.entity_kind.canonical_table + FK candidate_proposed_kind_fkey), [`taxonomy.term_target_kind`](../taxonomy/term_target_kind.md) (vocabulary taxonomy.entity_kind.canonical_table + FK term_target_kind_entity_kind_code_fkey).

## Indexes

`media_work_tenant_id_id_key` unique

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

insert: `Database["corpus"]["Tables"]["media_work"]["Insert"]`; row: `Database["corpus"]["Tables"]["media_work"]["Row"]`; update: `Database["corpus"]["Tables"]["media_work"]["Update"]`

Defined in: `20260912010200_km_02_corpus_identity.sql`.
