---
id: "rel:orchestration.artifact_tombstone"
kind: table
schema: orchestration
name: artifact_tombstone
domain: orchestration-ledger
aliases: []
tokens: [orchestration, artifact_tombstone, orchestration.artifact_tombstone, tenant_id, artifact_id, reason, retired_at]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"orchestration\"][\"Tables\"][\"artifact_tombstone\"][\"Row\"]"
defined_in: ["20260914010500_scoped_checkpoints.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# orchestration.artifact_tombstone

table in domain `orchestration-ledger`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `tenant_id` | `uuid` | no | — | PK |
| 2 | `artifact_id` | `uuid` | no | — | PK |
| 3 | `reason` | `text` | no | — | — |
| 4 | `retired_at` | `timestamp with time zone` | no | `clock_timestamp()` | — |

## Constraints

- PK (tenant_id, artifact_id)
- check `artifact_tombstone_reason_check`: `((length(btrim(reason)) >= 1) AND (length(btrim(reason)) <= 2000))`

## Relationships

Outbound: `tenant_id,artifact_id` → [`orchestration.artifact`](artifact.md)`.tenant_id,id`.
Inbound: none.

## Indexes

_None._

## Triggers

- `artifact_tombstone_admission` → [`orchestration.guard_artifact_tombstone`](../../functions/orchestration/guard_artifact_tombstone.md)
- `artifact_tombstone_apply` → [`orchestration.apply_artifact_tombstone`](../../functions/orchestration/apply_artifact_tombstone.md)
- `artifact_tombstone_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled.
- `artifact_tombstone_tenant` (ALL) for `executor_service`: `(tenant_id = util.current_tenant_id())`
- `product_api_workspace_tombstones` (ALL) for `product_api_owner`: `true`

## Grants

`executor_service`: INSERT, SELECT; `service_role`: INSERT, SELECT. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `executor_service`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["orchestration"]["Tables"]["artifact_tombstone"]["Insert"]`; row: `Database["orchestration"]["Tables"]["artifact_tombstone"]["Row"]`; update: `Database["orchestration"]["Tables"]["artifact_tombstone"]["Update"]`

Defined in: `20260914010500_scoped_checkpoints.sql`.
