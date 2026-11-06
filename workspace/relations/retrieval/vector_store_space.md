---
id: "rel:retrieval.vector_store_space"
kind: table
schema: retrieval
name: vector_store_space
domain: retrieval
aliases: [store attachment]
tokens: [retrieval, vector_store_space, retrieval.vector_store_space, id, tenant_id, vector_store_id, vector_space_id, active_space_version_id, authority_class, created_at]
summary: Attaches a vector store to a space and names the active published version.
summary_basis: curated
rls: enabled
readers: []
writers: []
typescript: "Database[\"retrieval\"][\"Tables\"][\"vector_store_space\"][\"Row\"]"
defined_in: ["20260903010100_knowledge_retrieval_contract.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# retrieval.vector_store_space

table in domain `retrieval`.

> curated (model_assisted, unreviewed) — Attaches a vector store to a space and names the active published version.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, id); unique (tenant_id, vector_store_id, vector_space_id) |
| 3 | `vector_store_id` | `uuid` | no | — | unique (tenant_id, vector_store_id, vector_space_id) |
| 4 | `vector_space_id` | `uuid` | no | — | unique (tenant_id, vector_store_id, vector_space_id) |
| 5 | `active_space_version_id` | `uuid` | yes | — | _curated:_ Version hybrid search should use when a store is queried. |
| 6 | `authority_class` | `text` | no | — | _curated:_ Which store is authoritative for the space. |
| 7 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, vector_store_id, vector_space_id)
- check `vector_store_space_authority_class_check`: `(authority_class = ANY (ARRAY['official'::text, 'exploratory'::text, 'user_managed'::text]))`

## Relationships

Outbound: `tenant_id,active_space_version_id` → [`retrieval.vector_space_version`](vector_space_version.md)`.tenant_id,id` on delete restrict; `tenant_id,vector_space_id` → [`retrieval.vector_space`](vector_space.md)`.tenant_id,id` on delete restrict; `tenant_id,vector_store_id` → [`retrieval.vector_store`](vector_store.md)`.tenant_id,id` on delete restrict.
Inbound: [`retrieval.publication_switch_receipt`](publication_switch_receipt.md).vector_store_space_id, [`retrieval.space_publication`](space_publication.md).vector_store_space_id.

## Indexes

`vector_store_space_tenant_id_id_key` unique; `vector_store_space_tenant_id_vector_store_id_vector_space_i_key` unique

## Triggers

- `vector_store_space_authority` → [`retrieval.validate_vector_store_space_authority`](../../functions/retrieval/validate_vector_store_space_authority.md)
- `vector_store_space_pointer_guard` → [`retrieval.guard_vector_store_space_pointer`](../../functions/retrieval/guard_vector_store_space_pointer.md)

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

No role has privileges. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

## Read paths

- Named queries: `q:retrieval.hybrid_search`.
- No agent role may SELECT directly.

## Write path

- No direct DML for any agent role.
- Via functions (best effort): [`retrieval.publish_vector_space`](../../functions/retrieval/publish_vector_space.md), [`retrieval.rollback_vector_space`](../../functions/retrieval/rollback_vector_space.md).

## TypeScript

insert: `Database["retrieval"]["Tables"]["vector_store_space"]["Insert"]`; row: `Database["retrieval"]["Tables"]["vector_store_space"]["Row"]`; update: `Database["retrieval"]["Tables"]["vector_store_space"]["Update"]`

## Examples

Search the active version

```bash
knowledge db query retrieval.hybrid_search --param filters={} --param limit=20 --param query_text=OpenAI API pricing 2026 --param vector_space_version_id=0192b100-0000-7000-8000-000000000001
```
Unpublished active versions still fail the publication gate.

Defined in: `20260903010100_knowledge_retrieval_contract.sql`.
