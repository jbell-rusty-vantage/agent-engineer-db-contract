---
id: "rel:evidence.revalidation_event"
kind: table
schema: evidence
name: revalidation_event
domain: evidence
aliases: []
tokens: [evidence, revalidation_event, evidence.revalidation_event, id, policy_id, trigger_kind, affected_refs, work_item_id, fired_at]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"evidence\"][\"Tables\"][\"revalidation_event\"][\"Row\"]"
defined_in: ["20260826000300_evidence_core.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# evidence.revalidation_event

table in domain `evidence`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `policy_id` | `uuid` | yes | — | FK → [`evidence.revalidation_policy`](revalidation_policy.md).id |
| 3 | `trigger_kind` | `text` | no | — | — |
| 4 | `affected_refs` | `jsonb` | no | `'[]'::jsonb` | — |
| 5 | `work_item_id` | `uuid` | yes | — | FK → [`orchestration.work_item`](../orchestration/work_item.md).id |
| 6 | `fired_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- check `revalidation_event_trigger_kind_check`: `(trigger_kind = ANY (ARRAY['time'::text, 'release'::text, 'source_change'::text, 'security'::text, 'retraction'::text, 'contradiction'::tex…`

## Relationships

Outbound: `policy_id` → [`evidence.revalidation_policy`](revalidation_policy.md)`.id`; `work_item_id` → [`orchestration.work_item`](../orchestration/work_item.md)`.id`.
Inbound: none.

## Indexes

`revalidation_event_fired_idx`

## Triggers

_None._

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `false`

## Grants

`executor_service`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `pipeline_agent`.

## Read paths

- Direct SELECT: `executor_service`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["evidence"]["Tables"]["revalidation_event"]["Insert"]`; row: `Database["evidence"]["Tables"]["revalidation_event"]["Row"]`; update: `Database["evidence"]["Tables"]["revalidation_event"]["Update"]`

Defined in: `20260826000300_evidence_core.sql`.
