---
id: "rel:content.document_version_source_capture"
kind: table
schema: content
name: document_version_source_capture
domain: content
aliases: []
tokens: [content, document_version_source_capture, content.document_version_source_capture, tenant_id, document_version_id, source_capture_id, capture_role, identity_confidence, resolution_evidence, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"content\"][\"Tables\"][\"document_version_source_capture\"][\"Row\"]"
defined_in: ["20260903010000_knowledge_content_contract.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# content.document_version_source_capture

table in domain `content`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | PK |
| 2 | `document_version_id` | `uuid` | no | — | PK |
| 3 | `source_capture_id` | `uuid` | no | — | PK |
| 4 | `capture_role` | `text` | no | `'primary'::text` | — |
| 5 | `identity_confidence` | `numeric(5,4)` | no | — | — |
| 6 | `resolution_evidence` | `jsonb` | no | `'{}'::jsonb` | — |
| 7 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (tenant_id, document_version_id, source_capture_id)
- check `document_version_source_capture_identity_confidence_check`: `((identity_confidence >= (0)::numeric) AND (identity_confidence <= (1)::numeric))`

## Relationships

Outbound: `tenant_id,document_version_id` → [`content.document_version`](document_version.md)`.tenant_id,id` on delete restrict; `tenant_id,source_capture_id` → [`evidence.source_capture`](../evidence/source_capture.md)`.tenant_id,id` on delete restrict.
Inbound: none.

## Indexes

_None._

## Triggers

- `document_version_source_capture_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

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

insert: `Database["content"]["Tables"]["document_version_source_capture"]["Insert"]`; row: `Database["content"]["Tables"]["document_version_source_capture"]["Row"]`; update: `Database["content"]["Tables"]["document_version_source_capture"]["Update"]`

Defined in: `20260903010000_knowledge_content_contract.sql`.
