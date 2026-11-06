---
id: "rel:staging.vetting_decision"
kind: table
schema: staging
name: vetting_decision
domain: staging
aliases: [vetting]
tokens: [staging, vetting_decision, staging.vetting_decision, id, tenant_id, candidate_id, decision, reason, receipt_id, created_at]
summary: "admit, reject, or defer vetting decision with a receipt."
summary_basis: curated
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, pipeline_agent, service_role]
typescript: "Database[\"staging\"][\"Tables\"][\"vetting_decision\"][\"Row\"]"
defined_in: ["20260826000700_staging.sql", "20260912010900_km_09_ranking_staging.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# staging.vetting_decision

table in domain `staging`.

> curated (model_assisted, unreviewed) — admit, reject, or defer vetting decision with a receipt.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id) |
| 3 | `candidate_id` | `uuid` | no | — | FK → [`staging.candidate`](candidate.md).id |
| 4 | `decision` | `text` | no | — | _curated:_ admit, reject, defer. |
| 5 | `reason` | `text` | no | — | _curated:_ Required text. |
| 6 | `receipt_id` | `uuid` | no | — | FK → [`orchestration.operation_receipt`](../orchestration/operation_receipt.md).id |
| 7 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `vetting_decision_decision_check`: `(decision = ANY (ARRAY['admit'::text, 'reject'::text, 'defer'::text]))`

## Relationships

Outbound: `candidate_id` → [`staging.candidate`](candidate.md)`.id` (+tenant); `receipt_id` → [`orchestration.operation_receipt`](../orchestration/operation_receipt.md)`.id`.
Inbound: none.

## Indexes

`vetting_decision_tenant_id_id_key` unique

## Triggers

_None._

## Row-level security

Enabled.
- `km_tenant_access` (ALL) for `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: SELECT; `executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`, `pipeline_agent`.

## TypeScript

insert: `Database["staging"]["Tables"]["vetting_decision"]["Insert"]`; row: `Database["staging"]["Tables"]["vetting_decision"]["Row"]`; update: `Database["staging"]["Tables"]["vetting_decision"]["Update"]`

## Examples

Candidates awaiting work

```bash
knowledge db query staging.unresolved --param limit=50
```
Vetting is separate from identity resolution.

Defined in: `20260826000700_staging.sql`, `20260912010900_km_09_ranking_staging.sql`.
