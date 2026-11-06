---
id: "rel:retrieval.search_projection_chunk_support"
kind: table
schema: retrieval
name: search_projection_chunk_support
domain: retrieval
aliases: []
tokens: [retrieval, search_projection_chunk_support, retrieval.search_projection_chunk_support, tenant_id, search_projection_id, ordinal, chunk_id, support_kind, locator_id, selected_text_sha256, created_at]
summary: "Typed, immutable faithful/atomic support for a purpose-specific search projection."
summary_basis: comment
rls: enabled
readers: [control_plane, executor_service, service_role]
writers: [control_plane, executor_service, service_role]
typescript: "Database[\"retrieval\"][\"Tables\"][\"search_projection_chunk_support\"][\"Row\"]"
defined_in: ["20260904011000_governed_projection_embedding_publication.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# retrieval.search_projection_chunk_support

table in domain `retrieval` — Typed, immutable faithful/atomic support for a purpose-specific search projection..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | PK; unique (tenant_id, search_projection_id, chunk_id, support_kind) |
| 2 | `search_projection_id` | `uuid` | no | — | PK; unique (tenant_id, search_projection_id, chunk_id, support_kind) |
| 3 | `ordinal` | `integer` | no | — | PK |
| 4 | `chunk_id` | `uuid` | no | — | unique (tenant_id, search_projection_id, chunk_id, support_kind) |
| 5 | `support_kind` | `text` | no | — | unique (tenant_id, search_projection_id, chunk_id, support_kind) |
| 6 | `locator_id` | `uuid` | yes | — | FK → [`evidence.locator`](../evidence/locator.md).id |
| 7 | `selected_text_sha256` | `text` | no | — | — |
| 8 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (tenant_id, search_projection_id, ordinal)
- unique (tenant_id, search_projection_id, chunk_id, support_kind)
- check `search_projection_chunk_support_ordinal_check`: `(ordinal >= 0)`
- check `search_projection_chunk_support_selected_text_sha256_check`: `(selected_text_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `search_projection_chunk_support_support_kind_check`: `(support_kind = ANY (ARRAY['faithful_source'::text, 'atomic_support'::text]))`

## Relationships

Outbound: `tenant_id,search_projection_id` → [`retrieval.search_projection`](search_projection.md)`.tenant_id,id` on delete restrict; `locator_id` → [`evidence.locator`](../evidence/locator.md)`.id` on delete restrict; `tenant_id,chunk_id` → [`retrieval.retrieval_chunk`](retrieval_chunk.md)`.tenant_id,id` on delete restrict.
Inbound: none.

## Indexes

`search_projection_chunk_suppo_tenant_id_search_projection_i_key` unique

## Triggers

- `search_projection_chunk_support_immutable` → [`util.reject_mutation`](../../functions/util/reject_mutation.md)

## Row-level security

Enabled and forced.
- `bounded_role_access` (ALL) for `control_plane`, `executor_service`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: INSERT, SELECT; `executor_service`: INSERT, SELECT; `service_role`: INSERT, SELECT. None: `anon`, `app_reader`, `authenticated`, `pipeline_agent`, `verifier_agent`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`.

## Write path

- Direct DML: `control_plane`, `executor_service`.

## TypeScript

insert: `Database["retrieval"]["Tables"]["search_projection_chunk_support"]["Insert"]`; row: `Database["retrieval"]["Tables"]["search_projection_chunk_support"]["Row"]`; update: `Database["retrieval"]["Tables"]["search_projection_chunk_support"]["Update"]`

Defined in: `20260904011000_governed_projection_embedding_publication.sql`.
