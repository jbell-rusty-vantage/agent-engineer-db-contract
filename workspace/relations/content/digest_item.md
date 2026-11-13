---
id: "rel:content.digest_item"
kind: table
schema: content
name: digest_item
domain: content
lens: corpus
aliases: [digest item, key point]
tokens: [content, digest_item, content.digest_item, id, tenant_id, digest_id, ordinal, item_kind, text, payload, node_ids, entity_id, claim_id, unit_change_id, confidence]
summary: "One digest item — key point, entity role, assertion reference, change, open question, limitation or research direction — anchored to unit node ids."
summary_basis: curated
rls: enabled
readers: [app_reader, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"content\"][\"Tables\"][\"digest_item\"][\"Row\"]"
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", part2_content.sql]
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# content.digest_item

table in domain `content`, lens `corpus` — One digest item: a key point, an entity role, a reference to an assertion/claim, a change, an open question, a limitation or a cautious research direction, each anchored to unit node ids..

> curated (model_assisted, unreviewed) — One digest item — key point, entity role, assertion reference, change, open question, limitation or research direction — anchored to unit node ids.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | — |
| 3 | `digest_id` | `uuid` | no | — | unique (digest_id, ordinal); FK → [`content.document_digest`](document_digest.md).id |
| 4 | `ordinal` | `integer` | no | — | unique (digest_id, ordinal) |
| 5 | `item_kind` | `text` | no | — | key_point \| entity_role \| assertion_ref \| change \| open_question \| limitation \| research_direction \| problem \| method \| key_result \| artifact \| practitioner_change \| recommendation (what a source recommends doing, kept apart from what it asserts; loop 3).; _curated:_ key_point, entity_role, assertion, change, open_question, limitation, research_direction. |
| 6 | `text` | `text` | yes | — | — |
| 7 | `payload` | `jsonb` | no | `'{}'::jsonb` | — |
| 8 | `node_ids` | `uuid[]` | no | `'{}'::uuid[]` | _curated:_ content.document_node ids the item is anchored to; cite these, not the text. |
| 9 | `entity_id` | `uuid` | yes | — | FK → [`catalog.entity`](../catalog/entity.md).id |
| 10 | `claim_id` | `uuid` | yes | — | FK → [`evidence.claim`](../evidence/claim.md).id; _curated:_ For assertion items, the evidence.claim it references. |
| 11 | `unit_change_id` | `uuid` | yes | — | FK → [`content.unit_change`](unit_change.md).id |
| 12 | `confidence` | `numeric` | yes | — | — |

## Constraints

- PK (id)
- unique (digest_id, ordinal)
- check `digest_item_confidence_check`: `((confidence >= (0)::numeric) AND (confidence <= (1)::numeric))`
- check `digest_item_item_kind_check`: `(item_kind = ANY (ARRAY['key_point'::text, 'entity_role'::text, 'assertion_ref'::text, 'change'::text, 'open_question'::text, 'limitation':…`
- check `digest_item_ordinal_check`: `(ordinal >= 0)`

## Relationships

Outbound: `claim_id` → [`evidence.claim`](../evidence/claim.md)`.id`; `digest_id` → [`content.document_digest`](document_digest.md)`.id` on delete restrict; `entity_id` → [`catalog.entity`](../catalog/entity.md)`.id`; `unit_change_id` → [`content.unit_change`](unit_change.md)`.id`.
Inbound: [`retrieval.projection_target`](../retrieval/projection_target.md).digest_item_id.
Polymorphic target of: [`retrieval.projection_target`](../retrieval/projection_target.md) (check constraint projection_target_exactly_one).

## Indexes

`digest_item_digest_id_ordinal_key` unique

## Triggers

_None._

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`app_reader`: SELECT; `control_plane`: SELECT; `executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: SELECT; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `authenticated`.

## Read paths

- Named queries: `q:content.document_digest`.
- Exposed through: [`api.digest_items`](../api/digest_items.md).
- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["content"]["Tables"]["digest_item"]["Insert"]`; row: `Database["content"]["Tables"]["digest_item"]["Row"]`; update: `Database["content"]["Tables"]["digest_item"]["Update"]`

## Examples

Items with anchors

```bash
knowledge db query content.document_digest --param document_id=0192b000-0000-7000-8000-000000000001
```
node_ids column.

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `part2_content.sql`.
