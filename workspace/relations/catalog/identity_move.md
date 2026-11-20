---
id: "rel:catalog.identity_move"
kind: table
schema: catalog
name: identity_move
domain: identity
lens: corpus
aliases: []
tokens: [catalog, identity_move, catalog.identity_move, id, seq, tenant_id, merge_id, split_id, table_name, column_name, row_key, action, detail, undone, created_at]
summary: "One row per row touched by a merge or a split: moved, closed_as_duplicate (the winner already had it), kept_on_source (the table refused the change), adopted (a move made earlier by hand, now recorded) or added (an alias). The log an undo reads."
summary_basis: comment
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"catalog\"][\"Tables\"][\"identity_move\"][\"Row\"]"
defined_in: ["20261119120000_build09_rv01_change_reasons_identity_proposals.sql"]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# catalog.identity_move

table in domain `identity`, lens `corpus` — One row per row touched by a merge or a split: moved, closed_as_duplicate (the winner already had it), kept_on_source (the table refused the change), adopted (a move made earlier by hand, now recorded) or added (an alias). The log an undo reads..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `seq` | `bigint` | no | — | identity always |
| 3 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | — |
| 4 | `merge_id` | `uuid` | yes | — | FK → [`catalog.entity_merge`](entity_merge.md).id |
| 5 | `split_id` | `uuid` | yes | — | FK → [`catalog.entity_split`](entity_split.md).id |
| 6 | `table_name` | `text` | no | — | — |
| 7 | `column_name` | `text` | yes | — | — |
| 8 | `row_key` | `jsonb` | no | — | — |
| 9 | `action` | `text` | no | — | — |
| 10 | `detail` | `jsonb` | no | `'{}'::jsonb` | — |
| 11 | `undone` | `boolean` | no | `false` | — |
| 12 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- check `identity_move_action_check`: `(action = ANY (ARRAY['moved'::text, 'closed_as_duplicate'::text, 'kept_on_source'::text, 'adopted'::text, 'added'::text]))`
- check `identity_move_one_parent`: `(num_nonnulls(merge_id, split_id) = 1)`

## Relationships

Outbound: `merge_id` → [`catalog.entity_merge`](entity_merge.md)`.id`; `split_id` → [`catalog.entity_split`](entity_split.md)`.id`.
Inbound: none.
Polymorphic: exactly one of `merge_id`, `split_id` → [`catalog.entity_merge`](entity_merge.md) | [`catalog.entity_split`](entity_split.md) — basis: check constraint identity_move_one_parent.

## Indexes

`identity_move_merge_idx`; `identity_move_split_idx`

## Triggers

_None._

## Row-level security

Enabled.
- `km_tenant_access` (ALL) for `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: SELECT; `executor_service`: SELECT; `pipeline_agent`: SELECT; `service_role`: SELECT; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Named queries: `q:facts.changes_since`.
- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- No direct DML for any agent role.
- Via functions (best effort): [`catalog._log_move`](../../functions/catalog/_log_move.md), [`catalog.undo_merge`](../../functions/catalog/undo_merge.md).

## TypeScript

insert: `Database["catalog"]["Tables"]["identity_move"]["Insert"]`; row: `Database["catalog"]["Tables"]["identity_move"]["Row"]`; update: `Database["catalog"]["Tables"]["identity_move"]["Update"]`

Defined in: `20261119120000_build09_rv01_change_reasons_identity_proposals.sql`.
