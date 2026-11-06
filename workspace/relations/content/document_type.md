---
id: "rel:content.document_type"
kind: table
schema: content
name: document_type
domain: content
aliases: []
tokens: [content, document_type, content.document_type, code, family, description, is_primary_source, default_chunking_slug, default_extraction_kinds, default_spaces, default_summary_kinds, work_entity_kind, published_at_is_world_time]
summary: null
summary_basis: none
rls: disabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, pipeline_agent, service_role]
typescript: "Database[\"content\"][\"Tables\"][\"document_type\"][\"Row\"]"
defined_in: ["20260912010100_km_01_vocabularies.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# content.document_type

table in domain `content`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `code` | `text` | no | — | PK |
| 2 | `family` | `text` | no | — | — |
| 3 | `description` | `text` | no | — | — |
| 4 | `is_primary_source` | `boolean` | no | — | — |
| 5 | `default_chunking_slug` | `text` | no | — | — |
| 6 | `default_extraction_kinds` | `text[]` | no | — | — |
| 7 | `default_spaces` | `text[]` | no | — | — |
| 8 | `default_summary_kinds` | `text[]` | no | `'{abstract}'::text[]` | — |
| 9 | `work_entity_kind` | `text` | yes | — | FK → [`taxonomy.entity_kind`](../taxonomy/entity_kind.md).code |
| 10 | `published_at_is_world_time` | `boolean` | no | `true` | — |

## Constraints

- PK (code)
- check `document_type_family_check`: `(family = ANY (ARRAY['regulatory_filing'::text, 'research'::text, 'vendor'::text, 'code'::text, 'media_transcript'::text, 'editorial'::text…`

## Relationships

Outbound: `work_entity_kind` → [`taxonomy.entity_kind`](../taxonomy/entity_kind.md)`.code`.
Inbound: [`content.document`](document.md).document_type_code, [`retrieval.vector_item`](../retrieval/vector_item.md).document_type_code.
Polymorphic: `work_entity_kind` selects one of 36 typed tables listed in [`taxonomy.entity_kind`](../../vocabularies/taxonomy.entity_kind.md) (`canonical_table`) — basis: vocabulary taxonomy.entity_kind.canonical_table + FK document_type_work_entity_kind_fkey.

## Indexes

_None._

## Triggers

_None._

## Row-level security

Disabled.

## Grants

`control_plane`: SELECT; `executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`, `pipeline_agent`.

## TypeScript

insert: `Database["content"]["Tables"]["document_type"]["Insert"]`; row: `Database["content"]["Tables"]["document_type"]["Row"]`; update: `Database["content"]["Tables"]["document_type"]["Update"]`

Defined in: `20260912010100_km_01_vocabularies.sql`.
