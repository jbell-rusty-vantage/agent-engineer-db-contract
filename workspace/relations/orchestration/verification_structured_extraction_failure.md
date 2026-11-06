---
id: "rel:orchestration.verification_structured_extraction_failure"
kind: table
schema: orchestration
name: verification_structured_extraction_failure
domain: orchestration-ledger
aliases: []
tokens: [orchestration, verification_structured_extraction_failure, orchestration.verification_structured_extraction_failure, tenant_id, operation_id, failure_code, status, completed_at, failure_artifact_id, failure_sha256, seal_payload_sha256, provider_call_sha256]
summary: null
summary_basis: none
rls: enabled
readers: [app_reader, control_plane, executor_service, service_role, verifier_agent]
writers: [control_plane, executor_service, service_role, verifier_agent]
typescript: "Database[\"orchestration\"][\"Tables\"][\"verification_structured_extraction_failure\"][\"Row\"]"
defined_in: ["20260906032500_verification_structured_extraction_failure.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# orchestration.verification_structured_extraction_failure

table in domain `orchestration-ledger`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `tenant_id` | `uuid` | no | — | PK |
| 2 | `operation_id` | `uuid` | no | — | PK |
| 3 | `failure_code` | `text` | no | — | — |
| 4 | `status` | `text` | no | `'preparing'::text` | — |
| 5 | `completed_at` | `timestamp with time zone` | no | `date_trunc('milliseconds'::text, clock_timestamp())` | — |
| 6 | `failure_artifact_id` | `uuid` | yes | — | — |
| 7 | `failure_sha256` | `text` | yes | — | — |
| 8 | `seal_payload_sha256` | `text` | yes | — | — |
| 9 | `provider_call_sha256` | `text` | yes | — | — |

## Constraints

- PK (tenant_id, operation_id)
- check `verification_structured_extraction_f_provider_call_sha256_check`: `((provider_call_sha256 IS NULL) OR (provider_call_sha256 ~ '^[0-9a-f]{64}$'::text))`
- check `verification_structured_extraction_fa_seal_payload_sha256_check`: `((seal_payload_sha256 IS NULL) OR (seal_payload_sha256 ~ '^[0-9a-f]{64}$'::text))`
- check `verification_structured_extraction_failure_check`: `(((status = 'preparing'::text) AND (failure_artifact_id IS NULL) AND (failure_sha256 IS NULL) AND (seal_payload_sha256 IS NULL) AND (provid…`
- check `verification_structured_extraction_failure_failure_code_check`: `(failure_code = ANY (ARRAY['PROVIDER_HTTP_FAILURE'::text, 'PROVIDER_RESPONSE_TOO_LARGE'::text, 'PROVIDER_RESPONSE_INVALID'::text, 'PROVIDER…`
- check `verification_structured_extraction_failure_failure_sha256_check`: `((failure_sha256 IS NULL) OR (failure_sha256 ~ '^[0-9a-f]{64}$'::text))`
- check `verification_structured_extraction_failure_status_check`: `(status = ANY (ARRAY['preparing'::text, 'published'::text]))`

## Relationships

Outbound: `tenant_id,failure_artifact_id` → [`orchestration.artifact`](artifact.md)`.tenant_id,id`; `tenant_id,operation_id` → [`orchestration.verification_structured_extraction`](verification_structured_extraction.md)`.tenant_id,operation_id`; `tenant_id,operation_id` → [`orchestration.verification_structured_extraction_execution`](verification_structured_extraction_execution.md)`.tenant_id,operation_id`.
Inbound: none.

## Indexes

_None._

## Triggers

- `artifact_retirement_3e546441c0838c262091b866` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)
- `verification_structured_extraction_failure_guard` → [`orchestration.guard_structured_extraction_failure`](../../functions/orchestration/guard_structured_extraction_failure.md)

## Row-level security

Enabled.
- `verification_structured_extraction_failure_reader` (SELECT) for `app_reader`: `(tenant_id = util.current_tenant_id())`
- `verification_structured_extraction_failure_worker` (ALL) for `control_plane`, `executor_service`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`app_reader`: SELECT; `control_plane`: INSERT, SELECT, UPDATE; `executor_service`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: INSERT, SELECT, UPDATE. None: `anon`, `authenticated`, `pipeline_agent`.

## Read paths

- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `verifier_agent`.

## Write path

- Direct DML: `control_plane`, `executor_service`, `verifier_agent`.

## TypeScript

insert: `Database["orchestration"]["Tables"]["verification_structured_extraction_failure"]["Insert"]`; row: `Database["orchestration"]["Tables"]["verification_structured_extraction_failure"]["Row"]`; update: `Database["orchestration"]["Tables"]["verification_structured_extraction_failure"]["Update"]`

Defined in: `20260906032500_verification_structured_extraction_failure.sql`.
