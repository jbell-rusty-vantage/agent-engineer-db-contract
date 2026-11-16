---
id: "rel:content.document_type"
kind: table
schema: content
name: document_type
domain: content
lens: corpus
aliases: []
tokens: [content, document_type, content.document_type, code, family, description, is_primary_source, default_chunking_slug, default_extraction_kinds, default_spaces, default_summary_kinds, work_entity_kind, published_at_is_world_time, status, axis_note, promoted_from_census]
summary: null
summary_basis: none
rls: disabled
readers: [app_reader, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, pipeline_agent, service_role]
typescript: "Database[\"content\"][\"Tables\"][\"document_type\"][\"Row\"]"
defined_in: ["20260912010100_km_01_vocabularies.sql"]
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# content.document_type

table in domain `content`, lens `corpus`.

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
| 11 | `status` | `text` | no | `'active'::text` | Open-world kinds: candidate (seen in census, grammar not settled), active, retired. unclassified is always valid. |
| 12 | `axis_note` | `text` | yes | — | — |
| 13 | `promoted_from_census` | `boolean` | no | `false` | — |

## Constraints

- PK (code)
- check `document_type_family_check`: `(family = ANY (ARRAY['regulatory_filing'::text, 'research'::text, 'vendor'::text, 'code'::text, 'media_transcript'::text, 'editorial'::text…`
- check `document_type_status_check`: `(status = ANY (ARRAY['candidate'::text, 'active'::text, 'retired'::text]))`

## Relationships

Outbound: `work_entity_kind` → [`taxonomy.entity_kind`](../taxonomy/entity_kind.md)`.code`.
Inbound: [`content.document`](document.md).document_type_code, [`content.document_kind_assignment`](document_kind_assignment.md).document_type_code, [`content.unit_assertion_mapping`](unit_assertion_mapping.md).document_type_code, [`retrieval.vector_item`](../retrieval/vector_item.md).document_type_code.
Polymorphic: `work_entity_kind` selects one of 39 typed tables listed in [`taxonomy.entity_kind`](../../vocabularies/taxonomy.entity_kind.md) (`canonical_table`) — basis: vocabulary taxonomy.entity_kind.canonical_table + FK document_type_work_entity_kind_fkey.

## Indexes

_None._

## Triggers

_None._

## Row-level security

Disabled.

## Grants

`app_reader`: SELECT; `control_plane`: SELECT; `executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `authenticated`.

## Read paths

- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`, `pipeline_agent`.

## TypeScript

insert: `Database["content"]["Tables"]["document_type"]["Insert"]`; row: `Database["content"]["Tables"]["document_type"]["Row"]`; update: `Database["content"]["Tables"]["document_type"]["Update"]`

Defined in: `20260912010100_km_01_vocabularies.sql`.
