---
id: "rel:research.report_v2_ingestion"
kind: table
schema: research
name: report_v2_ingestion
domain: research-v2
aliases: []
tokens: [research, report_v2_ingestion, research.report_v2_ingestion, tenant_id, use_decision_id, bound_effect_digest, report_id, revision, assertion_ref_digest, intent_id, receipt_id, outcome, recorded_at]
summary: "Ingestion result of one admitted exact use (keyed by component use_decision_id): the decision's subject (report revision or assertion) and the native operation receipt that names the same decision and bound effect digest."
summary_basis: comment
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"research\"][\"Tables\"][\"report_v2_ingestion\"][\"Row\"]"
defined_in: ["20261024010100_research_report_v2_projection.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# research.report_v2_ingestion

table in domain `research-v2` — Ingestion result of one admitted exact use (keyed by component use_decision_id): the decision's subject (report revision or assertion) and the native operation receipt that names the same decision and bound effect digest..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | PK |
| 2 | `use_decision_id` | `text` | no | — | PK |
| 3 | `bound_effect_digest` | `text` | no | — | — |
| 4 | `report_id` | `text` | no | — | — |
| 5 | `revision` | `integer` | no | — | — |
| 6 | `assertion_ref_digest` | `text` | yes | — | — |
| 7 | `intent_id` | `uuid` | no | — | FK → [`orchestration.operation_intent`](../orchestration/operation_intent.md).id |
| 8 | `receipt_id` | `uuid` | no | — | unique (receipt_id); FK → [`orchestration.operation_receipt`](../orchestration/operation_receipt.md).id |
| 9 | `outcome` | `text` | no | — | — |
| 10 | `recorded_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (tenant_id, use_decision_id)
- unique (receipt_id)
- check `report_v2_ingestion_bound_effect_digest_check`: `(bound_effect_digest ~ '^sha256:[0-9a-f]{64}$'::text)`
- check `report_v2_ingestion_outcome_check`: `(outcome = ANY (ARRAY['applied'::text, 'rejected'::text, 'noop'::text, 'partial'::text]))`

## Relationships

Outbound: `intent_id` → [`orchestration.operation_intent`](../orchestration/operation_intent.md)`.id`; `receipt_id` → [`orchestration.operation_receipt`](../orchestration/operation_receipt.md)`.id`; `tenant_id,report_id,revision,assertion_ref_digest` → [`research.report_v2_assertion`](report_v2_assertion.md)`.tenant_id,report_id,revision,assertion_ref_digest` on delete restrict; `tenant_id,report_id,revision` → [`research.report_v2_revision`](report_v2_revision.md)`.tenant_id,report_id,revision` on delete restrict.
Inbound: none.

## Indexes

`report_v2_ingestion_receipt_id_key` unique

## Triggers

- `report_v2_ingestion_guard` → [`research.guard_report_v2_ingestion`](../../functions/research/guard_report_v2_ingestion.md)
- `report_v2_ingestion_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

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

insert: `Database["research"]["Tables"]["report_v2_ingestion"]["Insert"]`; row: `Database["research"]["Tables"]["report_v2_ingestion"]["Row"]`; update: `Database["research"]["Tables"]["report_v2_ingestion"]["Update"]`

Defined in: `20261024010100_research_report_v2_projection.sql`.
