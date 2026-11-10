---
id: "rel:learning.criterion_result"
kind: table
schema: learning
name: criterion_result
domain: learning
lens: ours
aliases: []
tokens: [learning, criterion_result, learning.criterion_result, id, tenant_id, workspace_id, grading_run_id, criterion_key, value, visibility, judged_by, judgment, reviewer_id, explanation, evidence_refs, created_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"learning\"][\"Tables\"][\"criterion_result\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:027ab2b6133d5d59318c478f06d832d89f937e563c387539f37fb3d7668818a8"
---
# learning.criterion_result

table in domain `learning`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, workspace_id, grading_run_id, criterion_key); unique (tenant_id, workspace_id, id) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, grading_run_id, criterion_key); unique (tenant_id, workspace_id, id) |
| 4 | `grading_run_id` | `uuid` | no | — | unique (tenant_id, workspace_id, grading_run_id, criterion_key) |
| 5 | `criterion_key` | `text` | no | — | unique (tenant_id, workspace_id, grading_run_id, criterion_key) |
| 6 | `value` | `jsonb` | no | — | — |
| 7 | `visibility` | `text` | no | — | — |
| 8 | `judged_by` | `text` | no | — | — |
| 9 | `judgment` | `jsonb` | yes | — | — |
| 10 | `reviewer_id` | `uuid` | yes | — | FK → `auth.users`.id |
| 11 | `explanation` | `text` | no | — | — |
| 12 | `evidence_refs` | `jsonb` | no | `'[]'::jsonb` | — |
| 13 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, workspace_id, grading_run_id, criterion_key)
- unique (tenant_id, workspace_id, id)
- check `criterion_result_check`: `((judged_by = 'model'::text) = ((judgment IS NOT NULL) AND ((judgment ->> 'schema'::text) = 'aieng.decision-answer.v1'::text)))`
- check `criterion_result_check1`: `((judged_by = 'human'::text) = (reviewer_id IS NOT NULL))`
- check `criterion_result_explanation_check`: `product.nonblank(explanation)`
- check `criterion_result_judged_by_check`: `(judged_by = ANY (ARRAY['deterministic'::text, 'model'::text, 'human'::text]))`
- check `criterion_result_visibility_check`: `(visibility = ANY (ARRAY['student_visible'::text, 'withheld'::text]))`

## Relationships

Outbound: `reviewer_id` → `auth.users``.id` on delete restrict; `tenant_id,workspace_id,grading_run_id` → [`learning.grading_run`](grading_run.md)`.tenant_id,workspace_id,id` on delete restrict.
Inbound: none.

## Indexes

`criterion_result_reviewer_id_fkey_ix`; `criterion_result_tenant_id_workspace_id_grading_run_id_crit_key` unique; `criterion_result_tenant_id_workspace_id_id_key` unique

## Triggers

- `immutable_guard` → [`product.guard_immutable`](../../functions/product/guard_immutable.md)

## Row-level security

Enabled and forced.
- `product_api_all` (ALL) for `product_api_owner`: `true`

## Grants

No role has privileges. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

## Read paths

- No agent role may SELECT directly.

## Write path

- No direct DML for any agent role.
- Via functions (best effort): [`product.dispatch_worker`](../../functions/product/dispatch_worker.md).
- Product operations (best effort): [`record_grading`](../../ops/record_grading.md).

## TypeScript

insert: `Database["learning"]["Tables"]["criterion_result"]["Insert"]`; row: `Database["learning"]["Tables"]["criterion_result"]["Row"]`; update: `Database["learning"]["Tables"]["criterion_result"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
