---
id: "rel:research.report_section_version"
kind: table
schema: research
name: report_section_version
domain: research
aliases: [report outline, section revision]
tokens: [research, report_section_version, research.report_section_version, tenant_id, report_id, report_version_id, section_id, ordinal, heading, section_kind, question, conclusion, context, content_pointer]
summary: "Ordered heading, question, conclusion, context and JSON pointer for an exact revision."
summary_basis: curated
rls: enabled
readers: [app_reader, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [control_plane, executor_service, service_role]
typescript: "Database[\"research\"][\"Tables\"][\"report_section_version\"][\"Row\"]"
defined_in: ["20260913010000_research_report_packages.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# research.report_section_version

table in domain `research`.

> curated (model_assisted, unreviewed) — Read ordinal order. content_pointer addresses structured JSON; fetch the registered structure artifact for blocks and readable content.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | PK |
| 2 | `report_id` | `uuid` | no | — | — |
| 3 | `report_version_id` | `uuid` | no | — | PK; unique (report_version_id, ordinal) |
| 4 | `section_id` | `uuid` | no | — | PK |
| 5 | `ordinal` | `integer` | no | — | unique (report_version_id, ordinal) |
| 6 | `heading` | `text` | no | — | — |
| 7 | `section_kind` | `text` | no | — | — |
| 8 | `question` | `text` | yes | — | — |
| 9 | `conclusion` | `text` | yes | — | — |
| 10 | `context` | `jsonb` | no | `'{}'::jsonb` | — |
| 11 | `content_pointer` | `text` | no | — | — |

## Constraints

- PK (tenant_id, report_version_id, section_id)
- unique (report_version_id, ordinal)
- check `report_section_version_content_pointer_check`: `(content_pointer ~~ '/sections/%'::text)`
- check `report_section_version_context_check`: `(jsonb_typeof(context) = 'object'::text)`
- check `report_section_version_heading_check`: `(btrim(heading) <> ''::text)`
- check `report_section_version_ordinal_check`: `(ordinal >= 0)`
- check `report_section_version_section_kind_check`: `(section_kind = ANY (ARRAY['scope'::text, 'summary'::text, 'finding'::text, 'comparison'::text, 'timeline'::text, 'measurement'::text, 'syn…`

## Relationships

Outbound: `tenant_id,report_id,report_version_id` → [`research.report_package`](report_package.md)`.tenant_id,report_id,report_version_id`; `tenant_id,report_id,section_id` → [`research.report_section`](report_section.md)`.tenant_id,report_id,id`.
Inbound: [`research.report_assertion`](report_assertion.md).report_version_id,section_id, [`research.report_question_section`](report_question_section.md).report_version_id,section_id, [`research.report_section_dependency`](report_section_dependency.md).report_version_id,section_id|required_version_id,required_section_id.

## Indexes

`report_section_version_report_version_id_ordinal_key` unique

## Triggers

- `report_projection_open` → [`research.guard_report_projection`](../../functions/research/guard_report_projection.md)
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

insert: `Database["research"]["Tables"]["report_section_version"]["Insert"]`; row: `Database["research"]["Tables"]["report_section_version"]["Row"]`; update: `Database["research"]["Tables"]["report_section_version"]["Update"]`

Defined in: `20260913010000_research_report_packages.sql`.
