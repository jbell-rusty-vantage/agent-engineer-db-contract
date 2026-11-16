---
id: "rel:acquisition.attention_sweep"
kind: table
schema: acquisition
name: attention_sweep
domain: acquisition
lens: corpus
aliases: []
tokens: [acquisition, attention_sweep, acquisition.attention_sweep, id, tenant_id, policy_id, trigger_kind, trigger_ref, mission_id, origin_kind, window_from, window_to, started_at, ended_at, items_seen, items_selected, items_captured, rejected, spend_usd, credits, outcome, receipt_id, note]
summary: "Loop 4: one execution of an attention policy: trigger, window, items seen / selected / captured, rejections by reason, spend. Every fetch it makes carries sweep_id. origin_kind=mission only when a Mission Control mission ran it."
summary_basis: comment
rls: enabled
readers: [app_reader, control_plane, pipeline_agent, service_role, verifier_agent]
writers: [control_plane, pipeline_agent, service_role]
typescript: "Database[\"acquisition\"][\"Tables\"][\"attention_sweep\"][\"Row\"]"
defined_in: ["20261113120000_build08_loop4_source_intelligence_experiments.sql"]
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# acquisition.attention_sweep

table in domain `acquisition`, lens `corpus` — Loop 4: one execution of an attention policy: trigger, window, items seen / selected / captured, rejections by reason, spend. Every fetch it makes carries sweep_id. origin_kind=mission only when a Mission Control mission ran it..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | — |
| 3 | `policy_id` | `uuid` | no | — | FK → [`acquisition.attention_policy`](attention_policy.md).id |
| 4 | `trigger_kind` | `text` | no | — | — |
| 5 | `trigger_ref` | `jsonb` | no | `'{}'::jsonb` | — |
| 6 | `mission_id` | `uuid` | yes | — | FK → [`orchestration.mission`](../orchestration/mission.md).id |
| 7 | `origin_kind` | `text` | no | — | — |
| 8 | `window_from` | `timestamp with time zone` | yes | — | — |
| 9 | `window_to` | `timestamp with time zone` | yes | — | — |
| 10 | `started_at` | `timestamp with time zone` | no | `now()` | — |
| 11 | `ended_at` | `timestamp with time zone` | yes | — | — |
| 12 | `items_seen` | `integer` | no | `0` | — |
| 13 | `items_selected` | `integer` | no | `0` | — |
| 14 | `items_captured` | `integer` | no | `0` | — |
| 15 | `rejected` | `jsonb` | no | `'{}'::jsonb` | — |
| 16 | `spend_usd` | `numeric(10,4)` | no | `0` | — |
| 17 | `credits` | `integer` | no | `0` | — |
| 18 | `outcome` | `text` | yes | — | — |
| 19 | `receipt_id` | `uuid` | yes | — | — |
| 20 | `note` | `text` | yes | — | — |

## Constraints

- PK (id)
- check `attention_sweep_check`: `((origin_kind = 'mission'::text) = (mission_id IS NOT NULL))`
- check `attention_sweep_check1`: `(items_selected <= items_seen)`
- check `attention_sweep_origin_kind_check`: `(origin_kind = ANY (ARRAY['standalone'::text, 'mission'::text]))`
- check `attention_sweep_outcome_check`: `(outcome = ANY (ARRAY['completed'::text, 'partial'::text, 'failed'::text, 'budget_stopped'::text]))`
- check `attention_sweep_trigger_kind_check`: `(trigger_kind = ANY (ARRAY['schedule'::text, 'event'::text, 'manual'::text, 'backfill'::text]))`

## Relationships

Outbound: `mission_id` → [`orchestration.mission`](../orchestration/mission.md)`.id`; `policy_id` → [`acquisition.attention_policy`](attention_policy.md)`.id`.
Inbound: [`acquisition.fetch`](fetch.md).sweep_id, [`verification.probe_run`](../verification/probe_run.md).sweep_id.

## Indexes

`attention_sweep_policy_ix`

## Triggers

_None._

## Row-level security

Enabled.
- `attention_sweep_tenant` (ALL) for `public`: `(tenant_id = util.current_tenant_id())`

## Grants

`app_reader`: SELECT; `control_plane`: INSERT, SELECT, UPDATE; `pipeline_agent`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `authenticated`, `executor_service`.

## Read paths

- Exposed through: [`api.attention_policies`](../api/attention_policies.md).
- Direct SELECT: `app_reader`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `control_plane`, `pipeline_agent`.

## TypeScript

insert: `Database["acquisition"]["Tables"]["attention_sweep"]["Insert"]`; row: `Database["acquisition"]["Tables"]["attention_sweep"]["Row"]`; update: `Database["acquisition"]["Tables"]["attention_sweep"]["Update"]`

Defined in: `20261113120000_build08_loop4_source_intelligence_experiments.sql`.
