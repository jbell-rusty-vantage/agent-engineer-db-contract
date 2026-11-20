---
id: "rel:guidance.item"
kind: table
schema: guidance
name: item
domain: guidance
lens: corpus
aliases: [guidance item, engineering record, knowledge record]
tokens: [guidance, item, guidance.item, id, tenant_id, kind, title, statement, scope, assurance_level, provenance_claim_id, created_by_receipt_id, created_at, payload, applies_to_version_ids, source_node_id]
summary: "One expert knowledge item typed by guidance.item_kind with assurance, provenance claim and a kind-validated payload."
summary_basis: curated
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"guidance\"][\"Tables\"][\"item\"][\"Row\"]"
defined_in: []
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# guidance.item

table in domain `guidance`, lens `corpus` — One expert knowledge item: kind (guidance.item_kind), statement, scope, assurance level, provenance claim and typed payload..

> curated (model_assisted, unreviewed) — One expert knowledge item typed by guidance.item_kind with assurance, provenance claim and a kind-validated payload.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id); unique (tenant_id, id, kind) |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id); unique (tenant_id, id, kind) |
| 3 | `kind` | `text` | no | — | unique (tenant_id, id, kind); FK → [`guidance.item_kind`](item_kind.md).code; _curated:_ FK-style code into guidance.item_kind; payload_schema validates payload. |
| 4 | `title` | `text` | no | — | — |
| 5 | `statement` | `text` | no | — | — |
| 6 | `scope` | `jsonb` | no | `'{}'::jsonb` | — |
| 7 | `assurance_level` | `text` | no | `'asserted'::text` | FK → [`guidance.assurance_level`](assurance_level.md).code; _curated:_ Code into guidance.assurance_level. |
| 8 | `provenance_claim_id` | `uuid` | yes | — | FK → [`evidence.claim`](../evidence/claim.md).id |
| 9 | `created_by_receipt_id` | `uuid` | no | — | FK → [`orchestration.operation_receipt`](../orchestration/operation_receipt.md).id |
| 10 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 11 | `payload` | `jsonb` | no | `'{}'::jsonb` | — |
| 12 | `applies_to_version_ids` | `uuid[]` | no | `'{}'::uuid[]` | _curated:_ Software or model versions the item holds for. |
| 13 | `source_node_id` | `uuid` | yes | — | _curated:_ Typed unit the item was learned from. |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, id, kind)

## Relationships

Outbound: `kind` → [`guidance.item_kind`](item_kind.md)`.code`; `assurance_level` → [`guidance.assurance_level`](assurance_level.md)`.code`; `created_by_receipt_id` → [`orchestration.operation_receipt`](../orchestration/operation_receipt.md)`.id` (deferrable); `provenance_claim_id` → [`evidence.claim`](../evidence/claim.md)`.id` (+tenant).
Inbound: [`authoring.release_item`](../authoring/release_item.md).record_id, [`authoring.revision_binding`](../authoring/revision_binding.md).record_id, [`evidence.claim_record`](../evidence/claim_record.md).record_id, [`guidance.item_subject`](item_subject.md).item_id, [`inquiry.support`](../inquiry/support.md).record_id, [`retrieval.packet_member`](../retrieval/packet_member.md).guidance_item_id, [`retrieval.projection_target`](../retrieval/projection_target.md).record_id, [`taxonomy.assignment`](../taxonomy/assignment.md).target_record_id.
Polymorphic target of: [`retrieval.projection_target`](../retrieval/projection_target.md) (check constraint projection_target_exactly_one), [`taxonomy.assignment`](../taxonomy/assignment.md) (check constraint assignment_one_target_ck).

## Indexes

`record_tenant_id_id_key` unique; `record_tenant_id_id_kind_key` unique

## Triggers

- `record_receipt_tenant` → [`catalog.check_receipt_tenant`](../../functions/catalog/check_receipt_tenant.md) (constraint trigger)
- `record_requires_admission` → [`verification.require_receipt_admission`](../../functions/verification/require_receipt_admission.md) (constraint trigger, deferred)

## Row-level security

Enabled.
- `km_tenant_access` (ALL) for `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: SELECT; `executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: SELECT; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Named queries: `q:guidance.items`.
- Exposed through: [`api.guidance_items`](../api/guidance_items.md).
- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["guidance"]["Tables"]["item"]["Insert"]`; row: `Database["guidance"]["Tables"]["item"]["Row"]`; update: `Database["guidance"]["Tables"]["item"]["Update"]`

## Examples

Items of one kind

```bash
knowledge db query guidance.items --param entity_id=null --param kind=failure_mode --param limit=50 --param text=null
```
api.guidance_items adds subject_entity_ids.

Defined in: unknown.
