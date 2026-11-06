---
id: "rel:temporal.event_kind"
kind: table
schema: temporal
name: event_kind
domain: temporal-facts
aliases: [event vocabulary]
tokens: [temporal, event_kind, temporal.event_kind, code, subject_kinds, object_kinds, starts_stream_kind, ends_stream_kind, description]
summary: Event vocabulary with subject and object kinds and optional start/end stream kinds.
summary_basis: curated
rls: disabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"temporal\"][\"Tables\"][\"event_kind\"][\"Row\"]"
defined_in: ["20260912010100_km_01_vocabularies.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# temporal.event_kind

table in domain `temporal-facts`.

> curated (model_assisted, unreviewed) — Event vocabulary with subject and object kinds and optional start/end stream kinds.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `code` | `text` | no | — | PK |
| 2 | `subject_kinds` | `text[]` | no | — | — |
| 3 | `object_kinds` | `text[]` | yes | — | — |
| 4 | `starts_stream_kind` | `text` | yes | — | FK → [`temporal.stream_kind`](stream_kind.md).code; _curated:_ Optional stream this event opens. |
| 5 | `ends_stream_kind` | `text` | yes | — | FK → [`temporal.stream_kind`](stream_kind.md).code; _curated:_ Optional stream this event closes. |
| 6 | `description` | `text` | no | — | — |

## Constraints

- PK (code)

## Relationships

Outbound: `ends_stream_kind` → [`temporal.stream_kind`](stream_kind.md)`.code`; `starts_stream_kind` → [`temporal.stream_kind`](stream_kind.md)`.code`.
Inbound: [`temporal.event`](event.md).kind.

## Indexes

_None._

## Triggers

_None._

## Row-level security

Disabled.

## Grants

`control_plane`: SELECT; `executor_service`: SELECT; `pipeline_agent`: SELECT; `service_role`: SELECT; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Named queries: `q:vocab.event_kind`.
- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- No direct DML for any agent role.
- No write path for agents; rows are seeded by migrations or platform tooling.

## TypeScript

insert: `Database["temporal"]["Tables"]["event_kind"]["Insert"]`; row: `Database["temporal"]["Tables"]["event_kind"]["Row"]`; update: `Database["temporal"]["Tables"]["event_kind"]["Update"]`

## Examples

Price-changed event kind

```bash
knowledge db query vocab.event_kind --param code=price_changed
```
Subject kinds include model_offering and compute_offering.

Defined in: `20260912010100_km_01_vocabularies.sql`.
