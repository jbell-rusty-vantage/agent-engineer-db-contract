---
id: "rel:retrieval.vector_store_lifecycle_event"
kind: table
schema: retrieval
name: vector_store_lifecycle_event
domain: retrieval
aliases: []
tokens: [retrieval, vector_store_lifecycle_event, retrieval.vector_store_lifecycle_event, id, tenant_id, vector_store_id, actor_identity, reason, previous_lifecycle, new_lifecycle, occurred_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, service_role]
writers: [control_plane, service_role]
typescript: "Database[\"retrieval\"][\"Tables\"][\"vector_store_lifecycle_event\"][\"Row\"]"
defined_in: ["20260904015000_vector_store_lifecycle_control_plane.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# retrieval.vector_store_lifecycle_event

table in domain `retrieval`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id) |
| 3 | `vector_store_id` | `uuid` | no | — | — |
| 4 | `actor_identity` | `text` | no | — | — |
| 5 | `reason` | `text` | no | — | — |
| 6 | `previous_lifecycle` | `text` | no | — | — |
| 7 | `new_lifecycle` | `text` | no | — | — |
| 8 | `occurred_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `vector_store_lifecycle_event_reason_check`: `((length(btrim(reason)) >= 1) AND (length(btrim(reason)) <= 2000))`

## Relationships

Outbound: `tenant_id,vector_store_id` → [`retrieval.vector_store`](vector_store.md)`.tenant_id,id` on delete restrict.
Inbound: none.

## Indexes

`vector_store_lifecycle_event_tenant_id_id_key` unique

## Triggers

- `vector_store_lifecycle_event_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled and forced.
- `control_plane_access` (ALL) for `control_plane`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: INSERT, SELECT; `service_role`: INSERT, SELECT. None: `anon`, `app_reader`, `authenticated`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `control_plane`.

## Write path

- Direct DML: `control_plane`.
- Via functions (best effort): [`retrieval.transition_vector_store_lifecycle`](../../functions/retrieval/transition_vector_store_lifecycle.md).

## TypeScript

insert: `Database["retrieval"]["Tables"]["vector_store_lifecycle_event"]["Insert"]`; row: `Database["retrieval"]["Tables"]["vector_store_lifecycle_event"]["Row"]`; update: `Database["retrieval"]["Tables"]["vector_store_lifecycle_event"]["Update"]`

Defined in: `20260904015000_vector_store_lifecycle_control_plane.sql`.
