---
id: "rel:orchestration.provider_route"
kind: table
schema: orchestration
name: provider_route
domain: orchestration-ledger
aliases: []
tokens: [orchestration, provider_route, orchestration.provider_route, id, abstract_operation, provider, policy_version, selection_rules, priority, enabled, failure_rollup, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, service_role]
writers: [control_plane, executor_service, service_role]
typescript: "Database[\"orchestration\"][\"Tables\"][\"provider_route\"][\"Row\"]"
defined_in: ["20260826000200_orchestration.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# orchestration.provider_route

table in domain `orchestration-ledger`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `abstract_operation` | `text` | no | — | unique (abstract_operation, provider, policy_version) |
| 3 | `provider` | `text` | no | — | unique (abstract_operation, provider, policy_version) |
| 4 | `policy_version` | `integer` | no | `1` | unique (abstract_operation, provider, policy_version) |
| 5 | `selection_rules` | `jsonb` | no | `'{}'::jsonb` | — |
| 6 | `priority` | `integer` | no | `100` | — |
| 7 | `enabled` | `boolean` | no | `true` | — |
| 8 | `failure_rollup` | `jsonb` | no | `'{}'::jsonb` | — |
| 9 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (abstract_operation, provider, policy_version)

## Relationships

Outbound: none.
Inbound: none.

## Indexes

`provider_route_abstract_operation_provider_policy_version_key` unique

## Triggers

_None._

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `false`

## Grants

`control_plane`: INSERT, SELECT, UPDATE; `executor_service`: INSERT, SELECT; `service_role`: INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`.

## Write path

- Direct DML: `control_plane`, `executor_service`.

## TypeScript

insert: `Database["orchestration"]["Tables"]["provider_route"]["Insert"]`; row: `Database["orchestration"]["Tables"]["provider_route"]["Row"]`; update: `Database["orchestration"]["Tables"]["provider_route"]["Update"]`

Defined in: `20260826000200_orchestration.sql`.
