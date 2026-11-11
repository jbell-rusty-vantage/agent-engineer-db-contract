---
id: "rel:authoring.release"
kind: table
schema: authoring
name: release
domain: authoring
lens: ours
aliases: []
tokens: [authoring, release, authoring.release, id, tenant_id, workspace_id, root_work_id, root_revision_id, release_no, audience_ceiling, manifest_artifact_id, closure_sha256, approved_event_id, created_by, created_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"authoring\"][\"Tables\"][\"release\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:fbf5703bf7a6f6131c452444ee949f1feec1bbe813c78d772fb3886b510815b9"
---
# authoring.release

table in domain `authoring`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id); unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, id); unique (tenant_id, workspace_id, id); unique (tenant_id, workspace_id, root_work_id, release_no) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id); unique (tenant_id, workspace_id, root_work_id, release_no) |
| 4 | `root_work_id` | `uuid` | no | — | unique (tenant_id, workspace_id, root_work_id, release_no) |
| 5 | `root_revision_id` | `uuid` | no | — | — |
| 6 | `release_no` | `integer` | no | — | unique (tenant_id, workspace_id, root_work_id, release_no) |
| 7 | `audience_ceiling` | `text` | no | — | — |
| 8 | `manifest_artifact_id` | `uuid` | no | — | — |
| 9 | `closure_sha256` | `text` | no | — | — |
| 10 | `approved_event_id` | `uuid` | no | — | — |
| 11 | `created_by` | `uuid` | no | — | FK → `auth.users`.id |
| 12 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, workspace_id, id)
- unique (tenant_id, workspace_id, root_work_id, release_no)
- check `release_audience_ceiling_check`: `(audience_ceiling = ANY (ARRAY['workspace'::text, 'named'::text, 'public'::text]))`
- check `release_closure_sha256_check`: `(closure_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `release_release_no_check`: `(release_no > 0)`

## Relationships

Outbound: `created_by` → `auth.users``.id` on delete restrict; `tenant_id,manifest_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict; `tenant_id,workspace_id,approved_event_id` → [`authoring.event`](event.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,root_work_id,root_revision_id` → [`authoring.work_revision`](work_revision.md)`.tenant_id,workspace_id,work_id,id` on delete restrict.
Inbound: [`authoring.distribution_offer`](distribution_offer.md).workspace_id,release_id, [`authoring.release_item`](release_item.md).workspace_id,release_id, [`curriculum.release_transition`](../curriculum/release_transition.md).workspace_id,from_release_id|workspace_id,to_release_id.

## Indexes

`release_created_by_fkey_ix`; `release_tenant_id_id_key` unique; `release_tenant_id_manifest_artifact_id_fkey_ix`; `release_tenant_id_workspace_id_approved_event_id_fkey_ix`; `release_tenant_id_workspace_id_id_key` unique; `release_tenant_id_workspace_id_root_work_id_release_no_key` unique; `release_tenant_id_workspace_id_root_work_id_root_revisi_ix`

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
- Product operations (best effort): [`freeze_release`](../../ops/freeze_release.md).

## TypeScript

insert: `Database["authoring"]["Tables"]["release"]["Insert"]`; row: `Database["authoring"]["Tables"]["release"]["Row"]`; update: `Database["authoring"]["Tables"]["release"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
