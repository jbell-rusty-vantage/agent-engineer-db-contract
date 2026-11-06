---
id: "rel:research.research_bundle"
kind: table
schema: research
name: research_bundle
domain: research
aliases: []
tokens: [research, research_bundle, research.research_bundle, id, tenant_id, mission_id, bundle_version, manifest_artifact_id, status, created_at, updated_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"research\"][\"Tables\"][\"research_bundle\"][\"Row\"]"
defined_in: ["20260826000900_research.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# research.research_bundle

table in domain `research`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | — |
| 3 | `mission_id` | `uuid` | no | — | unique (mission_id, bundle_version); FK → [`orchestration.mission`](../orchestration/mission.md).id |
| 4 | `bundle_version` | `integer` | no | `1` | unique (mission_id, bundle_version) |
| 5 | `manifest_artifact_id` | `uuid` | yes | — | FK → [`orchestration.artifact`](../orchestration/artifact.md).id |
| 6 | `status` | `research.bundle_status` | no | `'assembling'::research.bundle_status` | — |
| 7 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 8 | `updated_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (mission_id, bundle_version)

## Relationships

Outbound: `manifest_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.id`; `mission_id` → [`orchestration.mission`](../orchestration/mission.md)`.id` on delete cascade.
Inbound: [`research.bundle_artifact`](bundle_artifact.md).bundle_id.

## Indexes

`research_bundle_mission_id_bundle_version_key` unique

## Triggers

- `artifact_retirement_f6764bd9df4ad903d9e9c722` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)
- `research_bundle_set_updated_at` → [`util.set_updated_at`](../../functions/util/set_updated_at.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: SELECT; `executor_service`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["research"]["Tables"]["research_bundle"]["Insert"]`; row: `Database["research"]["Tables"]["research_bundle"]["Row"]`; update: `Database["research"]["Tables"]["research_bundle"]["Update"]`

Defined in: `20260826000900_research.sql`.
