---
id: "rel:authoring.command"
kind: table
schema: authoring
name: command
domain: authoring
lens: ours
aliases: []
tokens: [authoring, command, authoring.command, id, tenant_id, workspace_id, actor_id, operation, idempotency_key, input_sha256, result, origin, origin_ref, client_grant_id, created_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"authoring\"][\"Tables\"][\"command\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# authoring.command

table in domain `authoring`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, workspace_id, actor_id, idempotency_key); unique (tenant_id, workspace_id, id) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, actor_id, idempotency_key); unique (tenant_id, workspace_id, id) |
| 4 | `actor_id` | `uuid` | no | — | unique (tenant_id, workspace_id, actor_id, idempotency_key); FK → `auth.users`.id |
| 5 | `operation` | `text` | no | — | — |
| 6 | `idempotency_key` | `text` | no | — | unique (tenant_id, workspace_id, actor_id, idempotency_key) |
| 7 | `input_sha256` | `text` | no | — | — |
| 8 | `result` | `jsonb` | no | — | — |
| 9 | `origin` | `text` | no | — | — |
| 10 | `origin_ref` | `jsonb` | no | `'{}'::jsonb` | — |
| 11 | `client_grant_id` | `uuid` | yes | — | — |
| 12 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, workspace_id, actor_id, idempotency_key)
- unique (tenant_id, workspace_id, id)
- check `command_idempotency_key_check`: `((char_length(idempotency_key) >= 8) AND (char_length(idempotency_key) <= 200))`
- check `command_input_sha256_check`: `(input_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `command_origin_check`: `(origin = ANY (ARRAY['web'::text, 'harness'::text, 'mcp'::text, 'cli'::text, 'api'::text, 'worker'::text, 'system'::text]))`

## Relationships

Outbound: `actor_id` → `auth.users``.id` on delete restrict; `tenant_id,client_grant_id` → [`access.client_grant`](../access/client_grant.md)`.tenant_id,id` on delete restrict; `tenant_id,workspace_id` → [`authoring.workspace`](workspace.md)`.tenant_id,id` on delete restrict.
Inbound: none.

## Indexes

`command_actor_id_fkey_ix`; `command_tenant_id_client_grant_id_fkey_ix`; `command_tenant_id_workspace_id_actor_id_idempotency_key_key` unique; `command_tenant_id_workspace_id_id_key` unique

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
- Via functions (best effort): [`api.product_command`](../../functions/api/product_command.md).

## TypeScript

insert: `Database["authoring"]["Tables"]["command"]["Insert"]`; row: `Database["authoring"]["Tables"]["command"]["Row"]`; update: `Database["authoring"]["Tables"]["command"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
