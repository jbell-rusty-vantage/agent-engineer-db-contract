---
id: "rel:research.report"
kind: table
schema: research
name: report
domain: research
aliases: [report]
tokens: [research, report, research.report, id, tenant_id, mission_id, slug, title, created_at, report_type, purpose]
summary: "Tenant report slug and title, optionally tied to a mission."
summary_basis: curated
rls: enabled
readers: [app_reader, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [control_plane, executor_service, service_role]
typescript: "Database[\"research\"][\"Tables\"][\"report\"][\"Row\"]"
defined_in: ["20260826000900_research.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# research.report

table in domain `research`.

> curated (model_assisted, unreviewed) — Tenant report slug and title, optionally tied to a mission.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, slug); unique (tenant_id, id) |
| 3 | `mission_id` | `uuid` | yes | — | FK → [`orchestration.mission`](../orchestration/mission.md).id; _curated:_ Optional for v1 registration; the legacy report.publish compatibility path requires a mission. |
| 4 | `slug` | `text` | no | — | unique (tenant_id, slug) |
| 5 | `title` | `text` | no | — | — |
| 6 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 7 | `report_type` | `text` | no | `'research_synthesis'::text` | — |
| 8 | `purpose` | `text` | no | `''::text` | — |

## Constraints

- PK (id)
- unique (tenant_id, slug)
- unique (tenant_id, id)
- check `report_report_type_check`: `(btrim(report_type) <> ''::text)`

## Relationships

Outbound: `mission_id` → [`orchestration.mission`](../orchestration/mission.md)`.id` (+tenant) on delete set null.
Inbound: [`research.report_section`](report_section.md).report_id, [`research.report_v2_revision`](report_v2_revision.md).domain_report_id, [`research.report_version`](report_version.md).report_id.

## Indexes

`report_tenant_id_slug_key` unique; `report_tenant_id_uq` unique

## Triggers

_None._

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`app_reader`: SELECT; `control_plane`: INSERT, SELECT, UPDATE; `executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: SELECT; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `authenticated`.

## Read paths

- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `control_plane`, `executor_service`.

## TypeScript

insert: `Database["research"]["Tables"]["report"]["Insert"]`; row: `Database["research"]["Tables"]["report"]["Row"]`; update: `Database["research"]["Tables"]["report"]["Update"]`

## Examples

Recent intents for a mission

```bash
knowledge db query receipts.recent_for_mission --param limit=20 --param mission_id=0192a000-0000-7000-8000-000000000001
```
Look for intent_type knowledge_ingestion after a report.publish.

Defined in: `20260826000900_research.sql`.
