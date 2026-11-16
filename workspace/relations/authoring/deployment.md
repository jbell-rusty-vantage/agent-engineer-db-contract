---
id: "rel:authoring.deployment"
kind: table
schema: authoring
name: deployment
domain: authoring
lens: ours
aliases: []
tokens: [authoring, deployment, authoring.deployment, id, tenant_id, workspace_id, revision_id, file_set_id, target, environment, url, external_ref, snapshot_file_set_id, status, origin, created_by, created_at, retired_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"authoring\"][\"Tables\"][\"deployment\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:216c4ae7230478c8e60934da25c852e10680d6caed71a662962ea3c0ac1676d3"
---
# authoring.deployment

table in domain `authoring`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id); unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, id); unique (tenant_id, workspace_id, id) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id) |
| 4 | `revision_id` | `uuid` | yes | — | — |
| 5 | `file_set_id` | `uuid` | yes | — | — |
| 6 | `target` | `text` | no | — | — |
| 7 | `environment` | `text` | no | — | — |
| 8 | `url` | `text` | no | — | — |
| 9 | `external_ref` | `jsonb` | yes | — | — |
| 10 | `snapshot_file_set_id` | `uuid` | yes | — | — |
| 11 | `status` | `text` | no | — | — |
| 12 | `origin` | `text` | no | — | — |
| 13 | `created_by` | `uuid` | no | — | FK → `auth.users`.id |
| 14 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 15 | `retired_at` | `timestamp with time zone` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, workspace_id, id)
- check `deployment_check`: `((target <> 'platform_static'::text) OR (file_set_id IS NOT NULL))`
- check `deployment_check1`: `((target <> 'external'::text) OR (external_ref IS NOT NULL))`
- check `deployment_check2`: `((status = 'retired'::text) = (retired_at IS NOT NULL))`
- check `deployment_environment_check`: `(environment = ANY (ARRAY['preview'::text, 'published'::text]))`
- check `deployment_origin_check`: `(origin = ANY (ARRAY['web'::text, 'harness'::text, 'mcp'::text, 'cli'::text, 'worker'::text]))`
- check `deployment_status_check`: `(status = ANY (ARRAY['pending'::text, 'live'::text, 'failed'::text, 'retired'::text]))`
- check `deployment_target_check`: `(target = ANY (ARRAY['platform_static'::text, 'external'::text]))`
- check `deployment_url_check`: `(url ~ '^https://'::text)`

## Relationships

Outbound: `created_by` → `auth.users``.id` on delete restrict; `tenant_id,workspace_id,file_set_id` → [`authoring.file_set`](file_set.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,revision_id` → [`authoring.work_revision`](work_revision.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,snapshot_file_set_id` → [`authoring.file_set`](file_set.md)`.tenant_id,workspace_id,id` on delete restrict.
Inbound: [`learning.evidence_item`](../learning/evidence_item.md).workspace_id,deployment_id.

## Indexes

`deployment_created_by_fkey_ix`; `deployment_tenant_id_id_key` unique; `deployment_tenant_id_workspace_id_file_set_id_fkey_ix`; `deployment_tenant_id_workspace_id_id_key` unique; `deployment_tenant_id_workspace_id_revision_id_fkey_ix`; `deployment_tenant_id_workspace_id_snapshot_file_set_id__ix`

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
- Product operations (best effort): [`record_deployment`](../../ops/record_deployment.md), [`set_deployment_status`](../../ops/set_deployment_status.md).

## TypeScript

insert: `Database["authoring"]["Tables"]["deployment"]["Insert"]`; row: `Database["authoring"]["Tables"]["deployment"]["Row"]`; update: `Database["authoring"]["Tables"]["deployment"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
