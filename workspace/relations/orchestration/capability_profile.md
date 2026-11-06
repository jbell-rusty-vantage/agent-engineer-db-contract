---
id: "rel:orchestration.capability_profile"
kind: table
schema: orchestration
name: capability_profile
domain: orchestration-ledger
aliases: []
tokens: [orchestration, capability_profile, orchestration.capability_profile, id, tenant_id, slug, purpose, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, service_role]
writers: [control_plane, executor_service, service_role]
typescript: "Database[\"orchestration\"][\"Tables\"][\"capability_profile\"][\"Row\"]"
defined_in: ["20260826000200_orchestration.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# orchestration.capability_profile

table in domain `orchestration-ledger`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, slug) |
| 3 | `slug` | `text` | no | — | unique (tenant_id, slug) |
| 4 | `purpose` | `text` | no | — | — |
| 5 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, slug)

## Relationships

Outbound: none.
Inbound: [`orchestration.capability_profile_item`](capability_profile_item.md).profile_id, [`orchestration.mission`](mission.md).capability_profile_id, [`orchestration.work_item`](work_item.md).capability_profile_id.

## Indexes

`capability_profile_tenant_id_slug_key` unique

## Triggers

_None._

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

insert: `Database["orchestration"]["Tables"]["capability_profile"]["Insert"]`; row: `Database["orchestration"]["Tables"]["capability_profile"]["Row"]`; update: `Database["orchestration"]["Tables"]["capability_profile"]["Update"]`

Defined in: `20260826000200_orchestration.sql`.
