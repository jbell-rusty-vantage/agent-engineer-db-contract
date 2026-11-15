---
id: "rel:conversation.context_snapshot"
kind: table
schema: conversation
name: context_snapshot
domain: library
lens: private
aliases: []
tokens: [conversation, context_snapshot, conversation.context_snapshot, id, tenant_id, workspace_id, digest, body, created_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"conversation\"][\"Tables\"][\"context_snapshot\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
---
# conversation.context_snapshot

table in domain `library`, lens `private`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, workspace_id, digest); unique (tenant_id, workspace_id, id) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, digest); unique (tenant_id, workspace_id, id) |
| 4 | `digest` | `text` | no | — | unique (tenant_id, workspace_id, digest) |
| 5 | `body` | `jsonb` | no | — | — |
| 6 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, workspace_id, digest)
- unique (tenant_id, workspace_id, id)
- check `context_snapshot_body_check`: `((body ->> 'schema'::text) = 'aieng.context.v1'::text)`
- check `context_snapshot_digest_check`: `(digest ~ '^[0-9a-f]{64}$'::text)`

## Relationships

Outbound: `tenant_id,workspace_id` → [`authoring.workspace`](../authoring/workspace.md)`.tenant_id,id` on delete restrict.
Inbound: [`conversation.context_item`](context_item.md).workspace_id,snapshot_id, [`conversation.message`](message.md).workspace_id,context_snapshot_id.

## Indexes

`context_snapshot_tenant_id_workspace_id_digest_key` unique; `context_snapshot_tenant_id_workspace_id_id_key` unique

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
- Product operations (best effort): [`append_message`](../../ops/append_message.md).

## TypeScript

insert: `Database["conversation"]["Tables"]["context_snapshot"]["Insert"]`; row: `Database["conversation"]["Tables"]["context_snapshot"]["Row"]`; update: `Database["conversation"]["Tables"]["context_snapshot"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
