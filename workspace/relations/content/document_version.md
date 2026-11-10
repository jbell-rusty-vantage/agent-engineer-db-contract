---
id: "rel:content.document_version"
kind: table
schema: content
name: document_version
domain: content
lens: corpus
aliases: []
tokens: [content, document_version, content.document_version, id, tenant_id, document_id, version_label, published_at, effective_from, resolved_revision, manifest_sha256, correction_state, supersedes_id, created_at, format_code]
summary: null
summary_basis: none
rls: enabled
readers: [app_reader, executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"content\"][\"Tables\"][\"document_version\"][\"Row\"]"
defined_in: ["20260903010000_knowledge_content_contract.sql"]
workspace_fingerprint: "sha256:027ab2b6133d5d59318c478f06d832d89f937e563c387539f37fb3d7668818a8"
---
# content.document_version

table in domain `content`, lens `corpus`.

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
| 12 | `format_code` | `text` | yes | — | FK → [`content.format`](format.md).code; Format axis of this captured version (content.format). |

## Constraints

- PK (id)
- unique (tenant_id, document_id, version_label)
- unique (tenant_id, id)
- check `document_version_check`: `((supersedes_id IS NULL) OR (supersedes_id <> id))`
- check `document_version_correction_state_check`: `(correction_state = ANY (ARRAY['current'::text, 'corrected'::text, 'retracted'::text, 'withdrawn'::text]))`
- check `document_version_manifest_sha256_check`: `(manifest_sha256 ~ '^[0-9a-f]{64}$'::text)`

## Relationships

Outbound: `format_code` → [`content.format`](format.md)`.code`; `tenant_id,document_id` → [`content.document`](document.md)`.tenant_id,id` on delete restrict; `tenant_id,supersedes_id` → [`content.document_version`](document_version.md)`.tenant_id,id` on delete restrict.
Inbound: [`content.document_digest`](document_digest.md).document_version_id, [`content.document_representation`](document_representation.md).document_version_id, [`content.document_summary`](document_summary.md).document_version_id, [`content.document_version`](document_version.md).supersedes_id, [`content.document_version_source_capture`](document_version_source_capture.md).document_version_id, [`content.refresh_check`](refresh_check.md).new_version_id|prior_version_id, [`content.unit_change`](unit_change.md).to_version_id, [`retrieval.vector_store_document`](../retrieval/vector_store_document.md).document_version_id.

## Indexes

`document_version_document_idx`; `document_version_tenant_id_document_id_version_label_key` unique; `document_version_tenant_id_id_key` unique

## Triggers

- `document_version_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)
- `predecessor_direction` → [`util.validate_predecessor`](../../functions/util/validate_predecessor.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`app_reader`: SELECT; `executor_service`: INSERT, SELECT; `service_role`: INSERT, SELECT. None: `anon`, `authenticated`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Named queries: `q:content.document_digest`, `q:content.document_units`, `q:content.talk_segments`, `q:facts.changes_since`.
- Exposed through: [`api.api_symbols`](../api/api_symbols.md), [`api.claim_candidates`](../api/claim_candidates.md), [`api.endpoints`](../api/endpoints.md).
- Direct SELECT: `app_reader`, `executor_service`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["content"]["Tables"]["document_version"]["Insert"]`; row: `Database["content"]["Tables"]["document_version"]["Row"]`; update: `Database["content"]["Tables"]["document_version"]["Update"]`

Defined in: `20260903010000_knowledge_content_contract.sql`.
