---
id: "rel:evaluation.verification_benchmark_checkpoint"
kind: table
schema: evaluation
name: verification_benchmark_checkpoint
domain: evaluation
aliases: []
tokens: [evaluation, verification_benchmark_checkpoint, evaluation.verification_benchmark_checkpoint, id, tenant_id, benchmark_run_id, checkpoint_context_sha256, checkpoint_sha256, result_sha256, result, completed_at, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, service_role]
writers: [control_plane, service_role]
typescript: "Database[\"evaluation\"][\"Tables\"][\"verification_benchmark_checkpoint\"][\"Row\"]"
defined_in: ["20260906029000_verification_benchmark_durable_run.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# evaluation.verification_benchmark_checkpoint

table in domain `evaluation`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, benchmark_run_id, checkpoint_context_sha256); unique (tenant_id, id) |
| 3 | `benchmark_run_id` | `uuid` | no | — | unique (tenant_id, benchmark_run_id, checkpoint_context_sha256) |
| 4 | `checkpoint_context_sha256` | `text` | no | — | unique (tenant_id, benchmark_run_id, checkpoint_context_sha256) |
| 5 | `checkpoint_sha256` | `text` | no | — | — |
| 6 | `result_sha256` | `text` | no | — | — |
| 7 | `result` | `jsonb` | no | — | — |
| 8 | `completed_at` | `timestamp with time zone` | no | — | — |
| 9 | `created_at` | `timestamp with time zone` | no | `clock_timestamp()` | — |

## Constraints

- PK (id)
- unique (tenant_id, benchmark_run_id, checkpoint_context_sha256)
- unique (tenant_id, id)
- check `verification_benchmark_checkpoi_checkpoint_context_sha256_check`: `(checkpoint_context_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `verification_benchmark_checkpoint_checkpoint_sha256_check`: `(checkpoint_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `verification_benchmark_checkpoint_result_sha256_check`: `(result_sha256 ~ '^[0-9a-f]{64}$'::text)`

## Relationships

Outbound: `tenant_id,benchmark_run_id` → [`evaluation.verification_benchmark_run`](verification_benchmark_run.md)`.tenant_id,id` on delete restrict.
Inbound: none.

## Indexes

`verification_benchmark_checkp_tenant_id_benchmark_run_id_ch_key` unique; `verification_benchmark_checkpoint_tenant_id_id_key` unique

## Triggers

- `verification_benchmark_checkpoint_immutable` → [`evaluation.enforce_verification_benchmark_checkpoint_immutable`](../../functions/evaluation/enforce_verification_benchmark_checkpoint_immutable.md)
- `verification_benchmark_checkpoint_validate` → [`evaluation.validate_verification_benchmark_checkpoint`](../../functions/evaluation/validate_verification_benchmark_checkpoint.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `control_plane`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `control_plane`.

## Write path

- Direct DML: `control_plane`.

## TypeScript

insert: `Database["evaluation"]["Tables"]["verification_benchmark_checkpoint"]["Insert"]`; row: `Database["evaluation"]["Tables"]["verification_benchmark_checkpoint"]["Row"]`; update: `Database["evaluation"]["Tables"]["verification_benchmark_checkpoint"]["Update"]`

Defined in: `20260906029000_verification_benchmark_durable_run.sql`.
