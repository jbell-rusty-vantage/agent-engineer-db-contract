---
id: "rel:content.document_identifier"
kind: table
schema: content
name: document_identifier
domain: content
aliases: []
tokens: [content, document_identifier, content.document_identifier, id, tenant_id, document_id, identifier_type, normalized_value, authority, valid_from, valid_to, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"content\"][\"Tables\"][\"document_identifier\"][\"Row\"]"
defined_in: ["20260903010000_knowledge_content_contract.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# content.document_identifier

table in domain `content`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, identifier_type, normalized_value) |
| 3 | `document_id` | `uuid` | no | — | — |
| 4 | `identifier_type` | `text` | no | — | unique (tenant_id, identifier_type, normalized_value) |
| 5 | `normalized_value` | `text` | no | — | unique (tenant_id, identifier_type, normalized_value) |
| 6 | `authority` | `text` | yes | — | — |
| 7 | `valid_from` | `timestamp with time zone` | yes | — | — |
| 8 | `valid_to` | `timestamp with time zone` | yes | — | — |
| 9 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, identifier_type, normalized_value)
- check `document_identifier_check`: `((valid_to IS NULL) OR (valid_from IS NULL) OR (valid_to > valid_from))`
- check `document_identifier_identifier_type_check`: `(identifier_type = ANY (ARRAY['url'::text, 'doi'::text, 'arxiv'::text, 'openreview'::text, 'isbn'::text, 'repository'::text, 'media_id'::te…`

## Relationships

Outbound: `tenant_id,document_id` → [`content.document`](document.md)`.tenant_id,id` on delete restrict.
Inbound: none.

## Indexes

`document_identifier_tenant_id_identifier_type_normalized_va_key` unique

## Triggers

- `document_identifier_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

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

insert: `Database["content"]["Tables"]["document_identifier"]["Insert"]`; row: `Database["content"]["Tables"]["document_identifier"]["Row"]`; update: `Database["content"]["Tables"]["document_identifier"]["Update"]`

Defined in: `20260903010000_knowledge_content_contract.sql`.
