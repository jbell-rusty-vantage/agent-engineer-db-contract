---
id: "rel:temporal.segment"
kind: table
schema: temporal
name: segment
domain: temporal-facts
aliases: [fact, temporal fact, state segment]
tokens: [temporal, segment, temporal.segment, id, tenant_id, stream_id, valid_during, belief, temporal_basis, status, amount, currency, unit, ref_entity_id, payload, extent_id, caused_by_event_id, replaces_segment_id, primary_claim_id, k_from, k_to, created_at, specification_id]
summary: "A fact on a stream: world interval valid_during, knowledge interval [k_from,k_to)."
summary_basis: curated
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"temporal\"][\"Tables\"][\"segment\"][\"Row\"]"
defined_in: ["20260912010400_km_04_temporal.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# temporal.segment

table in domain `temporal-facts`.

> curated (model_assisted, unreviewed) — A fact on a stream: world interval valid_during, knowledge interval [k_from,k_to).

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
| 11 | `ref_entity_id` | `uuid` | yes | — | FK → [`corpus.entity`](../corpus/entity.md).id |
| 12 | `payload` | `jsonb` | no | `'{}'::jsonb` | — |
| 13 | `extent_id` | `uuid` | yes | — | FK → [`temporal.extent`](extent.md).id |
| 14 | `caused_by_event_id` | `uuid` | yes | — | FK → [`temporal.event`](event.md).id |
| 15 | `replaces_segment_id` | `uuid` | yes | — | FK → [`temporal.segment`](segment.md).id; _curated:_ Set by assert_state when splitting or replacing. |
| 16 | `primary_claim_id` | `uuid` | yes | — | FK → [`evidence.claim`](../evidence/claim.md).id |
| 17 | `k_from` | `bigint` | no | — | — |
| 18 | `k_to` | `bigint` | yes | — | _curated:_ Null means current knowledge; closure only via helpers. |
| 19 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 20 | `specification_id` | `uuid` | yes | — | FK → [`corpus.ai_model_version_spec`](../corpus/ai_model_version_spec.md).id |

## Constraints

- PK (id)
- unique (tenant_id, id)
- **exclusion** `segment_stream_id_valid_during_excl`: `EXCLUDE USING gist (stream_id WITH =, valid_during WITH &&) WHERE (k_to IS NULL)`
- check `segment_belief_check`: `(belief = ANY (ARRAY['accepted'::text, 'disputed'::text, 'unknown'::text]))`
- check `segment_check`: `((k_to IS NULL) OR (k_to > k_from))`
- check `segment_check1`: `((replaces_segment_id IS NULL) OR (replaces_segment_id <> id))`
- check `segment_check2`: `((temporal_basis = ANY (ARRAY['observation_bounded'::text, 'unresolved'::text])) OR (extent_id IS NOT NULL))`
- check `segment_temporal_basis_check`: `(temporal_basis = ANY (ARRAY['explicit'::text, 'carry_forward'::text, 'observation_bounded'::text, 'unresolved'::text]))`
- check `segment_valid_during_check`: `((NOT isempty(valid_during)) AND lower_inc(valid_during) AND (NOT upper_inc(valid_during)) AND (NOT lower_inf(valid_during)))`

## Relationships

14 outbound and 4 inbound foreign keys; full list in [details](segment.details.md).

## Indexes

4 indexes; see [details](segment.details.md).

## Triggers

3 triggers; see [details](segment.details.md).

## Row-level security

Enabled; 1 policies in [details](segment.details.md).

## Grants

`control_plane`: SELECT; `executor_service`: SELECT; `pipeline_agent`: SELECT; `service_role`: SELECT; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Named queries: `q:entity.at`, `q:entity.relationships`, `q:entity.timeline`, `q:entity.what_changed`, `q:facts.current_by_stream`, `q:facts.history_for_stream`, `q:relationships.current_by_kind`.
- Exposed through: [`api.current_facts`](../api/current_facts.md), [`api.current_relationships`](../api/current_relationships.md).
- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- No direct DML for any agent role.
- Via functions (best effort): [`temporal.assert_state`](../../functions/temporal/assert_state.md), [`temporal.close_segment`](../../functions/temporal/close_segment.md).

## TypeScript

insert: `Database["temporal"]["Tables"]["segment"]["Insert"]`; row: `Database["temporal"]["Tables"]["segment"]["Row"]`; update: `Database["temporal"]["Tables"]["segment"]["Update"]`

## Examples

Input price in March 2026 as known at head 0

```bash
knowledge db query entity.at --param at=2026-03-15T00:00:00Z --param entity_id=0192b000-0000-7000-8000-000000000001 --param k=0
```
Filter result rows to stream_kind model_offering_price.

Defined in: `20260912010400_km_04_temporal.sql`.
