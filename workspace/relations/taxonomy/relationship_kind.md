---
id: "rel:taxonomy.relationship_kind"
kind: table
schema: taxonomy
name: relationship_kind
domain: relationships
lens: corpus
aliases: [relationship vocabulary]
tokens: [taxonomy, relationship_kind, taxonomy.relationship_kind, code, from_kinds, to_kinds, temporal, symmetric, inverse_label, description, property_schema]
summary: "Edge vocabulary with endpoint kinds, temporal flag, and property schema."
summary_basis: curated
rls: disabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"taxonomy\"][\"Tables\"][\"relationship_kind\"][\"Row\"]"
defined_in: ["20260912010100_km_01_vocabularies.sql"]
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# taxonomy.relationship_kind

table in domain `relationships`, lens `corpus`.

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
Inbound: [`catalog.relationship`](../catalog/relationship.md).kind, [`content.unit_assertion_mapping`](../content/unit_assertion_mapping.md).relationship_kind.

## Indexes

_None._

## Triggers

_None._

## Row-level security

Disabled.

## Grants

`control_plane`: SELECT; `executor_service`: SELECT; `pipeline_agent`: SELECT; `service_role`: SELECT; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Named queries: `q:catalog.concepts`, `q:catalog.events`, `q:catalog.organizations`, `q:catalog.papers`, `q:catalog.people`, `q:catalog.software`, `q:catalog.talks`, `q:entity.relationships`, `q:relationships.current_by_kind`, `q:vocab.relationship_kind`.
- Exposed through: [`api.capabilities`](../api/capabilities.md), [`api.compute_devices`](../api/compute_devices.md), [`api.compute_offerings`](../api/compute_offerings.md), [`api.concepts`](../api/concepts.md), [`api.current_relationships`](../api/current_relationships.md), [`api.events`](../api/events.md), [`api.organizations`](../api/organizations.md), [`api.papers`](../api/papers.md), [`api.people`](../api/people.md), [`api.protocol_versions`](../api/protocol_versions.md), [`api.software`](../api/software.md), [`api.talks`](../api/talks.md).
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
