---
id: "rel:content.document_node"
kind: table
schema: content
name: document_node
domain: content
lens: corpus
aliases: [typed unit, unit, node]
tokens: [content, document_node, content.document_node, id, tenant_id, representation_id, parent_id, ordinal, stable_local_key, unit_kind, role, inline_text, artifact_id, selector, page_number, start_offset, end_offset, bbox, language, normalized_content_sha256, created_at, start_ms, end_ms, speaker_entity_id, unit_kind_version, attributes, logical_key, grammar_version]
summary: "A typed unit of a representation — unit_kind from the grammar, validated attributes, a logical_key stable across captures and a typed position."
summary_basis: curated
rls: enabled
readers: [app_reader, executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"content\"][\"Tables\"][\"document_node\"][\"Row\"]"
defined_in: ["20260903010000_knowledge_content_contract.sql"]
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
---
# content.document_node

table in domain `content`, lens `corpus` — A typed unit of a representation: unit_kind (+version) from content.unit_kind, validated attributes, a logical_key stable across captures (grammar logical key), a stable_local_key within this representation, and typed position (offsets, page, bbox, timecodes)..

> curated (model_assisted, unreviewed) — A typed unit of a representation — unit_kind from the grammar, validated attributes, a logical_key stable across captures and a typed position.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id); unique (tenant_id, representation_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id); unique (tenant_id, representation_id, parent_id, ordinal); unique (tenant_id, representation_id, stable_local_key); unique (tenant_id, representation_id, id) |
| 3 | `representation_id` | `uuid` | no | — | unique (tenant_id, representation_id, parent_id, ordinal); unique (tenant_id, representation_id, stable_local_key); unique (tenant_id, representation_id, id) |
| 4 | `parent_id` | `uuid` | yes | — | unique (tenant_id, representation_id, parent_id, ordinal) |
| 5 | `ordinal` | `integer` | no | — | unique (tenant_id, representation_id, parent_id, ordinal) |
| 6 | `stable_local_key` | `text` | no | — | unique (tenant_id, representation_id, stable_local_key); _curated:_ Stable within this representation. |
| 7 | `unit_kind` | `text` | no | — | _curated:_ content.unit_kind code (+ unit_kind_version). |
| 8 | `role` | `text` | yes | — | — |
| 9 | `inline_text` | `text` | yes | — | — |
| 10 | `artifact_id` | `uuid` | yes | — | — |
| 11 | `selector` | `jsonb` | no | `'{}'::jsonb` | — |
| 12 | `page_number` | `integer` | yes | — | — |
| 13 | `start_offset` | `integer` | yes | — | — |
| 14 | `end_offset` | `integer` | yes | — | — |
| 15 | `bbox` | `jsonb` | yes | — | — |
| 16 | `language` | `text` | yes | — | — |
| 17 | `normalized_content_sha256` | `text` | no | — | — |
| 18 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 19 | `start_ms` | `integer` | yes | — | _curated:_ Timecode units (transcript_segment, media_segment): window start. |
| 20 | `end_ms` | `integer` | yes | — | — |
| 21 | `speaker_entity_id` | `uuid` | yes | — | FK → [`catalog.entity`](../catalog/entity.md).id |
| 22 | `unit_kind_version` | `integer` | no | `1` | — |
| 23 | `attributes` | `jsonb` | no | `'{}'::jsonb` | _curated:_ Validated by the unit kind's attributes_schema (content.validate_unit_attributes). |
| 24 | `logical_key` | `text` | yes | — | Grammar logical key: unit_kind + the logical_key_attributes values, so the same unit can be matched across versions for diffs (price_row:gpt-6.1\|input_tokens\|standard\|global).; _curated:_ unit_kind + logical_key_attributes values, e.g. price_row:gpt-6.1\|input_tokens\|standard\|global; stable across versions for diffs. |
| 25 | `grammar_version` | `text` | yes | — | _curated:_ Grammar (unit kind set + parser) that produced the unit; a later grammar never reinterprets old units silently. |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, representation_id, parent_id, ordinal)
- unique (tenant_id, representation_id, stable_local_key)
- unique (tenant_id, representation_id, id)
- 7 check constraints; see [details](document_node.details.md)

## Relationships

5 outbound and 16 inbound foreign keys; full list in [details](document_node.details.md).

## Indexes

7 indexes; see [details](document_node.details.md).

## Triggers

3 triggers; see [details](document_node.details.md).

## Row-level security

Enabled; 1 policies in [details](document_node.details.md).

## Grants

`app_reader`: SELECT; `executor_service`: INSERT, SELECT; `service_role`: INSERT, SELECT. None: `anon`, `authenticated`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Named queries: `q:content.document_units`, `q:content.talk_segments`, `q:facts.changes_since`, `q:facts.locators`, `q:retrieval.evidence_packet`.
- Exposed through: [`api.claim_candidates`](../api/claim_candidates.md).
- Direct SELECT: `app_reader`, `executor_service`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["content"]["Tables"]["document_node"]["Insert"]`; row: `Database["content"]["Tables"]["document_node"]["Row"]`; update: `Database["content"]["Tables"]["document_node"]["Update"]`

## Examples

Transcript window of a talk

```bash
knowledge db query content.talk_segments --param from_ms=0 --param query=null --param talk_id=0192b000-0000-7000-8000-000000000001 --param to_ms=600000
```
node_id is the citation anchor.

Defined in: `20260903010000_knowledge_content_contract.sql`.
