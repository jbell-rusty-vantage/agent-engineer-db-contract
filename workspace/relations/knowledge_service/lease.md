---
id: "rel:knowledge_service.lease"
kind: table
schema: knowledge_service
name: lease
domain: knowledge-service-runtime
aliases: []
tokens: [knowledge_service, lease, knowledge_service.lease, id, tenant_id, operation_step_id, holder_identity, lease_token, fencing_token, acquired_at, heartbeat_at, expires_at, released_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, service_role]
writers: [control_plane, executor_service, service_role]
typescript: "Database[\"knowledge_service\"][\"Tables\"][\"lease\"][\"Row\"]"
defined_in: ["20260903010200_knowledge_runtime_security.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# knowledge_service.lease

table in domain `knowledge-service-runtime`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id); unique (tenant_id, operation_step_id) |
| 3 | `operation_step_id` | `uuid` | no | — | unique (tenant_id, operation_step_id) |
| 4 | `holder_identity` | `text` | no | — | — |
| 5 | `lease_token` | `uuid` | no | `gen_random_uuid()` | unique (lease_token) |
| 6 | `fencing_token` | `bigint` | no | — | identity always |
| 7 | `acquired_at` | `timestamp with time zone` | no | `now()` | — |
| 8 | `heartbeat_at` | `timestamp with time zone` | no | `now()` | — |
| 9 | `expires_at` | `timestamp with time zone` | no | — | — |
| 10 | `released_at` | `timestamp with time zone` | yes | — | — |

## Constraints

- PK (id)
- unique (lease_token)
- unique (tenant_id, id)
- unique (tenant_id, operation_step_id)
- check `lease_check`: `(expires_at > acquired_at)`
- check `lease_check1`: `((released_at IS NULL) OR (released_at >= acquired_at))`

## Relationships

Outbound: `tenant_id,operation_step_id` → [`knowledge_service.operation_step`](operation_step.md)`.tenant_id,id` on delete restrict.
Inbound: none.

## Indexes

`knowledge_lease_expiry_idx` where `(released_at IS NULL)`; `lease_lease_token_key` unique; `lease_tenant_id_id_key` unique; `lease_tenant_id_operation_step_id_key` unique

## Triggers

_None._

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: INSERT, SELECT, UPDATE; `executor_service`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`.

## Write path

- Direct DML: `control_plane`, `executor_service`.

## TypeScript

insert: `Database["knowledge_service"]["Tables"]["lease"]["Insert"]`; row: `Database["knowledge_service"]["Tables"]["lease"]["Row"]`; update: `Database["knowledge_service"]["Tables"]["lease"]["Update"]`

Defined in: `20260903010200_knowledge_runtime_security.sql`.
