---
id: "rel:temporal.event"
kind: table
schema: temporal
name: event
domain: temporal-facts
aliases: [event identity]
tokens: [temporal, event, temporal.event, id, tenant_id, kind, subject_entity_id, object_entity_id, relationship_id, dedupe_key, created_at]
summary: "Event identity (kind, subject, optional object/relationship, dedupe_key)."
summary_basis: curated
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"temporal\"][\"Tables\"][\"event\"][\"Row\"]"
defined_in: ["20260912010400_km_04_temporal.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# temporal.event

table in domain `temporal-facts`.

> curated (model_assisted, unreviewed) — Event identity (kind, subject, optional object/relationship, dedupe_key).

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id); unique (tenant_id, kind, subject_entity_id, object_entity_id, relationship_id, dedupe_key) |
| 3 | `kind` | `text` | no | — | unique (tenant_id, kind, subject_entity_id, object_entity_id, relationship_id, dedupe_key); FK → [`temporal.event_kind`](event_kind.md).code |
| 4 | `subject_entity_id` | `uuid` | no | — | unique (tenant_id, kind, subject_entity_id, object_entity_id, relationship_id, dedupe_key); FK → [`corpus.entity`](../corpus/entity.md).id |
| 5 | `object_entity_id` | `uuid` | yes | — | unique (tenant_id, kind, subject_entity_id, object_entity_id, relationship_id, dedupe_key); FK → [`corpus.entity`](../corpus/entity.md).id |
| 6 | `relationship_id` | `uuid` | yes | — | unique (tenant_id, kind, subject_entity_id, object_entity_id, relationship_id, dedupe_key); FK → [`corpus.relationship`](../corpus/relationship.md).id |
| 7 | `dedupe_key` | `text` | yes | — | unique (tenant_id, kind, subject_entity_id, object_entity_id, relationship_id, dedupe_key); _curated:_ Optional natural key so the same announcement is not inserted twice. |
| 8 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, kind, subject_entity_id, object_entity_id, relationship_id, dedupe_key)

## Relationships

Outbound: `kind` → [`temporal.event_kind`](event_kind.md)`.code`; `object_entity_id` → [`corpus.entity`](../corpus/entity.md)`.id` (+tenant); `relationship_id` → [`corpus.relationship`](../corpus/relationship.md)`.id` (+tenant); `subject_entity_id` → [`corpus.entity`](../corpus/entity.md)`.id` (+tenant).
Inbound: [`temporal.event_occurrence`](event_occurrence.md).event_id, [`temporal.segment`](segment.md).caused_by_event_id.

## Indexes

`event_tenant_id_id_key` unique; `event_tenant_id_kind_subject_entity_id_object_entity_id_rel_key` unique

## Triggers

_None._

## Row-level security

Enabled.
- `km_tenant_access` (ALL) for `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: SELECT; `executor_service`: SELECT; `pipeline_agent`: SELECT; `service_role`: SELECT; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Named queries: `q:entity.card`, `q:entity.timeline`, `q:entity.what_changed`, `q:events.current_for_entity`.
- Exposed through: [`api.events_current`](../api/events_current.md).
- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- No direct DML for any agent role.
- Via functions (best effort): [`temporal.assert_event`](../../functions/temporal/assert_event.md).

## TypeScript

insert: `Database["temporal"]["Tables"]["event"]["Insert"]`; row: `Database["temporal"]["Tables"]["event"]["Row"]`; update: `Database["temporal"]["Tables"]["event"]["Update"]`

## Examples

Current occurrences for a subject

```bash
knowledge db query events.current_for_entity --param entity_id=0192b000-0000-7000-8000-000000000001
```
Joins through event_occurrence where k_to is null.

Defined in: `20260912010400_km_04_temporal.sql`.
