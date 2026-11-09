---
id: "rel:taxonomy.entity_kind"
kind: table
schema: taxonomy
name: entity_kind
domain: identity
lens: corpus
aliases: [entity vocabulary, kinds]
tokens: [taxonomy, entity_kind, taxonomy.entity_kind, code, label, canonical_schema, canonical_table, description, attributes_schema, parent_kind, lens, is_work]
summary: "Closed list of entity kinds with the JSON Schema that validates catalog.entity.attributes, the parent kind and the work flag."
summary_basis: curated
rls: enabled
readers: [app_reader, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"taxonomy\"][\"Tables\"][\"entity_kind\"][\"Row\"]"
defined_in: ["20260829192855_optimize_ai_entity_taxonomy_and_relationships.sql"]
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
---
# taxonomy.entity_kind

table in domain `identity`, lens `corpus` — Primary canonical AI knowledge entity divisions and their typed corpus tables..

> curated (model_assisted, unreviewed) — Closed list of entity kinds with the JSON Schema that validates catalog.entity.attributes, the parent kind and the work flag.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `code` | `text` | no | — | PK |
| 2 | `label` | `text` | no | `''::text` | — |
| 3 | `canonical_schema` | `text` | no | `'corpus'::text` | — |
| 4 | `canonical_table` | `text` | no | `''::text` | — |
| 5 | `description` | `text` | no | — | — |
| 6 | `attributes_schema` | `jsonb` | no | `'{"type": "object"}'::jsonb` | JSON Schema validating catalog.entity.attributes for this kind (pg_jsonschema).; _curated:_ JSON Schema (pg_jsonschema) for catalog.entity.attributes of this kind. |
| 7 | `parent_kind` | `text` | yes | — | FK → [`taxonomy.entity_kind`](entity_kind.md).code; Kind whose rows this kind versions or belongs to (model version -> model); the link itself is a catalog.relationship.; _curated:_ Kind whose rows this kind versions or belongs to (model version -> model); the link itself is a catalog.relationship. |
| 8 | `lens` | `text` | no | `'corpus'::text` | _curated:_ Whose knowledge rows of this kind are (corpus for every industry kind). |
| 9 | `is_work` | `boolean` | no | `false` | _curated:_ True for kinds that also have a catalog.work row and content.document rows. |

## Constraints

- PK (code)
- check `entity_kind_lens_check`: `(lens = ANY (ARRAY['corpus'::text, 'ours'::text, 'machinery'::text]))`

## Relationships

Outbound: `parent_kind` → [`taxonomy.entity_kind`](entity_kind.md)`.code`.
Inbound: [`catalog.entity`](../catalog/entity.md).kind, [`content.document_type`](../content/document_type.md).work_entity_kind, [`orchestration.operation_receipt_target`](../orchestration/operation_receipt_target.md).entity_kind, [`staging.candidate`](../staging/candidate.md).proposed_kind, [`taxonomy.entity_kind`](entity_kind.md).parent_kind, [`taxonomy.term_target_kind`](term_target_kind.md).entity_kind_code.
Polymorphic: `parent_kind` selects one of 36 typed tables listed in [`taxonomy.entity_kind`](../../vocabularies/taxonomy.entity_kind.md) (`canonical_table`) — basis: vocabulary taxonomy.entity_kind.canonical_table + FK entity_kind_parent_kind_fkey.

## Indexes

_None._

## Triggers

_None._

## Row-level security

Enabled.
- `global_vocabulary_read` (SELECT) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `true`

## Grants

`app_reader`: SELECT; `executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: SELECT; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `authenticated`, `control_plane`.

## Read paths

- Named queries: `q:entity.attributes`.
- Direct SELECT: `app_reader`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["taxonomy"]["Tables"]["entity_kind"]["Insert"]`; row: `Database["taxonomy"]["Tables"]["entity_kind"]["Row"]`; update: `Database["taxonomy"]["Tables"]["entity_kind"]["Update"]`

## Examples

Attributes with their kind schema

```bash
knowledge db query entity.attributes --param entity_id=0192b000-0000-7000-8000-000000000001 --param kind=organization
```
Join uses ek.code = entity.kind.

Defined in: `20260829192855_optimize_ai_entity_taxonomy_and_relationships.sql`.
