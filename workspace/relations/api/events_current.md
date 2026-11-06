---
id: "rel:api.events_current"
kind: view
schema: api
name: events_current
domain: api-surface
aliases: [current events view]
tokens: [api, events_current, api.events_current, event_id, tenant_id, kind, subject_entity_id, object_entity_id, occurrence_id, occurred_during, occurrence_mode, payload]
summary: Current event occurrences for the tenant.
summary_basis: curated
rls: disabled
readers: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"api\"][\"Views\"][\"events_current\"][\"Row\"]"
defined_in: ["20260912011000_km_10_api.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# api.events_current

view in domain `api-surface`.

> curated (model_assisted, unreviewed) — Current event occurrences for the tenant.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `event_id` | `uuid` | yes | — | — |
| 2 | `tenant_id` | `uuid` | yes | — | — |
| 3 | `kind` | `text` | yes | — | — |
| 4 | `subject_entity_id` | `uuid` | yes | — | — |
| 5 | `object_entity_id` | `uuid` | yes | — | — |
| 6 | `occurrence_id` | `uuid` | yes | — | _curated:_ temporal.event_occurrence.id. |
| 7 | `occurred_during` | `tstzrange` | yes | — | — |
| 8 | `occurrence_mode` | `text` | yes | — | — |
| 9 | `payload` | `jsonb` | yes | — | — |

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

- Named queries: `q:events.current_for_entity`.
- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

Views are not written.

## View definition

```sql
SELECT event_id,
    tenant_id,
    kind,
    subject_entity_id,
    object_entity_id,
    occurrence_id,
    occurred_during,
    occurrence_mode,
    payload
   FROM api.current_event_rows() current_event_rows(event_id, tenant_id, kind, subject_entity_id, object_entity_id, occurrence_id, occurred_during, occurrence_mode, payload);
```

## TypeScript

row: `Database["api"]["Views"]["events_current"]["Row"]`

## Examples

Events for one subject

```bash
knowledge db query events.current_for_entity --param entity_id=0192b000-0000-7000-8000-000000000001
```
Filters the view by subject_entity_id.

Defined in: `20260912011000_km_10_api.sql`.
