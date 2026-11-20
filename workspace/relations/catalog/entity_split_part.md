---
id: "rel:catalog.entity_split_part"
kind: table
schema: catalog
name: entity_split_part
domain: identity
lens: corpus
aliases: []
tokens: [catalog, entity_split_part, catalog.entity_split_part, tenant_id, split_id, to_entity_id]
summary: One record that a mixed record was split into.
summary_basis: comment
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"catalog\"][\"Tables\"][\"entity_split_part\"][\"Row\"]"
defined_in: ["20261119120000_build09_rv01_change_reasons_identity_proposals.sql"]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# catalog.entity_split_part

table in domain `identity`, lens `corpus` — One record that a mixed record was split into..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | — |
| 2 | `split_id` | `uuid` | no | — | PK; FK → [`catalog.entity_split`](entity_split.md).id |
| 3 | `to_entity_id` | `uuid` | no | — | PK; FK → [`catalog.entity`](entity.md).id |

## Constraints

- PK (split_id, to_entity_id)

## Relationships

Outbound: `split_id` → [`catalog.entity_split`](entity_split.md)`.id`; `to_entity_id` → [`catalog.entity`](entity.md)`.id`.
Inbound: none.

## Indexes

_None._

## Triggers

_None._

## Row-level security

Enabled.
- `km_tenant_access` (ALL) for `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: SELECT; `executor_service`: SELECT; `pipeline_agent`: SELECT; `service_role`: SELECT; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Named queries: `q:facts.changes_since`.
- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- No direct DML for any agent role.
- Via functions (best effort): [`catalog.split_entity`](../../functions/catalog/split_entity.md).

## TypeScript

insert: `Database["catalog"]["Tables"]["entity_split_part"]["Insert"]`; row: `Database["catalog"]["Tables"]["entity_split_part"]["Row"]`; update: `Database["catalog"]["Tables"]["entity_split_part"]["Update"]`

Defined in: `20261119120000_build09_rv01_change_reasons_identity_proposals.sql`.
