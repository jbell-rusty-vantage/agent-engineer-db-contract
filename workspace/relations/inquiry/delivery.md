---
id: "rel:inquiry.delivery"
kind: table
schema: inquiry
name: delivery
domain: inquiry
lens: ours
aliases: []
tokens: [inquiry, delivery, inquiry.delivery, id, tenant_id, workspace_id, obligation_id, revision_id, artifact_id, file_set_id, mc_output_revision_id, delivered_by, delivered_kind, origin, delivered_event_id, state, assessment, decided_by, decided_event_id, created_at, decided_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"inquiry\"][\"Tables\"][\"delivery\"][\"Row\"]"
defined_in: ["20261105010100_product_foundation.sql"]
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# inquiry.delivery

table in domain `inquiry`, lens `ours`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, workspace_id, id) |
| 2 | `tenant_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id) |
| 3 | `workspace_id` | `uuid` | no | — | unique (tenant_id, workspace_id, id) |
| 4 | `obligation_id` | `uuid` | no | — | — |
| 5 | `revision_id` | `uuid` | yes | — | — |
| 6 | `artifact_id` | `uuid` | yes | — | — |
| 7 | `file_set_id` | `uuid` | yes | — | — |
| 8 | `mc_output_revision_id` | `uuid` | yes | — | — |
| 9 | `delivered_by` | `uuid` | no | — | FK → `auth.users`.id |
| 10 | `delivered_kind` | `text` | no | — | — |
| 11 | `origin` | `text` | no | — | — |
| 12 | `delivered_event_id` | `uuid` | no | — | — |
| 13 | `state` | `text` | no | `'submitted'::text` | — |
| 14 | `assessment` | `jsonb` | no | `'{}'::jsonb` | — |
| 15 | `decided_by` | `uuid` | yes | — | FK → `auth.users`.id |
| 16 | `decided_event_id` | `uuid` | yes | — | — |
| 17 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 18 | `decided_at` | `timestamp with time zone` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, workspace_id, id)
- check `delivery_assessment_check`: `(jsonb_typeof(assessment) = 'object'::text)`
- check `delivery_check`: `(num_nonnulls(revision_id, artifact_id, file_set_id) = 1)`
- check `delivery_check1`: `((state = ANY (ARRAY['accepted'::text, 'rejected'::text])) = ((decided_by IS NOT NULL) AND (decided_at IS NOT NULL) AND (decided_event_id I…`
- check `delivery_delivered_kind_check`: `(delivered_kind = ANY (ARRAY['human'::text, 'agent'::text, 'system'::text]))`
- check `delivery_origin_check`: `(origin = ANY (ARRAY['mc'::text, 'native_harness'::text, 'manual'::text]))`
- check `delivery_state_check`: `(state = ANY (ARRAY['submitted'::text, 'accepted'::text, 'rejected'::text, 'withdrawn'::text]))`

## Relationships

Outbound: `decided_by` → `auth.users``.id` on delete restrict; `delivered_by` → `auth.users``.id` on delete restrict; `tenant_id,artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id` on delete restrict; `tenant_id,workspace_id,decided_event_id` → [`authoring.event`](../authoring/event.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,delivered_event_id` → [`authoring.event`](../authoring/event.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,file_set_id` → [`authoring.file_set`](../authoring/file_set.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,obligation_id` → [`inquiry.obligation`](obligation.md)`.tenant_id,workspace_id,id` on delete restrict; `tenant_id,workspace_id,revision_id` → [`authoring.work_revision`](../authoring/work_revision.md)`.tenant_id,workspace_id,id` on delete restrict.
Inbound: none.

## Indexes

`delivery_decided_by_fkey_ix`; `delivery_delivered_by_fkey_ix`; `delivery_tenant_id_artifact_id_fkey_ix`; `delivery_tenant_id_workspace_id_decided_event_id_fkey_ix`; `delivery_tenant_id_workspace_id_delivered_event_id_fkey_ix`; `delivery_tenant_id_workspace_id_file_set_id_fkey_ix`; `delivery_tenant_id_workspace_id_id_key` unique; `delivery_tenant_id_workspace_id_obligation_id_fkey_ix`; `delivery_tenant_id_workspace_id_revision_id_fkey_ix`

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
- Via functions (best effort): [`product.dispatch_research_command`](../../functions/product/dispatch_research_command.md).
- Product operations (best effort): [`decide_delivery`](../../ops/decide_delivery.md), [`deliver_output`](../../ops/deliver_output.md).

## TypeScript

insert: `Database["inquiry"]["Tables"]["delivery"]["Insert"]`; row: `Database["inquiry"]["Tables"]["delivery"]["Row"]`; update: `Database["inquiry"]["Tables"]["delivery"]["Update"]`

Defined in: `20261105010100_product_foundation.sql`.
