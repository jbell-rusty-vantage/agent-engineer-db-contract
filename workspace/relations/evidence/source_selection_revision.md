---
id: "rel:evidence.source_selection_revision"
kind: table
schema: evidence
name: source_selection_revision
domain: evidence
aliases: []
tokens: [evidence, source_selection_revision, evidence.source_selection_revision, tenant_id, attempt_id, revision, idempotency_key, request_sha256, selection_artifact_id, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, pipeline_agent, service_role]
typescript: "Database[\"evidence\"][\"Tables\"][\"source_selection_revision\"][\"Row\"]"
defined_in: ["20260914010400_source_attempt_recovery.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# evidence.source_selection_revision

table in domain `evidence`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `tenant_id` | `uuid` | no | — | PK; unique (tenant_id, attempt_id, idempotency_key); unique (tenant_id, attempt_id, revision, idempotency_key, selection_artifact_id) |
| 2 | `attempt_id` | `uuid` | no | — | PK; unique (tenant_id, attempt_id, idempotency_key); unique (tenant_id, attempt_id, revision, idempotency_key, selection_artifact_id) |
| 3 | `revision` | `bigint` | no | — | PK; unique (tenant_id, attempt_id, revision, idempotency_key, selection_artifact_id) |
| 4 | `idempotency_key` | `text` | no | — | unique (tenant_id, attempt_id, idempotency_key); unique (tenant_id, attempt_id, revision, idempotency_key, selection_artifact_id) |
| 5 | `request_sha256` | `text` | no | — | — |
| 6 | `selection_artifact_id` | `uuid` | no | — | unique (tenant_id, attempt_id, revision, idempotency_key, selection_artifact_id) |
| 7 | `created_at` | `timestamp with time zone` | no | `clock_timestamp()` | — |

## Constraints

- PK (tenant_id, attempt_id, revision)
- unique (tenant_id, attempt_id, idempotency_key)
- unique (tenant_id, attempt_id, revision, idempotency_key, selection_artifact_id)
- check `source_selection_revision_idempotency_key_check`: `((length(btrim(idempotency_key)) >= 1) AND (length(btrim(idempotency_key)) <= 256))`
- check `source_selection_revision_request_sha256_check`: `(request_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `source_selection_revision_revision_check`: `(revision > 0)`

## Relationships

Outbound: `tenant_id,attempt_id` → [`evidence.source_provider_attempt`](source_provider_attempt.md)`.tenant_id,id`; `tenant_id,selection_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id`.
Inbound: [`evidence.source_result_selection`](source_result_selection.md).attempt_id,revision,idempotency_key,selection_artifact_id.

## Indexes

`source_selection_revision_tenant_id_attempt_id_idempotency__key` unique; `source_selection_revision_tenant_id_attempt_id_revision_ide_key` unique

## Triggers

- `artifact_retirement_251821f7e530698d7aa4fbf2` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)
- `source_selection_revision_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)
- `source_selection_revision_nonempty` → [`evidence.require_source_selection_decisions`](../../functions/evidence/require_source_selection_decisions.md) (constraint trigger, deferred)

## Row-level security

Enabled.
- `source_selection_revision_tenant` (ALL) for `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: SELECT; `executor_service`: INSERT, SELECT; `pipeline_agent`: INSERT, SELECT; `service_role`: INSERT, SELECT; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`, `pipeline_agent`.

## TypeScript

insert: `Database["evidence"]["Tables"]["source_selection_revision"]["Insert"]`; row: `Database["evidence"]["Tables"]["source_selection_revision"]["Row"]`; update: `Database["evidence"]["Tables"]["source_selection_revision"]["Update"]`

Defined in: `20260914010400_source_attempt_recovery.sql`.
