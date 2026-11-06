---
id: "rel:knowledge.record"
kind: table
schema: knowledge
name: record
domain: knowledge-records
aliases: [engineering record]
tokens: [knowledge, record, knowledge.record, id, tenant_id, kind, title, statement, scope, assurance_level, provenance_claim_id, created_by_receipt_id, created_at]
summary: Identity of a typed engineering record with assurance and a creating receipt.
summary_basis: curated
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"knowledge\"][\"Tables\"][\"record\"][\"Row\"]"
defined_in: ["20260912010700_km_07_knowledge.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# knowledge.record

table in domain `knowledge-records`.

> curated (model_assisted, unreviewed) — Identity of a typed engineering record with assurance and a creating receipt.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id); unique (tenant_id, id, kind) |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id); unique (tenant_id, id, kind) |
| 3 | `kind` | `text` | no | — | unique (tenant_id, id, kind); _curated:_ Selects the typed child table. |
| 4 | `title` | `text` | no | — | — |
| 5 | `statement` | `text` | no | — | — |
| 6 | `scope` | `jsonb` | no | `'{}'::jsonb` | — |
| 7 | `assurance_level` | `text` | no | `'asserted'::text` | FK → [`knowledge.assurance_level`](assurance_level.md).code; _curated:_ FK-style code into knowledge.assurance_level. |
| 8 | `provenance_claim_id` | `uuid` | yes | — | FK → [`evidence.claim`](../evidence/claim.md).id |
| 9 | `created_by_receipt_id` | `uuid` | no | — | FK → [`orchestration.operation_receipt`](../orchestration/operation_receipt.md).id |
| 10 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, id, kind)
- check `record_kind_check`: `(kind = ANY (ARRAY['technical_problem'::text, 'solution_pattern'::text, 'advanced_usage_pattern'::text, 'implementation_example'::text, 'fa…`

## Relationships

Outbound: `assurance_level` → [`knowledge.assurance_level`](assurance_level.md)`.code`; `created_by_receipt_id` → [`orchestration.operation_receipt`](../orchestration/operation_receipt.md)`.id` (deferrable); `provenance_claim_id` → [`evidence.claim`](../evidence/claim.md)`.id` (+tenant).
Inbound: [`evidence.claim_record`](../evidence/claim_record.md).record_id, [`knowledge.advanced_usage_pattern`](advanced_usage_pattern.md).id|id,kind, [`knowledge.benchmark_result`](benchmark_result.md).id|id,kind, [`knowledge.compatibility_constraint`](compatibility_constraint.md).id|id,kind, [`knowledge.failure_mode`](failure_mode.md).id|id,kind, [`knowledge.implementation_example`](implementation_example.md).id|id,kind, [`knowledge.operational_practice`](operational_practice.md).id|id,kind, [`knowledge.record_entity_link`](record_entity_link.md).record_id, [`knowledge.security_consideration`](security_consideration.md).id|id,kind, [`knowledge.solution_pattern`](solution_pattern.md).id|id,kind, [`knowledge.technical_problem`](technical_problem.md).id|id,kind, [`retrieval.projection_target`](../retrieval/projection_target.md).record_id … 1 more in [details](record.details.md).
Polymorphic target of: [`retrieval.projection_target`](../retrieval/projection_target.md) (check constraint projection_target_check), [`taxonomy.assignment`](../taxonomy/assignment.md) (check constraint assignment_check).

## Indexes

`record_tenant_id_id_key` unique; `record_tenant_id_id_kind_key` unique

## Triggers

- `record_receipt_tenant` → [`corpus.check_receipt_tenant`](../../functions/corpus/check_receipt_tenant.md) (constraint trigger)
- `record_requires_admission` → [`research.require_receipt_admission`](../../functions/research/require_receipt_admission.md) (constraint trigger, deferred)

## Row-level security

Enabled.
- `km_tenant_access` (ALL) for `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: SELECT; `executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: SELECT; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Exposed through: [`api.technical_record_search`](../api/technical_record_search.md).
- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["knowledge"]["Tables"]["record"]["Insert"]`; row: `Database["knowledge"]["Tables"]["record"]["Row"]`; update: `Database["knowledge"]["Tables"]["record"]["Update"]`

## Examples

Card may mention linked records indirectly

```bash
knowledge db query entity.card --param entity_id=0192b000-0000-7000-8000-000000000001
```
Direct record search is api.technical_record_search, not a catalog query yet.

Defined in: `20260912010700_km_07_knowledge.sql`.
