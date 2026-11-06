---
id: "rel:content.document"
kind: table
schema: content
name: document
domain: content
aliases: []
tokens: [content, document, content.document, id, tenant_id, document_type_code, canonical_title, canonical_source_id, lifecycle, created_by_attempt_id, supersedes_id, created_at, work_entity_id, repository_file_id]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"content\"][\"Tables\"][\"document\"][\"Row\"]"
defined_in: ["20260903010000_knowledge_content_contract.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# content.document

table in domain `content`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id) |
| 3 | `document_type_code` | `text` | no | — | FK → [`content.document_type`](document_type.md).code |
| 4 | `canonical_title` | `text` | no | — | — |
| 5 | `canonical_source_id` | `uuid` | yes | — | — |
| 6 | `lifecycle` | `text` | no | `'active'::text` | — |
| 7 | `created_by_attempt_id` | `uuid` | yes | — | — |
| 8 | `supersedes_id` | `uuid` | yes | — | — |
| 9 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 10 | `work_entity_id` | `uuid` | yes | — | FK → [`corpus.entity`](../corpus/entity.md).id |
| 11 | `repository_file_id` | `uuid` | yes | — | FK → [`corpus.repository_file`](../corpus/repository_file.md).id |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `document_check`: `((supersedes_id IS NULL) OR (supersedes_id <> id))`
- check `document_lifecycle_check`: `(lifecycle = ANY (ARRAY['active'::text, 'deprecated'::text, 'retracted'::text, 'deleted'::text, 'superseded'::text]))`

## Relationships

Outbound: `document_type_code` → [`content.document_type`](document_type.md)`.code`; `repository_file_id` → [`corpus.repository_file`](../corpus/repository_file.md)`.id`; `tenant_id,canonical_source_id` → [`evidence.source`](../evidence/source.md)`.tenant_id,id` on delete restrict; `tenant_id,created_by_attempt_id` → [`orchestration.attempt`](../orchestration/attempt.md)`.tenant_id,id` on delete restrict; `tenant_id,supersedes_id` → [`content.document`](document.md)`.tenant_id,id` on delete restrict; `work_entity_id` → [`corpus.entity`](../corpus/entity.md)`.id`.
Inbound: [`content.document`](document.md).supersedes_id, [`content.document_about_entity`](document_about_entity.md).document_id, [`content.document_identifier`](document_identifier.md).document_id, [`content.document_version`](document_version.md).document_id, [`retrieval.vector_store_document`](../retrieval/vector_store_document.md).document_id.

## Indexes

`document_tenant_id_id_key` unique; `document_title_trgm_idx`

## Triggers

- `document_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)
- `document_work_integrity` → [`content.check_document_work`](../../functions/content/check_document_work.md)
- `predecessor_direction` → [`util.validate_predecessor`](../../functions/util/validate_predecessor.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`executor_service`: INSERT, SELECT; `service_role`: INSERT, SELECT. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `executor_service`.

## Write path

- Direct DML: `executor_service`.
- Via functions (best effort): [`corpus.import_research_starter_catalog`](../../functions/corpus/import_research_starter_catalog.md).

## TypeScript

insert: `Database["content"]["Tables"]["document"]["Insert"]`; row: `Database["content"]["Tables"]["document"]["Row"]`; update: `Database["content"]["Tables"]["document"]["Update"]`

Defined in: `20260903010000_knowledge_content_contract.sql`.
