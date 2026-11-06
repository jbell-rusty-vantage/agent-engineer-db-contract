---
id: "rel:orchestration.mission"
kind: table
schema: orchestration
name: mission
domain: orchestration-ledger
aliases: []
tokens: [orchestration, mission, orchestration.mission, id, tenant_id, slug, goal, research_questions, acceptance_criteria, selection_id, capability_profile_id, budget_cost_usd, budget_wall_seconds, budget_max_fanout, budget_max_depth, budget_max_retries, status, terminal_reason, started_at, ended_at, created_at, updated_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role]
writers: [control_plane, executor_service, service_role]
typescript: "Database[\"orchestration\"][\"Tables\"][\"mission\"][\"Row\"]"
defined_in: ["20260826000200_orchestration.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# orchestration.mission

table in domain `orchestration-ledger`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id); unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id); unique (tenant_id, slug); unique (tenant_id, id) |
| 3 | `slug` | `text` | yes | — | unique (tenant_id, slug) |
| 4 | `goal` | `text` | no | — | — |
| 5 | `research_questions` | `jsonb` | no | `'[]'::jsonb` | — |
| 6 | `acceptance_criteria` | `jsonb` | no | `'[]'::jsonb` | — |
| 7 | `selection_id` | `uuid` | yes | — | FK → [`ranking.selection`](../ranking/selection.md).id |
| 8 | `capability_profile_id` | `uuid` | yes | — | FK → [`orchestration.capability_profile`](capability_profile.md).id |
| 9 | `budget_cost_usd` | `numeric(12,4)` | yes | — | — |
| 10 | `budget_wall_seconds` | `integer` | yes | — | — |
| 11 | `budget_max_fanout` | `integer` | yes | — | — |
| 12 | `budget_max_depth` | `integer` | yes | — | — |
| 13 | `budget_max_retries` | `integer` | yes | — | — |
| 14 | `status` | `orchestration.mission_status` | no | `'created'::orchestration.mission_status` | — |
| 15 | `terminal_reason` | `text` | yes | — | — |
| 16 | `started_at` | `timestamp with time zone` | yes | — | — |
| 17 | `ended_at` | `timestamp with time zone` | yes | — | — |
| 18 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 19 | `updated_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, slug)
- unique (tenant_id, id)
- check `mission_terminal_has_end`: `((status = ANY (ARRAY['succeeded'::orchestration.mission_status, 'failed'::orchestration.mission_status, 'cancelled'::orchestration.mission…`

## Relationships

Outbound: `capability_profile_id` → [`orchestration.capability_profile`](capability_profile.md)`.id`; `selection_id` → [`ranking.selection`](../ranking/selection.md)`.id`.
Inbound: [`evaluation.eval_run`](../evaluation/eval_run.md).mission_id, [`knowledge_service.eve_operation_binding`](../knowledge_service/eve_operation_binding.md).mission_id, [`observability.trace`](../observability/trace.md).mission_id, [`observability.usage_rollup`](../observability/usage_rollup.md).mission_id, [`orchestration.agent_session`](agent_session.md).mission_id, [`orchestration.artifact`](artifact.md).mission_id, [`orchestration.artifact_manifest`](artifact_manifest.md).mission_id, [`orchestration.continuation_checkpoint`](continuation_checkpoint.md).mission_id, [`orchestration.mission_event`](mission_event.md).mission_id, [`orchestration.operation_intent`](operation_intent.md).mission_id, [`orchestration.outbox_event`](outbox_event.md).mission_id, [`orchestration.work_item`](work_item.md).mission_id … 5 more in [details](mission.details.md).

## Indexes

`mission_eve_binding_tenant_id_uq` unique; `mission_slug_uq` unique; `mission_status_idx`; `mission_tenant_id_uq` unique

## Triggers

- `mission_set_updated_at` → [`util.set_updated_at`](../../functions/util/set_updated_at.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: INSERT, SELECT, UPDATE; `executor_service`: INSERT, SELECT; `pipeline_agent`: SELECT; `service_role`: INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `verifier_agent`.

## Read paths

- Exposed through: [`api.mission_progress`](../api/mission_progress.md).
- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`.

## Write path

- Direct DML: `control_plane`, `executor_service`.

## TypeScript

insert: `Database["orchestration"]["Tables"]["mission"]["Insert"]`; row: `Database["orchestration"]["Tables"]["mission"]["Row"]`; update: `Database["orchestration"]["Tables"]["mission"]["Update"]`

Defined in: `20260826000200_orchestration.sql`.
