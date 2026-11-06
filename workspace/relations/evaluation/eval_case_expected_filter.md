---
id: "rel:evaluation.eval_case_expected_filter"
kind: table
schema: evaluation
name: eval_case_expected_filter
domain: evaluation
aliases: []
tokens: [evaluation, eval_case_expected_filter, evaluation.eval_case_expected_filter, id, tenant_id, eval_case_id, filter_kind, expected_filter, hard_constraint, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, service_role]
writers: [control_plane, service_role]
typescript: "Database[\"evaluation\"][\"Tables\"][\"eval_case_expected_filter\"][\"Row\"]"
defined_in: ["20260903010300_knowledge_retrieval_completeness.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# evaluation.eval_case_expected_filter

table in domain `evaluation`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | — |
| 3 | `eval_case_id` | `uuid` | no | — | — |
| 4 | `filter_kind` | `text` | no | — | — |
| 5 | `expected_filter` | `jsonb` | no | — | — |
| 6 | `hard_constraint` | `boolean` | no | `true` | — |
| 7 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)

## Relationships

Outbound: `tenant_id,eval_case_id` → [`evaluation.eval_case`](eval_case.md)`.tenant_id,id` on delete restrict.
Inbound: none.

## Indexes

_None._

## Triggers

- `eval_case_expected_filter_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: INSERT, SELECT; `executor_service`: SELECT; `service_role`: INSERT, SELECT. None: `anon`, `app_reader`, `authenticated`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`.

## Write path

- Direct DML: `control_plane`.

## TypeScript

insert: `Database["evaluation"]["Tables"]["eval_case_expected_filter"]["Insert"]`; row: `Database["evaluation"]["Tables"]["eval_case_expected_filter"]["Row"]`; update: `Database["evaluation"]["Tables"]["eval_case_expected_filter"]["Update"]`

Defined in: `20260903010300_knowledge_retrieval_completeness.sql`.
