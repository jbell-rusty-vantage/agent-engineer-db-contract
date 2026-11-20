---
id: "rel:content.document_summary"
kind: table
schema: content
name: document_summary
domain: content
lens: corpus
aliases: [summary, prose summary]
tokens: [content, document_summary, content.document_summary, id, tenant_id, document_version_id, representation_id, derived_from_representation_id, transformation_run_id, summary_kind, scope, scope_node_id, focus_entity_id, audience, text, language, token_count, content_sha256, coverage_ratio, lifecycle, supersedes_id, created_at, digest_id]
summary: Prose rendering of a digest for an audience; never evidence by itself.
summary_basis: curated
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, pipeline_agent, service_role]
typescript: "Database[\"content\"][\"Tables\"][\"document_summary\"][\"Row\"]"
defined_in: ["20260912010600_km_06_content.sql"]
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# content.document_summary

table in domain `content`, lens `corpus`.

> curated (model_assisted, unreviewed) — Prose rendering of a digest for an audience; never evidence by itself.

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
| 10 | `focus_entity_id` | `uuid` | yes | — | FK → [`catalog.entity`](../catalog/entity.md).id |
| 11 | `audience` | `text` | no | `'general'::text` | _curated:_ Who the rendering is for. |
| 12 | `text` | `text` | no | — | — |
| 13 | `language` | `text` | yes | — | — |
| 14 | `token_count` | `integer` | no | — | — |
| 15 | `content_sha256` | `text` | no | — | — |
| 16 | `coverage_ratio` | `numeric(5,4)` | yes | — | — |
| 17 | `lifecycle` | `text` | no | `'active'::text` | — |
| 18 | `supersedes_id` | `uuid` | yes | — | FK → [`content.document_summary`](document_summary.md).id |
| 19 | `created_at` | `timestamp with time zone` | no | `now()` | — |
| 20 | `digest_id` | `uuid` | yes | — | FK → [`content.document_digest`](document_digest.md).id; The structured digest this prose summary renders; prose without a digest is not evidence.; _curated:_ The structured digest this prose renders; prose without a digest is not evidence. |

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

Outbound: `derived_from_representation_id` → [`content.document_representation`](document_representation.md)`.id` (+tenant); `digest_id` → [`content.document_digest`](document_digest.md)`.id`; `document_version_id` → [`content.document_version`](document_version.md)`.id` (+tenant); `focus_entity_id` → [`catalog.entity`](../catalog/entity.md)`.id` (+tenant); `representation_id` → [`content.document_representation`](document_representation.md)`.id` (+tenant); `scope_node_id` → [`content.document_node`](document_node.md)`.id` (+tenant); `supersedes_id` → [`content.document_summary`](document_summary.md)`.id` (+tenant); `transformation_run_id` → [`content.transformation_run`](transformation_run.md)`.id` (+tenant).
Inbound: [`content.document_summary`](document_summary.md).supersedes_id, [`content.document_summary_source`](document_summary_source.md).summary_id, [`retrieval.projection_target`](../retrieval/projection_target.md).summary_id.
Polymorphic target of: [`retrieval.projection_target`](../retrieval/projection_target.md) (check constraint projection_target_exactly_one).

## Indexes

2 indexes; see [details](document_summary.details.md).

## Triggers

3 triggers; see [details](document_summary.details.md).

## Row-level security

Enabled; 1 policies in [details](document_summary.details.md).

## Grants

`control_plane`: SELECT; `executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`, `pipeline_agent`.

## TypeScript

insert: `Database["content"]["Tables"]["document_summary"]["Insert"]`; row: `Database["content"]["Tables"]["document_summary"]["Row"]`; update: `Database["content"]["Tables"]["document_summary"]["Update"]`

## Examples

Read the digest instead

```bash
knowledge db query content.document_digest --param document_id=0192b000-0000-7000-8000-000000000001
```
api.summary_evidence expands a summary into faithful nodes and locators.

Defined in: `20260912010600_km_06_content.sql`.
