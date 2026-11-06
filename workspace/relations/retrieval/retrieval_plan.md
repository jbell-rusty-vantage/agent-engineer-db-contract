---
id: "rel:retrieval.retrieval_plan"
kind: table
schema: retrieval
name: retrieval_plan
domain: retrieval
aliases: []
tokens: [retrieval, retrieval_plan, retrieval.retrieval_plan, id, tenant_id, query_intent, decomposition, spaces, filters, policy_version, proposed_by_attempt_id, validated, validation_errors, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"retrieval\"][\"Tables\"][\"retrieval_plan\"][\"Row\"]"
defined_in: ["20260826001000_retrieval.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# retrieval.retrieval_plan

table in domain `retrieval`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id) |
| 3 | `query_intent` | `text` | no | — | — |
| 4 | `decomposition` | `jsonb` | no | `'[]'::jsonb` | — |
| 5 | `spaces` | `jsonb` | no | `'[]'::jsonb` | — |
| 6 | `filters` | `jsonb` | no | `'{}'::jsonb` | — |
| 7 | `policy_version` | `integer` | no | `1` | — |
| 8 | `proposed_by_attempt_id` | `uuid` | yes | — | FK → [`orchestration.attempt`](../orchestration/attempt.md).id |
| 9 | `validated` | `boolean` | no | `false` | — |
| 10 | `validation_errors` | `jsonb` | yes | — | — |
| 11 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)

## Relationships

Outbound: `proposed_by_attempt_id` → [`orchestration.attempt`](../orchestration/attempt.md)`.id`.
Inbound: [`retrieval.retrieval_run`](retrieval_run.md).plan_id.

## Indexes

`retrieval_plan_tenant_id_uq` unique

## Triggers

- `retrieval_plan_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`executor_service`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `executor_service`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["retrieval"]["Tables"]["retrieval_plan"]["Insert"]`; row: `Database["retrieval"]["Tables"]["retrieval_plan"]["Row"]`; update: `Database["retrieval"]["Tables"]["retrieval_plan"]["Update"]`

Defined in: `20260826001000_retrieval.sql`.
