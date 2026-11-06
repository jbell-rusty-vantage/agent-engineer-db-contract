---
id: "rel:research.report_question_section"
kind: table
schema: research
name: report_question_section
domain: research
aliases: [answering sections]
tokens: [research, report_question_section, research.report_question_section, tenant_id, report_version_id, question_key, section_id]
summary: Question-to-section links within an exact report revision.
summary_basis: curated
rls: enabled
readers: [app_reader, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [control_plane, executor_service, service_role]
typescript: "Database[\"research\"][\"Tables\"][\"report_question_section\"][\"Row\"]"
defined_in: ["20260913010000_research_report_packages.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# research.report_question_section

table in domain `research`.

> curated (model_assisted, unreviewed) — Answered, partial and conflicting coverage requires answering sections when sealing. Links locate answers; they do not certify correctness.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | — |
| 2 | `report_version_id` | `uuid` | no | — | PK |
| 3 | `question_key` | `text` | no | — | PK |
| 4 | `section_id` | `uuid` | no | — | PK |

## Constraints

- PK (report_version_id, question_key, section_id)

## Relationships

Outbound: `tenant_id,report_version_id,question_key` → [`research.report_question`](report_question.md)`.tenant_id,report_version_id,question_key`; `tenant_id,report_version_id,section_id` → [`research.report_section_version`](report_section_version.md)`.tenant_id,report_version_id,section_id`.
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

- Named queries: `q:reports.questions`.
- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `control_plane`, `executor_service`.

## TypeScript

insert: `Database["research"]["Tables"]["report_question_section"]["Insert"]`; row: `Database["research"]["Tables"]["report_question_section"]["Row"]`; update: `Database["research"]["Tables"]["report_question_section"]["Update"]`

Defined in: `20260913010000_research_report_packages.sql`.
