---
id: "rel:research.report_question"
kind: table
schema: research
name: report_question
domain: research
aliases: [report gaps, question coverage]
tokens: [research, report_question, research.report_question, tenant_id, report_version_id, question_key, question, required, coverage, explanation, resolution_evidence_needed]
summary: "Original research questions, coverage, explanations and missing evidence."
summary_basis: curated
rls: enabled
readers: [app_reader, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [control_plane, executor_service, service_role]
typescript: "Database[\"research\"][\"Tables\"][\"report_question\"][\"Row\"]"
defined_in: ["20260913010000_research_report_packages.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# research.report_question

table in domain `research`.

> curated (model_assisted, unreviewed) — Coverage is independent of assertion support. A sealed partial report can retain unanswered questions; inspect required flags and resolution_evidence_needed.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | PK |
| 2 | `report_version_id` | `uuid` | no | — | PK |
| 3 | `question_key` | `text` | no | — | PK |
| 4 | `question` | `text` | no | — | — |
| 5 | `required` | `boolean` | no | `true` | — |
| 6 | `coverage` | `text` | no | — | — |
| 7 | `explanation` | `text` | no | — | — |
| 8 | `resolution_evidence_needed` | `text` | yes | — | — |

## Constraints

- PK (tenant_id, report_version_id, question_key)
- check `report_question_check`: `((coverage = 'answered'::text) OR (btrim(explanation) <> ''::text))`
- check `report_question_coverage_check`: `(coverage = ANY (ARRAY['answered'::text, 'partial'::text, 'unanswered'::text, 'conflicting'::text, 'out_of_scope'::text]))`
- check `report_question_question_check`: `(btrim(question) <> ''::text)`
- check `report_question_question_key_check`: `(btrim(question_key) <> ''::text)`

## Relationships

Outbound: `tenant_id,report_version_id` → [`research.report_package`](report_package.md)`.tenant_id,report_version_id`.
Inbound: [`research.report_question_section`](report_question_section.md).report_version_id,question_key.

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

insert: `Database["research"]["Tables"]["report_question"]["Insert"]`; row: `Database["research"]["Tables"]["report_question"]["Row"]`; update: `Database["research"]["Tables"]["report_question"]["Update"]`

Defined in: `20260913010000_research_report_packages.sql`.
