---
id: "rel:retrieval.retrieval_candidate"
kind: table
schema: retrieval
name: retrieval_candidate
domain: retrieval
aliases: []
tokens: [retrieval, retrieval_candidate, retrieval.retrieval_candidate, id, run_id, vector_item_id, lexical_ref, stage_scores, final_score, rank, tenant_id]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"retrieval\"][\"Tables\"][\"retrieval_candidate\"][\"Row\"]"
defined_in: ["20260826001000_retrieval.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# retrieval.retrieval_candidate

table in domain `retrieval`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `run_id` | `uuid` | no | — | FK → [`retrieval.retrieval_run`](retrieval_run.md).id |
| 3 | `vector_item_id` | `uuid` | yes | — | FK → [`retrieval.vector_item`](vector_item.md).id |
| 4 | `lexical_ref` | `text` | yes | — | — |
| 5 | `stage_scores` | `jsonb` | no | `'{}'::jsonb` | — |
| 6 | `final_score` | `numeric` | yes | — | — |
| 7 | `rank` | `integer` | yes | — | — |
| 8 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id) |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `retrieval_candidate_has_ref`: `(num_nonnulls(vector_item_id, lexical_ref) >= 1)`

## Relationships

Outbound: `run_id` → [`retrieval.retrieval_run`](retrieval_run.md)`.id` (+tenant) on delete cascade; `vector_item_id` → [`retrieval.vector_item`](vector_item.md)`.id`.
Inbound: [`retrieval.retrieval_candidate_source`](retrieval_candidate_source.md).retrieval_candidate_id.

## Indexes

`retrieval_candidate_run_idx`; `retrieval_candidate_tenant_id_uq` unique

## Triggers

- `retrieval_candidate_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `false`

## Grants

`executor_service`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `executor_service`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["retrieval"]["Tables"]["retrieval_candidate"]["Insert"]`; row: `Database["retrieval"]["Tables"]["retrieval_candidate"]["Row"]`; update: `Database["retrieval"]["Tables"]["retrieval_candidate"]["Update"]`

Defined in: `20260826001000_retrieval.sql`.
