---
id: "rel:retrieval.retrieval_candidate_source"
kind: table
schema: retrieval
name: retrieval_candidate_source
domain: retrieval
aliases: []
tokens: [retrieval, retrieval_candidate_source, retrieval.retrieval_candidate_source, id, tenant_id, retrieval_candidate_id, channel, search_projection_id, vector_item_id, source_rank, score, explanation, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"retrieval\"][\"Tables\"][\"retrieval_candidate_source\"][\"Row\"]"
defined_in: ["20260903010300_knowledge_retrieval_completeness.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# retrieval.retrieval_candidate_source

table in domain `retrieval`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | — |
| 3 | `retrieval_candidate_id` | `uuid` | no | — | — |
| 4 | `channel` | `text` | no | — | — |
| 5 | `search_projection_id` | `uuid` | yes | — | — |
| 6 | `vector_item_id` | `uuid` | yes | — | — |
| 7 | `source_rank` | `integer` | no | — | — |
| 8 | `score` | `numeric` | no | — | — |
| 9 | `explanation` | `jsonb` | no | `'{}'::jsonb` | — |
| 10 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- check `retrieval_candidate_source_channel_check`: `(channel = ANY (ARRAY['vector'::text, 'lexical'::text, 'exact'::text, 'graph'::text, 'rerank'::text]))`
- check `retrieval_candidate_source_check`: `(num_nonnulls(search_projection_id, vector_item_id) >= 1)`
- check `retrieval_candidate_source_source_rank_check`: `(source_rank > 0)`

## Relationships

Outbound: `tenant_id,retrieval_candidate_id` → [`retrieval.retrieval_candidate`](retrieval_candidate.md)`.tenant_id,id` on delete restrict; `tenant_id,search_projection_id` → [`retrieval.search_projection`](search_projection.md)`.tenant_id,id` on delete restrict; `tenant_id,vector_item_id` → [`retrieval.vector_item`](vector_item.md)`.tenant_id,id` on delete restrict.
Inbound: none.

## Indexes

_None._

## Triggers

- `retrieval_candidate_source_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`executor_service`: INSERT, SELECT; `service_role`: INSERT, SELECT. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `executor_service`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["retrieval"]["Tables"]["retrieval_candidate_source"]["Insert"]`; row: `Database["retrieval"]["Tables"]["retrieval_candidate_source"]["Row"]`; update: `Database["retrieval"]["Tables"]["retrieval_candidate_source"]["Update"]`

Defined in: `20260903010300_knowledge_retrieval_completeness.sql`.
