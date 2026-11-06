---
id: "rel:knowledge_service.receipt"
kind: table
schema: knowledge_service
name: receipt
domain: knowledge-service-runtime
aliases: []
tokens: [knowledge_service, receipt, knowledge_service.receipt, id, tenant_id, operation_id, step_id, receipt_kind, idempotency_key, executor_identity, input_sha256, output_sha256, outcome, body, signature, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, service_role]
writers: [control_plane, executor_service, service_role]
typescript: "Database[\"knowledge_service\"][\"Tables\"][\"receipt\"][\"Row\"]"
defined_in: ["20260903010200_knowledge_runtime_security.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# knowledge_service.receipt

table in domain `knowledge-service-runtime`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id); unique (tenant_id, idempotency_key) |
| 3 | `operation_id` | `uuid` | no | — | — |
| 4 | `step_id` | `uuid` | yes | — | — |
| 5 | `receipt_kind` | `text` | no | — | — |
| 6 | `idempotency_key` | `text` | no | — | unique (tenant_id, idempotency_key) |
| 7 | `executor_identity` | `text` | no | — | — |
| 8 | `input_sha256` | `text` | no | — | — |
| 9 | `output_sha256` | `text` | yes | — | — |
| 10 | `outcome` | `text` | no | — | — |
| 11 | `body` | `jsonb` | no | — | — |
| 12 | `signature` | `text` | yes | — | — |
| 13 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, idempotency_key)
- check `receipt_input_sha256_check`: `(input_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `receipt_output_sha256_check`: `((output_sha256 IS NULL) OR (output_sha256 ~ '^[0-9a-f]{64}$'::text))`

## Relationships

Outbound: `tenant_id,operation_id` → [`knowledge_service.operation`](operation.md)`.tenant_id,id` on delete restrict; `tenant_id,step_id` → [`knowledge_service.operation_step`](operation_step.md)`.tenant_id,id` on delete restrict.
Inbound: none.

## Indexes

`receipt_tenant_id_id_key` unique; `receipt_tenant_id_idempotency_key_key` unique

## Triggers

- `receipt_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)
- `verification_benchmark_comparison_success_receipt` → [`evaluation.guard_verification_benchmark_comparison_success_receipt`](../../functions/evaluation/guard_verification_benchmark_comparison_success_receipt.md)
- `verification_structured_extraction_failure_receipt` → [`orchestration.guard_structured_extraction_failure_receipt`](../../functions/orchestration/guard_structured_extraction_failure_receipt.md)
- `verification_structured_extraction_success_receipt` → [`orchestration.guard_structured_extraction_success_receipt`](../../functions/orchestration/guard_structured_extraction_success_receipt.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: INSERT, SELECT, UPDATE; `executor_service`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`.

## Write path

- Direct DML: `control_plane`, `executor_service`.

## TypeScript

insert: `Database["knowledge_service"]["Tables"]["receipt"]["Insert"]`; row: `Database["knowledge_service"]["Tables"]["receipt"]["Row"]`; update: `Database["knowledge_service"]["Tables"]["receipt"]["Update"]`

Defined in: `20260903010200_knowledge_runtime_security.sql`.
