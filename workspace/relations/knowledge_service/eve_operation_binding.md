---
id: "rel:knowledge_service.eve_operation_binding"
kind: table
schema: knowledge_service
name: eve_operation_binding
domain: knowledge-service-runtime
aliases: []
tokens: [knowledge_service, eve_operation_binding, knowledge_service.eve_operation_binding, tenant_id, operation_id, idempotency_key, grant_id, use_case, request_sha256, actor_identity, mission_id, work_item_id, attempt_id, agent_deployment_id, capability_version, original_external_execution, issuer, original_key_id, original_jti, original_payload_sha256, created_at]
summary: Immutable first-lineage binding for API-verified Eve verification requests. It grants no authority itself.
summary_basis: comment
rls: enabled
readers: [control_plane, service_role]
writers: [control_plane, service_role]
typescript: "Database[\"knowledge_service\"][\"Tables\"][\"eve_operation_binding\"][\"Row\"]"
defined_in: ["20260908010000_eve_verification_binding.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# knowledge_service.eve_operation_binding

table in domain `knowledge-service-runtime` — Immutable first-lineage binding for API-verified Eve verification requests. It grants no authority itself..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | PK; unique (tenant_id, idempotency_key) |
| 2 | `operation_id` | `uuid` | no | — | PK |
| 3 | `idempotency_key` | `text` | no | — | unique (tenant_id, idempotency_key) |
| 4 | `grant_id` | `text` | no | — | — |
| 5 | `use_case` | `text` | no | — | — |
| 6 | `request_sha256` | `text` | no | — | — |
| 7 | `actor_identity` | `text` | no | — | — |
| 8 | `mission_id` | `uuid` | no | — | — |
| 9 | `work_item_id` | `uuid` | no | — | — |
| 10 | `attempt_id` | `uuid` | no | — | — |
| 11 | `agent_deployment_id` | `text` | no | — | — |
| 12 | `capability_version` | `text` | no | — | — |
| 13 | `original_external_execution` | `jsonb` | no | — | — |
| 14 | `issuer` | `text` | no | — | — |
| 15 | `original_key_id` | `text` | no | — | — |
| 16 | `original_jti` | `text` | no | — | — |
| 17 | `original_payload_sha256` | `text` | no | — | — |
| 18 | `created_at` | `timestamp with time zone` | no | `clock_timestamp()` | — |

## Constraints

- PK (tenant_id, operation_id)
- unique (tenant_id, idempotency_key)
- check `eve_operation_binding_actor_identity_check`: `((actor_identity = btrim(actor_identity)) AND ((char_length(actor_identity) >= 3) AND (char_length(actor_identity) <= 512)))`
- check `eve_operation_binding_agent_deployment_id_check`: `((agent_deployment_id = btrim(agent_deployment_id)) AND ((char_length(agent_deployment_id) >= 1) AND (char_length(agent_deployment_id) <= 2…`
- check `eve_operation_binding_capability_version_check`: `((capability_version = btrim(capability_version)) AND ((char_length(capability_version) >= 1) AND (char_length(capability_version) <= 255)))`
- check `eve_operation_binding_grant_id_check`: `((grant_id = btrim(grant_id)) AND ((char_length(grant_id) >= 1) AND (char_length(grant_id) <= 255)))`
- check `eve_operation_binding_idempotency_key_check`: `((idempotency_key = btrim(idempotency_key)) AND ((char_length(idempotency_key) >= 1) AND (char_length(idempotency_key) <= 512)))`
- check `eve_operation_binding_issuer_check`: `((issuer = btrim(issuer)) AND ((char_length(issuer) >= 1) AND (char_length(issuer) <= 255)))`
- check `eve_operation_binding_original_external_execution_check`: `((original_external_execution ?& ARRAY['runtime'::text, 'runId'::text, 'sessionId'::text, 'turnId'::text, 'toolCallId'::text]) AND ((origin…`
- check `eve_operation_binding_original_jti_check`: `((original_jti = btrim(original_jti)) AND ((char_length(original_jti) >= 1) AND (char_length(original_jti) <= 255)))`
- check `eve_operation_binding_original_key_id_check`: `((original_key_id = btrim(original_key_id)) AND ((char_length(original_key_id) >= 1) AND (char_length(original_key_id) <= 255)))`
- check `eve_operation_binding_original_payload_sha256_check`: `(original_payload_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `eve_operation_binding_request_sha256_check`: `(request_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `eve_operation_binding_use_case_check`: `(use_case = ANY (ARRAY['verifyClaims'::text, 'verifyReport'::text]))`

## Relationships

Outbound: `tenant_id,attempt_id` → [`orchestration.attempt`](../orchestration/attempt.md)`.tenant_id,id` on delete restrict; `tenant_id,mission_id` → [`orchestration.mission`](../orchestration/mission.md)`.tenant_id,id` on delete restrict; `tenant_id,work_item_id` → [`orchestration.work_item`](../orchestration/work_item.md)`.tenant_id,id` on delete restrict.
Inbound: [`knowledge_service.eve_operation_invocation`](eve_operation_invocation.md).operation_id.

## Indexes

`eve_operation_binding_attempt_idx`; `eve_operation_binding_tenant_id_idempotency_key_key` unique

## Triggers

- `eve_operation_binding_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled.
- `eve_operation_binding_control_plane` (ALL) for `control_plane`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: INSERT, SELECT; `service_role`: INSERT, SELECT. None: `anon`, `app_reader`, `authenticated`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `control_plane`.

## Write path

- Direct DML: `control_plane`.

## TypeScript

insert: `Database["knowledge_service"]["Tables"]["eve_operation_binding"]["Insert"]`; row: `Database["knowledge_service"]["Tables"]["eve_operation_binding"]["Row"]`; update: `Database["knowledge_service"]["Tables"]["eve_operation_binding"]["Update"]`

Defined in: `20260908010000_eve_verification_binding.sql`.
