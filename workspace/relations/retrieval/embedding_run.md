---
id: "rel:retrieval.embedding_run"
kind: table
schema: retrieval
name: embedding_run
domain: retrieval
aliases: []
tokens: [retrieval, embedding_run, retrieval.embedding_run, id, tenant_id, vector_space_version_id, operation_id, adapter_version, gateway_model_slug, provider_route_policy, expected_dimensions, input_manifest_sha256, output_manifest_sha256, idempotency_key, status, request_id, observed_provider_route, usage, latency_ms, retry_history, cost_usd, receipt, failure_class, created_at, completed_at, promotion_decision_id, legacy_provenance]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"retrieval\"][\"Tables\"][\"embedding_run\"][\"Row\"]"
defined_in: ["20260903010100_knowledge_retrieval_contract.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# retrieval.embedding_run

table in domain `retrieval`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id); unique (tenant_id, idempotency_key) |
| 3 | `vector_space_version_id` | `uuid` | no | — | — |
| 4 | `operation_id` | `uuid` | yes | — | — |
| 5 | `adapter_version` | `text` | no | — | — |
| 6 | `gateway_model_slug` | `text` | no | — | — |
| 7 | `provider_route_policy` | `jsonb` | no | — | — |
| 8 | `expected_dimensions` | `integer` | no | — | — |
| 9 | `input_manifest_sha256` | `text` | no | — | — |
| 10 | `output_manifest_sha256` | `text` | yes | — | — |
| 11 | `idempotency_key` | `text` | no | — | unique (tenant_id, idempotency_key) |
| 12 | `status` | `text` | no | `'queued'::text` | — |
| 13 | `request_id` | `text` | yes | — | — |
| 14 | `observed_provider_route` | `text` | yes | — | — |
| 15 | `usage` | `jsonb` | no | `'{}'::jsonb` | — |
| 16 | `latency_ms` | `bigint` | yes | — | — |
| 17 | `retry_history` | `jsonb` | no | `'[]'::jsonb` | — |
| 18 | `cost_usd` | `numeric(14,6)` | yes | — | — |
| 19 | `receipt` | `jsonb` | yes | — | — |
| 20 | `failure_class` | `text` | yes | — | — |
| 21 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 22 | `completed_at` | `timestamp with time zone` | yes | — | — |
| 23 | `promotion_decision_id` | `uuid` | yes | — | — |
| 24 | `legacy_provenance` | `boolean` | no | `false` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, idempotency_key)
- check `embedding_run_input_manifest_sha256_check`: `(input_manifest_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `embedding_run_provenance_required_ck`: `(legacy_provenance OR ((operation_id IS NOT NULL) AND (promotion_decision_id IS NOT NULL)))`

## Relationships

Outbound: `tenant_id,operation_id` → [`knowledge_service.operation`](../knowledge_service/operation.md)`.tenant_id,id` on delete restrict; `tenant_id,promotion_decision_id` → [`retrieval.content_promotion_decision`](content_promotion_decision.md)`.tenant_id,id` on delete restrict; `tenant_id,vector_space_version_id` → [`retrieval.vector_space_version`](vector_space_version.md)`.tenant_id,id` on delete restrict.
Inbound: [`retrieval.embedding_item`](embedding_item.md).embedding_run_id.

## Indexes

`embedding_run_tenant_id_id_key` unique; `embedding_run_tenant_id_idempotency_key_key` unique

## Triggers

- `embedding_run_no_new_legacy` → [`retrieval.reject_new_legacy_governance_provenance`](../../functions/retrieval/reject_new_legacy_governance_provenance.md)
- `embedding_run_terminal_guard` → [`retrieval.guard_terminal_status`](../../functions/retrieval/guard_terminal_status.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

No role has privileges. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

## Read paths

- No agent role may SELECT directly.

## Write path

- No direct DML for any agent role.
- No write path for agents; rows are seeded by migrations or platform tooling.

## TypeScript

insert: `Database["retrieval"]["Tables"]["embedding_run"]["Insert"]`; row: `Database["retrieval"]["Tables"]["embedding_run"]["Row"]`; update: `Database["retrieval"]["Tables"]["embedding_run"]["Update"]`

Defined in: `20260903010100_knowledge_retrieval_contract.sql`.
