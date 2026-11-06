---
id: "rel:api.current_relationships"
kind: view
schema: api
name: current_relationships
domain: api-surface
aliases: [current relationships view]
tokens: [api, current_relationships, api.current_relationships, id, tenant_id, kind, from_entity_id, to_entity_id, qualifier, episode, properties, primary_claim_id, k_from, k_to, created_at]
summary: "Current relationships, hiding inactive temporal edges."
summary_basis: curated
rls: disabled
readers: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"api\"][\"Views\"][\"current_relationships\"][\"Row\"]"
defined_in: ["20260912011000_km_10_api.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# api.current_relationships

view in domain `api-surface`.

> curated (model_assisted, unreviewed) — Current relationships, hiding inactive temporal edges.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | yes | — | — |
| 2 | `tenant_id` | `uuid` | yes | — | — |
| 3 | `kind` | `text` | yes | — | — |
| 4 | `from_entity_id` | `uuid` | yes | — | — |
| 5 | `to_entity_id` | `uuid` | yes | — | — |
| 6 | `qualifier` | `text` | yes | — | — |
| 7 | `episode` | `integer` | yes | — | — |
| 8 | `properties` | `jsonb` | yes | — | — |
| 9 | `primary_claim_id` | `uuid` | yes | — | — |
| 10 | `k_from` | `bigint` | yes | — | — |
| 11 | `k_to` | `bigint` | yes | — | _curated:_ Always null in this view. |
| 12 | `created_at` | `timestamp with time zone` | yes | — | — |

## Constraints

_None._

## Relationships

Outbound: none.
Inbound: none.

## Indexes

_None._

## Triggers

_None._

## Row-level security

Disabled.

## Grants

`app_reader`: SELECT; `authenticated`: SELECT; `control_plane`: SELECT; `executor_service`: SELECT; `pipeline_agent`: SELECT; `service_role`: SELECT; `verifier_agent`: SELECT. None: `anon`.

## Read paths

- Named queries: `q:relationships.current_by_kind`.
- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

Views are not written.

## View definition

```sql
SELECT id,
    tenant_id,
    kind,
    from_entity_id,
    to_entity_id,
    qualifier,
    episode,
    properties,
    primary_claim_id,
    k_from,
    k_to,
    created_at
   FROM api.current_relationship_rows() current_relationship_rows(id, tenant_id, kind, from_entity_id, to_entity_id, qualifier, episode, properties, primary_claim_id, k_from, k_to, created_at);
```

## TypeScript

row: `Database["api"]["Views"]["current_relationships"]["Row"]`

## Examples

Current develops

```bash
knowledge db query relationships.current_by_kind --param entity_id=null --param kind=develops --param limit=50
```
Replay a past head with entity.relationships and p_k.

Defined in: `20260912011000_km_10_api.sql`.
