---
id: "rel:guidance.item_subject"
kind: table
schema: guidance
name: item_subject
domain: guidance
lens: corpus
aliases: []
tokens: [guidance, item_subject, guidance.item_subject, tenant_id, item_id, entity_id, role]
summary: "Which entities an item is about and in which role (subject, component, version, alternative)."
summary_basis: comment
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"guidance\"][\"Tables\"][\"item_subject\"][\"Row\"]"
defined_in: []
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
---
# guidance.item_subject

table in domain `guidance`, lens `corpus` — Which entities an item is about and in which role (subject, component, version, alternative)..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | PK |
| 2 | `item_id` | `uuid` | no | — | PK; FK → [`guidance.item`](item.md).id |
| 3 | `entity_id` | `uuid` | no | — | PK; FK → [`catalog.entity`](../catalog/entity.md).id |
| 4 | `role` | `text` | no | — | PK |

## Constraints

- PK (tenant_id, item_id, entity_id, role)

## Relationships

Outbound: `entity_id` → [`catalog.entity`](../catalog/entity.md)`.id` (+tenant); `item_id` → [`guidance.item`](item.md)`.id` (+tenant).
Inbound: none.

## Indexes

_None._

## Triggers

_None._

## Row-level security

Enabled.
- `km_tenant_access` (ALL) for `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: SELECT; `executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: SELECT; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Named queries: `q:catalog.concepts`, `q:guidance.items`.
- Exposed through: [`api.concepts`](../api/concepts.md), [`api.guidance_items`](../api/guidance_items.md).
- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["guidance"]["Tables"]["item_subject"]["Insert"]`; row: `Database["guidance"]["Tables"]["item_subject"]["Row"]`; update: `Database["guidance"]["Tables"]["item_subject"]["Update"]`

Defined in: unknown.
