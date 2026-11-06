---
id: "rel:corpus.entity_merge"
kind: table
schema: corpus
name: entity_merge
domain: identity
aliases: [merge]
tokens: [corpus, entity_merge, corpus.entity_merge, id, tenant_id, from_entity_id, to_entity_id, reason, receipt_id, created_at]
summary: Durable merge of two entities; loser becomes lifecycle merged.
summary_basis: curated
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"corpus\"][\"Tables\"][\"entity_merge\"][\"Row\"]"
defined_in: ["20260826000500_corpus.sql", "20260912010200_km_02_corpus_identity.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# corpus.entity_merge

table in domain `identity`.

> curated (model_assisted, unreviewed) — Durable merge of two entities; loser becomes lifecycle merged.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id) |
| 3 | `from_entity_id` | `uuid` | no | — | FK → [`corpus.entity`](entity.md).id; _curated:_ Loser; must differ from to_entity_id. |
| 4 | `to_entity_id` | `uuid` | no | — | FK → [`corpus.entity`](entity.md).id |
| 5 | `reason` | `text` | no | — | — |
| 6 | `receipt_id` | `uuid` | no | — | FK → [`orchestration.operation_receipt`](../orchestration/operation_receipt.md).id; _curated:_ Required. |
| 7 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `entity_merge_check`: `(from_entity_id <> to_entity_id)`

## Relationships

Outbound: `from_entity_id` → [`corpus.entity`](entity.md)`.id` (+tenant); `receipt_id` → [`orchestration.operation_receipt`](../orchestration/operation_receipt.md)`.id`; `to_entity_id` → [`corpus.entity`](entity.md)`.id` (+tenant).
Inbound: [`evaluation.review_task`](../evaluation/review_task.md).entity_merge_id.
Polymorphic target of: [`evaluation.review_task`](../evaluation/review_task.md) (check constraint review_task_exactly_one_subject).

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

- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["corpus"]["Tables"]["entity_merge"]["Insert"]`; row: `Database["corpus"]["Tables"]["entity_merge"]["Row"]`; update: `Database["corpus"]["Tables"]["entity_merge"]["Update"]`

## Examples

Card of the surviving entity

```bash
knowledge db query entity.card --param entity_id=0192b000-0000-7000-8000-000000000001
```
Follow merged_into_id if you still hold the loser id.

Defined in: `20260826000500_corpus.sql`, `20260912010200_km_02_corpus_identity.sql`.
