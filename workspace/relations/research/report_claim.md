---
id: "rel:research.report_claim"
kind: table
schema: research
name: report_claim
domain: research
aliases: []
tokens: [research, report_claim, research.report_claim, report_version_id, claim_id, role, tenant_id]
summary: null
summary_basis: none
rls: enabled
readers: [app_reader, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [control_plane, executor_service, service_role]
typescript: "Database[\"research\"][\"Tables\"][\"report_claim\"][\"Row\"]"
defined_in: ["20260826000900_research.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# research.report_claim

table in domain `research`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `report_version_id` | `uuid` | no | — | PK; FK → [`research.report_version`](report_version.md).id |
| 2 | `claim_id` | `uuid` | no | — | PK; FK → [`evidence.claim`](../evidence/claim.md).id |
| 3 | `role` | `text` | no | `'supports'::text` | PK |
| 4 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | — |

## Constraints

- PK (report_version_id, claim_id, role)
- check `report_claim_role_check`: `(role = ANY (ARRAY['supports'::text, 'context'::text, 'caveat'::text, 'contradicts'::text]))`

## Relationships

Outbound: `claim_id` → [`evidence.claim`](../evidence/claim.md)`.id` (+tenant); `report_version_id` → [`research.report_version`](report_version.md)`.id` (+tenant) on delete cascade.
Inbound: none.

## Indexes

`report_claim_claim_idx`

## Triggers

- `report_projection_open` → [`research.guard_report_projection`](../../functions/research/guard_report_projection.md)
- `report_row_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`app_reader`: SELECT; `control_plane`: INSERT, SELECT; `executor_service`: INSERT, SELECT; `pipeline_agent`: SELECT; `service_role`: INSERT, SELECT; `verifier_agent`: SELECT. None: `anon`, `authenticated`.

## Read paths

- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `control_plane`, `executor_service`.

## TypeScript

insert: `Database["research"]["Tables"]["report_claim"]["Insert"]`; row: `Database["research"]["Tables"]["report_claim"]["Row"]`; update: `Database["research"]["Tables"]["report_claim"]["Update"]`

Defined in: `20260826000900_research.sql`.
