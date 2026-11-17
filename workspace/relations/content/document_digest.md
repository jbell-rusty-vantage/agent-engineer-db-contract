---
id: "rel:content.document_digest"
kind: table
schema: content
name: document_digest
domain: content
lens: corpus
aliases: [digest]
tokens: [content, document_digest, content.document_digest, id, tenant_id, document_version_id, scope, scope_node_id, focus_entity_id, digest_schema_version, producer_identity, producer_kind, transformation_run_id, lifecycle, created_at]
summary: "Structured digest of a version (or section/entity view); items are records anchored to units, prose summaries only render it."
summary_basis: curated
rls: enabled
readers: [app_reader, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"content\"][\"Tables\"][\"document_digest\"][\"Row\"]"
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", part2_content.sql]
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# content.document_digest

table in domain `content`, lens `corpus` — A structured digest of a version (or section/entity view): items are records anchored to units; prose summaries in content.document_summary are renderings of a digest, never evidence..

> curated (model_assisted, unreviewed) — Structured digest of a version (or section/entity view); items are records anchored to units, prose summaries only render it.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `id` | `uuid` | no | `util.uuidv7()` | PK |
| 2 | `tenant_id` | `uuid` | no | `util.default_tenant_id()` | — |
| 3 | `document_version_id` | `uuid` | no | — | — |
| 4 | `scope` | `text` | no | — | _curated:_ version, section or entity view; scope_node_id / focus_entity_id narrow it. |
| 5 | `scope_node_id` | `uuid` | yes | — | — |
| 6 | `focus_entity_id` | `uuid` | yes | — | FK → [`catalog.entity`](../catalog/entity.md).id |
| 7 | `digest_schema_version` | `text` | no | `'aieng.digest.v1'::text` | — |
| 8 | `producer_identity` | `text` | no | — | — |
| 9 | `producer_kind` | `text` | no | — | _curated:_ rule, model or person. |
| 10 | `transformation_run_id` | `uuid` | yes | — | — |
| 11 | `lifecycle` | `text` | no | `'active'::text` | _curated:_ Only active digests are read by api.document_digest. |
| 12 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (id)
- check `digest_entity_scope`: `((scope <> 'entity_view'::text) OR (focus_entity_id IS NOT NULL))`
- check `digest_section_scope`: `((scope <> 'section'::text) OR (scope_node_id IS NOT NULL))`
- check `document_digest_lifecycle_check`: `(lifecycle = ANY (ARRAY['active'::text, 'superseded'::text, 'withdrawn'::text]))`
- check `document_digest_producer_kind_check`: `(producer_kind = ANY (ARRAY['deterministic'::text, 'model'::text, 'person'::text]))`
- check `document_digest_scope_check`: `(scope = ANY (ARRAY['document'::text, 'section'::text, 'entity_view'::text]))`

## Relationships

Outbound: `focus_entity_id` → [`catalog.entity`](../catalog/entity.md)`.id`; `tenant_id,document_version_id` → [`content.document_version`](document_version.md)`.tenant_id,id`; `tenant_id,scope_node_id` → [`content.document_node`](document_node.md)`.tenant_id,id`; `tenant_id,transformation_run_id` → [`content.transformation_run`](transformation_run.md)`.tenant_id,id`.
Inbound: [`content.digest_item`](digest_item.md).digest_id, [`content.document_summary`](document_summary.md).digest_id, [`retrieval.projection_target`](../retrieval/projection_target.md).digest_id.
Polymorphic target of: [`retrieval.projection_target`](../retrieval/projection_target.md) (check constraint projection_target_exactly_one).

## Indexes

_None._

## Triggers

_None._

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `(tenant_id = util.current_tenant_id())`

## Grants

`app_reader`: SELECT; `control_plane`: SELECT; `executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: SELECT; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `authenticated`.

## Read paths

- Named queries: `q:content.document_digest`.
- Exposed through: [`api.digest_items`](../api/digest_items.md).
- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["content"]["Tables"]["document_digest"]["Insert"]`; row: `Database["content"]["Tables"]["document_digest"]["Row"]`; update: `Database["content"]["Tables"]["document_digest"]["Update"]`

## Examples

Digest of a document

```bash
knowledge db query content.document_digest --param document_id=0192b000-0000-7000-8000-000000000001
```
Newest version only.

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `part2_content.sql`.
