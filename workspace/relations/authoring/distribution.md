---
id: "rel:authoring.distribution"
kind: table
schema: authoring
name: distribution
domain: authoring
lens: ours
aliases: []
tokens: [authoring, distribution, authoring.distribution, id, tenant_id, workspace_id, root_work_id, channel, title, created_by, created_at, closed_at, closed_event_id]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"authoring\"][\"Tables\"][\"distribution\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
---
# authoring.distribution

table in domain `authoring`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id); unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, id); unique (tenant_id, workspace_id, id) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id) |
| 4 | `root_work_id` | `uuid` | no | — | — |
| 5 | `channel` | `text` | no | — | — |
| 6 | `title` | `text` | no | — | — |
| 7 | `created_by` | `uuid` | no | — | FK → `auth.users`.id |
| 8 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 9 | `closed_at` | `timestamp with time zone` | yes | — | — |
| 10 | `closed_event_id` | `uuid` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, workspace_id, id)
- check `distribution_channel_check`: `(channel = ANY (ARRAY['workspace'::text, 'invited'::text, 'public_library'::text, 'official_catalog'::text]))`
- check `distribution_title_check`: `product.nonblank(title)`

## Relationships

Outbound: `created_by` → `auth.users``.id` on delete restrict; `tenant_id,workspace_id,closed_event_id` → [`authoring.event`](event.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,root_work_id` → [`authoring.work`](work.md)`.tenant_id,workspace_id,id` on delete restrict.
Inbound: [`authoring.distribution_member`](distribution_member.md).workspace_id,distribution_id, [`authoring.distribution_offer`](distribution_offer.md).workspace_id,distribution_id, [`learning.enrollment`](../learning/enrollment.md).source_workspace_id,distribution_id.

## Indexes

`distribution_created_by_fkey_ix`; `distribution_official_open_uq` unique where `((channel = 'official_catalog'::text) AND (closed_at IS NUL…`; `distribution_tenant_id_id_key` unique; `distribution_tenant_id_workspace_id_closed_event_id_fke_ix`; `distribution_tenant_id_workspace_id_id_key` unique; `distribution_tenant_id_workspace_id_root_work_id_fkey_ix`

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
- Product operations (best effort): [`open_distribution`](../../ops/open_distribution.md).

## TypeScript

insert: `Database["authoring"]["Tables"]["distribution"]["Insert"]`; row: `Database["authoring"]["Tables"]["distribution"]["Row"]`; update: `Database["authoring"]["Tables"]["distribution"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
