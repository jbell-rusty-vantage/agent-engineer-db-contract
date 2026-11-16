---
id: "rel:authoring.workspace"
kind: table
schema: authoring
name: workspace
domain: authoring
lens: ours
aliases: []
tokens: [authoring, workspace, authoring.workspace, id, tenant_id, owner_id, kind, name, created_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"authoring\"][\"Tables\"][\"workspace\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:94ffe6a458de74a3cfebdee4fb31f371d14c89d7eaa16cfe1ab1cae9dc94743b"
---
# authoring.workspace

table in domain `authoring`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, id) |
| 3 | `owner_id` | `uuid` | no | — | FK → `auth.users`.id |
| 4 | `kind` | `text` | no | `'shared'::text` | — |
| 5 | `name` | `text` | no | — | — |
| 6 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `workspace_kind_check`: `(kind = ANY (ARRAY['personal'::text, 'shared'::text]))`
- check `workspace_name_check`: `product.nonblank(name)`

## Relationships

Outbound: `owner_id` → `auth.users``.id` on delete restrict.
Inbound: [`authoring.asset_scope`](asset_scope.md).workspace_id, [`authoring.command`](command.md).workspace_id, [`authoring.event`](event.md).workspace_id, [`authoring.file_set`](file_set.md).workspace_id, [`authoring.work`](work.md).workspace_id, [`authoring.workspace_member`](workspace_member.md).workspace_id, [`conversation.context_snapshot`](../conversation/context_snapshot.md).workspace_id, [`conversation.thread`](../conversation/thread.md).workspace_id, [`learning.attempt`](../learning/attempt.md).workspace_id, [`learning.enrollment`](../learning/enrollment.md).workspace_id, [`learning.mastery_decision`](../learning/mastery_decision.md).workspace_id, [`library.connection`](../library/connection.md).workspace_id … 1 more in [details](workspace.details.md).

## Indexes

`workspace_owner_id_fkey_ix`; `workspace_personal_uq` unique where `(kind = 'personal'::text)`; `workspace_tenant_id_id_key` unique

## Triggers

- `immutable_guard` → [`product.guard_immutable`](../../functions/product/guard_immutable.md)

## Row-level security

Enabled and forced.
- `product_api_all` (ALL) for `product_api_owner`: `true`

## Grants

No role has privileges. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

## Read paths

- Named queries: `q:ours.works_authored`.
- Exposed through: [`api.works_authored`](../api/works_authored.md).
- No agent role may SELECT directly.

## Write path

- No direct DML for any agent role.
- Via functions (best effort): [`product.dispatch_command`](../../functions/product/dispatch_command.md), [`product.personal_workspace`](../../functions/product/personal_workspace.md).
- Product operations (best effort): [`create_workspace`](../../ops/create_workspace.md).

## TypeScript

insert: `Database["authoring"]["Tables"]["workspace"]["Insert"]`; row: `Database["authoring"]["Tables"]["workspace"]["Row"]`; update: `Database["authoring"]["Tables"]["workspace"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
