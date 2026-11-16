---
id: "rel:content.unit_kind"
kind: table
schema: content
name: unit_kind
domain: content
lens: corpus
aliases: [grammar, unit kinds]
tokens: [content, unit_kind, content.unit_kind, code, version, status, description, is_universal, applicable_document_types, parent_kinds, attributes_schema, logical_key_attributes, selector_kind, retrieval_role, entity_roles]
summary: "Grammar as data — the typed units a document kind decomposes into, with JSON Schema, logical-key attributes, locator kind, retrieval role and entity roles."
summary_basis: curated
rls: disabled
readers: [app_reader, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"content\"][\"Tables\"][\"unit_kind\"][\"Row\"]"
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", part2_content.sql]
workspace_fingerprint: "sha256:94ffe6a458de74a3cfebdee4fb31f371d14c89d7eaa16cfe1ab1cae9dc94743b"
---
# content.unit_kind

table in domain `content`, lens `corpus` — Grammar as data: the typed units a document kind decomposes into, with a JSON Schema for attributes, the attributes forming the logical key (stable across captures), the locator kind and the retrieval role. Universal units apply to every kind..

> curated (model_assisted, unreviewed) — Grammar as data — the typed units a document kind decomposes into, with JSON Schema, logical-key attributes, locator kind, retrieval role and entity roles.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `code` | `text` | no | — | PK |
| 2 | `version` | `integer` | no | `1` | PK |
| 3 | `status` | `text` | no | `'active'::text` | — |
| 4 | `description` | `text` | no | — | — |
| 5 | `is_universal` | `boolean` | no | `false` | — |
| 6 | `applicable_document_types` | `text[]` | yes | — | _curated:_ Document kinds that use this unit kind; universal units apply to every kind. |
| 7 | `parent_kinds` | `text[]` | yes | — | — |
| 8 | `attributes_schema` | `jsonb` | no | `'{"type": "object"}'::jsonb` | — |
| 9 | `logical_key_attributes` | `text[]` | no | `'{}'::text[]` | _curated:_ Attribute names whose values form the logical key. |
| 10 | `selector_kind` | `text` | no | — | — |
| 11 | `retrieval_role` | `text` | no | `'embed'::text` | _curated:_ How the unit is indexed (searchable text, structural, metadata). |
| 12 | `entity_roles` | `text[]` | no | `'{}'::text[]` | _curated:_ Roles content.unit_entity_role may use for this kind (offering, provider, speaker, software, …). |

## Constraints

- PK (code, version)
- check `unit_kind_retrieval_role_check`: `(retrieval_role = ANY (ARRAY['embed'::text, 'filter'::text, 'structure_only'::text]))`
- check `unit_kind_selector_kind_check`: `(selector_kind = ANY (ARRAY['text_quote'::text, 'character_position'::text, 'multi_fragment_text'::text, 'json_pointer'::text, 'html'::text…`
- check `unit_kind_status_check`: `(status = ANY (ARRAY['candidate'::text, 'active'::text, 'retired'::text]))`
- check `unit_kind_version_check`: `(version >= 1)`

## Relationships

Outbound: none.
Inbound: [`content.document_node`](document_node.md).unit_kind,unit_kind_version, [`content.unit_assertion_mapping`](unit_assertion_mapping.md).unit_kind,unit_kind_version.

## Indexes

_None._

## Triggers

_None._

## Row-level security

Disabled.

## Grants

`app_reader`: SELECT; `control_plane`: SELECT; `executor_service`: SELECT; `pipeline_agent`: SELECT; `service_role`: SELECT; `verifier_agent`: SELECT. None: `anon`, `authenticated`.

## Read paths

- Named queries: `q:vocab.unit_kind`.
- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- No direct DML for any agent role.
- No write path for agents; rows are seeded by migrations or platform tooling.

## TypeScript

insert: `Database["content"]["Tables"]["unit_kind"]["Insert"]`; row: `Database["content"]["Tables"]["unit_kind"]["Row"]`; update: `Database["content"]["Tables"]["unit_kind"]["Update"]`

## Examples

Grammar of a pricing page

```bash
knowledge db query vocab.unit_kind --param code=null --param document_type=pricing_page
```
price_row plus the universal units.

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `part2_content.sql`.
