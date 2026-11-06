---
id: "rel:research.report_artifact"
kind: table
schema: research
name: report_artifact
domain: research
aliases: [report renditions, report manifest]
tokens: [research, report_artifact, research.report_artifact, tenant_id, report_version_id, artifact_id, role]
summary: Package artifact roles referencing the shared artifact registry.
summary_basis: curated
rls: enabled
readers: [app_reader, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [control_plane, executor_service, service_role]
typescript: "Database[\"research\"][\"Tables\"][\"report_artifact\"][\"Row\"]"
defined_in: ["20260913010000_research_report_packages.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# research.report_artifact

table in domain `research` — References the canonical artifact registry; storage location, digest, bytes and availability are never copied into report rows..

> curated (model_assisted, unreviewed) — Resolve bytes, digest, media type and availability through orchestration.artifact. Signed URLs are transient. Post-seal assessments live outside the frozen package manifest.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | — |
| 2 | `report_version_id` | `uuid` | no | — | PK |
| 3 | `artifact_id` | `uuid` | no | — | PK |
| 4 | `role` | `text` | no | — | PK |

## Constraints

- PK (report_version_id, artifact_id, role)
- check `report_artifact_role_check`: `(role = ANY (ARRAY['structure'::text, 'markdown'::text, 'html'::text, 'pdf'::text, 'manifest'::text, 'verification'::text, 'input'::text]))`

## Relationships

Outbound: `tenant_id,artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id`; `tenant_id,report_version_id` → [`research.report_package`](report_package.md)`.tenant_id,report_version_id`.
Inbound: none.

## Indexes

`report_artifact_reverse`; `report_single_rendition` unique where `(role = ANY (ARRAY['structure'::text, 'markdown'::text, 'ma…`

## Triggers

- `artifact_retirement_8cccaed3b98bff5320927708` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md)
- `report_projection_open` → [`research.guard_report_projection`](../../functions/research/guard_report_projection.md)
- `report_row_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`app_reader`: SELECT; `control_plane`: INSERT, SELECT; `executor_service`: INSERT, SELECT; `pipeline_agent`: SELECT; `service_role`: INSERT, SELECT; `verifier_agent`: SELECT. None: `anon`, `authenticated`.

## Read paths

- Named queries: `q:reports.artifacts`.
- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `control_plane`, `executor_service`.

## TypeScript

insert: `Database["research"]["Tables"]["report_artifact"]["Insert"]`; row: `Database["research"]["Tables"]["report_artifact"]["Row"]`; update: `Database["research"]["Tables"]["report_artifact"]["Update"]`

Defined in: `20260913010000_research_report_packages.sql`.
