---
id: "rel:inquiry.acceptance"
kind: table
schema: inquiry
name: acceptance
domain: inquiry
lens: ours
aliases: []
tokens: [inquiry, acceptance, inquiry.acceptance, id, tenant_id, workspace_id, brief_work_id, brief_revision_id, acceptance_no, revises_acceptance_id, accepted_by, accepted_event_id, budget_limit_usd, spent_usd, budget_policy, world_from, world_to, world_precision, knowledge_policy, execution_origin, mc_installation_id, mc_application_id, mc_mission_id, mc_revision_id, mc_run_id, state, state_changed_at, created_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"inquiry\"][\"Tables\"][\"acceptance\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# inquiry.acceptance

table in domain `inquiry`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id); unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, id); unique (tenant_id, workspace_id, brief_work_id, acceptance_no); unique (tenant_id, workspace_id, id) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, brief_work_id, acceptance_no); unique (tenant_id, workspace_id, id) |
| 4 | `brief_work_id` | `uuid` | no | — | unique (tenant_id, workspace_id, brief_work_id, acceptance_no) |
| 5 | `brief_revision_id` | `uuid` | no | — | — |
| 6 | `acceptance_no` | `integer` | no | — | unique (tenant_id, workspace_id, brief_work_id, acceptance_no) |
| 7 | `revises_acceptance_id` | `uuid` | yes | — | — |
| 8 | `accepted_by` | `uuid` | no | — | FK → `auth.users`.id |
| 9 | `accepted_event_id` | `uuid` | no | — | — |
| 10 | `budget_limit_usd` | `numeric(10,2)` | no | — | — |
| 11 | `spent_usd` | `numeric(10,2)` | no | `0` | — |
| 12 | `budget_policy` | `jsonb` | no | `'{}'::jsonb` | — |
| 13 | `world_from` | `timestamp with time zone` | yes | — | — |
| 14 | `world_to` | `timestamp with time zone` | yes | — | — |
| 15 | `world_precision` | `text` | no | `'unknown'::text` | — |
| 16 | `knowledge_policy` | `text` | no | — | — |
| 17 | `execution_origin` | `text` | no | — | — |
| 18 | `mc_installation_id` | `uuid` | yes | — | — |
| 19 | `mc_application_id` | `text` | yes | — | — |
| 20 | `mc_mission_id` | `uuid` | yes | — | — |
| 21 | `mc_revision_id` | `uuid` | yes | — | — |
| 22 | `mc_run_id` | `uuid` | yes | — | — |
| 23 | `state` | `text` | no | `'accepted'::text` | — |
| 24 | `state_changed_at` | `timestamp with time zone` | no | `now()` | — |
| 25 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, workspace_id, brief_work_id, acceptance_no)
- unique (tenant_id, workspace_id, id)
- check `acceptance_acceptance_no_check`: `(acceptance_no > 0)`
- check `acceptance_budget_limit_usd_check`: `(budget_limit_usd >= (0)::numeric)`
- check `acceptance_budget_policy_check`: `(jsonb_typeof(budget_policy) = 'object'::text)`
- check `acceptance_check`: `((execution_origin <> 'mc'::text) OR ((mc_installation_id IS NOT NULL) AND (mc_application_id IS NOT NULL) AND (mc_mission_id IS NOT NULL) …`
- check `acceptance_check1`: `((execution_origin = 'mc'::text) OR (num_nonnulls(mc_installation_id, mc_application_id, mc_mission_id, mc_revision_id, mc_run_id) = 0))`
- check `acceptance_check2`: `(spent_usd <= budget_limit_usd)`
- check `acceptance_check3`: `(((world_precision = 'unknown'::text) AND (world_from IS NULL) AND (world_to IS NULL)) OR ((world_precision = 'instant'::text) AND (world_f…`
- check `acceptance_execution_origin_check`: `(execution_origin = ANY (ARRAY['mc'::text, 'native_harness'::text, 'manual'::text]))`
- check `acceptance_knowledge_policy_check`: `(knowledge_policy = ANY (ARRAY['sealed'::text, 'latest_at_run'::text]))`
- check `acceptance_spent_usd_check`: `(spent_usd >= (0)::numeric)`
- check `acceptance_state_check`: `(state = ANY (ARRAY['accepted'::text, 'running'::text, 'delivered'::text, 'closed'::text, 'cancelled'::text, 'failed'::text, 'superseded'::…`
- check `acceptance_world_precision_check`: `(world_precision = ANY (ARRAY['instant'::text, 'day'::text, 'unknown'::text]))`

## Relationships

4 outbound and 3 inbound foreign keys; full list in [details](acceptance.details.md).

## Indexes

7 indexes; see [details](acceptance.details.md).

## Triggers

1 triggers; see [details](acceptance.details.md).

## Row-level security

Enabled; 1 policies in [details](acceptance.details.md).

## Grants

No role has privileges. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

## Read paths

- No agent role may SELECT directly.

## Write path

- No direct DML for any agent role.
- Via functions (best effort): [`product.dispatch_research_command`](../../functions/product/dispatch_research_command.md).
- Product operations (best effort): [`accept_research`](../../ops/accept_research.md), [`deliver_output`](../../ops/deliver_output.md), [`set_acceptance_state`](../../ops/set_acceptance_state.md), [`withdraw_acceptance`](../../ops/withdraw_acceptance.md).

## TypeScript

insert: `Database["inquiry"]["Tables"]["acceptance"]["Insert"]`; row: `Database["inquiry"]["Tables"]["acceptance"]["Row"]`; update: `Database["inquiry"]["Tables"]["acceptance"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
