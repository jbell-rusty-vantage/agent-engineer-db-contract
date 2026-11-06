---
id: "rel:orchestration.verification_provider_budget"
kind: table
schema: orchestration
name: verification_provider_budget
domain: orchestration-ledger
aliases: []
tokens: [orchestration, verification_provider_budget, orchestration.verification_provider_budget, id, tenant_id, budget_key, ceiling_cost_micros, reserved_cost_micros, settled_cost_micros, created_at, updated_at]
summary: null
summary_basis: none
rls: enabled
readers: [app_reader, control_plane, executor_service, service_role, verifier_agent]
writers: [control_plane, executor_service, service_role, verifier_agent]
typescript: "Database[\"orchestration\"][\"Tables\"][\"verification_provider_budget\"][\"Row\"]"
defined_in: ["20260906010000_verification_provider_budget_accounting.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# orchestration.verification_provider_budget

table in domain `orchestration-ledger`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, budget_key); unique (tenant_id, id) |
| 3 | `budget_key` | `text` | no | — | unique (tenant_id, budget_key) |
| 4 | `ceiling_cost_micros` | `bigint` | no | — | — |
| 5 | `reserved_cost_micros` | `bigint` | no | `0` | — |
| 6 | `settled_cost_micros` | `bigint` | no | `0` | — |
| 7 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 8 | `updated_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, budget_key)
- unique (tenant_id, id)
- check `verification_provider_budget_budget_key_check`: `(budget_key ~ '^[a-z0-9][a-z0-9._-]{0,119}$'::text)`
- check `verification_provider_budget_ceiling_cost_micros_check`: `((ceiling_cost_micros > 0) AND (ceiling_cost_micros <= 20000000))`
- check `verification_provider_budget_reservation_ceiling_ck`: `(reserved_cost_micros <= ceiling_cost_micros)`
- check `verification_provider_budget_reserved_cost_micros_check`: `(reserved_cost_micros >= 0)`
- check `verification_provider_budget_settled_cost_micros_check`: `(settled_cost_micros >= 0)`

## Relationships

Outbound: none.
Inbound: [`orchestration.verification_provider_attempt`](verification_provider_attempt.md).budget_id.

## Indexes

`verification_provider_budget_tenant_id_budget_key_key` unique; `verification_provider_budget_tenant_id_id_key` unique

## Triggers

- `verification_provider_budget_immutable` → [`orchestration.verification_provider_budget_guard`](../../functions/orchestration/verification_provider_budget_guard.md)
- `verification_provider_budget_set_updated_at` → [`util.set_updated_at`](../../functions/util/set_updated_at.md)

## Row-level security

Enabled.
- `verification_provider_budget_bounded_role_access` (ALL) for `control_plane`, `executor_service`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`
- `verification_provider_budget_reader_access` (SELECT) for `app_reader`: `(tenant_id = util.current_tenant_id())`

## Grants

`app_reader`: SELECT; `control_plane`: INSERT, SELECT, UPDATE; `executor_service`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: INSERT, SELECT, UPDATE. None: `anon`, `authenticated`, `pipeline_agent`.

## Read paths

- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `verifier_agent`.

## Write path

- Direct DML: `control_plane`, `executor_service`, `verifier_agent`.
- Via functions (best effort): [`orchestration.apply_provider_reconciliation`](../../functions/orchestration/apply_provider_reconciliation.md).

## TypeScript

insert: `Database["orchestration"]["Tables"]["verification_provider_budget"]["Insert"]`; row: `Database["orchestration"]["Tables"]["verification_provider_budget"]["Row"]`; update: `Database["orchestration"]["Tables"]["verification_provider_budget"]["Update"]`

Defined in: `20260906010000_verification_provider_budget_accounting.sql`.
