---
id: "rel:api.guidance_items"
kind: view
schema: api
name: guidance_items
domain: guidance
lens: corpus
aliases: [guidance table]
tokens: [api, guidance_items, api.guidance_items, id, tenant_id, kind, title, statement, scope, assurance_level, payload, provenance_claim_id, created_at, subject_entity_ids]
summary: L1 — expert guidance items with their subject entities.
summary_basis: curated
rls: disabled
readers: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"api\"][\"Views\"][\"guidance_items\"][\"Row\"]"
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", part1_renames.sql]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# api.guidance_items

view in domain `guidance`, lens `corpus` — L1 view: expert guidance items with their subject entities..

> curated (model_assisted, unreviewed) — L1 — expert guidance items with their subject entities.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | yes | — | — |
| 2 | `tenant_id` | `uuid` | yes | — | — |
| 3 | `kind` | `text` | yes | — | — |
| 4 | `title` | `text` | yes | — | — |
| 5 | `statement` | `text` | yes | — | — |
| 6 | `scope` | `jsonb` | yes | — | — |
| 7 | `assurance_level` | `text` | yes | — | _curated:_ Code from guidance.assurance_level. |
| 8 | `payload` | `jsonb` | yes | — | — |
| 9 | `provenance_claim_id` | `uuid` | yes | — | — |
| 10 | `created_at` | `timestamp with time zone` | yes | — | — |
| 11 | `subject_entity_ids` | `uuid[]` | yes | — | _curated:_ Entities the item is about (guidance.item_subject). |

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

- Named queries: `q:guidance.items`.
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
    payload,
    provenance_claim_id,
    created_at,
    ( SELECT array_agg(s.entity_id) AS array_agg
           FROM guidance.item_subject s
          WHERE s.item_id = i.id) AS subject_entity_ids
   FROM guidance.item i
  WHERE tenant_id = util.current_tenant_id();
```

## TypeScript

row: `Database["api"]["Views"]["guidance_items"]["Row"]`

## Examples

Guidance for an entity

```bash
knowledge db query guidance.items --param entity_id=null --param kind=null --param limit=50 --param text=null
```
Filter by kind (failure_mode, solution_pattern, …).

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `part1_renames.sql`.
