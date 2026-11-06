---
id: "rel:public.factory_runtime_event"
kind: table
schema: public
name: factory_runtime_event
domain: research-starter-protected
aliases: []
tokens: [public, factory_runtime_event, public.factory_runtime_event, eve_event_id, factory_episode_id, eve_session_id, event_type, event_data, event_meta, payload_sha256, payload_byte_size, redaction_version, payload_truncated, agent_name, agent_node_id, channel_kind, subagent_name, call_id, emitted_at, ingested_at, event_ordinal, repository, issue_number, sensitivity_class, retention_until]
summary: "Append-only, redacted copy of Eve root-agent durable stream events. Eve event ids provide idempotency; session ids bind events to factory episodes."
summary_basis: comment
rls: enabled
readers: []
writers: []
typescript: "Database[\"public\"][\"Tables\"][\"factory_runtime_event\"][\"Row\"]"
defined_in: ["20260822040000_factory_runtime_event_ledger.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# public.factory_runtime_event

table in domain `research-starter-protected` — Append-only, redacted copy of Eve root-agent durable stream events. Eve event ids provide idempotency; session ids bind events to factory episodes..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `eve_event_id` | `text` | no | — | PK |
| 2 | `factory_episode_id` | `uuid` | no | — | FK → [`public.factory_episode`](factory_episode.md).factory_episode_id |
| 3 | `eve_session_id` | `text` | no | — | — |
| 4 | `event_type` | `text` | no | — | — |
| 5 | `event_data` | `jsonb` | yes | — | — |
| 6 | `event_meta` | `jsonb` | no | — | — |
| 7 | `payload_sha256` | `text` | no | — | — |
| 8 | `payload_byte_size` | `bigint` | no | — | — |
| 9 | `redaction_version` | `text` | no | `'factory-event-redaction-v1'::text` | — |
| 10 | `payload_truncated` | `boolean` | no | `false` | — |
| 11 | `agent_name` | `text` | no | — | — |
| 12 | `agent_node_id` | `text` | yes | — | — |
| 13 | `channel_kind` | `text` | yes | — | — |
| 14 | `subagent_name` | `text` | yes | — | — |
| 15 | `call_id` | `text` | yes | — | — |
| 16 | `emitted_at` | `timestamp with time zone` | no | — | — |
| 17 | `ingested_at` | `timestamp with time zone` | no | `timezone('utc'::text, now())` | — |
| 18 | `event_ordinal` | `bigint` | no | — | Episode-local total order allocated under a Postgres advisory lock. |
| 19 | `repository` | `text` | yes | — | — |
| 20 | `issue_number` | `bigint` | yes | — | — |
| 21 | `sensitivity_class` | `text` | no | `'confidential'::text` | — |
| 22 | `retention_until` | `timestamp with time zone` | no | `(timezone('utc'::text, now()) + '30 days'::interval)` | Governed retention boundary; payload erasure requires a separately audited process. |

## Constraints

- PK (eve_event_id)
- check `factory_runtime_event_digest_check`: `(payload_sha256 ~ '^sha256:[0-9a-f]{64}$'::text)`
- check `factory_runtime_event_ordinal_positive`: `(event_ordinal > 0)`
- check `factory_runtime_event_sensitivity_check`: `(sensitivity_class = ANY (ARRAY['internal'::text, 'confidential'::text, 'restricted'::text]))`
- check `factory_runtime_event_size_check`: `(payload_byte_size >= 0)`

## Relationships

Outbound: `factory_episode_id` → [`public.factory_episode`](factory_episode.md)`.factory_episode_id` on delete restrict.
Inbound: none.

## Indexes

`factory_runtime_event_episode_idx`; `factory_runtime_event_episode_ordinal_uniq` unique; `factory_runtime_event_session_idx`; `factory_runtime_event_station_idx` where `(subagent_name IS NOT NULL)`

## Triggers

- `factory_runtime_event_immutable` → [`public.reject_immutable_row_change`](../../functions/public/reject_immutable_row_change.md)

## Row-level security

Enabled.

## Grants

No role has privileges. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

## Read paths

- No agent role may SELECT directly.

## Write path

- No direct DML for any agent role.
- No write path for agents; rows are seeded by migrations or platform tooling.

## TypeScript

insert: `Database["public"]["Tables"]["factory_runtime_event"]["Insert"]`; row: `Database["public"]["Tables"]["factory_runtime_event"]["Row"]`; update: `Database["public"]["Tables"]["factory_runtime_event"]["Update"]`

Defined in: `20260822040000_factory_runtime_event_ledger.sql`.
