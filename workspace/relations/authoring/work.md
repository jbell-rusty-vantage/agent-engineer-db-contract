---
id: "rel:authoring.work"
kind: table
schema: authoring
name: work
domain: authoring
lens: ours
aliases: [work, course, module, report work]
tokens: [authoring, work, authoring.work, id, tenant_id, workspace_id, kind, slug, head_revision_id, created_by, created_at]
summary: "Identity of an authored thing (course, module, lesson, activity, brief, report, template, dataset); head_revision_id is the mutable pointer."
summary_basis: curated
rls: enabled
readers: []
writers: []
typescript: "Database[\"authoring\"][\"Tables\"][\"work\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:216c4ae7230478c8e60934da25c852e10680d6caed71a662962ea3c0ac1676d3"
---
# authoring.work

table in domain `authoring`, lens `ours`.

> curated (model_assisted, unreviewed) — Identity of an authored thing (course, module, lesson, activity, brief, report, template, dataset); head_revision_id is the mutable pointer.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id); unique (tenant_id, workspace_id, id); unique (tenant_id, workspace_id, id, kind) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, id); unique (tenant_id, workspace_id, id); unique (tenant_id, workspace_id, id, kind); unique (tenant_id, workspace_id, slug) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id); unique (tenant_id, workspace_id, id, kind); unique (tenant_id, workspace_id, slug) |
| 4 | `kind` | `text` | no | — | unique (tenant_id, workspace_id, id, kind); _curated:_ course, module, lesson, activity, brief, report, template, dataset, document. |
| 5 | `slug` | `text` | no | — | unique (tenant_id, workspace_id, slug) |
| 6 | `head_revision_id` | `uuid` | yes | — | _curated:_ Current revision; pass it as p_expected_head to revise_work. |
| 7 | `created_by` | `uuid` | no | — | FK → `auth.users`.id |
| 8 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, workspace_id, id)
- unique (tenant_id, workspace_id, id, kind)
- unique (tenant_id, workspace_id, slug)
- check `work_kind_check`: `(kind = ANY (ARRAY['course'::text, 'track'::text, 'module'::text, 'lesson'::text, 'activity'::text, 'report'::text, 'dataset'::text, 'decis…`
- check `work_slug_check`: `(slug ~ '^[a-z0-9][a-z0-9-]{0,99}$'::text)`

## Relationships

Outbound: `created_by` → `auth.users``.id` on delete restrict; `tenant_id,workspace_id,id,head_revision_id` → [`authoring.work_revision`](work_revision.md)`.tenant_id,workspace_id,work_id,id` on delete restrict; `tenant_id,workspace_id` → [`authoring.workspace`](workspace.md)`.tenant_id,id` on delete restrict.
Inbound: [`authoring.distribution`](distribution.md).workspace_id,root_work_id, [`authoring.event`](event.md).workspace_id,work_id, [`authoring.revision_binding`](revision_binding.md).workspace_id,target_work_id, [`authoring.work_revision`](work_revision.md).workspace_id,work_id, [`dataset.cell`](../dataset/cell.md).workspace_id,dataset_work_id,dataset_kind, [`dataset.field`](../dataset/field.md).workspace_id,dataset_work_id,dataset_kind, [`dataset.proposal`](../dataset/proposal.md).workspace_id,dataset_work_id,dataset_kind, [`dataset.row`](../dataset/row.md).workspace_id,dataset_work_id,dataset_kind, [`inquiry.watch`](../inquiry/watch.md).workspace_id,brief_work_id, [`learning.environment_session`](../learning/environment_session.md).workspace_id,project_work_id, [`library.connected_item`](../library/connected_item.md).workspace_id,work_id, [`library.resource_control`](../library/resource_control.md).workspace_id,work_id … 1 more in [details](work.details.md).

## Indexes

`work_created_by_fkey_ix`; `work_head_fk_ix`; `work_tenant_id_id_key` unique; `work_tenant_id_workspace_id_id_key` unique; `work_tenant_id_workspace_id_id_kind_key` unique; `work_tenant_id_workspace_id_slug_key` unique

## Triggers

- `mutable_guard` → [`product.guard_mutable`](../../functions/product/guard_mutable.md)

## Row-level security

Enabled and forced.
- `product_api_all` (ALL) for `product_api_owner`: `true`

## Grants

No role has privileges. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

## Read paths

- Named queries: `q:ours.modules_affected_by_release`, `q:ours.works_authored`.
- Exposed through: [`api.works_authored`](../api/works_authored.md).
- No agent role may SELECT directly.

## Write path

- No direct DML for any agent role.
- Via functions (best effort): [`product.dataset_commit`](../../functions/product/dataset_commit.md), [`product.dispatch_command`](../../functions/product/dispatch_command.md), [`product.dispatch_research_command`](../../functions/product/dispatch_research_command.md).
- Product operations (best effort): [`create_dataset`](../../ops/create_dataset.md), [`create_work`](../../ops/create_work.md), [`revise_work`](../../ops/revise_work.md).

## TypeScript

insert: `Database["authoring"]["Tables"]["work"]["Insert"]`; row: `Database["authoring"]["Tables"]["work"]["Row"]`; update: `Database["authoring"]["Tables"]["work"]["Update"]`

## Examples

Works at head

```bash
knowledge db query ours.works_authored --param kind=null --param limit=50 --param released=null --param text=null
```
api.works_authored joins head revision and bindings.

Defined in: `20261105010100_product_foundation.sql`.
