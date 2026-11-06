---
id: "rel:research.report_package"
kind: table
schema: research
name: report_package
domain: research
aliases: [report package, research-report.v1]
tokens: [research, report_package, research.report_package, report_version_id, tenant_id, report_id, schema_version, authoring_mode, title, scope, as_of, producer_attempt_id, producer_identity, producer_version, predecessor_version_id, created_at]
summary: "Version scope, cutoff, producer, authoring mode and predecessor."
summary_basis: curated
rls: enabled
readers: [app_reader, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [control_plane, executor_service, service_role]
typescript: "Database[\"research\"][\"Tables\"][\"report_package\"][\"Row\"]"
defined_in: ["20260913010000_research_report_packages.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# research.report_package

table in domain `research` — Report v1 authoring envelope. Incremental and post-research assembly share one contract. Legacy report versions remain readable without this envelope..

> curated (model_assisted, unreviewed) — Incremental and post_research use the same contract. An earlier predecessor belongs to the same report; a mission and producer attempt are optional.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `report_version_id` | `uuid` | no | — | PK; unique (tenant_id, report_id, report_version_id); unique (tenant_id, report_version_id) |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, report_id, report_version_id); unique (tenant_id, report_version_id) |
| 3 | `report_id` | `uuid` | no | — | unique (tenant_id, report_id, report_version_id) |
| 4 | `schema_version` | `text` | no | `'research-report.v1'::text` | — |
| 5 | `authoring_mode` | `text` | no | — | — |
| 6 | `title` | `text` | no | — | — |
| 7 | `scope` | `jsonb` | no | — | — |
| 8 | `as_of` | `timestamp with time zone` | no | — | — |
| 9 | `producer_attempt_id` | `uuid` | yes | — | — |
| 10 | `producer_identity` | `text` | no | — | — |
| 11 | `producer_version` | `text` | no | — | — |
| 12 | `predecessor_version_id` | `uuid` | yes | — | — |
| 13 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (report_version_id)
- unique (tenant_id, report_id, report_version_id)
- unique (tenant_id, report_version_id)
- check `report_package_authoring_mode_check`: `(authoring_mode = ANY (ARRAY['incremental'::text, 'post_research'::text]))`
- check `report_package_check`: `(predecessor_version_id IS DISTINCT FROM report_version_id)`
- check `report_package_producer_identity_check`: `(btrim(producer_identity) <> ''::text)`
- check `report_package_producer_version_check`: `(btrim(producer_version) <> ''::text)`
- check `report_package_schema_version_check`: `(schema_version = 'research-report.v1'::text)`
- check `report_package_scope_check`: `(jsonb_typeof(scope) = 'object'::text)`
- check `report_package_title_check`: `(btrim(title) <> ''::text)`

## Relationships

Outbound: `tenant_id,producer_attempt_id` → [`orchestration.attempt`](../orchestration/attempt.md)`.tenant_id,id`; `tenant_id,report_id,predecessor_version_id` → [`research.report_version`](report_version.md)`.tenant_id,report_id,id`; `tenant_id,report_id,report_version_id` → [`research.report_version`](report_version.md)`.tenant_id,report_id,id`.
Inbound: [`research.report_artifact`](report_artifact.md).report_version_id, [`research.report_question`](report_question.md).report_version_id, [`research.report_section_version`](report_section_version.md).report_id,report_version_id.

## Indexes

`report_package_tenant_id_report_id_report_version_id_key` unique; `report_package_tenant_id_report_version_id_key` unique

## Triggers

- `report_projection_open` → [`research.guard_report_projection`](../../functions/research/guard_report_projection.md)
- `report_row_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`app_reader`: SELECT; `control_plane`: INSERT, SELECT; `executor_service`: INSERT, SELECT; `pipeline_agent`: SELECT; `service_role`: INSERT, SELECT; `verifier_agent`: SELECT. None: `anon`, `authenticated`.

## Read paths

- Named queries: `q:reports.versions`.
- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `control_plane`, `executor_service`.

## TypeScript

insert: `Database["research"]["Tables"]["report_package"]["Insert"]`; row: `Database["research"]["Tables"]["report_package"]["Row"]`; update: `Database["research"]["Tables"]["report_package"]["Update"]`

Defined in: `20260913010000_research_report_packages.sql`.
