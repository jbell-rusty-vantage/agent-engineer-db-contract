---
id: "rel:public.factory_canary_result"
kind: table
schema: public
name: factory_canary_result
domain: research-starter-protected
aliases: []
tokens: [public, factory_canary_result, public.factory_canary_result, factory_canary_result_id, promotion_decision_id, traffic_fraction, started_at, finished_at, status, metrics, rollback_reason, created_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"public\"][\"Tables\"][\"factory_canary_result\"][\"Row\"]"
defined_in: ["20260822010000_app_factory_optimization_control_plane.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# public.factory_canary_result

table in domain `research-starter-protected`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `factory_canary_result_id` | `uuid` | no | `gen_random_uuid()` | PK |
| 2 | `promotion_decision_id` | `uuid` | no | — | FK → [`public.factory_promotion_decision`](factory_promotion_decision.md).factory_promotion_decision_id |
| 3 | `traffic_fraction` | `numeric` | no | — | — |
| 4 | `started_at` | `timestamp with time zone` | no | — | — |
| 5 | `finished_at` | `timestamp with time zone` | yes | — | — |
| 6 | `status` | `text` | no | `'running'::text` | — |
| 7 | `metrics` | `jsonb` | no | `'{}'::jsonb` | — |
| 8 | `rollback_reason` | `text` | yes | — | — |
| 9 | `created_at` | `timestamp with time zone` | no | `timezone('utc'::text, now())` | — |

## Constraints

- PK (factory_canary_result_id)
- check `factory_canary_fraction_check`: `((traffic_fraction > (0)::numeric) AND (traffic_fraction <= (1)::numeric))`
- check `factory_canary_status_check`: `(status = ANY (ARRAY['running'::text, 'passed'::text, 'failed'::text, 'rolled_back'::text, 'cancelled'::text]))`

## Relationships

Outbound: `promotion_decision_id` → [`public.factory_promotion_decision`](factory_promotion_decision.md)`.factory_promotion_decision_id` on delete cascade.
Inbound: none.

## Indexes

_None._

## Triggers

_None._

## Row-level security

Enabled.

## Grants

No role has privileges. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

## Read paths

- No agent role may SELECT directly.

## Write path

- No direct DML for any agent role.
- No write path for agents; rows are seeded by migrations or platform tooling.

## TypeScript

insert: `Database["public"]["Tables"]["factory_canary_result"]["Insert"]`; row: `Database["public"]["Tables"]["factory_canary_result"]["Row"]`; update: `Database["public"]["Tables"]["factory_canary_result"]["Update"]`

Defined in: `20260822010000_app_factory_optimization_control_plane.sql`.
