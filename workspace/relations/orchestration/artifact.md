---
id: "rel:orchestration.artifact"
kind: table
schema: orchestration
name: artifact
domain: orchestration-ledger
aliases: [artifact]
tokens: [orchestration, artifact, orchestration.artifact, id, tenant_id, artifact_type, schema_version, sha256, bucket_class, storage_bucket, object_path, media_type, size_bytes, producer_attempt_id, mission_id, superseded_by_id, created_at, verification_contract_version, storage_state, available_at, registration_error_class, custody_registered_at]
summary: Content-addressed stored object typed by artifact_type.
summary_basis: curated
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role]
writers: [control_plane, executor_service, service_role]
typescript: "Database[\"orchestration\"][\"Tables\"][\"artifact\"][\"Row\"]"
defined_in: ["20260826000200_orchestration.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# orchestration.artifact

table in domain `orchestration-ledger`.

> curated (model_assisted, unreviewed) — Content-addressed stored object typed by artifact_type.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id) |
| 3 | `artifact_type` | `text` | no | — | FK → [`orchestration.artifact_type`](artifact_type.md).code |
| 4 | `schema_version` | `integer` | no | `1` | — |
| 5 | `sha256` | `text` | no | — | _curated:_ 64 lowercase hex; unique with artifact_type. |
| 6 | `bucket_class` | `orchestration.bucket_class` | no | — | _curated:_ source_captures, candidate, accepted, ledger, or published. |
| 7 | `storage_bucket` | `text` | no | — | — |
| 8 | `object_path` | `text` | no | — | — |
| 9 | `media_type` | `text` | yes | — | — |
| 10 | `size_bytes` | `bigint` | yes | — | — |
| 11 | `producer_attempt_id` | `uuid` | yes | — | FK → [`orchestration.attempt`](attempt.md).id |
| 12 | `mission_id` | `uuid` | yes | — | FK → [`orchestration.mission`](mission.md).id |
| 13 | `superseded_by_id` | `uuid` | yes | — | FK → [`orchestration.artifact`](artifact.md).id |
| 14 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 15 | `verification_contract_version` | `text` | yes | — | Immutable opt-in to verification CAS and metadata admission. NULL preserves legacy artifact identity and writer compatibility. |
| 16 | `storage_state` | `text` | no | `'available'::text` | Registration-first object lifecycle. Receipts may only reference available rows; pending/failed rows are reconciliation evidence.; _curated:_ stored or pending when the bucket write lagged the row. |
| 17 | `available_at` | `timestamp with time zone` | yes | `now()` | — |
| 18 | `registration_error_class` | `text` | yes | — | — |
| 19 | `custody_registered_at` | `timestamp with time zone` | no | `clock_timestamp()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `artifact_sha256_check`: `(sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `artifact_size_bytes_check`: `(size_bytes >= 0)`
- check `artifact_storage_lifecycle_ck`: `(((storage_state = 'pending'::text) AND (available_at IS NULL) AND (registration_error_class IS NULL)) OR ((storage_state = 'available'::te…`
- check `artifact_storage_state_check`: `(storage_state = ANY (ARRAY['pending'::text, 'available'::text, 'failed'::text]))`
- check `artifact_verification_contract_version_check`: `((verification_contract_version IS NULL) OR (verification_contract_version = 'verification.v1'::text))`
- check `artifact_verification_contract_version_ck`: `((verification_contract_version IS NULL) OR (verification_contract_version = 'verification.v1'::text))`
- check `verification_bucket_cas_path_ck`: `((verification_contract_version IS NULL) OR ((storage_bucket = 'ai-engineer-cloud-bucket'::text) AND (object_path ~ (('^'::text \|\| (tenant_…`

## Relationships

5 outbound and 104 inbound foreign keys; full list in [details](artifact.details.md).

## Indexes

7 indexes; see [details](artifact.details.md).

## Triggers

6 triggers; see [details](artifact.details.md).

## Row-level security

Enabled; 2 policies in [details](artifact.details.md).

## Grants

`control_plane`: INSERT, SELECT, UPDATE; `executor_service`: INSERT, SELECT; `pipeline_agent`: SELECT; `service_role`: INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `verifier_agent`.

## Read paths

- Named queries: `q:artifacts.by_type`, `q:reports.artifacts`.
- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`.

## Write path

- Direct DML: `control_plane`, `executor_service`.
- Via functions (best effort): [`orchestration.apply_artifact_tombstone`](../../functions/orchestration/apply_artifact_tombstone.md), [`orchestration.reconcile_legacy_artifact_custody`](../../functions/orchestration/reconcile_legacy_artifact_custody.md).

## TypeScript

insert: `Database["orchestration"]["Tables"]["artifact"]["Insert"]`; row: `Database["orchestration"]["Tables"]["artifact"]["Row"]`; update: `Database["orchestration"]["Tables"]["artifact"]["Update"]`

## Examples

Ingestion receipts on disk

```bash
knowledge db query artifacts.by_type --param artifact_type=knowledge_ingestion_receipt --param limit=50
```
Agents read bytes through the executor, not with bucket credentials.

Defined in: `20260826000200_orchestration.sql`.
