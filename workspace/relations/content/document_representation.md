---
id: "rel:content.document_representation"
kind: table
schema: content
name: document_representation
domain: content
lens: corpus
aliases: []
tokens: [content, document_representation, content.document_representation, id, tenant_id, document_version_id, artifact_id, representation_kind, representation_class, media_type, language, content_sha256, transformation_run_id, acceptance_state, source_native_byte_identical, supersedes_id, created_at, grammar_version]
summary: null
summary_basis: none
rls: enabled
readers: [app_reader, executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"content\"][\"Tables\"][\"document_representation\"][\"Row\"]"
defined_in: ["20260903010000_knowledge_content_contract.sql"]
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# content.document_representation

table in domain `content`, lens `corpus`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id) |
| 3 | `document_version_id` | `uuid` | no | — | — |
| 4 | `artifact_id` | `uuid` | no | — | — |
| 5 | `representation_kind` | `text` | no | — | — |
| 6 | `representation_class` | `text` | no | — | — |
| 7 | `media_type` | `text` | no | — | — |
| 8 | `language` | `text` | yes | — | — |
| 9 | `content_sha256` | `text` | no | — | — |
| 10 | `transformation_run_id` | `uuid` | yes | — | — |
| 11 | `acceptance_state` | `text` | no | `'pending'::text` | — |
| 12 | `source_native_byte_identical` | `boolean` | no | `false` | — |
| 13 | `supersedes_id` | `uuid` | yes | — | — |
| 14 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 15 | `grammar_version` | `text` | yes | — | The grammar (unit_kind set + parser version) that produced this representation's units; a later grammar never reinterprets old units silently. |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `document_representation_acceptance_state_check`: `(acceptance_state = ANY (ARRAY['pending'::text, 'accepted'::text, 'rejected'::text, 'quarantined'::text, 'deferred'::text, 'superseded'::te…`
- check `document_representation_check`: `((supersedes_id IS NULL) OR (supersedes_id <> id))`
- check `document_representation_check1`: `((NOT source_native_byte_identical) OR (representation_class = 'source_native'::text))`
- check `document_representation_content_sha256_check`: `(content_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `document_representation_representation_class_check`: `(representation_class = ANY (ARRAY['source_native'::text, 'rendered_snapshot'::text, 'faithful_normalization'::text, 'structural_extraction…`
- check `representation_kind_v2`: `(representation_kind = ANY (ARRAY['captured_source'::text, 'structural_document'::text, 'source_native'::text, 'markdown'::text, 'plain_tex…`

## Relationships

Outbound: `tenant_id,artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict; `tenant_id,document_version_id` → [`content.document_version`](document_version.md)`.tenant_id,id` on delete restrict; `tenant_id,supersedes_id` → [`content.document_representation`](document_representation.md)`.tenant_id,id` on delete restrict; `tenant_id,transformation_run_id` → [`content.transformation_run`](transformation_run.md)`.tenant_id,id` on delete restrict.
Inbound: [`content.conversion_evaluation`](conversion_evaluation.md).representation_id, [`content.document_node`](document_node.md).representation_id, [`content.document_representation`](document_representation.md).supersedes_id, [`content.document_summary`](document_summary.md).derived_from_representation_id|representation_id, [`content.representation_decision`](representation_decision.md).representation_id, [`content.structure_census`](structure_census.md).representation_id, [`content.transformation_input`](transformation_input.md).representation_id, [`content.transformation_output`](transformation_output.md).representation_id, [`evidence.extraction_run`](../evidence/extraction_run.md).representation_id, [`retrieval.chunk_set`](../retrieval/chunk_set.md).representation_id, [`retrieval.packet_member`](../retrieval/packet_member.md).source_representation_id, [`retrieval.vector_store_document`](../retrieval/vector_store_document.md).representation_id.

## Indexes

2 indexes; see [details](document_representation.details.md).

## Triggers

3 triggers; see [details](document_representation.details.md).

## Row-level security

Enabled; 1 policies in [details](document_representation.details.md).

## Grants

`app_reader`: SELECT; `executor_service`: INSERT, SELECT; `service_role`: INSERT, SELECT. None: `anon`, `authenticated`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Named queries: `q:content.document_units`, `q:content.talk_segments`, `q:evidence.claim`, `q:evidence.verified_claims`.
- Exposed through: [`api.api_symbols`](../api/api_symbols.md), [`api.bundle_files`](../api/bundle_files.md), [`api.claim_candidates`](../api/claim_candidates.md), [`api.claim_surfaces`](../api/claim_surfaces.md), [`api.endpoints`](../api/endpoints.md), [`api.hook_entries`](../api/hook_entries.md), [`api.mcp_prompts`](../api/mcp_prompts.md), [`api.mcp_resources`](../api/mcp_resources.md), [`api.mcp_tools`](../api/mcp_tools.md), [`api.symbol_docs`](../api/symbol_docs.md).
- Direct SELECT: `app_reader`, `executor_service`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["content"]["Tables"]["document_representation"]["Insert"]`; row: `Database["content"]["Tables"]["document_representation"]["Row"]`; update: `Database["content"]["Tables"]["document_representation"]["Update"]`

Defined in: `20260903010000_knowledge_content_contract.sql`.
