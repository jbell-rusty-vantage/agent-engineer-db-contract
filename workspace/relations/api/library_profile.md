---
id: "rel:api.library_profile"
kind: view
schema: api
name: library_profile
domain: api-surface
aliases: [library profile view]
tokens: [api, library_profile, api.library_profile, id, tenant_id, kind, display_name, slug, summary, lifecycle, merged_into_id, projection_knowledge_seq, created_by_receipt_id, created_at, updated_at, ecosystem, package_name]
summary: Invoker view of library identities with ecosystem and package_name.
summary_basis: curated
rls: disabled
readers: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"api\"][\"Views\"][\"library_profile\"][\"Row\"]"
defined_in: ["20260826001500_api_and_grants.sql", "20260912011000_km_10_api.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# api.library_profile

view in domain `api-surface`.

> curated (model_assisted, unreviewed) — Invoker view of library identities with ecosystem and package_name.

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
| 13 | `ecosystem` | `text` | yes | — | _curated:_ Package ecosystem for the library. |
| 14 | `package_name` | `text` | yes | — | _curated:_ Canonical package name in that ecosystem. |

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

```sql
SELECT e.id,
    e.tenant_id,
    e.kind,
    e.display_name,
    e.slug,
    e.summary,
    e.lifecycle,
    e.merged_into_id,
    e.projection_knowledge_seq,
    e.created_by_receipt_id,
    e.created_at,
    e.updated_at,
    l.ecosystem,
    l.package_name
   FROM corpus.entity e
     JOIN corpus.library l ON l.id = e.id;
```

## TypeScript

row: `Database["api"]["Views"]["library_profile"]["Row"]`

## Examples

Resolve the library first

```bash
knowledge db query entity.resolve --param text=openai
```
Prefer entity.card after you have the id; this view is the PostgREST surface.

Defined in: `20260826001500_api_and_grants.sql`, `20260912011000_km_10_api.sql`.
