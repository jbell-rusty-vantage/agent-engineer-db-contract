---
id: "rel:evidence.claim_conflict"
kind: table
schema: evidence
name: claim_conflict
domain: evidence
aliases: []
tokens: [evidence, claim_conflict, evidence.claim_conflict, id, claim_a_id, claim_b_id, conflict_kind, detected_by, detected_at]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role, verifier_agent]
writers: [executor_service, service_role, verifier_agent]
typescript: "Database[\"evidence\"][\"Tables\"][\"claim_conflict\"][\"Row\"]"
defined_in: ["20260826000300_evidence_core.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# evidence.claim_conflict

table in domain `evidence`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `claim_a_id` | `uuid` | no | — | unique (claim_a_id, claim_b_id, conflict_kind); FK → [`evidence.claim`](claim.md).id |
| 3 | `claim_b_id` | `uuid` | no | — | unique (claim_a_id, claim_b_id, conflict_kind); FK → [`evidence.claim`](claim.md).id |
| 4 | `conflict_kind` | `text` | no | — | unique (claim_a_id, claim_b_id, conflict_kind) |
| 5 | `detected_by` | `text` | no | — | — |
| 6 | `detected_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (claim_a_id, claim_b_id, conflict_kind)
- check `claim_conflict_conflict_kind_check`: `(conflict_kind = ANY (ARRAY['contradiction'::text, 'scope_mismatch'::text, 'staleness'::text, 'measurement'::text, 'definitional'::text]))`
- check `claim_conflict_distinct`: `(claim_a_id <> claim_b_id)`

## Relationships

Outbound: `claim_a_id` → [`evidence.claim`](claim.md)`.id` on delete cascade; `claim_b_id` → [`evidence.claim`](claim.md)`.id` on delete cascade.
Inbound: [`evaluation.review_task`](../evaluation/review_task.md).claim_conflict_id, [`evidence.conflict_reconciliation`](conflict_reconciliation.md).conflict_id.
Polymorphic target of: [`evaluation.review_task`](../evaluation/review_task.md) (check constraint review_task_exactly_one_subject).

## Indexes

`claim_conflict_claim_a_id_claim_b_id_conflict_kind_key` unique

## Triggers

_None._

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `false`

## Grants

`executor_service`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: INSERT, SELECT. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `pipeline_agent`.

## Read paths

- Direct SELECT: `executor_service`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`, `verifier_agent`.

## TypeScript

insert: `Database["evidence"]["Tables"]["claim_conflict"]["Insert"]`; row: `Database["evidence"]["Tables"]["claim_conflict"]["Row"]`; update: `Database["evidence"]["Tables"]["claim_conflict"]["Update"]`

Defined in: `20260826000300_evidence_core.sql`.
