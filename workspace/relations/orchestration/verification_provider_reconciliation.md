---
id: "rel:orchestration.verification_provider_reconciliation"
kind: table
schema: orchestration
name: verification_provider_reconciliation
domain: orchestration-ledger
aliases: []
tokens: [orchestration, verification_provider_reconciliation, orchestration.verification_provider_reconciliation, tenant_id, provider_attempt_id, operation_id, artifact_id, artifact_sha256, body, applied_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, service_role]
writers: [control_plane, service_role]
typescript: "Database[\"orchestration\"][\"Tables\"][\"verification_provider_reconciliation\"][\"Row\"]"
defined_in: ["20260906032800_verification_provider_reconciliation_ledger.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# orchestration.verification_provider_reconciliation

table in domain `orchestration-ledger`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `tenant_id` | `uuid` | no | — | PK; unique (tenant_id, artifact_id) |
| 2 | `provider_attempt_id` | `uuid` | no | — | PK |
| 3 | `operation_id` | `uuid` | no | — | — |
| 4 | `artifact_id` | `uuid` | no | — | unique (tenant_id, artifact_id) |
| 5 | `artifact_sha256` | `text` | no | — | — |
| 6 | `body` | `jsonb` | no | — | — |
| 7 | `applied_at` | `timestamp with time zone` | no | `clock_timestamp()` | — |

## Constraints

- PK (tenant_id, provider_attempt_id)
- unique (tenant_id, artifact_id)
- check `verification_provider_reconciliation_artifact_sha256_check`: `(artifact_sha256 ~ '^[0-9a-f]{64}$'::text)`

## Relationships

Outbound: `tenant_id,provider_attempt_id` → [`orchestration.verification_provider_attempt`](verification_provider_attempt.md)`.tenant_id,id`; `tenant_id,operation_id` → [`knowledge_service.operation`](../knowledge_service/operation.md)`.tenant_id,id`; `tenant_id,artifact_id` → [`orchestration.artifact`](artifact.md)`.tenant_id,id`.
Inbound: none.

## Indexes

`verification_provider_reconciliation_tenant_id_artifact_id_key` unique

## Triggers

- `apply_provider_reconciliation` → [`orchestration.apply_provider_reconciliation`](../../functions/orchestration/apply_provider_reconciliation.md)
- `artifact_retirement_f66705aa49bbe0727e191c35` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)
- `guard_provider_reconciliation` → [`orchestration.guard_provider_reconciliation`](../../functions/orchestration/guard_provider_reconciliation.md)

## Row-level security

Enabled.
- `provider_reconciliation_control` (ALL) for `control_plane`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: INSERT, SELECT; `service_role`: INSERT, SELECT. None: `anon`, `app_reader`, `authenticated`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `control_plane`.

## Write path

- Direct DML: `control_plane`.

## TypeScript

insert: `Database["orchestration"]["Tables"]["verification_provider_reconciliation"]["Insert"]`; row: `Database["orchestration"]["Tables"]["verification_provider_reconciliation"]["Row"]`; update: `Database["orchestration"]["Tables"]["verification_provider_reconciliation"]["Update"]`

Defined in: `20260906032800_verification_provider_reconciliation_ledger.sql`.
