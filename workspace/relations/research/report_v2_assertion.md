---
id: "rel:research.report_v2_assertion"
kind: table
schema: research
name: report_v2_assertion
domain: research-v2
aliases: []
tokens: [research, report_v2_assertion, research.report_v2_assertion, tenant_id, report_id, revision, assertion_ref_digest, assertion_id, assertion_kind, projected_at]
summary: "Assertions cited by a projected v2 revision, keyed by the assertion Ref digest listed in the component revision's assertion_refs; the component assertion record is the owner."
summary_basis: comment
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"research\"][\"Tables\"][\"report_v2_assertion\"][\"Row\"]"
defined_in: ["20261024010100_research_report_v2_projection.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# research.report_v2_assertion

table in domain `research-v2` — Assertions cited by a projected v2 revision, keyed by the assertion Ref digest listed in the component revision's assertion_refs; the component assertion record is the owner..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | PK; unique (tenant_id, report_id, revision, assertion_id) |
| 2 | `report_id` | `text` | no | — | PK; unique (tenant_id, report_id, revision, assertion_id) |
| 3 | `revision` | `integer` | no | — | PK; unique (tenant_id, report_id, revision, assertion_id) |
| 4 | `assertion_ref_digest` | `text` | no | — | PK |
| 5 | `assertion_id` | `text` | no | — | unique (tenant_id, report_id, revision, assertion_id) |
| 6 | `assertion_kind` | `text` | no | — | — |
| 7 | `projected_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (tenant_id, report_id, revision, assertion_ref_digest)
- unique (tenant_id, report_id, revision, assertion_id)
- check `report_v2_assertion_assertion_ref_digest_check`: `(assertion_ref_digest ~ '^sha256:[0-9a-f]{64}$'::text)`

## Relationships

Outbound: `tenant_id,report_id,revision` → [`research.report_v2_revision`](report_v2_revision.md)`.tenant_id,report_id,revision` on delete restrict.
Inbound: [`research.report_v2_ingestion`](report_v2_ingestion.md).report_id,revision,assertion_ref_digest.

## Indexes

`report_v2_assertion_tenant_id_report_id_revision_assertion__key` unique

## Triggers

- `report_v2_assertion_guard` → [`research.guard_report_v2_assertion`](../../functions/research/guard_report_v2_assertion.md)
- `report_v2_assertion_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

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

insert: `Database["research"]["Tables"]["report_v2_assertion"]["Insert"]`; row: `Database["research"]["Tables"]["report_v2_assertion"]["Row"]`; update: `Database["research"]["Tables"]["report_v2_assertion"]["Update"]`

Defined in: `20261024010100_research_report_v2_projection.sql`.
