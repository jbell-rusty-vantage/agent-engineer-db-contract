---
id: "rel:learning.attempt"
kind: table
schema: learning
name: attempt
domain: learning
lens: ours
aliases: []
tokens: [learning, attempt, learning.attempt, id, tenant_id, workspace_id, learner_id, task_revision_id, task_release_item_id, enrollment_id, adoption_id, requirement_key, option_id, purpose, conditions, previous_attempt_id, mastery_decision_id, equivalence_request_id, environment_session_id, state, started_at, ended_at, active_seconds, active_seconds_source]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"learning\"][\"Tables\"][\"attempt\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# learning.attempt

table in domain `learning`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id) |
| 4 | `learner_id` | `uuid` | no | — | FK → `auth.users`.id |
| 5 | `task_revision_id` | `uuid` | yes | — | — |
| 6 | `task_release_item_id` | `uuid` | yes | — | — |
| 7 | `enrollment_id` | `uuid` | yes | — | — |
| 8 | `adoption_id` | `uuid` | yes | — | — |
| 9 | `requirement_key` | `uuid` | yes | — | — |
| 10 | `option_id` | `uuid` | yes | — | — |
| 11 | `purpose` | `text` | no | — | — |
| 12 | `conditions` | `jsonb` | no | — | — |
| 13 | `previous_attempt_id` | `uuid` | yes | — | — |
| 14 | `mastery_decision_id` | `uuid` | yes | — | — |
| 15 | `equivalence_request_id` | `uuid` | yes | — | — |
| 16 | `environment_session_id` | `uuid` | yes | — | — |
| 17 | `state` | `text` | no | `'started'::text` | — |
| 18 | `started_at` | `timestamp with time zone` | no | `now()` | — |
| 19 | `ended_at` | `timestamp with time zone` | yes | — | — |
| 20 | `active_seconds` | `integer` | yes | — | — |
| 21 | `active_seconds_source` | `text` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, workspace_id, id)
- check `attempt_active_seconds_check`: `(active_seconds >= 0)`
- check `attempt_check`: `(num_nonnulls(task_revision_id, task_release_item_id) = 1)`
- check `attempt_check1`: `((purpose <> 'official'::text) OR ((enrollment_id IS NOT NULL) AND (adoption_id IS NOT NULL) AND (requirement_key IS NOT NULL) AND (option_…`
- check `attempt_check2`: `((purpose = ANY (ARRAY['retention_check'::text, 'transfer_check'::text])) = (mastery_decision_id IS NOT NULL))`
- check `attempt_conditions_check`: `(((conditions ->> 'schema'::text) = 'aieng.attempt-conditions.v1'::text) AND ((conditions ->> 'facet'::text) = ANY (ARRAY['independent'::te…`
- check `attempt_purpose_check`: `(purpose = ANY (ARRAY['practice'::text, 'official'::text, 'diagnostic'::text, 'retention_check'::text, 'transfer_check'::text]))`
- check `attempt_state_check`: `(state = ANY (ARRAY['started'::text, 'submitted'::text, 'abandoned'::text, 'expired'::text]))`

## Relationships

Outbound: `learner_id` → `auth.users``.id` on delete restrict; `tenant_id,option_id` → [`curriculum.requirement_option`](../curriculum/requirement_option.md)`.tenant_id,id` on delete restrict; `tenant_id,task_release_item_id` → [`authoring.release_item`](../authoring/release_item.md)`.tenant_id,id` on delete restrict; `tenant_id,workspace_id,enrollment_id,adoption_id` → [`learning.release_adoption`](release_adoption.md)`.tenant_id,workspace_id,enrollment_id,id` on delete restrict; `tenant_id,workspace_id,enrollment_id` → [`learning.enrollment`](enrollment.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,environment_session_id` → [`learning.environment_session`](environment_session.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,equivalence_request_id` → [`learning.equivalence_request`](equivalence_request.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id` → [`authoring.workspace`](../authoring/workspace.md)`.tenant_id,id` on delete restrict; `tenant_id,workspace_id,mastery_decision_id` → [`learning.mastery_decision`](mastery_decision.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,previous_attempt_id` → [`learning.attempt`](attempt.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,task_revision_id` → [`authoring.work_revision`](../authoring/work_revision.md)`.tenant_id,workspace_id,id` on delete restrict.
Inbound: [`learning.attempt`](attempt.md).workspace_id,previous_attempt_id, [`learning.submission`](submission.md).workspace_id,attempt_id.

## Indexes

11 indexes; see [details](attempt.details.md).

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
- Via functions (best effort): [`product.dispatch_command`](../../functions/product/dispatch_command.md).
- Product operations (best effort): [`start_attempt`](../../ops/start_attempt.md), [`submit_attempt`](../../ops/submit_attempt.md).

## TypeScript

insert: `Database["learning"]["Tables"]["attempt"]["Insert"]`; row: `Database["learning"]["Tables"]["attempt"]["Row"]`; update: `Database["learning"]["Tables"]["attempt"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
