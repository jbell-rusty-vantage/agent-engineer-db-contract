---
id: "rel:learning.submission"
kind: table
schema: learning
name: submission
domain: learning
lens: ours
aliases: []
tokens: [learning, submission, learning.submission, id, tenant_id, workspace_id, attempt_id, learner_id, manifest_artifact_id, closure_sha256, observed_conditions, submitted_via, created_at, withdrawn_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"learning\"][\"Tables\"][\"submission\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# learning.submission

table in domain `learning`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, workspace_id, attempt_id); unique (tenant_id, workspace_id, id) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, attempt_id); unique (tenant_id, workspace_id, id) |
| 4 | `attempt_id` | `uuid` | no | — | unique (tenant_id, workspace_id, attempt_id) |
| 5 | `learner_id` | `uuid` | no | — | FK → `auth.users`.id |
| 6 | `manifest_artifact_id` | `uuid` | no | — | — |
| 7 | `closure_sha256` | `text` | no | — | — |
| 8 | `observed_conditions` | `jsonb` | no | `'{}'::jsonb` | — |
| 9 | `submitted_via` | `text` | no | — | — |
| 10 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 11 | `withdrawn_at` | `timestamp with time zone` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, workspace_id, attempt_id)
- unique (tenant_id, workspace_id, id)
- check `submission_closure_sha256_check`: `(closure_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `submission_submitted_via_check`: `(submitted_via = ANY (ARRAY['web'::text, 'harness'::text, 'import'::text]))`

## Relationships

Outbound: `learner_id` → `auth.users``.id` on delete restrict; `tenant_id,manifest_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict; `tenant_id,workspace_id,attempt_id` → [`learning.attempt`](attempt.md)`.tenant_id,workspace_id,id` on delete restrict.
Inbound: [`learning.appeal`](appeal.md).workspace_id,new_evidence_submission_id, [`learning.assessment_result`](assessment_result.md).workspace_id,submission_id, [`learning.evidence_item`](evidence_item.md).workspace_id,submission_id, [`learning.grading_run`](grading_run.md).workspace_id,submission_id.

## Indexes

`submission_learner_id_fkey_ix`; `submission_tenant_id_manifest_artifact_id_fkey_ix`; `submission_tenant_id_workspace_id_attempt_id_key` unique; `submission_tenant_id_workspace_id_id_key` unique

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
- Via functions (best effort): [`product.dispatch_command`](../../functions/product/dispatch_command.md).
- Product operations (best effort): [`submit_attempt`](../../ops/submit_attempt.md).

## TypeScript

insert: `Database["learning"]["Tables"]["submission"]["Insert"]`; row: `Database["learning"]["Tables"]["submission"]["Row"]`; update: `Database["learning"]["Tables"]["submission"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
