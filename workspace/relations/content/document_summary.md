---
id: "rel:content.document_summary"
kind: table
schema: content
name: document_summary
domain: content
aliases: []
tokens: [content, document_summary, content.document_summary, id, tenant_id, document_version_id, representation_id, derived_from_representation_id, transformation_run_id, summary_kind, scope, scope_node_id, focus_entity_id, audience, text, language, token_count, content_sha256, coverage_ratio, lifecycle, supersedes_id, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, pipeline_agent, service_role]
typescript: "Database[\"content\"][\"Tables\"][\"document_summary\"][\"Row\"]"
defined_in: ["20260912010600_km_06_content.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# content.document_summary

table in domain `content`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK; unique (tenant_id, id) |
| 2 | `tenant_id` | `uuid` | no | `util.current_tenant_id()` | unique (tenant_id, id) |
| 3 | `document_version_id` | `uuid` | no | — | FK → [`content.document_version`](document_version.md).id |
| 4 | `representation_id` | `uuid` | no | — | FK → [`content.document_representation`](document_representation.md).id |
| 5 | `derived_from_representation_id` | `uuid` | no | — | FK → [`content.document_representation`](document_representation.md).id |
| 6 | `transformation_run_id` | `uuid` | no | — | FK → [`content.transformation_run`](transformation_run.md).id |
| 7 | `summary_kind` | `text` | no | — | — |
| 8 | `scope` | `text` | no | — | — |
| 9 | `scope_node_id` | `uuid` | yes | — | FK → [`content.document_node`](document_node.md).id |
| 10 | `focus_entity_id` | `uuid` | yes | — | FK → [`corpus.entity`](../corpus/entity.md).id |
| 11 | `audience` | `text` | no | `'general'::text` | — |
| 12 | `text` | `text` | no | — | — |
| 13 | `language` | `text` | yes | — | — |
| 14 | `token_count` | `integer` | no | — | — |
| 15 | `content_sha256` | `text` | no | — | — |
| 16 | `coverage_ratio` | `numeric(5,4)` | yes | — | — |
| 17 | `lifecycle` | `text` | no | `'active'::text` | — |
| 18 | `supersedes_id` | `uuid` | yes | — | FK → [`content.document_summary`](document_summary.md).id |
| 19 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- unique (tenant_id, id)
- check `document_summary_audience_check`: `(audience = ANY (ARRAY['general'::text, 'investor'::text, 'engineer'::text, 'learner'::text]))`
- check `document_summary_check`: `((scope <> 'section'::text) OR (scope_node_id IS NOT NULL))`
- check `document_summary_check1`: `((scope <> 'entity_view'::text) OR (focus_entity_id IS NOT NULL))`
- check `document_summary_content_sha256_check`: `(content_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `document_summary_coverage_ratio_check`: `((coverage_ratio >= (0)::numeric) AND (coverage_ratio <= (1)::numeric))`
- check `document_summary_lifecycle_check`: `(lifecycle = ANY (ARRAY['active'::text, 'superseded'::text, 'withdrawn'::text]))`
- check `document_summary_scope_check`: `(scope = ANY (ARRAY['document'::text, 'section'::text, 'chunk_group'::text, 'entity_view'::text]))`
- check `document_summary_summary_kind_check`: `(summary_kind = ANY (ARRAY['abstract'::text, 'executive'::text, 'technical'::text, 'key_claims'::text, 'timeline'::text, 'entity_centric'::…`
- check `document_summary_token_count_check`: `(token_count > 0)`

## Relationships

Outbound: `derived_from_representation_id` → [`content.document_representation`](document_representation.md)`.id` (+tenant); `document_version_id` → [`content.document_version`](document_version.md)`.id` (+tenant); `focus_entity_id` → [`corpus.entity`](../corpus/entity.md)`.id` (+tenant); `representation_id` → [`content.document_representation`](document_representation.md)`.id` (+tenant); `scope_node_id` → [`content.document_node`](document_node.md)`.id` (+tenant); `supersedes_id` → [`content.document_summary`](document_summary.md)`.id` (+tenant); `transformation_run_id` → [`content.transformation_run`](transformation_run.md)`.id` (+tenant).
Inbound: [`content.document_summary`](document_summary.md).supersedes_id, [`content.document_summary_source`](document_summary_source.md).summary_id, [`retrieval.projection_target`](../retrieval/projection_target.md).summary_id.
Polymorphic target of: [`retrieval.projection_target`](../retrieval/projection_target.md) (check constraint projection_target_check).

## Indexes

`document_summary_active_uq` unique where `(lifecycle = 'active'::text)`; `document_summary_tenant_id_id_key` unique

## Triggers

- `summary_content_immutable` → [`content.guard_summary_content`](../../functions/content/guard_summary_content.md)
- `summary_lineage` → [`content.check_summary_lineage`](../../functions/content/check_summary_lineage.md) (constraint trigger, deferred)
- `summary_sources_integrity` → [`content.check_summary_sources`](../../functions/content/check_summary_sources.md) (constraint trigger, deferred)

## Row-level security

Enabled.
- `km_tenant_access` (ALL) for `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`control_plane`: SELECT; `executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`, `pipeline_agent`.

## TypeScript

insert: `Database["content"]["Tables"]["document_summary"]["Insert"]`; row: `Database["content"]["Tables"]["document_summary"]["Row"]`; update: `Database["content"]["Tables"]["document_summary"]["Update"]`

Defined in: `20260912010600_km_06_content.sql`.
