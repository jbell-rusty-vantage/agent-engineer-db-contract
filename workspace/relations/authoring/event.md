---
id: "rel:authoring.event"
kind: table
schema: authoring
name: event
domain: authoring
lens: ours
aliases: []
tokens: [authoring, event, authoring.event, id, tenant_id, workspace_id, work_id, revision_id, kind, related_event_id, actor_id, actor_kind, client_surface, author_role, payload_schema, payload, dedupe_key, created_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"authoring\"][\"Tables\"][\"event\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
---
# authoring.event

table in domain `authoring`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id); unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, id); unique (tenant_id, workspace_id, dedupe_key); unique (tenant_id, workspace_id, id) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, dedupe_key); unique (tenant_id, workspace_id, id) |
| 4 | `work_id` | `uuid` | yes | — | — |
| 5 | `revision_id` | `uuid` | yes | — | — |
| 6 | `kind` | `text` | no | — | — |
| 7 | `related_event_id` | `uuid` | yes | — | — |
| 8 | `actor_id` | `uuid` | no | — | FK → `auth.users`.id |
| 9 | `actor_kind` | `text` | no | — | — |
| 10 | `client_surface` | `text` | no | — | — |
| 11 | `author_role` | `text` | no | — | — |
| 12 | `payload_schema` | `text` | no | — | — |
| 13 | `payload` | `jsonb` | no | `'{}'::jsonb` | — |
| 14 | `dedupe_key` | `text` | no | — | unique (tenant_id, workspace_id, dedupe_key) |
| 15 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, workspace_id, dedupe_key)
- unique (tenant_id, workspace_id, id)
- check `event_actor_kind_check`: `(actor_kind = ANY (ARRAY['human'::text, 'agent'::text, 'system'::text]))`
- check `event_author_role_check`: `(author_role = ANY (ARRAY['student'::text, 'teacher'::text, 'system_author'::text, 'learner'::text, 'maintainer'::text]))`
- check `event_check`: `((revision_id IS NULL) OR (work_id IS NOT NULL))`
- check `event_client_surface_check`: `(client_surface = ANY (ARRAY['web'::text, 'harness'::text, 'import'::text, 'system'::text]))`
- check `event_dedupe_key_check`: `product.nonblank(dedupe_key)`
- check `event_kind_check`: `(kind = ANY (ARRAY['feedback'::text, 'revision_proposed'::text, 'reviewed'::text, 'change_detected'::text, 'change_acknowledged'::text, 'wi…`
- check `event_payload_schema_check`: `(payload_schema ~ '^aieng\.[a-z-]+\.v[0-9]+$'::text)`

## Relationships

Outbound: `actor_id` → `auth.users``.id` on delete restrict; `tenant_id,workspace_id` → [`authoring.workspace`](workspace.md)`.tenant_id,id` on delete restrict; `tenant_id,workspace_id,related_event_id` → [`authoring.event`](event.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,work_id` → [`authoring.work`](work.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,work_id,revision_id` → [`authoring.work_revision`](work_revision.md)`.tenant_id,workspace_id,work_id,id` on delete restrict.
Inbound: [`authoring.distribution`](distribution.md).workspace_id,closed_event_id, [`authoring.distribution_offer`](distribution_offer.md).workspace_id,approval_event_id|workspace_id,end_event_id, [`authoring.event`](event.md).workspace_id,related_event_id, [`authoring.release`](release.md).workspace_id,approved_event_id, [`curriculum.release_transition`](../curriculum/release_transition.md).workspace_id,reviewed_event_id, [`inquiry.acceptance`](../inquiry/acceptance.md).workspace_id,accepted_event_id, [`inquiry.delivery`](../inquiry/delivery.md).workspace_id,decided_event_id|workspace_id,delivered_event_id, [`library.removal`](../library/removal.md).workspace_id,impact_acknowledged_event_id.

## Indexes

`event_actor_id_fkey_ix`; `event_tenant_id_id_key` unique; `event_tenant_id_workspace_id_dedupe_key_key` unique; `event_tenant_id_workspace_id_id_key` unique; `event_tenant_id_workspace_id_related_event_id_fkey_ix`; `event_tenant_id_workspace_id_work_id_fkey_ix`; `event_tenant_id_workspace_id_work_id_revision_id_fkey_ix`

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
- Via functions (best effort): [`product.new_event`](../../functions/product/new_event.md).

## TypeScript

insert: `Database["authoring"]["Tables"]["event"]["Insert"]`; row: `Database["authoring"]["Tables"]["event"]["Row"]`; update: `Database["authoring"]["Tables"]["event"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
