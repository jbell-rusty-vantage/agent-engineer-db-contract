---
id: "dom:relationships"
kind: domain
lens: corpus
schemas: [taxonomy]
aliases: [graph, edges, relationship kind, facets, terms]
relations: [catalog.relationship, taxonomy.relationship_kind, taxonomy.entity_kind, taxonomy.facet, taxonomy.facet_version, taxonomy.term, taxonomy.term_relation, taxonomy.term_target_kind, taxonomy.assignment, taxonomy.assignment_review_requirement]
functions: [api.related, api.relationships, catalog.check_relationship_kinds, catalog.check_relationship_properties, temporal.assert_relationship]
tasks: [assert-relationship, compose-ingestion-intent, talk-to-repo-to-paper, what-do-we-know-about-entity]
summary: One relationship table; kinds constrain endpoints and may carry a relationship_active stream.
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
---
# Relationships and taxonomy

One relationship table; kinds constrain endpoints and may carry a relationship_active stream.

> curated (model_assisted, unreviewed) — `catalog.relationship` is the only edge table. `kind` references
> `taxonomy.relationship_kind`, which lists `from_kinds`, `to_kinds`, whether the edge is
> temporal, and a `property_schema`. Trigger `relationship_kinds` rejects illegal endpoint
> kinds (SQLSTATE 23514). Current edges have `k_to` null; the unique current key is
> `(tenant, kind, from, to, qualifier, episode)`. The L1 views fold the common edges into
> columns (developer, provider, speakers, repositories, techniques), so read a view before
> walking edges by hand.
> 
> Temporal kinds (employed_by, offered_by, …) also need an active `relationship_active`
> stream on the relationship subject. `api.relationships` and `api.current_relationships`
> hide temporal edges that are not active at the requested world time. Non-temporal kinds
> (`offered_as`, `version_of`, `has_code`, `presented_at`, `about`, `cites`) are current
> whenever `k_to` is null. `api.related(entity, kind, direction, at)` returns just the ids.
> 
> Read with `q:entity.relationships` (direction both, outgoing, incoming) or
> `q:relationships.current_by_kind`. Check `q:vocab.relationship_kind` before composing a
> relationship.assert proposal. Properties must satisfy property_schema via
> `temporal.payload_valid`. `version_of` additionally requires a matching pair
> (product_version/product, ai_model_version/ai_model, library_release/library).
> 
> Facets and terms in `taxonomy` classify entities, guidance items or authored works through
> `taxonomy.assignment` (cardinality and target scope enforced by triggers); they are not
> substitutes for relationship kinds. Agents never insert edges; `temporal.assert_relationship`
> runs as `executor_service` inside a batch.

## Relations that matter

| Relation | Summary | Enforced | Direct writers |
| --- | --- | --- | --- |
| [`catalog.relationship`](../relations/catalog/relationship.md) | One edge table; kinds constrain endpoints and may be temporal. | PK (id); unique (tenant_id, id); RLS | helpers only |
| [`taxonomy.relationship_kind`](../relations/taxonomy/relationship_kind.md) | Edge vocabulary with endpoint kinds, temporal flag, and property schema. | PK (code) | helpers only |
| [`taxonomy.entity_kind`](../relations/taxonomy/entity_kind.md) | Closed list of entity kinds with the JSON Schema that validates catalog.entity.attributes, the parent kind an… | PK (code); RLS | `executor_service` |
| [`taxonomy.facet`](../relations/taxonomy/facet.md) | table | PK (id); unique (tenant_id, slug); RLS | `executor_service` |
| [`taxonomy.facet_version`](../relations/taxonomy/facet_version.md) | table | PK (id); unique (facet_id, version); RLS | `executor_service` |
| [`taxonomy.term`](../relations/taxonomy/term.md) | table | PK (id); unique (facet_version_id, slug); RLS | `executor_service` |
| [`taxonomy.term_relation`](../relations/taxonomy/term_relation.md) | table | PK (from_term_id, to_term_id, relation_kind); RLS | `executor_service` |
| [`taxonomy.term_target_kind`](../relations/taxonomy/term_target_kind.md) | Restricts secondary taxonomy terms to compatible primary entity kinds. | PK (term_id, entity_kind_code); RLS | `executor_service` |
| [`taxonomy.assignment`](../relations/taxonomy/assignment.md) | table | PK (id); RLS | `executor_service` |
| [`taxonomy.assignment_review_requirement`](../relations/taxonomy/assignment_review_requirement.md) | table | PK (facet_id); RLS | `executor_service` |

## Functions

[`api.related`](../functions/api/related.md), [`api.relationships`](../functions/api/relationships.md), [`catalog.check_relationship_kinds`](../functions/catalog/check_relationship_kinds.md), [`catalog.check_relationship_properties`](../functions/catalog/check_relationship_properties.md), [`temporal.assert_relationship`](../functions/temporal/assert_relationship.md)

## Named queries

[`q:entity.relationships`](../queries/README.md), [`q:relationships.current_by_kind`](../queries/README.md), [`q:vocab.relationship_kind`](../queries/README.md)

## Tasks

[`assert-relationship`](../tasks/assert-relationship.md), [`compose-ingestion-intent`](../tasks/compose-ingestion-intent.md), [`talk-to-repo-to-paper`](../tasks/talk-to-repo-to-paper.md), [`what-do-we-know-about-entity`](../tasks/what-do-we-know-about-entity.md)

Schemas: [`taxonomy`](../schemas/taxonomy/README.md).
