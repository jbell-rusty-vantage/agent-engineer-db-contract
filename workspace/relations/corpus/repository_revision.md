---
id: "rel:corpus.repository_revision"
kind: table
schema: corpus
name: repository_revision
domain: identity
aliases: []
tokens: [corpus, repository_revision, corpus.repository_revision, id, tenant_id, repository_id, commit_sha, ref_name, committed_at, tree_sha, tree_manifest_artifact_id, manifest_truncated, file_count, total_bytes, languages, capture_id, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"corpus\"][\"Tables\"][\"repository_revision\"][\"Row\"]"
defined_in: ["20260912010200_km_02_corpus_identity.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# corpus.repository_revision

table in domain `identity`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id); unique (tenant_id, repository_id, commit_sha) |
| 3 | `repository_id` | `uuid` | no | — | unique (tenant_id, repository_id, commit_sha); FK → [`corpus.repository`](repository.md).id |
| 4 | `commit_sha` | `text` | no | — | unique (tenant_id, repository_id, commit_sha) |
| 5 | `ref_name` | `text` | yes | — | — |
| 6 | `committed_at` | `timestamp with time zone` | yes | — | — |
| 7 | `tree_sha` | `text` | yes | — | — |
| 8 | `tree_manifest_artifact_id` | `uuid` | yes | — | FK → [`orchestration.artifact`](../orchestration/artifact.md).id |
| 9 | `manifest_truncated` | `boolean` | no | `false` | — |
| 10 | `file_count` | `integer` | yes | — | — |
| 11 | `total_bytes` | `bigint` | yes | — | — |
| 12 | `languages` | `jsonb` | no | `'{}'::jsonb` | — |
| 13 | `capture_id` | `uuid` | yes | — | FK → [`evidence.source_capture`](../evidence/source_capture.md).id |
| 14 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, repository_id, commit_sha)
- check `repository_revision_commit_sha_check`: `(commit_sha ~ '^[0-9a-f]{40}$\|^[0-9a-f]{64}$'::text)`

## Relationships

Outbound: `capture_id` → [`evidence.source_capture`](../evidence/source_capture.md)`.id` (+tenant); `repository_id` → [`corpus.repository`](repository.md)`.id` (+tenant); `tree_manifest_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.id` (+tenant).
Inbound: [`corpus.library_release`](library_release.md).source_revision_id, [`corpus.repository_file`](repository_file.md).revision_id, [`corpus.repository_module`](repository_module.md).first_seen_revision_id|last_seen_revision_id.

## Indexes

`repository_revision_tenant_id_id_key` unique; `repository_revision_tenant_id_repository_id_commit_sha_key` unique

## Triggers

- `artifact_retirement_c6fb98900c8acfd7dddc674e` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)
- `artifact_retirement_d809e315e282ab1796cd292e` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)

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

insert: `Database["corpus"]["Tables"]["repository_revision"]["Insert"]`; row: `Database["corpus"]["Tables"]["repository_revision"]["Row"]`; update: `Database["corpus"]["Tables"]["repository_revision"]["Update"]`

Defined in: `20260912010200_km_02_corpus_identity.sql`.
