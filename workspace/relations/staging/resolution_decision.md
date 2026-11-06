---
id: "rel:staging.resolution_decision"
kind: table
schema: staging
name: resolution_decision
domain: staging
aliases: [resolution]
tokens: [staging, resolution_decision, staging.resolution_decision, id, tenant_id, candidate_id, entity_id, decision, receipt_id, created_at]
summary: "create, match, reject, or defer decision with a receipt."
summary_basis: curated
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, pipeline_agent, service_role]
typescript: "Database[\"staging\"][\"Tables\"][\"resolution_decision\"][\"Row\"]"
defined_in: ["20260826000700_staging.sql", "20260912010900_km_09_ranking_staging.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# staging.resolution_decision

table in domain `staging`.

> curated (model_assisted, unreviewed) — create, match, reject, or defer decision with a receipt.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id) |
| 3 | `candidate_id` | `uuid` | no | — | FK → [`staging.candidate`](candidate.md).id |
| 4 | `entity_id` | `uuid` | yes | — | FK → [`corpus.entity`](../corpus/entity.md).id |
| 5 | `decision` | `text` | no | — | _curated:_ create, match, reject, defer. |
| 6 | `receipt_id` | `uuid` | no | — | FK → [`orchestration.operation_receipt`](../orchestration/operation_receipt.md).id; _curated:_ Required. |
| 7 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `resolution_decision_decision_check`: `(decision = ANY (ARRAY['create'::text, 'match'::text, 'reject'::text, 'defer'::text]))`

## Relationships

Outbound: `candidate_id` → [`staging.candidate`](candidate.md)`.id` (+tenant); `entity_id` → [`corpus.entity`](../corpus/entity.md)`.id` (+tenant); `receipt_id` → [`orchestration.operation_receipt`](../orchestration/operation_receipt.md)`.id` (deferrable).
Inbound: none.

## Indexes

`resolution_decision_tenant_id_id_key` unique

## Triggers

_None._

## Row-level security

Enabled.
- `km_tenant_access` (ALL) for `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: SELECT; `executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Named queries: `q:staging.unresolved`.
- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`, `pipeline_agent`.

## TypeScript

insert: `Database["staging"]["Tables"]["resolution_decision"]["Insert"]`; row: `Database["staging"]["Tables"]["resolution_decision"]["Row"]`; update: `Database["staging"]["Tables"]["resolution_decision"]["Update"]`

## Examples

Still unresolved

```bash
knowledge db query staging.unresolved --param limit=50
```
A create/match/reject row removes the candidate from this query.

Defined in: `20260826000700_staging.sql`, `20260912010900_km_09_ranking_staging.sql`.
