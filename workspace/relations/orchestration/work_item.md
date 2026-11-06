---
id: "rel:orchestration.work_item"
kind: table
schema: orchestration
name: work_item
domain: orchestration-ledger
aliases: []
tokens: [orchestration, work_item, orchestration.work_item, id, tenant_id, mission_id, kind, spec, status, capability_profile_id, budget_cost_usd, budget_wall_seconds, max_attempts, attempt_count, terminal_evidence, created_at, updated_at, idempotency_key, lease_owner, lease_expires_at, heartbeat_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [control_plane, executor_service, service_role]
typescript: "Database[\"orchestration\"][\"Tables\"][\"work_item\"][\"Row\"]"
defined_in: ["20260826000200_orchestration.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# orchestration.work_item

table in domain `orchestration-ledger`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id) |
| 3 | `mission_id` | `uuid` | no | — | FK → [`orchestration.mission`](mission.md).id |
| 4 | `kind` | `text` | no | — | FK → [`orchestration.work_item_kind`](work_item_kind.md).code |
| 5 | `spec` | `jsonb` | no | `'{}'::jsonb` | — |
| 6 | `status` | `orchestration.work_item_status` | no | `'pending'::orchestration.work_item_status` | — |
| 7 | `capability_profile_id` | `uuid` | yes | — | FK → [`orchestration.capability_profile`](capability_profile.md).id |
| 8 | `budget_cost_usd` | `numeric(12,4)` | yes | — | — |
| 9 | `budget_wall_seconds` | `integer` | yes | — | — |
| 10 | `max_attempts` | `integer` | no | `3` | — |
| 11 | `attempt_count` | `integer` | no | `0` | — |
| 12 | `terminal_evidence` | `jsonb` | yes | — | — |
| 13 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 14 | `updated_at` | `timestamp with time zone` | no | `now()` | — |
| 15 | `idempotency_key` | `text` | yes | — | — |
| 16 | `lease_owner` | `text` | yes | — | — |
| 17 | `lease_expires_at` | `timestamp with time zone` | yes | — | — |
| 18 | `heartbeat_at` | `timestamp with time zone` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `work_item_attempts_sane`: `((attempt_count >= 0) AND (max_attempts > 0))`
- check `work_item_lease_consistent`: `(((status = 'running'::orchestration.work_item_status) AND (lease_owner IS NOT NULL) AND (lease_expires_at IS NOT NULL)) OR ((status <> 'ru…`

## Relationships

Outbound: `capability_profile_id` → [`orchestration.capability_profile`](capability_profile.md)`.id`; `kind` → [`orchestration.work_item_kind`](work_item_kind.md)`.code`; `mission_id` → [`orchestration.mission`](mission.md)`.id` on delete cascade.
Inbound: [`evaluation.eval_run`](../evaluation/eval_run.md).work_item_id, [`evaluation.gate_result`](../evaluation/gate_result.md).spawned_work_item_id, [`evidence.revalidation_event`](../evidence/revalidation_event.md).work_item_id, [`knowledge_service.eve_operation_binding`](../knowledge_service/eve_operation_binding.md).work_item_id, [`knowledge_service.operation`](../knowledge_service/operation.md).work_item_id, [`observability.trace`](../observability/trace.md).work_item_id, [`orchestration.artifact_manifest`](artifact_manifest.md).work_item_id, [`orchestration.attempt`](attempt.md).work_item_id, [`orchestration.work_item_artifact`](work_item_artifact.md).work_item_id, [`orchestration.work_item_dependency`](work_item_dependency.md).depends_on_id|work_item_id, [`orchestration.work_item_event`](work_item_event.md).work_item_id, [`ranking.ranking_run`](../ranking/ranking_run.md).work_item_id … 1 more in [details](work_item.details.md).

## Indexes

`work_item_idempotency_uq` unique where `(idempotency_key IS NOT NULL)`; `work_item_lease_idx` where `(status = ANY (ARRAY['pending'::orchestration.work_item_sta…`; `work_item_mission_idx`; `work_item_ready_idx` where `(status = ANY (ARRAY['pending'::orchestration.work_item_sta…`; `work_item_tenant_id_uq` unique

## Triggers

- `work_item_set_updated_at` → [`util.set_updated_at`](../../functions/util/set_updated_at.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: INSERT, SELECT, UPDATE; `executor_service`: INSERT, SELECT; `pipeline_agent`: SELECT; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Exposed through: [`api.mission_progress`](../api/mission_progress.md).
- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `control_plane`, `executor_service`.

## TypeScript

insert: `Database["orchestration"]["Tables"]["work_item"]["Insert"]`; row: `Database["orchestration"]["Tables"]["work_item"]["Row"]`; update: `Database["orchestration"]["Tables"]["work_item"]["Update"]`

Defined in: `20260826000200_orchestration.sql`.
