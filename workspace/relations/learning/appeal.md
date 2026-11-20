---
id: "rel:learning.appeal"
kind: table
schema: learning
name: appeal
domain: learning
lens: ours
aliases: []
tokens: [learning, appeal, learning.appeal, id, tenant_id, workspace_id, result_id, learner_id, grounds, new_evidence_submission_id, state, reviewer_id, resolution_result_id, resolution, created_at, resolved_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"learning\"][\"Tables\"][\"appeal\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# learning.appeal

table in domain `learning`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id) |
| 4 | `result_id` | `uuid` | no | — | — |
| 5 | `learner_id` | `uuid` | no | — | FK → `auth.users`.id |
| 6 | `grounds` | `text` | no | — | — |
| 7 | `new_evidence_submission_id` | `uuid` | yes | — | — |
| 8 | `state` | `text` | no | — | — |
| 9 | `reviewer_id` | `uuid` | yes | — | FK → `auth.users`.id |
| 10 | `resolution_result_id` | `uuid` | yes | — | — |
| 11 | `resolution` | `text` | yes | — | — |
| 12 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 13 | `resolved_at` | `timestamp with time zone` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, workspace_id, id)
- check `appeal_check`: `((state = ANY (ARRAY['upheld'::text, 'modified'::text, 'rejected'::text])) = ((resolved_at IS NOT NULL) AND (resolution IS NOT NULL)))`
- check `appeal_grounds_check`: `(product.nonblank(grounds) AND (char_length(grounds) <= 20000))`
- check `appeal_state_check`: `(state = ANY (ARRAY['open'::text, 'under_review'::text, 'upheld'::text, 'modified'::text, 'rejected'::text, 'withdrawn'::text]))`

## Relationships

Outbound: `learner_id` → `auth.users``.id` on delete restrict; `reviewer_id` → `auth.users``.id` on delete restrict; `tenant_id,workspace_id,new_evidence_submission_id` → [`learning.submission`](submission.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,resolution_result_id` → [`learning.assessment_result`](assessment_result.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,result_id` → [`learning.assessment_result`](assessment_result.md)`.tenant_id,workspace_id,id` on delete restrict.
Inbound: none.

## Indexes

`appeal_learner_id_fkey_ix`; `appeal_reviewer_id_fkey_ix`; `appeal_tenant_id_workspace_id_id_key` unique; `appeal_tenant_id_workspace_id_new_evidence_submission_i_ix`; `appeal_tenant_id_workspace_id_resolution_result_id_fkey_ix`; `appeal_tenant_id_workspace_id_result_id_fkey_ix`

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
- Product operations (best effort): [`open_appeal`](../../ops/open_appeal.md), [`resolve_appeal`](../../ops/resolve_appeal.md).

## TypeScript

insert: `Database["learning"]["Tables"]["appeal"]["Insert"]`; row: `Database["learning"]["Tables"]["appeal"]["Row"]`; update: `Database["learning"]["Tables"]["appeal"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
