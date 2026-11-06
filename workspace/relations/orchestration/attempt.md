---
id: "rel:orchestration.attempt"
kind: table
schema: orchestration
name: attempt
domain: orchestration-ledger
aliases: []
tokens: [orchestration, attempt, orchestration.attempt, id, tenant_id, work_item_id, attempt_no, agent_deployment_id, agent_session_id, eve_turn_ids, remote_child_ids, outcome, cost_usd, latency_ms, token_input, token_output, started_at, ended_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [control_plane, executor_service, service_role]
typescript: "Database[\"orchestration\"][\"Tables\"][\"attempt\"][\"Row\"]"
defined_in: ["20260826000200_orchestration.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# orchestration.attempt

table in domain `orchestration-ledger`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id) |
| 3 | `work_item_id` | `uuid` | no | — | unique (work_item_id, attempt_no); FK → [`orchestration.work_item`](work_item.md).id |
| 4 | `attempt_no` | `integer` | no | — | unique (work_item_id, attempt_no) |
| 5 | `agent_deployment_id` | `text` | no | — | — |
| 6 | `agent_session_id` | `uuid` | yes | — | FK → [`orchestration.agent_session`](agent_session.md).id |
| 7 | `eve_turn_ids` | `text[]` | no | `'{}'::text[]` | — |
| 8 | `remote_child_ids` | `text[]` | no | `'{}'::text[]` | — |
| 9 | `outcome` | `orchestration.attempt_outcome` | yes | — | — |
| 10 | `cost_usd` | `numeric(12,4)` | yes | — | — |
| 11 | `latency_ms` | `bigint` | yes | — | — |
| 12 | `token_input` | `bigint` | yes | — | — |
| 13 | `token_output` | `bigint` | yes | — | — |
| 14 | `started_at` | `timestamp with time zone` | no | `now()` | — |
| 15 | `ended_at` | `timestamp with time zone` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (work_item_id, attempt_no)

## Relationships

Outbound: `agent_session_id` → [`orchestration.agent_session`](agent_session.md)`.id`; `work_item_id` → [`orchestration.work_item`](work_item.md)`.id` on delete cascade.
Inbound: [`content.document`](../content/document.md).created_by_attempt_id, [`content.transformation_run`](../content/transformation_run.md).attempt_id, [`evaluation.eval_run`](../evaluation/eval_run.md).attempt_id, [`evidence.claim`](../evidence/claim.md).producer_attempt_id, [`evidence.extraction_run`](../evidence/extraction_run.md).attempt_id, [`evidence.extraction_signature`](../evidence/extraction_signature.md).produced_by_attempt_id, [`evidence.source_capture`](../evidence/source_capture.md).produced_by_attempt_id, [`evidence.source_query`](../evidence/source_query.md).attempt_id, [`knowledge_service.eve_operation_binding`](../knowledge_service/eve_operation_binding.md).attempt_id, [`knowledge_service.operation`](../knowledge_service/operation.md).attempt_id, [`observability.trace`](../observability/trace.md).attempt_id, [`orchestration.artifact`](artifact.md).producer_attempt_id … 8 more in [details](attempt.details.md).

## Indexes

`attempt_deployment_idx`; `attempt_session_idx`; `attempt_tenant_id_uq` unique; `attempt_work_item_id_attempt_no_key` unique

## Triggers

- `attempt_identity_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: INSERT, SELECT, UPDATE; `executor_service`: INSERT, SELECT; `pipeline_agent`: SELECT; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `control_plane`, `executor_service`.

## TypeScript

insert: `Database["orchestration"]["Tables"]["attempt"]["Insert"]`; row: `Database["orchestration"]["Tables"]["attempt"]["Row"]`; update: `Database["orchestration"]["Tables"]["attempt"]["Update"]`

Defined in: `20260826000200_orchestration.sql`.
