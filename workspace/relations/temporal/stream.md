---
id: "rel:temporal.stream"
kind: table
schema: temporal
name: stream
domain: temporal-facts
aliases: [fact series, stream slot]
tokens: [temporal, stream, temporal.stream, id, tenant_id, kind, subject_entity_id, subject_relationship_id, scope_key, created_at]
summary: "Identity of a fact series, unique on kind, subject, and scope_key."
summary_basis: curated
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"temporal\"][\"Tables\"][\"stream\"][\"Row\"]"
defined_in: ["20260912010400_km_04_temporal.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# temporal.stream

table in domain `temporal-facts`.

> curated (model_assisted, unreviewed) — Identity of a fact series, unique on kind, subject, and scope_key.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id); unique (tenant_id, kind, subject_entity_id, subject_relationship_id, scope_key) |
| 3 | `kind` | `text` | no | — | unique (tenant_id, kind, subject_entity_id, subject_relationship_id, scope_key); FK → [`temporal.stream_kind`](stream_kind.md).code |
| 4 | `subject_entity_id` | `uuid` | yes | — | unique (tenant_id, kind, subject_entity_id, subject_relationship_id, scope_key); FK → [`corpus.entity`](../corpus/entity.md).id; _curated:_ Exactly one of subject_entity_id or subject_relationship_id is set. |
| 5 | `subject_relationship_id` | `uuid` | yes | — | unique (tenant_id, kind, subject_entity_id, subject_relationship_id, scope_key); FK → [`corpus.relationship`](../corpus/relationship.md).id |
| 6 | `scope_key` | `text` | no | `''::text` | unique (tenant_id, kind, subject_entity_id, subject_relationship_id, scope_key); _curated:_ Distinguishes parallel series; default empty string. Not validated against any convention: a correction reuses the existing series key; a new price series defaults to the unit. |
| 7 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, kind, subject_entity_id, subject_relationship_id, scope_key)
- check `stream_check`: `(num_nonnulls(subject_entity_id, subject_relationship_id) = 1)`

## Relationships

Outbound: `kind` → [`temporal.stream_kind`](stream_kind.md)`.code`; `subject_entity_id` → [`corpus.entity`](../corpus/entity.md)`.id` (+tenant); `subject_relationship_id` → [`corpus.relationship`](../corpus/relationship.md)`.id` (+tenant).
Inbound: [`temporal.segment`](segment.md).stream_id.
Polymorphic: exactly one of `subject_entity_id`, `subject_relationship_id` → [`corpus.entity`](../corpus/entity.md) | [`corpus.relationship`](../corpus/relationship.md) — basis: check constraint stream_check.

## Indexes

`stream_tenant_id_id_key` unique; `stream_tenant_id_kind_subject_entity_id_subject_relationshi_key` unique

## Triggers

_None._

## Row-level security

Enabled.
- `km_tenant_access` (ALL) for `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: SELECT; `executor_service`: SELECT; `pipeline_agent`: SELECT; `service_role`: SELECT; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Named queries: `q:entity.at`, `q:entity.relationships`, `q:entity.timeline`, `q:entity.what_changed`, `q:facts.current_by_stream`, `q:facts.history_for_stream`, `q:relationships.current_by_kind`.
- Exposed through: [`api.current_facts`](../api/current_facts.md), [`api.current_relationships`](../api/current_relationships.md).
- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- No direct DML for any agent role.
- Via functions (best effort): [`temporal.assert_state`](../../functions/temporal/assert_state.md).

## TypeScript

insert: `Database["temporal"]["Tables"]["stream"]["Insert"]`; row: `Database["temporal"]["Tables"]["stream"]["Row"]`; update: `Database["temporal"]["Tables"]["stream"]["Update"]`

## Examples

History on one stream slot

```bash
knowledge db query facts.history_for_stream --param entity_id=0192b000-0000-7000-8000-000000000001 --param limit=50 --param offset=0 --param scope_key=per_1m_input_tokens --param stream_kind=model_offering_price
```
Subject is the offering; scope_key is the price unit.

Defined in: `20260912010400_km_04_temporal.sql`.
