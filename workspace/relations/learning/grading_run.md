---
id: "rel:learning.grading_run"
kind: table
schema: learning
name: grading_run
domain: learning
lens: ours
aliases: []
tokens: [learning, grading_run, learning.grading_run, id, tenant_id, workspace_id, submission_id, pipeline_revision_id, kind, runner, check_bundle_sha256, status, failure_class, reason, runtime_ref, replay_artifact_id, requested_by, created_at, started_at, finished_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"learning\"][\"Tables\"][\"grading_run\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# learning.grading_run

table in domain `learning`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id) |
| 4 | `submission_id` | `uuid` | no | — | — |
| 5 | `pipeline_revision_id` | `uuid` | no | — | — |
| 6 | `kind` | `text` | no | — | — |
| 7 | `runner` | `jsonb` | no | `'{}'::jsonb` | — |
| 8 | `check_bundle_sha256` | `text` | yes | — | — |
| 9 | `status` | `text` | no | — | — |
| 10 | `failure_class` | `text` | yes | — | — |
| 11 | `reason` | `text` | yes | — | — |
| 12 | `runtime_ref` | `jsonb` | no | `'{}'::jsonb` | — |
| 13 | `replay_artifact_id` | `uuid` | yes | — | — |
| 14 | `requested_by` | `text` | no | — | — |
| 15 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 16 | `started_at` | `timestamp with time zone` | yes | — | — |
| 17 | `finished_at` | `timestamp with time zone` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, workspace_id, id)
- check `grading_run_check`: `((status = ANY (ARRAY['unavailable'::text, 'error'::text])) = (failure_class IS NOT NULL))`
- check `grading_run_check_bundle_sha256_check`: `(check_bundle_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `grading_run_kind_check`: `(kind = ANY (ARRAY['deterministic'::text, 'model_judgment'::text, 'defense'::text, 'human_review'::text, 'mixed'::text]))`
- check `grading_run_requested_by_check`: `(requested_by = ANY (ARRAY['initial'::text, 'rerun'::text, 'appeal'::text, 'correction'::text]))`
- check `grading_run_status_check`: `(status = ANY (ARRAY['queued'::text, 'running'::text, 'completed'::text, 'unavailable'::text, 'abstained'::text, 'error'::text]))`

## Relationships

Outbound: `tenant_id,pipeline_revision_id` → [`authoring.work_revision`](../authoring/work_revision.md)`.tenant_id,id` on delete restrict; `tenant_id,replay_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict; `tenant_id,workspace_id,submission_id` → [`learning.submission`](submission.md)`.tenant_id,workspace_id,id` on delete restrict.
Inbound: [`learning.criterion_result`](criterion_result.md).workspace_id,grading_run_id.

## Indexes

`grading_run_tenant_id_pipeline_revision_id_fkey_ix`; `grading_run_tenant_id_replay_artifact_id_fkey_ix`; `grading_run_tenant_id_workspace_id_id_key` unique; `grading_run_tenant_id_workspace_id_submission_id_fkey_ix`

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
- Via functions (best effort): [`product.dispatch_worker`](../../functions/product/dispatch_worker.md).
- Product operations (best effort): [`record_grading`](../../ops/record_grading.md).

## TypeScript

insert: `Database["learning"]["Tables"]["grading_run"]["Insert"]`; row: `Database["learning"]["Tables"]["grading_run"]["Row"]`; update: `Database["learning"]["Tables"]["grading_run"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
