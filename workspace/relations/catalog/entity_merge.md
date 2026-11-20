---
id: "rel:catalog.entity_merge"
kind: table
schema: catalog
name: entity_merge
domain: identity
lens: corpus
aliases: [merge]
tokens: [catalog, entity_merge, catalog.entity_merge, id, tenant_id, from_entity_id, to_entity_id, reason, receipt_id, created_at, reason_code, note, proposal_id, knowledge_seq, undone_at, undone_receipt_id]
summary: Durable merge of two entities; loser becomes lifecycle merged.
summary_basis: curated
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"catalog\"][\"Tables\"][\"entity_merge\"][\"Row\"]"
defined_in: []
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# catalog.entity_merge

table in domain `identity`, lens `corpus` — A merge of two records that were one thing (our mistake, never a merger in the world). Written by catalog.merge_entities; what moved is in catalog.identity_move; undone_at marks a merge that was reversed..

> curated (model_assisted, unreviewed) — Durable merge of two entities; loser becomes lifecycle merged.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id) |
| 3 | `from_entity_id` | `uuid` | no | — | FK → [`catalog.entity`](entity.md).id; _curated:_ Loser; must differ from to_entity_id. |
| 4 | `to_entity_id` | `uuid` | no | — | FK → [`catalog.entity`](entity.md).id |
| 5 | `reason` | `text` | no | — | — |
| 6 | `receipt_id` | `uuid` | no | — | FK → [`orchestration.operation_receipt`](../orchestration/operation_receipt.md).id; _curated:_ Required. |
| 7 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 8 | `reason_code` | `text` | yes | — | FK → [`temporal.correction_reason`](../temporal/correction_reason.md).code |
| 9 | `note` | `text` | yes | — | — |
| 10 | `proposal_id` | `uuid` | yes | — | FK → [`catalog.proposal`](proposal.md).id |
| 11 | `knowledge_seq` | `bigint` | yes | — | — |
| 12 | `undone_at` | `timestamp with time zone` | yes | — | — |
| 13 | `undone_receipt_id` | `uuid` | yes | — | FK → [`orchestration.operation_receipt`](../orchestration/operation_receipt.md).id |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `entity_merge_check`: `(from_entity_id <> to_entity_id)`

## Relationships

Outbound: `from_entity_id` → [`catalog.entity`](entity.md)`.id` (+tenant); `proposal_id` → [`catalog.proposal`](proposal.md)`.id`; `reason_code` → [`temporal.correction_reason`](../temporal/correction_reason.md)`.code`; `receipt_id` → [`orchestration.operation_receipt`](../orchestration/operation_receipt.md)`.id`; `to_entity_id` → [`catalog.entity`](entity.md)`.id` (+tenant); `undone_receipt_id` → [`orchestration.operation_receipt`](../orchestration/operation_receipt.md)`.id`.
Inbound: [`catalog.identity_move`](identity_move.md).merge_id, [`evaluation.review_task`](../evaluation/review_task.md).entity_merge_id.
Polymorphic target of: [`catalog.identity_move`](identity_move.md) (check constraint identity_move_one_parent), [`evaluation.review_task`](../evaluation/review_task.md) (check constraint review_task_exactly_one_subject).

## Indexes

`entity_merge_tenant_id_id_key` unique

## Triggers

_None._

## Row-level security

Enabled.
- `km_tenant_access` (ALL) for `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: SELECT; `executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: SELECT; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Named queries: `q:facts.changes_since`.
- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`.
- Via functions (best effort): [`catalog.merge_entities`](../../functions/catalog/merge_entities.md), [`catalog.undo_merge`](../../functions/catalog/undo_merge.md).

## TypeScript

insert: `Database["catalog"]["Tables"]["entity_merge"]["Insert"]`; row: `Database["catalog"]["Tables"]["entity_merge"]["Row"]`; update: `Database["catalog"]["Tables"]["entity_merge"]["Update"]`

## Examples

Card of the surviving entity

```bash
knowledge db query entity.card --param entity_id=0192b000-0000-7000-8000-000000000001
```
Follow merged_into_id if you still hold the loser id.

Defined in: unknown.
