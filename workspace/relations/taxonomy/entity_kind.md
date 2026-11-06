---
id: "rel:taxonomy.entity_kind"
kind: table
schema: taxonomy
name: entity_kind
domain: identity
aliases: [entity vocabulary]
tokens: [taxonomy, entity_kind, taxonomy.entity_kind, code, label, canonical_schema, canonical_table, description]
summary: Closed list of entity kinds and their canonical typed tables.
summary_basis: curated
rls: enabled
readers: [app_reader, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"taxonomy\"][\"Tables\"][\"entity_kind\"][\"Row\"]"
defined_in: ["20260829192855_optimize_ai_entity_taxonomy_and_relationships.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# taxonomy.entity_kind

table in domain `identity` — Primary canonical AI knowledge entity divisions and their typed corpus tables..

> curated (model_assisted, unreviewed) — Closed list of entity kinds and their canonical typed tables.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `code` | `text` | no | — | PK |
| 2 | `label` | `text` | no | `''::text` | — |
| 3 | `canonical_schema` | `text` | no | `'corpus'::text` | unique (canonical_schema, canonical_table) |
| 4 | `canonical_table` | `text` | no | `''::text` | unique (canonical_schema, canonical_table); _curated:_ Always a corpus table for the 36 industry kinds. |
| 5 | `description` | `text` | no | — | — |

## Constraints

- PK (code)
- unique (canonical_schema, canonical_table)

## Relationships

Outbound: none.
Inbound: [`content.document_type`](../content/document_type.md).work_entity_kind, [`corpus.entity`](../corpus/entity.md).kind, [`orchestration.operation_receipt_target`](../orchestration/operation_receipt_target.md).entity_kind, [`staging.candidate`](../staging/candidate.md).proposed_kind, [`taxonomy.term_target_kind`](term_target_kind.md).entity_kind_code.

## Indexes

`entity_kind_canonical_schema_canonical_table_key` unique

## Triggers

_None._

## Row-level security

Enabled.
- `global_vocabulary_read` (SELECT) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `true`

## Grants

`app_reader`: SELECT; `executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: SELECT; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `authenticated`, `control_plane`.

## Read paths

- Named queries: `q:entity.typed_row`.
- Direct SELECT: `app_reader`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["taxonomy"]["Tables"]["entity_kind"]["Insert"]`; row: `Database["taxonomy"]["Tables"]["entity_kind"]["Row"]`; update: `Database["taxonomy"]["Tables"]["entity_kind"]["Update"]`

## Examples

Dispatch the typed row

```bash
knowledge db query entity.typed_row --param entity_id=0192b000-0000-7000-8000-000000000001 --param kind=organization
```
Join uses ek.code = entity.kind.

Defined in: `20260829192855_optimize_ai_entity_taxonomy_and_relationships.sql`.
