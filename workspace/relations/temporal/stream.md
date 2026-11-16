---
id: "rel:temporal.stream"
kind: table
schema: temporal
name: stream
domain: temporal-facts
lens: corpus
aliases: [fact series, stream slot]
tokens: [temporal, stream, temporal.stream, id, tenant_id, kind, subject_entity_id, subject_relationship_id, scope_key, created_at]
summary: "Identity of a fact series, unique on kind, subject, and scope_key."
summary_basis: curated
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"temporal\"][\"Tables\"][\"stream\"][\"Row\"]"
defined_in: ["20260912010400_km_04_temporal.sql"]
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# temporal.stream

table in domain `temporal-facts`, lens `corpus`.

> curated (model_assisted, unreviewed) — Identity of a fact series, unique on kind, subject, and scope_key.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id); unique (tenant_id, kind, subject_entity_id, subject_relationship_id, scope_key) |
| 3 | `kind` | `text` | no | — | unique (tenant_id, kind, subject_entity_id, subject_relationship_id, scope_key); FK → [`temporal.stream_kind`](stream_kind.md).code |
| 4 | `subject_entity_id` | `uuid` | yes | — | unique (tenant_id, kind, subject_entity_id, subject_relationship_id, scope_key); FK → [`catalog.entity`](../catalog/entity.md).id; _curated:_ Exactly one of subject_entity_id or subject_relationship_id is set. |
| 5 | `subject_relationship_id` | `uuid` | yes | — | unique (tenant_id, kind, subject_entity_id, subject_relationship_id, scope_key); FK → [`catalog.relationship`](../catalog/relationship.md).id |
| 6 | `scope_key` | `text` | no | `''::text` | unique (tenant_id, kind, subject_entity_id, subject_relationship_id, scope_key); _curated:_ Distinguishes parallel series; default empty string. Prices use meter\|tier\|region. Not validated against any convention: a correction reuses the existing series key. |
| 7 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, kind, subject_entity_id, subject_relationship_id, scope_key)
- check `stream_check`: `(num_nonnulls(subject_entity_id, subject_relationship_id) = 1)`

## Relationships

Outbound: `kind` → [`temporal.stream_kind`](stream_kind.md)`.code`; `subject_entity_id` → [`catalog.entity`](../catalog/entity.md)`.id` (+tenant); `subject_relationship_id` → [`catalog.relationship`](../catalog/relationship.md)`.id` (+tenant).
Inbound: [`temporal.segment`](segment.md).stream_id.
Polymorphic: exactly one of `subject_entity_id`, `subject_relationship_id` → [`catalog.entity`](../catalog/entity.md) | [`catalog.relationship`](../catalog/relationship.md) — basis: check constraint stream_check.

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

- Named queries: `q:catalog.benchmark_scores`, `q:catalog.concepts`, `q:catalog.events`, `q:catalog.model_offerings`, `q:catalog.model_offerings_at`, `q:catalog.models`, `q:catalog.models_at`, `q:catalog.organizations`, `q:catalog.papers`, `q:catalog.people`, `q:catalog.software`, `q:catalog.talks`, `q:entity.at`, `q:entity.relationships`, `q:entity.timeline`, `q:entity.what_changed`, `q:facts.changes_since`, `q:facts.current_by_stream`, `q:facts.history_for_stream`, `q:facts.locators`, `q:facts.price_history`, `q:relationships.current_by_kind`.
- Exposed through: [`api.benchmark_scores`](../api/benchmark_scores.md), [`api.capabilities`](../api/capabilities.md), [`api.compute_devices`](../api/compute_devices.md), [`api.compute_offerings`](../api/compute_offerings.md), [`api.concepts`](../api/concepts.md), [`api.current_facts`](../api/current_facts.md), [`api.current_relationships`](../api/current_relationships.md), [`api.events`](../api/events.md), [`api.model_offerings`](../api/model_offerings.md), [`api.models`](../api/models.md), [`api.organizations`](../api/organizations.md), [`api.papers`](../api/papers.md), [`api.people`](../api/people.md), [`api.protocol_versions`](../api/protocol_versions.md), [`api.registry_listings`](../api/registry_listings.md), [`api.software`](../api/software.md), [`api.talks`](../api/talks.md).
- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- No direct DML for any agent role.
- Via functions (best effort): [`temporal.assert_state`](../../functions/temporal/assert_state.md).

## TypeScript

insert: `Database["temporal"]["Tables"]["stream"]["Insert"]`; row: `Database["temporal"]["Tables"]["stream"]["Row"]`; update: `Database["temporal"]["Tables"]["stream"]["Update"]`

## Examples

History on one stream slot

```bash
knowledge db query facts.history_for_stream --param entity_id=0192b000-0000-7000-8000-000000000001 --param limit=50 --param offset=0 --param scope_key=input_tokens|| --param stream_kind=offering_price
```
Subject is the offering; scope_key is meter|tier|region.

Defined in: `20260912010400_km_04_temporal.sql`.
