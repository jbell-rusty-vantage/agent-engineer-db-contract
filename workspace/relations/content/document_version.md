---
id: "rel:content.document_version"
kind: table
schema: content
name: document_version
domain: content
aliases: []
tokens: [content, document_version, content.document_version, id, tenant_id, document_id, version_label, published_at, effective_from, resolved_revision, manifest_sha256, correction_state, supersedes_id, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"content\"][\"Tables\"][\"document_version\"][\"Row\"]"
defined_in: ["20260903010000_knowledge_content_contract.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# content.document_version

table in domain `content`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, document_id, version_label); unique (tenant_id, id) |
| 3 | `document_id` | `uuid` | no | — | unique (tenant_id, document_id, version_label) |
| 4 | `version_label` | `text` | no | — | unique (tenant_id, document_id, version_label) |
| 5 | `published_at` | `timestamp with time zone` | yes | — | — |
| 6 | `effective_from` | `timestamp with time zone` | yes | — | — |
| 7 | `resolved_revision` | `text` | yes | — | — |
| 8 | `manifest_sha256` | `text` | no | — | — |
| 9 | `correction_state` | `text` | no | `'current'::text` | — |
| 10 | `supersedes_id` | `uuid` | yes | — | — |
| 11 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, document_id, version_label)
- unique (tenant_id, id)
- check `document_version_check`: `((supersedes_id IS NULL) OR (supersedes_id <> id))`
- check `document_version_correction_state_check`: `(correction_state = ANY (ARRAY['current'::text, 'corrected'::text, 'retracted'::text, 'withdrawn'::text]))`
- check `document_version_manifest_sha256_check`: `(manifest_sha256 ~ '^[0-9a-f]{64}$'::text)`

## Relationships

Outbound: `tenant_id,document_id` → [`content.document`](document.md)`.tenant_id,id` on delete restrict; `tenant_id,supersedes_id` → [`content.document_version`](document_version.md)`.tenant_id,id` on delete restrict.
Inbound: [`content.document_representation`](document_representation.md).document_version_id, [`content.document_summary`](document_summary.md).document_version_id, [`content.document_version`](document_version.md).supersedes_id, [`content.document_version_source_capture`](document_version_source_capture.md).document_version_id, [`retrieval.vector_store_document`](../retrieval/vector_store_document.md).document_version_id.

## Indexes

`document_version_document_idx`; `document_version_tenant_id_document_id_version_label_key` unique; `document_version_tenant_id_id_key` unique

## Triggers

- `document_version_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)
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

## TypeScript

insert: `Database["content"]["Tables"]["document_version"]["Insert"]`; row: `Database["content"]["Tables"]["document_version"]["Row"]`; update: `Database["content"]["Tables"]["document_version"]["Update"]`

Defined in: `20260903010000_knowledge_content_contract.sql`.
