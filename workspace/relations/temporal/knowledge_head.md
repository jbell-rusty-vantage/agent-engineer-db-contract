---
id: "rel:temporal.knowledge_head"
kind: table
schema: temporal
name: knowledge_head
domain: temporal-facts
aliases: [head, tenant clock]
tokens: [temporal, knowledge_head, temporal.knowledge_head, tenant_id, knowledge_seq, updated_at, open_xid, open_k]
summary: One row per tenant; knowledge_seq is the sealed-batch clock and open_xid/open_k mark an open batch.
summary_basis: curated
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"temporal\"][\"Tables\"][\"knowledge_head\"][\"Row\"]"
defined_in: ["20260912010400_km_04_temporal.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# temporal.knowledge_head

table in domain `temporal-facts`.

> curated (model_assisted, unreviewed) — One row per tenant; knowledge_seq is the sealed-batch clock and open_xid/open_k mark an open batch.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | PK |
| 2 | `knowledge_seq` | `bigint` | no | `0` | _curated:_ Last sealed sequence; begin_batch compares p_expected_head to this value. |
| 3 | `updated_at` | `timestamp with time zone` | no | `now()` | — |
| 4 | `open_xid` | `xid8` | yes | — | _curated:_ Transaction id of the open batch; null when the head is idle. |
| 5 | `open_k` | `bigint` | yes | — | _curated:_ Sequence that stamp_k will write; equal to knowledge_seq+1 while a batch is open. |

## Constraints

- PK (tenant_id)

## Relationships

Outbound: none.
Inbound: none.

## Indexes

_None._

## Triggers

- `closed_head` → [`temporal.require_closed_head`](../../functions/temporal/require_closed_head.md) (constraint trigger, deferred)

## Row-level security

Enabled.
- `km_tenant_access` (ALL) for `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: SELECT; `executor_service`: SELECT; `pipeline_agent`: SELECT; `service_role`: SELECT; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Named queries: `q:entity.at`, `q:entity.relationships`, `q:entity.timeline`, `q:knowledge.head`.
- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- No direct DML for any agent role.
- Via functions (best effort): [`temporal.begin_batch`](../../functions/temporal/begin_batch.md), [`temporal.commit_batch`](../../functions/temporal/commit_batch.md), [`temporal.lock_knowledge_head`](../../functions/temporal/lock_knowledge_head.md).

## TypeScript

insert: `Database["temporal"]["Tables"]["knowledge_head"]["Insert"]`; row: `Database["temporal"]["Tables"]["knowledge_head"]["Row"]`; update: `Database["temporal"]["Tables"]["knowledge_head"]["Update"]`

## Examples

Read the current head

```bash
knowledge db query knowledge.head
```
app_reader path; returns 0 when no batch has been sealed.

Defined in: `20260912010400_km_04_temporal.sql`.
