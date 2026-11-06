---
id: "rel:research.report_section"
kind: table
schema: research
name: report_section
domain: research
aliases: [stable section, section identity]
tokens: [research, report_section, research.report_section, id, tenant_id, report_id, section_key]
summary: Stable section key within one report.
summary_basis: curated
rls: enabled
readers: [app_reader, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [control_plane, executor_service, service_role]
typescript: "Database[\"research\"][\"Tables\"][\"report_section\"][\"Row\"]"
defined_in: ["20260913010000_research_report_packages.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# research.report_section

table in domain `research`.

> curated (model_assisted, unreviewed) — Join report_section_version for the heading and content of a particular revision. A stable section alone does not identify reusable bytes.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, report_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, report_id, id); unique (tenant_id, report_id, section_key) |
| 3 | `report_id` | `uuid` | no | — | unique (tenant_id, report_id, id); unique (tenant_id, report_id, section_key) |
| 4 | `section_key` | `text` | no | — | unique (tenant_id, report_id, section_key) |

## Constraints

- PK (id)
- unique (tenant_id, report_id, id)
- unique (tenant_id, report_id, section_key)
- check `report_section_section_key_check`: `(btrim(section_key) <> ''::text)`

## Relationships

Outbound: `tenant_id,report_id` → [`research.report`](report.md)`.tenant_id,id`.
Inbound: [`research.report_section_version`](report_section_version.md).report_id,section_id.

## Indexes

`report_section_tenant_id_report_id_id_key` unique; `report_section_tenant_id_report_id_section_key_key` unique

## Triggers

- `report_row_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`app_reader`: SELECT; `control_plane`: INSERT, SELECT; `executor_service`: INSERT, SELECT; `pipeline_agent`: SELECT; `service_role`: INSERT, SELECT; `verifier_agent`: SELECT. None: `anon`, `authenticated`.

## Read paths

- Named queries: `q:reports.sections`.
- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `control_plane`, `executor_service`.

## TypeScript

insert: `Database["research"]["Tables"]["report_section"]["Insert"]`; row: `Database["research"]["Tables"]["report_section"]["Row"]`; update: `Database["research"]["Tables"]["report_section"]["Update"]`

Defined in: `20260913010000_research_report_packages.sql`.
