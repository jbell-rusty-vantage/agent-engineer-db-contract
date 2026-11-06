---
id: "rel:research.report_v2_revision"
kind: table
schema: research
name: report_v2_revision
domain: research-v2
aliases: []
tokens: [research, report_v2_revision, research.report_v2_revision, tenant_id, report_id, revision, report_revision_id, report_revision_digest, run_id, verification_snapshot_digest, report_kind, body_digest, domain_report_id, projected_at]
summary: "AI Engineer projection of one sealed knowledge_verification.report_revision (research-report.v2), keyed (tenant_id, report_id, revision) and bound to its run (tenant_id, run_id) and verification snapshot. Validated against the component by trigger; the component remains the owner of the revision, custody and seal."
summary_basis: comment
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"research\"][\"Tables\"][\"report_v2_revision\"][\"Row\"]"
defined_in: ["20261024010100_research_report_v2_projection.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# research.report_v2_revision

table in domain `research-v2` — AI Engineer projection of one sealed knowledge_verification.report_revision (research-report.v2), keyed (tenant_id, report_id, revision) and bound to its run (tenant_id, run_id) and verification snapshot. Validated against the component by trigger; the component remains the owner of the revision, custody and seal..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | PK; unique (tenant_id, report_revision_id) |
| 2 | `report_id` | `text` | no | — | PK |
| 3 | `revision` | `integer` | no | — | PK |
| 4 | `report_revision_id` | `text` | no | — | unique (tenant_id, report_revision_id) |
| 5 | `report_revision_digest` | `text` | no | — | — |
| 6 | `run_id` | `uuid` | no | — | — |
| 7 | `verification_snapshot_digest` | `text` | no | — | — |
| 8 | `report_kind` | `text` | no | — | — |
| 9 | `body_digest` | `text` | no | — | — |
| 10 | `domain_report_id` | `uuid` | yes | — | — |
| 11 | `projected_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (tenant_id, report_id, revision)
- unique (tenant_id, report_revision_id)
- check `report_v2_revision_body_digest_check`: `(body_digest ~ '^sha256:[0-9a-f]{64}$'::text)`
- check `report_v2_revision_report_id_check`: `(btrim(report_id) <> ''::text)`
- check `report_v2_revision_report_revision_digest_check`: `(report_revision_digest ~ '^sha256:[0-9a-f]{64}$'::text)`
- check `report_v2_revision_revision_check`: `(revision >= 1)`
- check `report_v2_revision_verification_snapshot_digest_check`: `(verification_snapshot_digest ~ '^sha256:[0-9a-f]{64}$'::text)`

## Relationships

Outbound: `tenant_id,domain_report_id` → [`research.report`](report.md)`.tenant_id,id` on delete restrict.
Inbound: [`research.report_v2_assertion`](report_v2_assertion.md).report_id,revision, [`research.report_v2_ingestion`](report_v2_ingestion.md).report_id,revision.

## Indexes

`report_v2_revision_tenant_id_report_revision_id_key` unique

## Triggers

- `report_v2_revision_guard` → [`research.guard_report_v2_revision`](../../functions/research/guard_report_v2_revision.md)
- `report_v2_revision_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled and forced.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: SELECT; `executor_service`: INSERT, SELECT; `pipeline_agent`: SELECT; `service_role`: INSERT, SELECT. None: `anon`, `app_reader`, `authenticated`, `verifier_agent`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["research"]["Tables"]["report_v2_revision"]["Insert"]`; row: `Database["research"]["Tables"]["report_v2_revision"]["Row"]`; update: `Database["research"]["Tables"]["report_v2_revision"]["Update"]`

Defined in: `20261024010100_research_report_v2_projection.sql`.
