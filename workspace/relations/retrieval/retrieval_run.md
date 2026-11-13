---
id: "rel:retrieval.retrieval_run"
kind: table
schema: retrieval
name: retrieval_run
domain: retrieval
lens: corpus
aliases: []
tokens: [retrieval, retrieval_run, retrieval.retrieval_run, id, plan_id, stage_timings, fusion_params, reranker_id, executed_at, tenant_id, operation_id, request_sha256]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"retrieval\"][\"Tables\"][\"retrieval_run\"][\"Row\"]"
defined_in: ["20260826001000_retrieval.sql"]
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# retrieval.retrieval_run

table in domain `retrieval`, lens `corpus`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `plan_id` | `uuid` | no | — | FK → [`retrieval.retrieval_plan`](retrieval_plan.md).id |
| 3 | `stage_timings` | `jsonb` | no | `'{}'::jsonb` | — |
| 4 | `fusion_params` | `jsonb` | no | `'{}'::jsonb` | — |
| 5 | `reranker_id` | `text` | yes | — | — |
| 6 | `executed_at` | `timestamp with time zone` | no | `now()` | — |
| 7 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id) |
| 8 | `operation_id` | `uuid` | yes | — | Durable API operation that authorized and executed this immutable retrieval run. |
| 9 | `request_sha256` | `text` | yes | — | Canonical digest of the validated retrieval request used for idempotent replay. |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `retrieval_run_request_sha256_ck`: `((request_sha256 IS NULL) OR (request_sha256 ~ '^[0-9a-f]{64}$'::text))`

## Relationships

Outbound: `tenant_id,operation_id` → [`knowledge_service.operation`](../knowledge_service/operation.md)`.tenant_id,id` on delete restrict; `plan_id` → [`retrieval.retrieval_plan`](retrieval_plan.md)`.id` (+tenant) on delete cascade.
Inbound: [`retrieval.evidence_packet`](evidence_packet.md).run_id, [`retrieval.retrieval_candidate`](retrieval_candidate.md).run_id.

## Indexes

`retrieval_run_operation_uq` unique where `(operation_id IS NOT NULL)`; `retrieval_run_tenant_id_uq` unique

## Triggers

- `retrieval_run_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `false`

## Grants

`executor_service`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `executor_service`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["retrieval"]["Tables"]["retrieval_run"]["Insert"]`; row: `Database["retrieval"]["Tables"]["retrieval_run"]["Row"]`; update: `Database["retrieval"]["Tables"]["retrieval_run"]["Update"]`

Defined in: `20260826001000_retrieval.sql`.
