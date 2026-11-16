---
id: "rel:acquisition.attention_policy"
kind: table
schema: acquisition
name: attention_policy
domain: source-intelligence
lens: corpus
aliases: []
tokens: [acquisition, attention_policy, acquisition.attention_policy, id, tenant_id, slug, title, scope_kind, channel_entity_ids, subject_entity_ids, watch_level, cadence, depth, selection, triggers, budget_usd_per_run, budget_credits_per_run, budget_total_usd, stop_condition, inquiry_watch_id, mission_id, designed_in_thread_id, state, rationale, decided_by, supersedes_id, created_at]
summary: "Loop 4: what we watch, how often (cadence, triggers), how deep (depth, selection) and on what budget. W0 ignore (registered, never swept; reason in rationale), W1 reference, W2 sampled, W3 release-coupled. A Mission Control watch mission (mission_id) executes it; a product watch (inquiry_watch_id) may have asked for it; a design interview (designed_in_thread_id) may have produced it."
summary_basis: comment
rls: enabled
readers: [app_reader, control_plane, pipeline_agent, service_role, verifier_agent]
writers: [control_plane, pipeline_agent, service_role]
typescript: "Database[\"acquisition\"][\"Tables\"][\"attention_policy\"][\"Row\"]"
defined_in: ["20261113120000_build08_loop4_source_intelligence_experiments.sql"]
workspace_fingerprint: "sha256:216c4ae7230478c8e60934da25c852e10680d6caed71a662962ea3c0ac1676d3"
---
# acquisition.attention_policy

table in domain `source-intelligence`, lens `corpus` — Loop 4: what we watch, how often (cadence, triggers), how deep (depth, selection) and on what budget. W0 ignore (registered, never swept; reason in rationale), W1 reference, W2 sampled, W3 release-coupled. A Mission Control watch mission (mission_id) executes it; a product watch (inquiry_watch_id) may have asked for it; a design interview (designed_in_thread_id) may have produced it..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, slug) |
| 3 | `slug` | `text` | no | — | unique (tenant_id, slug) |
| 4 | `title` | `text` | no | — | — |
| 5 | `scope_kind` | `text` | no | — | — |
| 6 | `channel_entity_ids` | `uuid[]` | no | `'{}'::uuid[]` | — |
| 7 | `subject_entity_ids` | `uuid[]` | no | `'{}'::uuid[]` | — |
| 8 | `watch_level` | `text` | no | — | — |
| 9 | `cadence` | `text` | yes | — | — |
| 10 | `depth` | `jsonb` | no | `'{}'::jsonb` | — |
| 11 | `selection` | `jsonb` | no | `'{}'::jsonb` | — |
| 12 | `triggers` | `jsonb` | no | `'[]'::jsonb` | — |
| 13 | `budget_usd_per_run` | `numeric(10,4)` | no | `0` | — |
| 14 | `budget_credits_per_run` | `integer` | no | `0` | — |
| 15 | `budget_total_usd` | `numeric(10,4)` | yes | — | — |
| 16 | `stop_condition` | `jsonb` | no | `'{}'::jsonb` | — |
| 17 | `inquiry_watch_id` | `uuid` | yes | — | FK → [`inquiry.watch`](../inquiry/watch.md).id |
| 18 | `mission_id` | `uuid` | yes | — | FK → [`orchestration.mission`](../orchestration/mission.md).id |
| 19 | `designed_in_thread_id` | `uuid` | yes | — | FK → [`conversation.thread`](../conversation/thread.md).id |
| 20 | `state` | `text` | no | `'active'::text` | — |
| 21 | `rationale` | `text` | no | — | — |
| 22 | `decided_by` | `text` | no | — | — |
| 23 | `supersedes_id` | `uuid` | yes | — | FK → [`acquisition.attention_policy`](attention_policy.md).id |
| 24 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, slug)
- check `attention_policy_budget_credits_per_run_check`: `(budget_credits_per_run >= 0)`
- check `attention_policy_budget_usd_per_run_check`: `(budget_usd_per_run >= (0)::numeric)`
- check `attention_policy_cadence_check`: `(cadence ~ '^P(T?[0-9]+[YMWDHS])+$'::text)`
- check `attention_policy_check`: `((watch_level = 'W0'::text) OR (cadence IS NOT NULL) OR (jsonb_array_length(triggers) > 0))`
- check `attention_policy_scope_kind_check`: `(scope_kind = ANY (ARRAY['channel'::text, 'entity'::text, 'query'::text, 'probe_set'::text]))`
- check `attention_policy_state_check`: `(state = ANY (ARRAY['active'::text, 'paused'::text, 'retired'::text]))`
- check `attention_policy_triggers_check`: `(jsonb_typeof(triggers) = 'array'::text)`
- check `attention_policy_watch_level_check`: `(watch_level = ANY (ARRAY['W0'::text, 'W1'::text, 'W2'::text, 'W3'::text]))`

## Relationships

Outbound: `designed_in_thread_id` → [`conversation.thread`](../conversation/thread.md)`.id`; `inquiry_watch_id` → [`inquiry.watch`](../inquiry/watch.md)`.id`; `mission_id` → [`orchestration.mission`](../orchestration/mission.md)`.id`; `supersedes_id` → [`acquisition.attention_policy`](attention_policy.md)`.id`.
Inbound: [`acquisition.attention_policy`](attention_policy.md).supersedes_id, [`acquisition.attention_sweep`](attention_sweep.md).policy_id.

## Indexes

`attention_policy_tenant_id_slug_key` unique

## Triggers

_None._

## Row-level security

Enabled.
- `attention_policy_tenant` (ALL) for `public`: `(tenant_id = util.current_tenant_id())`

## Grants

`app_reader`: SELECT; `control_plane`: INSERT, SELECT, UPDATE; `pipeline_agent`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `authenticated`, `executor_service`.

## Read paths

- Named queries: `q:acquisition.attention_due`, `q:acquisition.attention_policies`, `q:acquisition.open_sweeps`, `q:evidence.source_registry`.
- Exposed through: [`api.attention_policies`](../api/attention_policies.md), [`api.source_registry`](../api/source_registry.md).
- Direct SELECT: `app_reader`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `control_plane`, `pipeline_agent`.

## TypeScript

insert: `Database["acquisition"]["Tables"]["attention_policy"]["Insert"]`; row: `Database["acquisition"]["Tables"]["attention_policy"]["Row"]`; update: `Database["acquisition"]["Tables"]["attention_policy"]["Update"]`

Defined in: `20261113120000_build08_loop4_source_intelligence_experiments.sql`.
