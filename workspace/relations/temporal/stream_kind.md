---
id: "rel:temporal.stream_kind"
kind: table
schema: temporal
name: stream_kind
domain: temporal-facts
aliases: [stream vocabulary]
tokens: [temporal, stream_kind, temporal.stream_kind, code, subject_mode, subject_kinds, status_values, requires_amount, unit_values, requires_ref_entity, ref_entity_kinds, payload_schema, description]
summary: "Slot rules for a fact series (subject kinds, status values, units, payload schema)."
summary_basis: curated
rls: disabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"temporal\"][\"Tables\"][\"stream_kind\"][\"Row\"]"
defined_in: ["20260912010100_km_01_vocabularies.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# temporal.stream_kind

table in domain `temporal-facts`.

> curated (model_assisted, unreviewed) — Slot rules for a fact series (subject kinds, status values, units, payload schema).

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `code` | `text` | no | — | PK |
| 2 | `subject_mode` | `text` | no | — | _curated:_ entity or relationship. |
| 3 | `subject_kinds` | `text[]` | no | `'{}'::text[]` | — |
| 4 | `status_values` | `text[]` | yes | — | — |
| 5 | `requires_amount` | `boolean` | no | `false` | — |
| 6 | `unit_values` | `text[]` | yes | — | _curated:_ Closed list when requires_amount is true. |
| 7 | `requires_ref_entity` | `boolean` | no | `false` | — |
| 8 | `ref_entity_kinds` | `text[]` | yes | — | — |
| 9 | `payload_schema` | `jsonb` | no | `'{}'::jsonb` | — |
| 10 | `description` | `text` | no | — | — |

## Constraints

- PK (code)
- check `stream_kind_subject_mode_check`: `(subject_mode = ANY (ARRAY['entity'::text, 'relationship'::text]))`

## Relationships

Outbound: none.
Inbound: [`temporal.event_kind`](event_kind.md).ends_stream_kind|starts_stream_kind, [`temporal.stream`](stream.md).kind.

## Indexes

_None._

## Triggers

_None._

## Row-level security

Disabled.

## Grants

`control_plane`: SELECT; `executor_service`: SELECT; `pipeline_agent`: SELECT; `service_role`: SELECT; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Named queries: `q:vocab.stream_kind`.
- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- No direct DML for any agent role.
- No write path for agents; rows are seeded by migrations or platform tooling.

## TypeScript

insert: `Database["temporal"]["Tables"]["stream_kind"]["Insert"]`; row: `Database["temporal"]["Tables"]["stream_kind"]["Row"]`; update: `Database["temporal"]["Tables"]["stream_kind"]["Update"]`

## Examples

Price slot rules

```bash
knowledge db query vocab.stream_kind --param code=model_offering_price
```
requires_amount true; units include per_1m_input_tokens.

Defined in: `20260912010100_km_01_vocabularies.sql`.
