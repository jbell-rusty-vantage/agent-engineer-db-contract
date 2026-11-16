---
id: "rel:library.removal"
kind: table
schema: library
name: removal
domain: library
lens: ours
aliases: []
tokens: [library, removal, library.removal, id, tenant_id, workspace_id, requested_by, targets, impact, impact_acknowledged_event_id, state, steps, created_at, completed_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"library\"][\"Tables\"][\"removal\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# library.removal

table in domain `library`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id) |
| 4 | `requested_by` | `uuid` | no | — | FK → `auth.users`.id |
| 5 | `targets` | `jsonb` | no | — | — |
| 6 | `impact` | `jsonb` | no | — | — |
| 7 | `impact_acknowledged_event_id` | `uuid` | yes | — | — |
| 8 | `state` | `text` | no | — | — |
| 9 | `steps` | `jsonb` | no | `'[]'::jsonb` | — |
| 10 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 11 | `completed_at` | `timestamp with time zone` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, workspace_id, id)
- check `removal_state_check`: `(state = ANY (ARRAY['previewed'::text, 'acknowledged'::text, 'in_progress'::text, 'completed'::text, 'partial'::text, 'failed'::text, 'bloc…`

## Relationships

Outbound: `requested_by` → `auth.users``.id` on delete restrict; `tenant_id,workspace_id` → [`authoring.workspace`](../authoring/workspace.md)`.tenant_id,id` on delete restrict; `tenant_id,workspace_id,impact_acknowledged_event_id` → [`authoring.event`](../authoring/event.md)`.tenant_id,workspace_id,id` on delete restrict.
Inbound: [`authoring.work_revision`](../authoring/work_revision.md).workspace_id,purged_by_removal_id, [`conversation.message`](../conversation/message.md).workspace_id,redacted_by_removal_id.

## Indexes

`removal_requested_by_fkey_ix`; `removal_tenant_id_workspace_id_id_key` unique; `removal_tenant_id_workspace_id_impact_acknowledged_even_ix`

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
- Product operations (best effort): [`confirm_removal`](../../ops/confirm_removal.md), [`preview_removal`](../../ops/preview_removal.md).

## TypeScript

insert: `Database["library"]["Tables"]["removal"]["Insert"]`; row: `Database["library"]["Tables"]["removal"]["Row"]`; update: `Database["library"]["Tables"]["removal"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
