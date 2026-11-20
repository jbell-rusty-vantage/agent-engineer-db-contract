---
id: "rel:dataset.proposal"
kind: table
schema: dataset
name: proposal
domain: inquiry
lens: ours
aliases: []
tokens: [dataset, proposal, dataset.proposal, id, tenant_id, workspace_id, dataset_work_id, dataset_kind, base_revision_no, reason, acceptance_id, summary, dedupe_key, state, created_by, created_kind, created_at, decided_by, decided_at, applied_revision_id]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"dataset\"][\"Tables\"][\"proposal\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# dataset.proposal

table in domain `inquiry`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, workspace_id, dataset_work_id, dedupe_key); unique (tenant_id, workspace_id, id) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, dataset_work_id, dedupe_key); unique (tenant_id, workspace_id, id) |
| 4 | `dataset_work_id` | `uuid` | no | — | unique (tenant_id, workspace_id, dataset_work_id, dedupe_key) |
| 5 | `dataset_kind` | `text` | no | `'dataset'::text` | — |
| 6 | `base_revision_no` | `integer` | no | — | — |
| 7 | `reason` | `text` | no | — | — |
| 8 | `acceptance_id` | `uuid` | yes | — | — |
| 9 | `summary` | `jsonb` | no | — | — |
| 10 | `dedupe_key` | `text` | no | — | unique (tenant_id, workspace_id, dataset_work_id, dedupe_key) |
| 11 | `state` | `text` | no | `'open'::text` | — |
| 12 | `created_by` | `uuid` | no | — | FK → `auth.users`.id |
| 13 | `created_kind` | `text` | no | — | — |
| 14 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 15 | `decided_by` | `uuid` | yes | — | FK → `auth.users`.id |
| 16 | `decided_at` | `timestamp with time zone` | yes | — | — |
| 17 | `applied_revision_id` | `uuid` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, workspace_id, dataset_work_id, dedupe_key)
- unique (tenant_id, workspace_id, id)
- check `proposal_base_revision_no_check`: `(base_revision_no > 0)`
- check `proposal_check`: `((state = 'applied'::text) = (applied_revision_id IS NOT NULL))`
- check `proposal_check1`: `((state = ANY (ARRAY['applied'::text, 'rejected'::text])) = (decided_by IS NOT NULL))`
- check `proposal_created_kind_check`: `(created_kind = ANY (ARRAY['human'::text, 'agent'::text, 'system'::text]))`
- check `proposal_dataset_kind_check`: `(dataset_kind = 'dataset'::text)`
- check `proposal_dedupe_key_check`: `product.nonblank(dedupe_key)`
- check `proposal_reason_check`: `(reason = ANY (ARRAY['refresh'::text, 'correction'::text, 'watch'::text, 'agent_edit'::text, 'import'::text]))`
- check `proposal_state_check`: `(state = ANY (ARRAY['open'::text, 'applied'::text, 'rejected'::text, 'stale'::text]))`
- check `proposal_summary_check`: `(jsonb_typeof(summary) = 'object'::text)`

## Relationships

Outbound: `created_by` → `auth.users``.id` on delete restrict; `decided_by` → `auth.users``.id` on delete restrict; `tenant_id,workspace_id,acceptance_id` → [`inquiry.acceptance`](../inquiry/acceptance.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,applied_revision_id` → [`authoring.work_revision`](../authoring/work_revision.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,dataset_work_id,dataset_kind` → [`authoring.work`](../authoring/work.md)`.tenant_id,workspace_id,id,kind` on delete restrict.
Inbound: [`dataset.cell`](cell.md).workspace_id,proposal_id, [`dataset.row`](row.md).workspace_id,proposal_id.

## Indexes

`proposal_created_by_fkey_ix`; `proposal_decided_by_fkey_ix`; `proposal_tenant_id_workspace_id_acceptance_id_fkey_ix`; `proposal_tenant_id_workspace_id_applied_revision_id_fke_ix`; `proposal_tenant_id_workspace_id_dataset_work_id_dataset_ix`; `proposal_tenant_id_workspace_id_dataset_work_id_dedupe_key_key` unique; `proposal_tenant_id_workspace_id_id_key` unique

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
- Via functions (best effort): [`product.dispatch_research_command`](../../functions/product/dispatch_research_command.md).
- Product operations (best effort): [`commit_dataset_revision`](../../ops/commit_dataset_revision.md), [`decide_dataset_change`](../../ops/decide_dataset_change.md), [`propose_dataset_change`](../../ops/propose_dataset_change.md).

## TypeScript

insert: `Database["dataset"]["Tables"]["proposal"]["Insert"]`; row: `Database["dataset"]["Tables"]["proposal"]["Row"]`; update: `Database["dataset"]["Tables"]["proposal"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
