---
id: "rel:taxonomy.relationship_kind"
kind: table
schema: taxonomy
name: relationship_kind
domain: relationships
aliases: [relationship vocabulary]
tokens: [taxonomy, relationship_kind, taxonomy.relationship_kind, code, from_kinds, to_kinds, temporal, symmetric, inverse_label, description, property_schema]
summary: "Edge vocabulary with endpoint kinds, temporal flag, and property schema."
summary_basis: curated
rls: disabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"taxonomy\"][\"Tables\"][\"relationship_kind\"][\"Row\"]"
defined_in: ["20260912010100_km_01_vocabularies.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# taxonomy.relationship_kind

table in domain `relationships`.

> curated (model_assisted, unreviewed) — Edge vocabulary with endpoint kinds, temporal flag, and property schema.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `code` | `text` | no | — | PK |
| 2 | `from_kinds` | `text[]` | no | — | _curated:_ Allowed from-entity kinds. |
| 3 | `to_kinds` | `text[]` | no | — | _curated:_ Allowed to-entity kinds. |
| 4 | `temporal` | `boolean` | no | — | _curated:_ When true, a relationship_active stream is required. |
| 5 | `symmetric` | `boolean` | no | `false` | — |
| 6 | `inverse_label` | `text` | yes | — | — |
| 7 | `description` | `text` | no | — | — |
| 8 | `property_schema` | `jsonb` | no | `'{}'::jsonb` | — |

## Constraints

- PK (code)

## Relationships

Outbound: none.
Inbound: [`corpus.relationship`](../corpus/relationship.md).kind.

## Indexes

_None._

## Triggers

_None._

## Row-level security

Disabled.

## Grants

`control_plane`: SELECT; `executor_service`: SELECT; `pipeline_agent`: SELECT; `service_role`: SELECT; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Named queries: `q:entity.relationships`, `q:relationships.current_by_kind`, `q:vocab.relationship_kind`.
- Exposed through: [`api.current_relationships`](../api/current_relationships.md).
- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- No direct DML for any agent role.
- No write path for agents; rows are seeded by migrations or platform tooling.

## TypeScript

insert: `Database["taxonomy"]["Tables"]["relationship_kind"]["Insert"]`; row: `Database["taxonomy"]["Tables"]["relationship_kind"]["Row"]`; update: `Database["taxonomy"]["Tables"]["relationship_kind"]["Update"]`

## Examples

employed_by slot

```bash
knowledge db query vocab.relationship_kind --param code=employed_by
```
person to organization, temporal true.

Defined in: `20260912010100_km_01_vocabularies.sql`.
