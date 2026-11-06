---
id: "dom:relationships"
kind: domain
schemas: [corpus, taxonomy]
aliases: [graph, edges, relationship kind]
relations: [corpus.relationship, taxonomy.relationship_kind, taxonomy.entity_kind, taxonomy.facet, taxonomy.term, taxonomy.assignment, corpus.media_appearance]
functions: [api.relationships, temporal.assert_relationship]
tasks: [assert-relationship, compose-ingestion-intent, what-do-we-know-about-entity]
summary: One relationship table; kinds constrain endpoints and may carry a relationship_active stream.
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# Relationships

One relationship table; kinds constrain endpoints and may carry a relationship_active stream.

> curated (model_assisted, unreviewed) — `corpus.relationship` is the only edge table. `kind` references
> `taxonomy.relationship_kind`, which lists `from_kinds`, `to_kinds`, whether the edge
> is temporal, and a `property_schema`. Trigger `relationship_kinds` rejects illegal
> endpoint kinds (SQLSTATE 23514). Current edges have `k_to` null; the unique current
> key is `(tenant, kind, from, to, qualifier, episode)`.
> 
> Temporal kinds also need an active `relationship_active` stream on the relationship
> subject. `api.relationships` and `api.current_relationships` hide temporal edges that
> are not active at the requested world time. Non-temporal kinds (`offered_as`,
> `version_of`, `founded`) are current whenever `k_to` is null.
> 
> Read with `q:entity.relationships` (direction both, outgoing, incoming) or
> `q:relationships.current_by_kind`. Check `q:vocab.relationship_kind` before composing
> a relationship.assert proposal. Properties must satisfy property_schema via
> `temporal.payload_valid`. version_of additionally requires a matching pair
> (product_version/product, ai_model_version/ai_model, and so on).
> 
> Facets and terms in `taxonomy` classify entities, knowledge records, or lessons
> through `taxonomy.assignment`; they are not substitutes for relationship kinds.
> `corpus.media_appearance` is a timed mention of an entity inside a media work, not a
> `relationship` row. Agents never insert edges; `temporal.assert_relationship` runs as
> `executor_service` inside a batch.

## Relations that matter

| Relation | Summary | Enforced | Direct writers |
| --- | --- | --- | --- |
| [`corpus.relationship`](../relations/corpus/relationship.md) | One edge table; kinds constrain endpoints and may be temporal. | PK (id); unique (tenant_id, id); RLS | helpers only |
| [`taxonomy.relationship_kind`](../relations/taxonomy/relationship_kind.md) | Edge vocabulary with endpoint kinds, temporal flag, and property schema. | PK (code) | helpers only |
| [`taxonomy.entity_kind`](../relations/taxonomy/entity_kind.md) | Closed list of entity kinds and their canonical typed tables. | PK (code); unique (canonical_schema, canonical_table); RLS | `executor_service` |
| [`taxonomy.facet`](../relations/taxonomy/facet.md) | table | PK (id); unique (tenant_id, slug); RLS | `executor_service` |
| [`taxonomy.term`](../relations/taxonomy/term.md) | table | PK (id); unique (facet_version_id, slug); RLS | `executor_service` |
| [`taxonomy.assignment`](../relations/taxonomy/assignment.md) | table | PK (id); RLS | `executor_service` |
| [`corpus.media_appearance`](../relations/corpus/media_appearance.md) | table | PK (id); unique (tenant_id, id); RLS | `executor_service` |

## Functions

[`api.relationships`](../functions/api/relationships.md), [`temporal.assert_relationship`](../functions/temporal/assert_relationship.md)

## Named queries

[`q:entity.relationships`](../queries/README.md), [`q:relationships.current_by_kind`](../queries/README.md), [`q:vocab.relationship_kind`](../queries/README.md)

## Tasks

[`assert-relationship`](../tasks/assert-relationship.md), [`compose-ingestion-intent`](../tasks/compose-ingestion-intent.md), [`what-do-we-know-about-entity`](../tasks/what-do-we-know-about-entity.md)

Schemas: [`corpus`](../schemas/corpus/README.md), [`taxonomy`](../schemas/taxonomy/README.md).
