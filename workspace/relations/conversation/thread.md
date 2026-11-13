---
id: "rel:conversation.thread"
kind: table
schema: conversation
name: thread
domain: library
lens: private
aliases: [thread, chat]
tokens: [conversation, thread, conversation.thread, id, tenant_id, workspace_id, owner_id, visibility, title, purpose, mode, origin, imported_from, created_at, archived_at]
summary: "A learner's or author's conversation; messages become passages with lens private."
summary_basis: curated
rls: enabled
readers: []
writers: []
typescript: "Database[\"conversation\"][\"Tables\"][\"thread\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# conversation.thread

table in domain `library`, lens `private`.

> curated (model_assisted, unreviewed) — A learner's or author's conversation; messages become passages with lens private.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id) |
| 4 | `owner_id` | `uuid` | no | — | FK → `auth.users`.id |
| 5 | `visibility` | `text` | no | `'private'::text` | _curated:_ owner-only or workspace; the product search honours it. |
| 6 | `title` | `text` | no | — | — |
| 7 | `purpose` | `text` | no | — | tutor \| build \| research \| authoring \| project \| general \| defense \| interview (loop 4: a design interview between a person and an agent that produces probes, attention policies and claims, with knowledge-base retrieval snapshots on the agent turns). |
| 8 | `mode` | `text` | no | `'coach'::text` | _curated:_ How the thread runs (chat, tutor, review). |
| 9 | `origin` | `text` | no | `'native'::text` | — |
| 10 | `imported_from` | `jsonb` | yes | — | — |
| 11 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 12 | `archived_at` | `timestamp with time zone` | yes | — | _curated:_ Archived threads stay searchable to their owner. |

## Constraints

- PK (id)
- unique (tenant_id, workspace_id, id)
- check `thread_check`: `((origin = 'import'::text) = (imported_from IS NOT NULL))`
- check `thread_mode_check`: `(mode = ANY (ARRAY['coach'::text, 'build_with_me'::text, 'elicit'::text]))`
- check `thread_origin_check`: `(origin = ANY (ARRAY['native'::text, 'import'::text]))`
- check `thread_purpose_check`: `(purpose = ANY (ARRAY['tutor'::text, 'build'::text, 'research'::text, 'authoring'::text, 'project'::text, 'general'::text, 'defense'::text,…`
- check `thread_title_check`: `product.nonblank(title)`
- check `thread_visibility_check`: `(visibility = ANY (ARRAY['private'::text, 'workspace'::text]))`

## Relationships

Outbound: `owner_id` → `auth.users``.id` on delete restrict; `tenant_id,workspace_id` → [`authoring.workspace`](../authoring/workspace.md)`.tenant_id,id` on delete restrict.
Inbound: [`acquisition.attention_policy`](../acquisition/attention_policy.md).designed_in_thread_id, [`conversation.message`](message.md).workspace_id,thread_id, [`verification.probe`](../verification/probe.md).designed_in_thread_id.

## Indexes

`thread_owner_ix`; `thread_tenant_id_workspace_id_id_key` unique

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
- Product operations (best effort): [`create_thread`](../../ops/create_thread.md).

## TypeScript

insert: `Database["conversation"]["Tables"]["thread"]["Insert"]`; row: `Database["conversation"]["Tables"]["thread"]["Row"]`; update: `Database["conversation"]["Tables"]["thread"]["Update"]`

## Examples

Conversations are private passages

```bash
knowledge db query retrieval.search_unified --param lenses=["private"] --param limit=20 --param query=backoff --param workspace_ids=["0192a000-0000-7000-8000-000000000001"]
```
Rows whose target passage has message_id set.

Defined in: `20261105010100_product_foundation.sql`.
