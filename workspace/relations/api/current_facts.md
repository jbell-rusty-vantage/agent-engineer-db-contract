---
id: "rel:api.current_facts"
kind: view
schema: api
name: current_facts
domain: api-surface
lens: corpus
aliases: [current facts view]
tokens: [api, current_facts, api.current_facts, id, tenant_id, stream_id, valid_during, belief, temporal_basis, status, amount, currency, unit, ref_entity_id, payload, extent_id, caused_by_event_id, replaces_segment_id, primary_claim_id, k_from, k_to, created_at, stream_kind, subject_entity_id, subject_relationship_id, scope_key]
summary: Current segments whose valid_during contains now().
summary_basis: curated
rls: disabled
readers: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"api\"][\"Views\"][\"current_facts\"][\"Row\"]"
defined_in: ["20260912011000_km_10_api.sql", "20261108120000_build08_r2_knowledge_continuum.sql", part1_renames.sql]
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# api.current_facts

view in domain `api-surface`, lens `corpus`.

> curated (model_assisted, unreviewed) — Current segments whose valid_during contains now().

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | yes | — | — |
| 2 | `tenant_id` | `uuid` | yes | — | — |
| 3 | `stream_id` | `uuid` | yes | — | — |
| 4 | `valid_during` | `tstzrange` | yes | — | — |
| 5 | `belief` | `text` | yes | — | — |
| 6 | `temporal_basis` | `text` | yes | — | — |
| 7 | `status` | `text` | yes | — | — |
| 8 | `amount` | `numeric` | yes | — | — |
| 9 | `currency` | `bpchar` | yes | — | — |
| 10 | `unit` | `text` | yes | — | — |
| 11 | `ref_entity_id` | `uuid` | yes | — | — |
| 12 | `payload` | `jsonb` | yes | — | — |
| 13 | `extent_id` | `uuid` | yes | — | — |
| 14 | `caused_by_event_id` | `uuid` | yes | — | — |
| 15 | `replaces_segment_id` | `uuid` | yes | — | — |
| 16 | `primary_claim_id` | `uuid` | yes | — | — |
| 17 | `k_from` | `bigint` | yes | — | — |
| 18 | `k_to` | `bigint` | yes | — | _curated:_ Always null in this view. |
| 19 | `created_at` | `timestamp with time zone` | yes | — | — |
| 20 | `stream_kind` | `text` | yes | — | _curated:_ Copied from temporal.stream.kind. |
| 21 | `subject_entity_id` | `uuid` | yes | — | — |
| 22 | `subject_relationship_id` | `uuid` | yes | — | — |
| 23 | `scope_key` | `text` | yes | — | — |

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

- Named queries: `q:facts.current_by_stream`.
- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

Views are not written.

## View definition

See [details](current_facts.details.md).

## TypeScript

row: `Database["api"]["Views"]["current_facts"]["Row"]`

## Examples

Current prices

```bash
knowledge db query facts.current_by_stream --param entity_id=null --param limit=50 --param stream_kind=offering_price
```
Historical prices need entity.at or facts.price_history.

Defined in: `20260912011000_km_10_api.sql`, `20261108120000_build08_r2_knowledge_continuum.sql`, `part1_renames.sql`.
