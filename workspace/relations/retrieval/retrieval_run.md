---
id: "rel:retrieval.retrieval_run"
kind: table
schema: retrieval
name: retrieval_run
domain: retrieval
aliases: [retrieval run]
tokens: [retrieval, retrieval_run, retrieval.retrieval_run, id, plan_id, stage_timings, fusion_params, reranker_id, executed_at, tenant_id, operation_id, request_sha256]
summary: One executed retrieval plan; packets may record the run that built them.
summary_basis: curated
rls: enabled
readers: [executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"retrieval\"][\"Tables\"][\"retrieval_run\"][\"Row\"]"
defined_in: ["20260826001000_retrieval.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# retrieval.retrieval_run

table in domain `retrieval`.

> curated (model_assisted, unreviewed) — One executed retrieval plan; packets may record the run that built them.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `plan_id` | `uuid` | no | — | FK → [`retrieval.retrieval_plan`](retrieval_plan.md).id; _curated:_ Parent retrieval.retrieval_plan. |
| 3 | `stage_timings` | `jsonb` | no | `'{}'::jsonb` | — |
| 4 | `fusion_params` | `jsonb` | no | `'{}'::jsonb` | — |
| 5 | `reranker_id` | `text` | yes | — | — |
| 6 | `executed_at` | `timestamp with time zone` | no | `now()` | — |
| 7 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id) |
| 8 | `operation_id` | `uuid` | yes | — | Durable API operation that authorized and executed this immutable retrieval run. |
| 9 | `request_sha256` | `text` | yes | — | Canonical digest of the validated retrieval request used for idempotent replay.; _curated:_ Digest of the request that produced this run. |

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

## Examples

Packet built by a run

```bash
knowledge db query retrieval.evidence_packet --param packet_id=0192c000-0000-7000-8000-000000000001
```
Packet JSON may include run_id pointing here.

Defined in: `20260826001000_retrieval.sql`.
