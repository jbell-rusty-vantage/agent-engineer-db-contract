---
id: "rel:retrieval.vector_space"
kind: table
schema: retrieval
name: vector_space
domain: retrieval
lens: corpus
aliases: [space, space slug]
tokens: [retrieval, vector_space, retrieval.vector_space, id, tenant_id, slug, purpose, class, created_at]
summary: "Named embedding space (units, digests, entity_cards, assertions, own_content, learner_notes, knowledge_text, …); a facet of the one stack."
summary_basis: curated
rls: enabled
readers: [app_reader, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"retrieval\"][\"Tables\"][\"vector_space\"][\"Row\"]"
defined_in: ["20260826001000_retrieval.sql"]
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# retrieval.vector_space

table in domain `retrieval`, lens `corpus`.

> curated (model_assisted, unreviewed) — Named embedding space (units, digests, entity_cards, assertions, own_content, learner_notes, knowledge_text, …); a facet of the one stack.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | unique (tenant_id, slug); unique (tenant_id, id) |
| 3 | `slug` | `text` | no | — | unique (tenant_id, slug); _curated:_ Stable space name used in api.search_unified p_space_slugs. |
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

`app_reader`: SELECT; `control_plane`: SELECT; `executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: SELECT; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `authenticated`.

## Read paths

- Named queries: `q:retrieval.hybrid_search`, `q:retrieval.search_unified`.
- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["retrieval"]["Tables"]["vector_space"]["Insert"]`; row: `Database["retrieval"]["Tables"]["vector_space"]["Row"]`; update: `Database["retrieval"]["Tables"]["vector_space"]["Update"]`

## Examples

Restrict a search to spaces

```bash
knowledge db query retrieval.search_unified --param lenses=["corpus"] --param limit=20 --param query=pricing --param space_slugs=["units","digests"]
```
Spaces are facets; publication still gates what app_reader reads.

Defined in: `20260826001000_retrieval.sql`.
