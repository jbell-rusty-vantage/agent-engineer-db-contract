---
id: "rel:corpus.repository_file"
kind: table
schema: corpus
name: repository_file
domain: identity
aliases: []
tokens: [corpus, repository_file, corpus.repository_file, id, tenant_id, repository_id, revision_id, path, blob_sha, size_bytes, language, file_role, module_id, capture_id, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"corpus\"][\"Tables\"][\"repository_file\"][\"Row\"]"
defined_in: ["20260912010200_km_02_corpus_identity.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# corpus.repository_file

table in domain `identity`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id); unique (tenant_id, revision_id, path) |
| 3 | `repository_id` | `uuid` | no | — | FK → [`corpus.repository`](repository.md).id |
| 4 | `revision_id` | `uuid` | no | — | unique (tenant_id, revision_id, path); FK → [`corpus.repository_revision`](repository_revision.md).id |
| 5 | `path` | `text` | no | — | unique (tenant_id, revision_id, path) |
| 6 | `blob_sha` | `text` | yes | — | — |
| 7 | `size_bytes` | `integer` | yes | — | — |
| 8 | `language` | `text` | yes | — | — |
| 9 | `file_role` | `text` | no | — | — |
| 10 | `module_id` | `uuid` | yes | — | FK → [`corpus.repository_module`](repository_module.md).id |
| 11 | `capture_id` | `uuid` | yes | — | FK → [`evidence.source_capture`](../evidence/source_capture.md).id |
| 12 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, revision_id, path)
- check `repository_file_file_role_check`: `(file_role = ANY (ARRAY['readme'::text, 'manifest'::text, 'license'::text, 'changelog'::text, 'docs'::text, 'source'::text, 'example'::text…`

## Relationships

Outbound: `capture_id` → [`evidence.source_capture`](../evidence/source_capture.md)`.id` (+tenant); `module_id` → [`corpus.repository_module`](repository_module.md)`.id` (+tenant); `repository_id` → [`corpus.repository`](repository.md)`.id` (+tenant); `revision_id` → [`corpus.repository_revision`](repository_revision.md)`.id` (+tenant).
Inbound: [`content.document`](../content/document.md).repository_file_id, [`knowledge.implementation_example`](../knowledge/implementation_example.md).repository_file_id.

## Indexes

`repository_file_tenant_id_id_key` unique; `repository_file_tenant_id_revision_id_path_key` unique

## Triggers

- `repository_file_lineage` → [`corpus.check_repository_lineage`](../../functions/corpus/check_repository_lineage.md)

## Row-level security

Enabled.
- `km_tenant_access` (ALL) for `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: SELECT; `executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: SELECT; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["corpus"]["Tables"]["repository_file"]["Insert"]`; row: `Database["corpus"]["Tables"]["repository_file"]["Row"]`; update: `Database["corpus"]["Tables"]["repository_file"]["Update"]`

Defined in: `20260912010200_km_02_corpus_identity.sql`.
