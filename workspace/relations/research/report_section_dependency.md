---
id: "rel:research.report_section_dependency"
kind: table
schema: research
name: report_section_dependency
domain: research
aliases: [section reuse, required context]
tokens: [research, report_section_dependency, research.report_section_dependency, tenant_id, report_version_id, section_id, required_version_id, required_section_id, relation]
summary: "Exact section-revision dependencies for context, derivation and supersession."
summary_basis: curated
rls: enabled
readers: [app_reader, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [control_plane, executor_service, service_role]
typescript: "Database[\"research\"][\"Tables\"][\"report_section_dependency\"][\"Row\"]"
defined_in: ["20260913010000_research_report_packages.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# research.report_section_dependency

table in domain `research`.

> curated (model_assisted, unreviewed) — Follow required_version_id and required_section_id together. Carry required context into lessons or articles; rewritten assertions require new verification.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | — |
| 2 | `report_version_id` | `uuid` | no | — | PK |
| 3 | `section_id` | `uuid` | no | — | PK |
| 4 | `required_version_id` | `uuid` | no | — | PK |
| 5 | `required_section_id` | `uuid` | no | — | PK |
| 6 | `relation` | `text` | no | — | PK |

## Constraints

- PK (report_version_id, section_id, required_version_id, required_section_id, relation)
- check `report_section_dependency_check`: `((report_version_id <> required_version_id) OR (section_id <> required_section_id))`
- check `report_section_dependency_relation_check`: `(relation = ANY (ARRAY['requires_context'::text, 'derived_from'::text, 'supersedes'::text]))`

## Relationships

Outbound: `tenant_id,report_version_id,section_id` → [`research.report_section_version`](report_section_version.md)`.tenant_id,report_version_id,section_id`; `tenant_id,required_version_id,required_section_id` → [`research.report_section_version`](report_section_version.md)`.tenant_id,report_version_id,section_id`.
Inbound: none.

## Indexes

_None._

## Triggers

- `report_projection_open` → [`research.guard_report_projection`](../../functions/research/guard_report_projection.md)
- `report_row_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`app_reader`: SELECT; `control_plane`: INSERT, SELECT; `executor_service`: INSERT, SELECT; `pipeline_agent`: SELECT; `service_role`: INSERT, SELECT; `verifier_agent`: SELECT. None: `anon`, `authenticated`.

## Read paths

- Named queries: `q:reports.dependencies`.
- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `control_plane`, `executor_service`.

## TypeScript

insert: `Database["research"]["Tables"]["report_section_dependency"]["Insert"]`; row: `Database["research"]["Tables"]["report_section_dependency"]["Row"]`; update: `Database["research"]["Tables"]["report_section_dependency"]["Update"]`

Defined in: `20260913010000_research_report_packages.sql`.
