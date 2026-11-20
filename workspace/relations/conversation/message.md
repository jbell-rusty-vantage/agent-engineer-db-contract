---
id: "rel:conversation.message"
kind: table
schema: conversation
name: message
domain: library
lens: private
aliases: []
tokens: [conversation, message, conversation.message, id, tenant_id, workspace_id, thread_id, seq, role, author_id, agent_identity, client_surface, content, content_sha256, context_snapshot_id, runtime_ref, usage, created_at, redacted_at, redacted_by_removal_id]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"conversation\"][\"Tables\"][\"message\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# conversation.message

table in domain `library`, lens `private`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id); unique (tenant_id, workspace_id, thread_id, seq) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id); unique (tenant_id, workspace_id, thread_id, seq) |
| 4 | `thread_id` | `uuid` | no | — | unique (tenant_id, workspace_id, thread_id, seq) |
| 5 | `seq` | `integer` | no | — | unique (tenant_id, workspace_id, thread_id, seq) |
| 6 | `role` | `text` | no | — | — |
| 7 | `author_id` | `uuid` | yes | — | FK → `auth.users`.id |
| 8 | `agent_identity` | `text` | yes | — | — |
| 9 | `client_surface` | `text` | no | — | — |
| 10 | `content` | `jsonb` | no | — | — |
| 11 | `content_sha256` | `text` | no | — | — |
| 12 | `context_snapshot_id` | `uuid` | yes | — | — |
| 13 | `runtime_ref` | `jsonb` | no | `'{}'::jsonb` | — |
| 14 | `usage` | `jsonb` | no | `'{}'::jsonb` | — |
| 15 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 16 | `redacted_at` | `timestamp with time zone` | yes | — | — |
| 17 | `redacted_by_removal_id` | `uuid` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, workspace_id, id)
- unique (tenant_id, workspace_id, thread_id, seq)
- check `message_check`: `((role = 'user'::text) <= (author_id IS NOT NULL))`
- check `message_client_surface_check`: `(client_surface = ANY (ARRAY['web'::text, 'harness'::text, 'import'::text]))`
- check `message_content_check`: `(((content ->> 'schema'::text) = 'aieng.message.v1'::text) AND (octet_length((content)::text) <= 262144))`
- check `message_content_sha256_check`: `(content_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `message_role_check`: `(role = ANY (ARRAY['user'::text, 'assistant'::text, 'tool'::text, 'system_note'::text]))`
- check `message_seq_check`: `(seq > 0)`

## Relationships

Outbound: `author_id` → `auth.users``.id` on delete restrict; `tenant_id,workspace_id,redacted_by_removal_id` → [`library.removal`](../library/removal.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,context_snapshot_id` → [`conversation.context_snapshot`](context_snapshot.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,thread_id` → [`conversation.thread`](thread.md)`.tenant_id,workspace_id,id` on delete restrict.
Inbound: [`learning.evidence_item`](../learning/evidence_item.md).workspace_id,message_id, [`library.passage`](../library/passage.md).workspace_id,message_id.

## Indexes

`message_author_id_fkey_ix`; `message_redaction_fk_ix`; `message_tenant_id_workspace_id_context_snapshot_id_fkey_ix`; `message_tenant_id_workspace_id_id_key` unique; `message_tenant_id_workspace_id_thread_id_seq_key` unique

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
- Via functions (best effort): [`product.dispatch_command`](../../functions/product/dispatch_command.md).
- Product operations (best effort): [`append_message`](../../ops/append_message.md).

## TypeScript

insert: `Database["conversation"]["Tables"]["message"]["Insert"]`; row: `Database["conversation"]["Tables"]["message"]["Row"]`; update: `Database["conversation"]["Tables"]["message"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
