---
id: "rel:inquiry.watch"
kind: table
schema: inquiry
name: watch
domain: inquiry
lens: ours
aliases: []
tokens: [inquiry, watch, inquiry.watch, id, tenant_id, workspace_id, brief_work_id, subjects, sources, cadence, budget_per_run_usd, budget_total_usd, stop_condition, target_work_ids, mc_schedule_ref, state, created_by, created_at, state_changed_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"inquiry\"][\"Tables\"][\"watch\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:216c4ae7230478c8e60934da25c852e10680d6caed71a662962ea3c0ac1676d3"
---
# inquiry.watch

table in domain `inquiry`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id) |
| 4 | `brief_work_id` | `uuid` | no | — | — |
| 5 | `subjects` | `jsonb` | no | — | — |
| 6 | `sources` | `jsonb` | no | — | — |
| 7 | `cadence` | `text` | no | — | — |
| 8 | `budget_per_run_usd` | `numeric(10,2)` | no | — | — |
| 9 | `budget_total_usd` | `numeric(10,2)` | no | — | — |
| 10 | `stop_condition` | `jsonb` | no | `'{}'::jsonb` | — |
| 11 | `target_work_ids` | `uuid[]` | no | `'{}'::uuid[]` | — |
| 12 | `mc_schedule_ref` | `text` | yes | — | — |
| 13 | `state` | `text` | no | `'active'::text` | — |
| 14 | `created_by` | `uuid` | no | — | FK → `auth.users`.id |
| 15 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 16 | `state_changed_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, workspace_id, id)
- check `watch_budget_per_run_usd_check`: `(budget_per_run_usd >= (0)::numeric)`
- check `watch_cadence_check`: `(cadence ~ '^P(T?[0-9]+[YMWDHS])+$'::text)`
- check `watch_check`: `(budget_total_usd >= budget_per_run_usd)`
- check `watch_sources_check`: `(jsonb_typeof(sources) = 'array'::text)`
- check `watch_state_check`: `(state = ANY (ARRAY['active'::text, 'paused'::text, 'stopped'::text]))`
- check `watch_stop_condition_check`: `(jsonb_typeof(stop_condition) = 'object'::text)`
- check `watch_subjects_check`: `((jsonb_typeof(subjects) = 'array'::text) AND (jsonb_array_length(subjects) > 0))`

## Relationships

Outbound: `created_by` → `auth.users``.id` on delete restrict; `tenant_id,workspace_id,brief_work_id` → [`authoring.work`](../authoring/work.md)`.tenant_id,workspace_id,id` on delete restrict.
Inbound: [`acquisition.attention_policy`](../acquisition/attention_policy.md).inquiry_watch_id.

## Indexes

`watch_created_by_fkey_ix`; `watch_tenant_id_workspace_id_brief_work_id_fkey_ix`; `watch_tenant_id_workspace_id_id_key` unique

## Triggers

- `mutable_guard` → [`product.guard_mutable`](../../functions/product/guard_mutable.md)

## Row-level security

Enabled and forced.
- `product_api_all` (ALL) for `product_api_owner`: `true`

## Grants

No role has privileges. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

## Read paths

- No agent role may SELECT directly.

## Write path

- No direct DML for any agent role.
- Via functions (best effort): [`product.dispatch_research_command`](../../functions/product/dispatch_research_command.md).
- Product operations (best effort): [`create_watch`](../../ops/create_watch.md), [`set_watch_state`](../../ops/set_watch_state.md).

## TypeScript

insert: `Database["inquiry"]["Tables"]["watch"]["Insert"]`; row: `Database["inquiry"]["Tables"]["watch"]["Row"]`; update: `Database["inquiry"]["Tables"]["watch"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
