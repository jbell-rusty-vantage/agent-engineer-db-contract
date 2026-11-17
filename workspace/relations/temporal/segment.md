---
id: "rel:temporal.segment"
kind: table
schema: temporal
name: segment
domain: temporal-facts
lens: corpus
aliases: [fact, temporal fact, state segment]
tokens: [temporal, segment, temporal.segment, id, tenant_id, stream_id, valid_during, belief, temporal_basis, status, amount, currency, unit, ref_entity_id, payload, extent_id, caused_by_event_id, replaces_segment_id, primary_claim_id, k_from, k_to, created_at]
summary: "A fact on a stream: world interval valid_during, knowledge interval [k_from,k_to). One home for every number."
summary_basis: curated
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"temporal\"][\"Tables\"][\"segment\"][\"Row\"]"
defined_in: ["20260912010400_km_04_temporal.sql"]
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# temporal.segment

table in domain `temporal-facts`, lens `corpus`.

> curated (model_assisted, unreviewed) — A fact on a stream: world interval valid_during, knowledge interval [k_from,k_to). One home for every number.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id) |
| 3 | `stream_id` | `uuid` | no | — | FK → [`temporal.stream`](stream.md).id |
| 4 | `valid_during` | `tstzrange` | no | — | _curated:_ World interval [), bounded below, not empty. |
| 5 | `belief` | `text` | no | `'accepted'::text` | — |
| 6 | `temporal_basis` | `text` | no | — | _curated:_ explicit and carry_forward require extent_id. |
| 7 | `status` | `text` | yes | — | — |
| 8 | `amount` | `numeric(20,6)` | yes | — | — |
| 9 | `currency` | `character(3)` | yes | — | — |
| 10 | `unit` | `text` | yes | — | _curated:_ Must be in stream_kind.unit_values when that list is present. |
| 11 | `ref_entity_id` | `uuid` | yes | — | FK → [`catalog.entity`](../catalog/entity.md).id |
| 12 | `payload` | `jsonb` | no | `'{}'::jsonb` | _curated:_ Validated by stream_kind.payload_schema; offering_price requires meter. |
| 13 | `extent_id` | `uuid` | yes | — | FK → [`temporal.extent`](extent.md).id |
| 14 | `caused_by_event_id` | `uuid` | yes | — | FK → [`temporal.event`](event.md).id |
| 15 | `replaces_segment_id` | `uuid` | yes | — | FK → [`temporal.segment`](segment.md).id; _curated:_ Set by assert_state when splitting or replacing. |
| 16 | `primary_claim_id` | `uuid` | yes | — | FK → [`evidence.claim`](../evidence/claim.md).id |
| 17 | `k_from` | `bigint` | no | — | — |
| 18 | `k_to` | `bigint` | yes | — | _curated:_ Null means current knowledge; closure only via helpers. |
| 19 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- **exclusion** `segment_stream_id_valid_during_excl`: `EXCLUDE USING gist (stream_id WITH =, valid_during WITH &&) WHERE (k_to IS NULL)`
- 6 check constraints; see [details](segment.details.md)

## Relationships

12 outbound and 4 inbound foreign keys; full list in [details](segment.details.md).

## Indexes

4 indexes; see [details](segment.details.md).

## Triggers

3 triggers; see [details](segment.details.md).

## Row-level security

Enabled; 1 policies in [details](segment.details.md).

## Grants

`control_plane`: SELECT; `executor_service`: SELECT; `pipeline_agent`: SELECT; `service_role`: SELECT; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Named queries: `q:catalog.benchmark_scores`, `q:catalog.concepts`, `q:catalog.events`, `q:catalog.model_offerings`, `q:catalog.model_offerings_at`, `q:catalog.models`, `q:catalog.models_at`, `q:catalog.organizations`, `q:catalog.papers`, `q:catalog.people`, `q:catalog.software`, `q:catalog.talks`, `q:entity.at`, `q:entity.relationships`, `q:entity.timeline`, `q:entity.what_changed`, `q:facts.changes_since`, `q:facts.current_by_stream`, `q:facts.history_for_stream`, `q:facts.locators`, `q:facts.price_history`, `q:relationships.current_by_kind`.
- Exposed through: [`api.benchmark_scores`](../api/benchmark_scores.md), [`api.capabilities`](../api/capabilities.md), [`api.compute_devices`](../api/compute_devices.md), [`api.compute_offerings`](../api/compute_offerings.md), [`api.concepts`](../api/concepts.md), [`api.current_facts`](../api/current_facts.md), [`api.current_relationships`](../api/current_relationships.md), [`api.events`](../api/events.md), [`api.model_offerings`](../api/model_offerings.md), [`api.models`](../api/models.md), [`api.organizations`](../api/organizations.md), [`api.papers`](../api/papers.md), [`api.people`](../api/people.md), [`api.protocol_versions`](../api/protocol_versions.md), [`api.registry_listings`](../api/registry_listings.md), [`api.software`](../api/software.md), [`api.talks`](../api/talks.md).
- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- No direct DML for any agent role.
- Via functions (best effort): [`temporal.assert_state`](../../functions/temporal/assert_state.md), [`temporal.close_segment`](../../functions/temporal/close_segment.md).

## TypeScript

insert: `Database["temporal"]["Tables"]["segment"]["Insert"]`; row: `Database["temporal"]["Tables"]["segment"]["Row"]`; update: `Database["temporal"]["Tables"]["segment"]["Update"]`

## Examples

Input price history of an offering with both clocks

```bash
knowledge db query facts.price_history --param meter=input_tokens --param offering_id=0192b000-0000-7000-8000-000000000001
```
Includes superseded beliefs (k_to set).

Defined in: `20260912010400_km_04_temporal.sql`.
