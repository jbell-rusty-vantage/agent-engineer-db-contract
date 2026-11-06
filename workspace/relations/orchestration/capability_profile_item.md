---
id: "rel:orchestration.capability_profile_item"
kind: table
schema: orchestration
name: capability_profile_item
domain: orchestration-ledger
aliases: []
tokens: [orchestration, capability_profile_item, orchestration.capability_profile_item, profile_id, capability_version_id, activation]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, service_role]
writers: [control_plane, executor_service, service_role]
typescript: "Database[\"orchestration\"][\"Tables\"][\"capability_profile_item\"][\"Row\"]"
defined_in: ["20260826000200_orchestration.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# orchestration.capability_profile_item

table in domain `orchestration-ledger`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `profile_id` | `uuid` | no | — | PK; FK → [`orchestration.capability_profile`](capability_profile.md).id |
| 2 | `capability_version_id` | `uuid` | no | — | PK; FK → [`orchestration.capability_version`](capability_version.md).id |
| 3 | `activation` | `text` | no | `'available'::text` | — |

## Constraints

- PK (profile_id, capability_version_id)
- check `capability_profile_item_activation_check`: `(activation = ANY (ARRAY['available'::text, 'preloaded'::text, 'on_demand'::text, 'disabled'::text]))`

## Relationships

Outbound: `capability_version_id` → [`orchestration.capability_version`](capability_version.md)`.id` on delete cascade; `profile_id` → [`orchestration.capability_profile`](capability_profile.md)`.id` on delete cascade.
Inbound: none.

## Indexes

_None._

## Triggers

_None._

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `false`

## Grants

`control_plane`: INSERT, SELECT, UPDATE; `executor_service`: INSERT, SELECT; `service_role`: INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`.

## Write path

- Direct DML: `control_plane`, `executor_service`.

## TypeScript

insert: `Database["orchestration"]["Tables"]["capability_profile_item"]["Insert"]`; row: `Database["orchestration"]["Tables"]["capability_profile_item"]["Row"]`; update: `Database["orchestration"]["Tables"]["capability_profile_item"]["Update"]`

Defined in: `20260826000200_orchestration.sql`.
