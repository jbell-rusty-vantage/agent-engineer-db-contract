---
id: "rel:learning.equivalence_request"
kind: table
schema: learning
name: equivalence_request
domain: learning
lens: ours
aliases: []
tokens: [learning, equivalence_request, learning.equivalence_request, id, tenant_id, workspace_id, learner_id, enrollment_id, work_revision_id, requirement_keys, evidence_plan, assistant_check, state, decided_by, decision, decision_reason, created_at, decided_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"learning\"][\"Tables\"][\"equivalence_request\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:94ffe6a458de74a3cfebdee4fb31f371d14c89d7eaa16cfe1ab1cae9dc94743b"
---
# learning.equivalence_request

table in domain `learning`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id) |
| 4 | `learner_id` | `uuid` | no | — | FK → `auth.users`.id |
| 5 | `enrollment_id` | `uuid` | no | — | — |
| 6 | `work_revision_id` | `uuid` | no | — | — |
| 7 | `requirement_keys` | `uuid[]` | no | — | — |
| 8 | `evidence_plan` | `text` | no | — | — |
| 9 | `assistant_check` | `jsonb` | yes | — | — |
| 10 | `state` | `text` | no | — | — |
| 11 | `decided_by` | `uuid` | yes | — | FK → `auth.users`.id |
| 12 | `decision` | `text` | yes | — | — |
| 13 | `decision_reason` | `text` | yes | — | — |
| 14 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 15 | `decided_at` | `timestamp with time zone` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, workspace_id, id)
- check `equivalence_request_assistant_check_check`: `((assistant_check IS NULL) OR ((assistant_check ->> 'schema'::text) = 'aieng.decision-answer.v1'::text))`
- check `equivalence_request_check`: `((state = ANY (ARRAY['approved'::text, 'rejected'::text])) = ((decided_at IS NOT NULL) AND (decision IS NOT NULL)))`
- check `equivalence_request_decision_check`: `(decision = ANY (ARRAY['maintainer'::text, 'owner_course_auto'::text]))`
- check `equivalence_request_evidence_plan_check`: `product.nonblank(evidence_plan)`
- check `equivalence_request_requirement_keys_check`: `(cardinality(requirement_keys) > 0)`
- check `equivalence_request_state_check`: `(state = ANY (ARRAY['proposed'::text, 'checked'::text, 'approved'::text, 'rejected'::text, 'withdrawn'::text]))`

## Relationships

Outbound: `decided_by` → `auth.users``.id` on delete restrict; `learner_id` → `auth.users``.id` on delete restrict; `tenant_id,workspace_id,enrollment_id` → [`learning.enrollment`](enrollment.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,work_revision_id` → [`authoring.work_revision`](../authoring/work_revision.md)`.tenant_id,workspace_id,id` on delete restrict.
Inbound: [`learning.attempt`](attempt.md).workspace_id,equivalence_request_id.

## Indexes

`equivalence_request_decided_by_fkey_ix`; `equivalence_request_learner_id_fkey_ix`; `equivalence_request_tenant_id_workspace_id_enrollment_i_ix`; `equivalence_request_tenant_id_workspace_id_id_key` unique; `equivalence_request_tenant_id_workspace_id_work_revisio_ix`

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
- Via functions (best effort): [`product.dispatch_command`](../../functions/product/dispatch_command.md), [`product.dispatch_worker`](../../functions/product/dispatch_worker.md).
- Product operations (best effort): [`decide_equivalence`](../../ops/decide_equivalence.md), [`propose_equivalence`](../../ops/propose_equivalence.md), [`record_equivalence_check`](../../ops/record_equivalence_check.md).

## TypeScript

insert: `Database["learning"]["Tables"]["equivalence_request"]["Insert"]`; row: `Database["learning"]["Tables"]["equivalence_request"]["Row"]`; update: `Database["learning"]["Tables"]["equivalence_request"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
