---
id: "rel:temporal.event_occurrence"
kind: table
schema: temporal
name: event_occurrence
domain: temporal-facts
aliases: [occurrence]
tokens: [temporal, event_occurrence, temporal.event_occurrence, id, tenant_id, event_id, occurred_during, occurrence_mode, belief, extent_id, primary_claim_id, payload, k_from, k_to, created_at]
summary: "K-stamped occurrence of an event (actual, scheduled, or cancelled)."
summary_basis: curated
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"temporal\"][\"Tables\"][\"event_occurrence\"][\"Row\"]"
defined_in: ["20260912010400_km_04_temporal.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# temporal.event_occurrence

table in domain `temporal-facts`.

> curated (model_assisted, unreviewed) — K-stamped occurrence of an event (actual, scheduled, or cancelled).

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id) |
| 3 | `event_id` | `uuid` | no | — | FK → [`temporal.event`](event.md).id |
| 4 | `occurred_during` | `tstzrange` | no | — | _curated:_ World interval [), bounded below. |
| 5 | `occurrence_mode` | `text` | no | — | _curated:_ actual, scheduled, or cancelled. |
| 6 | `belief` | `text` | no | `'accepted'::text` | — |
| 7 | `extent_id` | `uuid` | yes | — | FK → [`temporal.extent`](extent.md).id |
| 8 | `primary_claim_id` | `uuid` | yes | — | FK → [`evidence.claim`](../evidence/claim.md).id |
| 9 | `payload` | `jsonb` | no | `'{}'::jsonb` | — |
| 10 | `k_from` | `bigint` | no | — | — |
| 11 | `k_to` | `bigint` | yes | — | — |
| 12 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `event_occurrence_belief_check`: `(belief = ANY (ARRAY['accepted'::text, 'disputed'::text, 'unknown'::text]))`
- check `event_occurrence_check`: `((k_to IS NULL) OR (k_to > k_from))`
- check `event_occurrence_occurred_during_check`: `(NOT isempty(occurred_during))`
- check `event_occurrence_occurred_during_check1`: `(lower_inc(occurred_during) AND (NOT upper_inc(occurred_during)) AND (NOT lower_inf(occurred_during)))`
- check `event_occurrence_occurrence_mode_check`: `(occurrence_mode = ANY (ARRAY['actual'::text, 'scheduled'::text, 'cancelled'::text]))`

## Relationships

Outbound: `event_id` → [`temporal.event`](event.md)`.id` (+tenant); `extent_id` → [`temporal.extent`](extent.md)`.id` (+tenant); `primary_claim_id` → [`evidence.claim`](../evidence/claim.md)`.id` (+tenant).
Inbound: [`evidence.segment_support`](../evidence/segment_support.md).event_occurrence_id.
Polymorphic target of: [`evidence.segment_support`](../evidence/segment_support.md) (check constraint segment_support_check).

## Indexes

`event_occurrence_current_uq` unique where `(k_to IS NULL)`; `event_occurrence_tenant_id_id_key` unique

## Triggers

- `guard_k` → [`temporal.guard_k`](../../functions/temporal/guard_k.md)
- `sealed_batch` → [`temporal.require_sealed_batch`](../../functions/temporal/require_sealed_batch.md) (constraint trigger, deferred)
- `stamp_k` → [`temporal.stamp_k`](../../functions/temporal/stamp_k.md)

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

insert: `Database["temporal"]["Tables"]["event_occurrence"]["Insert"]`; row: `Database["temporal"]["Tables"]["event_occurrence"]["Row"]`; update: `Database["temporal"]["Tables"]["event_occurrence"]["Update"]`

## Examples

Current events view

```bash
knowledge db query events.current_for_entity --param entity_id=0192b000-0000-7000-8000-000000000001
```
One current occurrence per event.

Defined in: `20260912010400_km_04_temporal.sql`.
