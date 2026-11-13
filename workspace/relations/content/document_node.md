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
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# content.document_node

table in domain `content`, lens `corpus` — A typed unit of a representation: unit_kind (+version) from content.unit_kind, validated attributes, a logical_key stable across captures (grammar logical key), a stable_local_key within this representation, and typed position (offsets, page, bbox, timecodes)..

> curated (model_assisted, unreviewed) — A typed unit of a representation — unit_kind from the grammar, validated attributes, a logical_key stable across captures and a typed position.

## Columns

`id` uuid not null, `tenant_id` uuid not null, `representation_id` uuid not null, `parent_id` uuid, `ordinal` integer not null, `stable_local_key` text not null, `unit_kind` text not null, `role` text, `inline_text` text, `artifact_id` uuid, `selector` jsonb not null, `page_number` integer, `start_offset` integer, `end_offset` integer, `bbox` jsonb, `language` text, `normalized_content_sha256` text not null, `created_at` timestamp with time zone not null, `start_ms` integer, `end_ms` integer, `speaker_entity_id` uuid, `unit_kind_version` integer not null, `attributes` jsonb not null, `logical_key` text, `grammar_version` text

Full column table: [details](document_node.details.md).

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, representation_id, parent_id, ordinal)
- unique (tenant_id, representation_id, stable_local_key)
- unique (tenant_id, representation_id, id)
- 7 check constraints; see [details](document_node.details.md)

## Relationships

5 outbound and 19 inbound foreign keys; full list in [details](document_node.details.md).

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
- Exposed through: [`api.api_symbols`](../api/api_symbols.md), [`api.bundle_files`](../api/bundle_files.md), [`api.claim_candidates`](../api/claim_candidates.md), [`api.claim_surfaces`](../api/claim_surfaces.md), [`api.digest_items`](../api/digest_items.md), [`api.endpoints`](../api/endpoints.md), [`api.hook_entries`](../api/hook_entries.md), [`api.mcp_prompts`](../api/mcp_prompts.md), [`api.mcp_resources`](../api/mcp_resources.md), [`api.mcp_tools`](../api/mcp_tools.md), [`api.symbol_docs`](../api/symbol_docs.md).
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
