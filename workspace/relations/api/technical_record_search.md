---
id: "rel:api.technical_record_search"
kind: view
schema: api
name: technical_record_search
domain: api-surface
aliases: [technical records view]
tokens: [api, technical_record_search, api.technical_record_search, id, tenant_id, kind, title, statement, scope, assurance_level, provenance_claim_id, created_by_receipt_id, created_at]
summary: Invoker view of knowledge.record for app_reader.
summary_basis: curated
rls: disabled
readers: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"api\"][\"Views\"][\"technical_record_search\"][\"Row\"]"
defined_in: ["20260826001500_api_and_grants.sql", "20260912011000_km_10_api.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# api.technical_record_search

view in domain `api-surface`.

> curated (model_assisted, unreviewed) — Invoker view of knowledge.record for app_reader.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | yes | — | — |
| 2 | `tenant_id` | `uuid` | yes | — | — |
| 3 | `kind` | `text` | yes | — | — |
| 4 | `title` | `text` | yes | — | — |
| 5 | `statement` | `text` | yes | — | — |
| 6 | `scope` | `jsonb` | yes | — | — |
| 7 | `assurance_level` | `text` | yes | — | _curated:_ Copied from knowledge.record. |
| 8 | `provenance_claim_id` | `uuid` | yes | — | _curated:_ Backing claim when present. |
| 9 | `created_by_receipt_id` | `uuid` | yes | — | — |
| 10 | `created_at` | `timestamp with time zone` | yes | — | — |

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
SELECT id,
    tenant_id,
    kind,
    title,
    statement,
    scope,
    assurance_level,
    provenance_claim_id,
    created_by_receipt_id,
    created_at
   FROM knowledge.record;
```

## TypeScript

row: `Database["api"]["Views"]["technical_record_search"]["Row"]`

## Examples

Entity overview first

```bash
knowledge db query entity.card --param entity_id=0192b000-0000-7000-8000-000000000001
```
Record search is not yet a named-query catalog entry.

Defined in: `20260826001500_api_and_grants.sql`, `20260912011000_km_10_api.sql`.
