---
id: "rel:orchestration.verification_provider_response_capture"
kind: table
schema: orchestration
name: verification_provider_response_capture
domain: orchestration-ledger
aliases: []
tokens: [orchestration, verification_provider_response_capture, orchestration.verification_provider_response_capture, tenant_id, provider_attempt_id, operation_id, operation_step_id, profile_artifact_id, profile_sha256, dispatch_fencing_token, http_status, response_envelope_artifact_id, transport_artifact_id, transport_sha256, captured_at]
summary: null
summary_basis: none
rls: enabled
readers: [app_reader, control_plane, executor_service, service_role, verifier_agent]
writers: [control_plane, executor_service, service_role, verifier_agent]
typescript: "Database[\"orchestration\"][\"Tables\"][\"verification_provider_response_capture\"][\"Row\"]"
defined_in: ["20260906031400_verification_provider_response_capture.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# orchestration.verification_provider_response_capture

table in domain `orchestration-ledger`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `tenant_id` | `uuid` | no | — | PK |
| 2 | `provider_attempt_id` | `uuid` | no | — | PK |
| 3 | `operation_id` | `uuid` | no | — | — |
| 4 | `operation_step_id` | `uuid` | no | — | — |
| 5 | `profile_artifact_id` | `uuid` | no | — | — |
| 6 | `profile_sha256` | `text` | no | — | — |
| 7 | `dispatch_fencing_token` | `bigint` | no | — | — |
| 8 | `http_status` | `integer` | no | — | — |
| 9 | `response_envelope_artifact_id` | `uuid` | no | — | — |
| 10 | `transport_artifact_id` | `uuid` | no | — | — |
| 11 | `transport_sha256` | `text` | no | — | — |
| 12 | `captured_at` | `timestamp with time zone` | no | `clock_timestamp()` | — |

## Constraints

- PK (tenant_id, provider_attempt_id)
- check `verification_provider_response_cap_dispatch_fencing_token_check`: `(dispatch_fencing_token > 0)`
- check `verification_provider_response_capture_http_status_check`: `((http_status >= 200) AND (http_status <= 599))`
- check `verification_provider_response_capture_profile_sha256_check`: `(profile_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `verification_provider_response_capture_transport_sha256_check`: `(transport_sha256 ~ '^[0-9a-f]{64}$'::text)`

## Relationships

Outbound: `tenant_id,profile_artifact_id` → [`orchestration.artifact`](artifact.md)`.tenant_id,id`; `tenant_id,provider_attempt_id` → [`orchestration.verification_provider_attempt`](verification_provider_attempt.md)`.tenant_id,id`; `tenant_id,response_envelope_artifact_id` → [`orchestration.artifact`](artifact.md)`.tenant_id,id`; `tenant_id,transport_artifact_id` → [`orchestration.artifact`](artifact.md)`.tenant_id,id`; `tenant_id,operation_id` → [`knowledge_service.operation`](../knowledge_service/operation.md)`.tenant_id,id`; `tenant_id,operation_step_id` → [`knowledge_service.operation_step`](../knowledge_service/operation_step.md)`.tenant_id,id`.
Inbound: none.

## Indexes

_None._

## Triggers

- `artifact_retirement_35ad36fc87809057550b8fc4` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)
- `artifact_retirement_3ceeee624e7332c2c0ab1c54` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)
- `artifact_retirement_c98bc9d5b2232e82a0721f47` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)
- `verification_provider_response_capture_guard` → [`orchestration.verification_provider_response_capture_guard`](../../functions/orchestration/verification_provider_response_capture_guard.md)

## Row-level security

Enabled.
- `verification_provider_response_capture_tenant_reader` (SELECT) for `app_reader`: `(tenant_id = util.current_tenant_id())`
- `verification_provider_response_capture_tenant_worker` (ALL) for `control_plane`, `executor_service`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`app_reader`: SELECT; `control_plane`: INSERT, SELECT; `executor_service`: INSERT, SELECT; `service_role`: INSERT, SELECT; `verifier_agent`: INSERT, SELECT. None: `anon`, `authenticated`, `pipeline_agent`.

## Read paths

- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `verifier_agent`.

## Write path

- Direct DML: `control_plane`, `executor_service`, `verifier_agent`.

## TypeScript

insert: `Database["orchestration"]["Tables"]["verification_provider_response_capture"]["Insert"]`; row: `Database["orchestration"]["Tables"]["verification_provider_response_capture"]["Row"]`; update: `Database["orchestration"]["Tables"]["verification_provider_response_capture"]["Update"]`

Defined in: `20260906031400_verification_provider_response_capture.sql`.
