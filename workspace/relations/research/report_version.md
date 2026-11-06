---
id: "rel:research.report_version"
kind: table
schema: research
name: report_version
domain: research
aliases: [report revision, legacy report]
tokens: [research, report_version, research.report_version, id, report_id, version, markdown_artifact_id, json_artifact_id, synthesis_consistency_eval_id, assurance_summary, published_at, tenant_id]
summary: Immutable revision and primary Markdown/JSON references.
summary_basis: curated
rls: enabled
readers: [app_reader, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [control_plane, executor_service, service_role]
typescript: "Database[\"research\"][\"Tables\"][\"report_version\"][\"Row\"]"
defined_in: ["20260826000900_research.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# research.report_version

table in domain `research`.

> curated (model_assisted, unreviewed) — Left join report_package when listing versions: a missing package identifies a legacy revision, not a damaged v1 package.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, report_id, id); unique (tenant_id, id) |
| 2 | `report_id` | `uuid` | no | — | unique (tenant_id, report_id, id); unique (report_id, version); FK → [`research.report`](report.md).id |
| 3 | `version` | `integer` | no | — | unique (report_id, version) |
| 4 | `markdown_artifact_id` | `uuid` | yes | — | FK → [`orchestration.artifact`](../orchestration/artifact.md).id |
| 5 | `json_artifact_id` | `uuid` | yes | — | FK → [`orchestration.artifact`](../orchestration/artifact.md).id |
| 6 | `synthesis_consistency_eval_id` | `uuid` | yes | — | FK → [`evaluation.eval_run`](../evaluation/eval_run.md).id |
| 7 | `assurance_summary` | `jsonb` | no | `'{}'::jsonb` | — |
| 8 | `published_at` | `timestamp with time zone` | no | `now()` | — |
| 9 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, report_id, id); unique (tenant_id, id) |

## Constraints

- PK (id)
- unique (tenant_id, report_id, id)
- unique (report_id, version)
- unique (tenant_id, id)
- check `report_version_positive`: `(version > 0)`

## Relationships

Outbound: `synthesis_consistency_eval_id` → [`evaluation.eval_run`](../evaluation/eval_run.md)`.id`; `json_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.id` (+tenant); `markdown_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.id` (+tenant); `report_id` → [`research.report`](report.md)`.id` (+tenant) on delete cascade.
Inbound: [`evaluation.review_task`](../evaluation/review_task.md).report_version_id, [`research.report_claim`](report_claim.md).report_version_id, [`research.report_package`](report_package.md).report_id,predecessor_version_id|report_id,report_version_id.
Polymorphic target of: [`evaluation.review_task`](../evaluation/review_task.md) (check constraint review_task_exactly_one_subject).

## Indexes

`report_version_report_id_uq` unique; `report_version_report_id_version_key` unique; `report_version_tenant_id_uq` unique

## Triggers

- `artifact_retirement_3a8e5328b459c13ec8461b91` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)
- `artifact_retirement_57c3a5f36c424c62ba5e1f0d` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)
- `artifact_retirement_7aeb4d91360ebd6dd314cdab` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)
- `artifact_retirement_e7fdc57ee5b0a7c4de5cf293` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)
- `report_version_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

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

insert: `Database["research"]["Tables"]["report_version"]["Insert"]`; row: `Database["research"]["Tables"]["report_version"]["Row"]`; update: `Database["research"]["Tables"]["report_version"]["Update"]`

Defined in: `20260826000900_research.sql`.
