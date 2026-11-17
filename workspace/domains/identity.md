---
id: "dom:identity"
kind: domain
lens: corpus
schemas: [catalog]
aliases: [entity, canonical entity, aliases, identifiers, catalog, works]
relations: [catalog.entity, catalog.entity_alias, catalog.entity_identifier, catalog.entity_merge, catalog.work, taxonomy.entity_kind, catalog.license, catalog.media_platform, catalog.distribution_kind]
functions: [api.entity_card, api.resolve_entity, catalog.rebuild_entity_projections, catalog.validate_entity_attributes]
tasks: [compose-ingestion-intent, find-entity-by-identifier, resolve-or-create-entity, stage-uncertain-candidate, what-do-we-know-about-entity]
summary: "One canonical row per industry identity; kind-specific attributes are a validated jsonb, not typed tables."
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# Identities (catalog)

One canonical row per industry identity; kind-specific attributes are a validated jsonb, not typed tables.

> curated (model_assisted, unreviewed) — `catalog.entity` is the identity. `kind` is a foreign key to `taxonomy.entity_kind`
> (36 kinds: organization, person, ai_model, ai_model_version, model_offering, library,
> repository, mcp_server, agent_skill, paper, talk, concept, technique, …). Since Build 08
> the thirty-six thin typed tables are gone: kind-specific attributes live in
> `catalog.entity.attributes` and trigger `catalog.validate_entity_attributes` checks them
> against `taxonomy.entity_kind.attributes_schema` (pg_jsonschema). Numbers that change over
> time (prices, context windows, headcount, stars) are fact streams in `temporal`, never
> attributes. `parent_kind` says which kind a kind versions (model version → model); the link
> itself is a `catalog.relationship`. Work kinds (`is_work`: paper, talk, media_work, story,
> case_study) also have a bibliographic row in `catalog.work`; their content is
> `content.document` rows with `work_entity_id`.
> 
> Resolve before creating. `q:entity.resolve` (`api.resolve_entity`) matches display name,
> alias and identifier value and returns at most 25 active rows. Prefer
> `q:entity.by_identifier` when the source prints a schemed id: `(scheme, value)` is unique
> per tenant. `q:entity.attributes` returns the row with its attributes and the kind's schema.
> `q:entity.card` is the current overview for agents on `app_reader`. For a table of a kind
> (all models, all organizations) go to the L1 views in `dom:api-surface` instead.
> 
> Aliases are typed (synonym, acronym, former_name, handle, ticker, slug, misspelling,
> translation, model_alias) and unique per entity, not globally. Identifiers use a closed
> `scheme` check; unknown namespaces belong in `other`. Merges are `catalog.entity_merge`
> rows: the loser becomes `lifecycle='merged'` with `merged_into_id`; resolve excludes them.
> 
> Writers are `executor_service` only, and every entity needs `created_by_receipt_id`.
> Agents author entity.create / entity.alias / entity.identifier proposals with an
> `attributes` object; if resolve is ambiguous use candidate.stage. Traps: treating
> display_name as a unique key; inventing identifier schemes; putting a price or a date
> that moves into attributes; creating a `model_offering` without its parent
> `ai_model_version` (the `offered_as` relationship and `parent_kind`).

## Relations that matter

| Relation | Summary | Enforced | Direct writers |
| --- | --- | --- | --- |
| [`catalog.entity`](../relations/catalog/entity.md) | One row per canonical identity; kind-specific attributes are a jsonb validated by taxonomy.entity_kind.attrib… | PK (id); unique (tenant_id, id), (tenant_id, id, kind), (tenant_id, kind, slug); RLS | `executor_service` |
| [`catalog.entity_alias`](../relations/catalog/entity_alias.md) | Typed alternate name for one entity; unique per entity, not globally. | PK (id); unique (tenant_id, entity_id, alias_normalized, alias_kind), (tenant_id, id); RLS | `executor_service` |
| [`catalog.entity_identifier`](../relations/catalog/entity_identifier.md) | Schemed external identifier; unique per tenant on (scheme, value). | PK (id); unique (tenant_id, id), (tenant_id, scheme, value); RLS | `executor_service` |
| [`catalog.entity_merge`](../relations/catalog/entity_merge.md) | Durable merge of two entities; loser becomes lifecycle merged. | PK (id); unique (tenant_id, id); RLS | `executor_service` |
| [`catalog.work`](../relations/catalog/work.md) | Bibliographic row behind a work entity (paper, talk, media work, story, case study); content lives in content… | PK (id); unique (tenant_id, id) | helpers only |
| [`taxonomy.entity_kind`](../relations/taxonomy/entity_kind.md) | Closed list of entity kinds with the JSON Schema that validates catalog.entity.attributes, the parent kind an… | PK (code); RLS | `executor_service` |
| [`catalog.license`](../relations/catalog/license.md) | table | PK (code) | `executor_service` |
| [`catalog.media_platform`](../relations/catalog/media_platform.md) | table | PK (code) | `executor_service` |
| [`catalog.distribution_kind`](../relations/catalog/distribution_kind.md) | table | PK (code) | `executor_service` |

## Functions

[`api.entity_card`](../functions/api/entity_card.md), [`api.resolve_entity`](../functions/api/resolve_entity.md), [`catalog.rebuild_entity_projections`](../functions/catalog/rebuild_entity_projections.md), [`catalog.validate_entity_attributes`](../functions/catalog/validate_entity_attributes.md)

## Named queries

[`q:entity.attributes`](../queries/README.md), [`q:entity.by_identifier`](../queries/README.md), [`q:entity.card`](../queries/README.md), [`q:entity.resolve`](../queries/README.md)

## Tasks

[`compose-ingestion-intent`](../tasks/compose-ingestion-intent.md), [`find-entity-by-identifier`](../tasks/find-entity-by-identifier.md), [`resolve-or-create-entity`](../tasks/resolve-or-create-entity.md), [`stage-uncertain-candidate`](../tasks/stage-uncertain-candidate.md), [`what-do-we-know-about-entity`](../tasks/what-do-we-know-about-entity.md)

Schemas: [`catalog`](../schemas/catalog/README.md).
