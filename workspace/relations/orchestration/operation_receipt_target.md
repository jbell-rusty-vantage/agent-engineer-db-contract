---
id: "rel:orchestration.operation_receipt_target"
kind: table
schema: orchestration
name: operation_receipt_target
domain: orchestration-ledger
aliases: []
tokens: [orchestration, operation_receipt_target, orchestration.operation_receipt_target, tenant_id, receipt_id, ordinal, target_schema, target_table, target_id, entity_id, entity_kind, role, action, proposal_id, claim_id]
summary: "Normalized targets of one native operation receipt: each corpus/staging/temporal/evidence/knowledge/ranking/research row the apply created, reused (already present, not rewritten), superseded (closed) or staged, with its role, the proposal that touched it, the entity (id and kind) for corpus rows and the claim for evidence rows. target_id is text because some targets are composite JSON tuples. Written once by executor_service in the apply transaction; immutable."
summary_basis: comment
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"orchestration\"][\"Tables\"][\"operation_receipt_target\"][\"Row\"]"
defined_in: ["20261031010000_operation_receipt_targets.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# orchestration.operation_receipt_target

table in domain `orchestration-ledger` — Normalized targets of one native operation receipt: each corpus/staging/temporal/evidence/knowledge/ranking/research row the apply created, reused (already present, not rewritten), superseded (closed) or staged, with its role, the proposal that touched it, the entity (id and kind) for corpus rows and the claim for evidence rows. target_id is text because some targets are composite JSON tuples. Written once by executor_service in the apply transaction; immutable..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | PK; unique (tenant_id, receipt_id, target_schema, target_table, target_id, role) |
| 2 | `receipt_id` | `uuid` | no | — | PK; unique (tenant_id, receipt_id, target_schema, target_table, target_id, role); FK → [`orchestration.operation_receipt`](operation_receipt.md).id |
| 3 | `ordinal` | `integer` | no | — | PK |
| 4 | `target_schema` | `text` | no | — | unique (tenant_id, receipt_id, target_schema, target_table, target_id, role) |
| 5 | `target_table` | `text` | no | — | unique (tenant_id, receipt_id, target_schema, target_table, target_id, role) |
| 6 | `target_id` | `text` | no | — | unique (tenant_id, receipt_id, target_schema, target_table, target_id, role) |
| 7 | `entity_id` | `uuid` | yes | — | — |
| 8 | `entity_kind` | `text` | yes | — | FK → [`taxonomy.entity_kind`](../taxonomy/entity_kind.md).code |
| 9 | `role` | `text` | no | — | unique (tenant_id, receipt_id, target_schema, target_table, target_id, role) |
| 10 | `action` | `text` | no | — | — |
| 11 | `proposal_id` | `text` | yes | — | — |
| 12 | `claim_id` | `uuid` | yes | — | — |

## Constraints

- PK (tenant_id, receipt_id, ordinal)
- unique (tenant_id, receipt_id, target_schema, target_table, target_id, role)
- check `operation_receipt_target_action_check`: `(action = ANY (ARRAY['created'::text, 'reused'::text, 'superseded'::text, 'staged'::text]))`
- check `operation_receipt_target_check`: `((entity_id IS NULL) = (entity_kind IS NULL))`
- check `operation_receipt_target_ordinal_check`: `(ordinal >= 0)`
- check `operation_receipt_target_role_check`: `(role = ANY (ARRAY['subject'::text, 'canonical'::text, 'supporting'::text, 'provenance'::text, 'staging'::text, 'projection'::text]))`
- check `operation_receipt_target_target_id_check`: `(btrim(target_id) <> ''::text)`
- check `operation_receipt_target_target_schema_check`: `(target_schema = ANY (ARRAY['corpus'::text, 'staging'::text, 'temporal'::text, 'evidence'::text, 'knowledge'::text, 'ranking'::text, 'resea…`
- check `operation_receipt_target_target_table_check`: `(btrim(target_table) <> ''::text)`

## Relationships

Outbound: `entity_kind` → [`taxonomy.entity_kind`](../taxonomy/entity_kind.md)`.code`; `receipt_id` → [`orchestration.operation_receipt`](operation_receipt.md)`.id`; `tenant_id,claim_id` → [`evidence.claim`](../evidence/claim.md)`.tenant_id,id`; `tenant_id,entity_id,entity_kind` → [`corpus.entity`](../corpus/entity.md)`.tenant_id,id,kind`.
Inbound: none.
Polymorphic: `entity_kind` selects one of 36 typed tables listed in [`taxonomy.entity_kind`](../../vocabularies/taxonomy.entity_kind.md) (`canonical_table`) — basis: vocabulary taxonomy.entity_kind.canonical_table + FK operation_receipt_target_entity_kind_fkey.

## Indexes

`operation_receipt_target_entity` where `(entity_id IS NOT NULL)`; `operation_receipt_target_lookup`; `operation_receipt_target_tenant_id_receipt_id_target_schema_key` unique

## Triggers

- `receipt_target_guard` → [`orchestration.guard_receipt_target`](../../functions/orchestration/guard_receipt_target.md)
- `receipt_target_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled and forced.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: SELECT; `executor_service`: INSERT, SELECT; `pipeline_agent`: SELECT; `service_role`: INSERT, SELECT. None: `anon`, `app_reader`, `authenticated`, `verifier_agent`.

## Read paths

- Exposed through: [`orchestration.mission_run_effects`](mission_run_effects.md).
- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["orchestration"]["Tables"]["operation_receipt_target"]["Insert"]`; row: `Database["orchestration"]["Tables"]["operation_receipt_target"]["Row"]`; update: `Database["orchestration"]["Tables"]["operation_receipt_target"]["Update"]`

Defined in: `20261031010000_operation_receipt_targets.sql`.
