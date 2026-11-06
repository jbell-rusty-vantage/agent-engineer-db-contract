---
id: "rel:api.entities"
kind: view
schema: api
name: entities
domain: api-surface
aliases: [entities view]
tokens: [api, entities, api.entities, id, tenant_id, kind, display_name, slug, summary, lifecycle, merged_into_id, projection_knowledge_seq, created_by_receipt_id, created_at, updated_at, aliases]
summary: Invoker view of tenant entities plus alias array.
summary_basis: curated
rls: disabled
readers: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"api\"][\"Views\"][\"entities\"][\"Row\"]"
defined_in: ["20260912011000_km_10_api.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# api.entities

view in domain `api-surface`.

> curated (model_assisted, unreviewed) — Invoker view of tenant entities plus alias array.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | yes | — | — |
| 2 | `tenant_id` | `uuid` | yes | — | — |
| 3 | `kind` | `text` | yes | — | — |
| 4 | `display_name` | `text` | yes | — | — |
| 5 | `slug` | `text` | yes | — | — |
| 6 | `summary` | `text` | yes | — | — |
| 7 | `lifecycle` | `text` | yes | — | — |
| 8 | `merged_into_id` | `uuid` | yes | — | — |
| 9 | `projection_knowledge_seq` | `bigint` | yes | — | — |
| 10 | `created_by_receipt_id` | `uuid` | yes | — | — |
| 11 | `created_at` | `timestamp with time zone` | yes | — | — |
| 12 | `updated_at` | `timestamp with time zone` | yes | — | — |
| 13 | `aliases` | `text[]` | yes | — | _curated:_ text[] from api.entity_aliases. |

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

- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

Views are not written.

## View definition

See [details](entities.details.md).

## TypeScript

row: `Database["api"]["Views"]["entities"]["Row"]`

## Examples

Prefer resolve over scanning the view

```bash
knowledge db query entity.resolve --param text=OpenAI
```
The view is the PostgREST surface; agents should use named queries.

Defined in: `20260912011000_km_10_api.sql`.
