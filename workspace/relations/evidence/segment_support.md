---
id: "rel:evidence.segment_support"
kind: table
schema: evidence
name: segment_support
domain: evidence
aliases: [support]
tokens: [evidence, segment_support, evidence.segment_support, id, tenant_id, segment_id, event_occurrence_id, claim_id, locator_id, role, k_from, k_to]
summary: K-stamped link from a claim and locator to a segment or occurrence.
summary_basis: curated
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"evidence\"][\"Tables\"][\"segment_support\"][\"Row\"]"
defined_in: ["20260912010500_km_05_evidence.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# evidence.segment_support

table in domain `evidence`.

> curated (model_assisted, unreviewed) — K-stamped link from a claim and locator to a segment or occurrence.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id) |
| 3 | `segment_id` | `uuid` | yes | — | FK → [`temporal.segment`](../temporal/segment.md).id; _curated:_ Exactly one of segment_id or event_occurrence_id. |
| 4 | `event_occurrence_id` | `uuid` | yes | — | FK → [`temporal.event_occurrence`](../temporal/event_occurrence.md).id |
| 5 | `claim_id` | `uuid` | no | — | FK → [`evidence.claim`](claim.md).id |
| 6 | `locator_id` | `uuid` | no | — | FK → [`evidence.locator`](locator.md).id |
| 7 | `role` | `text` | no | — | _curated:_ supports, challenges, or context. |
| 8 | `k_from` | `bigint` | no | — | — |
| 9 | `k_to` | `bigint` | yes | — | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `segment_support_check`: `(num_nonnulls(segment_id, event_occurrence_id) = 1)`
- check `segment_support_check1`: `((k_to IS NULL) OR (k_to > k_from))`
- check `segment_support_role_check`: `(role = ANY (ARRAY['supports'::text, 'challenges'::text, 'context'::text]))`

## Relationships

Outbound: `claim_id` → [`evidence.claim`](claim.md)`.id` (+tenant); `event_occurrence_id` → [`temporal.event_occurrence`](../temporal/event_occurrence.md)`.id` (+tenant); `locator_id` → [`evidence.locator`](locator.md)`.id` (+tenant); `segment_id` → [`temporal.segment`](../temporal/segment.md)`.id` (+tenant).
Inbound: none.
Polymorphic: exactly one of `segment_id`, `event_occurrence_id` → [`temporal.event_occurrence`](../temporal/event_occurrence.md) | [`temporal.segment`](../temporal/segment.md) — basis: check constraint segment_support_check.

## Indexes

`segment_support_tenant_id_id_key` unique

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

- Named queries: `q:evidence.claim_support`.
- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- No direct DML for any agent role.
- Via functions (best effort): [`temporal.admit_support`](../../functions/temporal/admit_support.md), [`temporal.withdraw_support`](../../functions/temporal/withdraw_support.md).

## TypeScript

insert: `Database["evidence"]["Tables"]["segment_support"]["Insert"]`; row: `Database["evidence"]["Tables"]["segment_support"]["Row"]`; update: `Database["evidence"]["Tables"]["segment_support"]["Update"]`

## Examples

Support for one claim

```bash
knowledge db query evidence.claim_support --param claim_id=0192d000-0000-7000-8000-000000000001
```
Written only through temporal.admit_support.

Defined in: `20260912010500_km_05_evidence.sql`.
