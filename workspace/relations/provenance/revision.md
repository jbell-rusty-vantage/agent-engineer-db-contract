---
id: "rel:provenance.revision"
kind: table
schema: provenance
name: revision
domain: provenance
aliases: []
tokens: [provenance, revision, provenance.revision, id, tenant_id, object_id, revision_no, sha256, storage_bucket, object_path, media_type, size_bytes, summary, sealed_at]
summary: Immutable sealed content for one object version. Bytes live at object_path in the provenance bucket.
summary_basis: comment
rls: enabled
readers: [authenticated, service_role]
writers: [authenticated, service_role]
typescript: "Database[\"provenance\"][\"Tables\"][\"revision\"][\"Row\"]"
defined_in: ["20260831201650_project_provenance.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# provenance.revision

table in domain `provenance` — Immutable sealed content for one object version. Bytes live at object_path in the provenance bucket..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | — |
| 3 | `object_id` | `uuid` | no | — | unique (object_id, revision_no); unique (storage_bucket, object_path, object_id); FK → [`provenance.object`](object.md).id |
| 4 | `revision_no` | `integer` | no | — | unique (object_id, revision_no) |
| 5 | `sha256` | `text` | no | — | — |
| 6 | `storage_bucket` | `text` | no | `'ai-engineer-project-provenance'::text` | unique (storage_bucket, object_path, object_id) |
| 7 | `object_path` | `text` | no | — | unique (storage_bucket, object_path, object_id); CAS key: cas/sha256/{first two hex chars of sha256}/{sha256}. |
| 8 | `media_type` | `text` | yes | — | — |
| 9 | `size_bytes` | `bigint` | yes | — | — |
| 10 | `summary` | `text` | yes | — | — |
| 11 | `sealed_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (object_id, revision_no)
- unique (storage_bucket, object_path, object_id)
- check `revision_path_cas`: `(object_path ~ '^cas/sha256/[0-9a-f]{2}/[0-9a-f]{64}$'::text)`
- check `revision_revision_no_check`: `(revision_no > 0)`
- check `revision_sha256_check`: `(sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `revision_size_bytes_check`: `((size_bytes IS NULL) OR (size_bytes >= 0))`

## Relationships

Outbound: `object_id` → [`provenance.object`](object.md)`.id`.
Inbound: [`provenance.edge`](edge.md).from_revision_id|to_revision_id.

## Indexes

`revision_object_id_revision_no_key` unique; `revision_object_idx`; `revision_sha256_idx`; `revision_storage_bucket_object_path_object_id_key` unique

## Triggers

- `revision_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled.
- `revision_tenant` (ALL) for `authenticated`, `service_role`: `(tenant_id = util.current_tenant_id())`

## Grants

`authenticated`: INSERT, SELECT; `service_role`: INSERT, SELECT. None: `anon`, `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Read paths

- No agent role may SELECT directly.

## Write path

- No direct DML for any agent role.
- No write path for agents; rows are seeded by migrations or platform tooling.

## TypeScript

insert: `Database["provenance"]["Tables"]["revision"]["Insert"]`; row: `Database["provenance"]["Tables"]["revision"]["Row"]`; update: `Database["provenance"]["Tables"]["revision"]["Update"]`

Defined in: `20260831201650_project_provenance.sql`.
