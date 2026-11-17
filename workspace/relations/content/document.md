---
id: "rel:content.document"
kind: table
schema: content
name: document
domain: content
lens: corpus
aliases: [document]
tokens: [content, document, content.document, id, tenant_id, document_type_code, canonical_title, canonical_source_id, lifecycle, created_by_attempt_id, supersedes_id, created_at, work_entity_id, source_role_code, source_role_method, attributes]
summary: "Identity of a captured work; typed open-world (document_type_code is the initial kind), with who speaks (source_role_code) and the work entity it belongs to."
summary_basis: curated
rls: enabled
readers: [app_reader, executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"content\"][\"Tables\"][\"document\"][\"Row\"]"
defined_in: ["20260903010000_knowledge_content_contract.sql"]
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# content.document

table in domain `content`, lens `corpus`.

> curated (model_assisted, unreviewed) — Identity of a captured work; typed open-world (document_type_code is the initial kind), with who speaks (source_role_code) and the work entity it belongs to.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id) |
| 3 | `document_type_code` | `text` | no | — | FK → [`content.document_type`](document_type.md).code; _curated:_ Initial kind assignment; the current one is the content.document_kind_assignment with superseded_by_id null. |
| 4 | `canonical_title` | `text` | no | — | — |
| 5 | `canonical_source_id` | `uuid` | yes | — | _curated:_ evidence.source the document is captured from. |
| 6 | `lifecycle` | `text` | no | `'active'::text` | — |
| 7 | `created_by_attempt_id` | `uuid` | yes | — | — |
| 8 | `supersedes_id` | `uuid` | yes | — | — |
| 9 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 10 | `work_entity_id` | `uuid` | yes | — | FK → [`catalog.entity`](../catalog/entity.md).id; _curated:_ catalog.entity of kind talk, paper, media_work, … whose content this is. |
| 12 | `source_role_code` | `text` | yes | — | FK → [`content.source_role`](source_role.md).code; Source-role axis: who speaks (content.source_role); set by rule (URL/publisher), model or person.; _curated:_ Who speaks (content.source_role); set by rule (URL/publisher), model or person (source_role_method). |
| 13 | `source_role_method` | `text` | yes | — | — |
| 14 | `attributes` | `jsonb` | no | `'{}'::jsonb` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `document_check`: `((supersedes_id IS NULL) OR (supersedes_id <> id))`
- check `document_lifecycle_check`: `(lifecycle = ANY (ARRAY['active'::text, 'deprecated'::text, 'retracted'::text, 'deleted'::text, 'superseded'::text]))`
- check `document_source_role_method_check`: `(source_role_method = ANY (ARRAY['rule'::text, 'model'::text, 'person'::text, 'default'::text]))`

## Relationships

6 outbound and 9 inbound foreign keys; full list in [details](document.details.md).

## Indexes

2 indexes; see [details](document.details.md).

## Triggers

3 triggers; see [details](document.details.md).

## Row-level security

Enabled; 1 policies in [details](document.details.md).

## Grants

`app_reader`: SELECT; `executor_service`: INSERT, SELECT; `service_role`: INSERT, SELECT. None: `anon`, `authenticated`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Named queries: `q:catalog.papers`, `q:catalog.talks`, `q:content.document_units`, `q:content.talk_segments`, `q:evidence.claim`, `q:evidence.verified_claims`, `q:facts.changes_since`.
- Exposed through: [`api.api_symbols`](../api/api_symbols.md), [`api.bundle_files`](../api/bundle_files.md), [`api.capabilities`](../api/capabilities.md), [`api.claim_candidates`](../api/claim_candidates.md), [`api.claim_surfaces`](../api/claim_surfaces.md), [`api.community_claims`](../api/community_claims.md), [`api.digest_items`](../api/digest_items.md), [`api.endpoints`](../api/endpoints.md), [`api.hook_entries`](../api/hook_entries.md), [`api.mcp_prompts`](../api/mcp_prompts.md), [`api.mcp_resources`](../api/mcp_resources.md), [`api.mcp_tools`](../api/mcp_tools.md), [`api.papers`](../api/papers.md), [`api.symbol_docs`](../api/symbol_docs.md), [`api.talks`](../api/talks.md).
- Direct SELECT: `app_reader`, `executor_service`.

## Write path

- Direct DML: `executor_service`.
- Via functions (best effort): [`catalog.import_research_starter_catalog`](../../functions/catalog/import_research_starter_catalog.md).

## TypeScript

insert: `Database["content"]["Tables"]["document"]["Insert"]`; row: `Database["content"]["Tables"]["document"]["Row"]`; update: `Database["content"]["Tables"]["document"]["Update"]`

## Examples

Units of a document

```bash
knowledge db query content.document_units --param document_id=0192b000-0000-7000-8000-000000000001 --param unit_kinds=null
```
Newest version first.

Defined in: `20260903010000_knowledge_content_contract.sql`.
