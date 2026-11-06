---
id: "rel:retrieval.chunk_edge"
kind: table
schema: retrieval
name: chunk_edge
domain: retrieval
aliases: []
tokens: [retrieval, chunk_edge, retrieval.chunk_edge, tenant_id, from_chunk_id, to_chunk_id, relation_kind, metadata, created_at]
summary: null
summary_basis: none
rls: enabled
readers: []
writers: []
typescript: "Database[\"retrieval\"][\"Tables\"][\"chunk_edge\"][\"Row\"]"
defined_in: ["20260903010100_knowledge_retrieval_contract.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# retrieval.chunk_edge

table in domain `retrieval`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | PK |
| 2 | `from_chunk_id` | `uuid` | no | — | PK |
| 3 | `to_chunk_id` | `uuid` | no | — | PK |
| 4 | `relation_kind` | `text` | no | — | PK |
| 5 | `metadata` | `jsonb` | no | `'{}'::jsonb` | — |
| 6 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (tenant_id, from_chunk_id, to_chunk_id, relation_kind)
- check `chunk_edge_check`: `(from_chunk_id <> to_chunk_id)`
- check `chunk_edge_relation_kind_check`: `(relation_kind = ANY (ARRAY['parent_of'::text, 'overlaps'::text, 'continues'::text, 'elaborates'::text, 'summarizes'::text, 'same_table'::t…`

## Relationships

Outbound: `tenant_id,from_chunk_id` → [`retrieval.retrieval_chunk`](retrieval_chunk.md)`.tenant_id,id` on delete restrict; `tenant_id,to_chunk_id` → [`retrieval.retrieval_chunk`](retrieval_chunk.md)`.tenant_id,id` on delete restrict.
Inbound: none.

## Indexes

_None._

## Triggers

- `chunk_edge_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

No role has privileges. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

## Read paths

- No agent role may SELECT directly.

## Write path

- No direct DML for any agent role.
- No write path for agents; rows are seeded by migrations or platform tooling.

## TypeScript

insert: `Database["retrieval"]["Tables"]["chunk_edge"]["Insert"]`; row: `Database["retrieval"]["Tables"]["chunk_edge"]["Row"]`; update: `Database["retrieval"]["Tables"]["chunk_edge"]["Update"]`

Defined in: `20260903010100_knowledge_retrieval_contract.sql`.
