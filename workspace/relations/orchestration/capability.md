---
id: "rel:orchestration.capability"
kind: table
schema: orchestration
name: capability
domain: orchestration-ledger
aliases: []
tokens: [orchestration, capability, orchestration.capability, id, tenant_id, slug, kind, purpose, operations, packages_mcp_server_version_id, created_at, updated_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, service_role]
writers: [control_plane, executor_service, service_role]
typescript: "Database[\"orchestration\"][\"Tables\"][\"capability\"][\"Row\"]"
defined_in: ["20260826000200_orchestration.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# orchestration.capability

table in domain `orchestration-ledger`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, slug) |
| 3 | `slug` | `text` | no | — | unique (tenant_id, slug) |
| 4 | `kind` | `text` | no | — | FK → [`orchestration.capability_kind`](capability_kind.md).code |
| 5 | `purpose` | `text` | no | — | — |
| 6 | `operations` | `text[]` | no | `'{}'::text[]` | — |
| 7 | `packages_mcp_server_version_id` | `uuid` | yes | — | FK → [`corpus.entity`](../corpus/entity.md).id |
| 8 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 9 | `updated_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, slug)

## Relationships

Outbound: `kind` → [`orchestration.capability_kind`](capability_kind.md)`.code`; `packages_mcp_server_version_id` → [`corpus.entity`](../corpus/entity.md)`.id`.
Inbound: [`orchestration.capability_version`](capability_version.md).capability_id.

## Indexes

`capability_tenant_id_slug_key` unique

## Triggers

- `capability_set_updated_at` → [`util.set_updated_at`](../../functions/util/set_updated_at.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: INSERT, SELECT, UPDATE; `executor_service`: INSERT, SELECT; `service_role`: INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`.

## Write path

- Direct DML: `control_plane`, `executor_service`.

## TypeScript

insert: `Database["orchestration"]["Tables"]["capability"]["Insert"]`; row: `Database["orchestration"]["Tables"]["capability"]["Row"]`; update: `Database["orchestration"]["Tables"]["capability"]["Update"]`

Defined in: `20260826000200_orchestration.sql`.
