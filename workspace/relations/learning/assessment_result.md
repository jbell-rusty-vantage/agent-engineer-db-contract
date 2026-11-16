---
id: "rel:learning.assessment_result"
kind: table
schema: learning
name: assessment_result
domain: learning
lens: ours
aliases: []
tokens: [learning, assessment_result, learning.assessment_result, id, tenant_id, workspace_id, submission_id, sequence_no, outcomes, status, finalized_by, finalization_policy_revision_id, finalized_at, supersedes_id, reason, explanation_artifact_id, created_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"learning\"][\"Tables\"][\"assessment_result\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# learning.assessment_result

table in domain `learning`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id); unique (tenant_id, workspace_id, submission_id, sequence_no) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id); unique (tenant_id, workspace_id, submission_id, sequence_no) |
| 4 | `submission_id` | `uuid` | no | — | unique (tenant_id, workspace_id, submission_id, sequence_no) |
| 5 | `sequence_no` | `integer` | no | — | unique (tenant_id, workspace_id, submission_id, sequence_no) |
| 6 | `outcomes` | `jsonb` | no | — | — |
| 7 | `status` | `text` | no | — | — |
| 8 | `finalized_by` | `text` | yes | — | — |
| 9 | `finalization_policy_revision_id` | `uuid` | yes | — | — |
| 10 | `finalized_at` | `timestamp with time zone` | yes | — | — |
| 11 | `supersedes_id` | `uuid` | yes | — | — |
| 12 | `reason` | `text` | no | — | — |
| 13 | `explanation_artifact_id` | `uuid` | yes | — | — |
| 14 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, workspace_id, id)
- unique (tenant_id, workspace_id, submission_id, sequence_no)
- check `assessment_result_check`: `((finalized_by IS NULL) = (finalized_at IS NULL))`
- check `assessment_result_check1`: `((finalized_by <> 'auto'::text) OR (finalization_policy_revision_id IS NOT NULL))`
- check `assessment_result_finalized_by_check`: `(finalized_by = ANY (ARRAY['auto'::text, 'human'::text]))`
- check `assessment_result_reason_check`: `product.nonblank(reason)`
- check `assessment_result_sequence_no_check`: `(sequence_no > 0)`
- check `assessment_result_status_check`: `(status = ANY (ARRAY['provisional'::text, 'final'::text, 'superseded'::text]))`

## Relationships

Outbound: `tenant_id,explanation_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict; `tenant_id,finalization_policy_revision_id` → [`authoring.work_revision`](../authoring/work_revision.md)`.tenant_id,id` on delete restrict; `tenant_id,workspace_id,submission_id` → [`learning.submission`](submission.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,supersedes_id` → [`learning.assessment_result`](assessment_result.md)`.tenant_id,workspace_id,id` on delete restrict.
Inbound: [`learning.appeal`](appeal.md).workspace_id,resolution_result_id|workspace_id,result_id, [`learning.assessment_result`](assessment_result.md).workspace_id,supersedes_id, [`learning.credit`](credit.md).workspace_id,result_id.

## Indexes

`assessment_result_tenant_id_explanation_artifact_id_fke_ix`; `assessment_result_tenant_id_finalization_policy_revisio_ix`; `assessment_result_tenant_id_workspace_id_id_key` unique; `assessment_result_tenant_id_workspace_id_submission_id_sequ_key` unique; `assessment_result_tenant_id_workspace_id_supersedes_id__ix`

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
- Via functions (best effort): [`product.dispatch_command`](../../functions/product/dispatch_command.md), [`product.dispatch_worker`](../../functions/product/dispatch_worker.md), [`product.finalize`](../../functions/product/finalize.md).
- Product operations (best effort): [`record_grading`](../../ops/record_grading.md), [`resolve_appeal`](../../ops/resolve_appeal.md).

## TypeScript

insert: `Database["learning"]["Tables"]["assessment_result"]["Insert"]`; row: `Database["learning"]["Tables"]["assessment_result"]["Row"]`; update: `Database["learning"]["Tables"]["assessment_result"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
