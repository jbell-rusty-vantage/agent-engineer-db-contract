---
id: "rel:retrieval.vector_space"
kind: table
schema: retrieval
name: vector_space
domain: retrieval
aliases: [space]
tokens: [retrieval, vector_space, retrieval.vector_space, id, tenant_id, slug, purpose, class, created_at]
summary: "Named embedding space (engineering_claims, entity_profiles, …)."
summary_basis: curated
rls: enabled
readers: [executor_service, service_role]
writers: [executor_service, service_role]
typescript: "Database[\"retrieval\"][\"Tables\"][\"vector_space\"][\"Row\"]"
defined_in: ["20260826001000_retrieval.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# retrieval.vector_space

table in domain `retrieval`.

> curated (model_assisted, unreviewed) — Named embedding space (engineering_claims, entity_profiles, …).

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, slug); unique (tenant_id, id) |
| 3 | `slug` | `text` | no | — | unique (tenant_id, slug); _curated:_ Stable space name used in filters. |
| 4 | `purpose` | `text` | no | — | — |
| 5 | `class` | `retrieval.space_class` | no | `'exploratory'::retrieval.space_class` | — |
| 6 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, slug)
- unique (tenant_id, id)

## Relationships

Outbound: none.
Inbound: [`retrieval.vector_space_version`](vector_space_version.md).vector_space_id, [`retrieval.vector_store_space`](vector_store_space.md).vector_space_id.

## Indexes

`vector_space_tenant_id_slug_key` unique; `vector_space_tenant_id_uq` unique

## Triggers

_None._

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`executor_service`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Named queries: `q:retrieval.hybrid_search`.
- Direct SELECT: `executor_service`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["retrieval"]["Tables"]["vector_space"]["Insert"]`; row: `Database["retrieval"]["Tables"]["vector_space"]["Row"]`; update: `Database["retrieval"]["Tables"]["vector_space"]["Update"]`

## Examples

Hybrid search needs a published version of a space

```bash
knowledge db query retrieval.hybrid_search --param filters={} --param limit=20 --param query_text=OpenAI API pricing 2026 --param vector_space_version_id=0192b100-0000-7000-8000-000000000001
```
Catalog entry is execute false; requires embedding.

Defined in: `20260826001000_retrieval.sql`.
