---
id: "dom:identity"
kind: domain
schemas: [corpus]
aliases: [entity, canonical entity, aliases, identifiers]
relations: [corpus.entity, corpus.entity_alias, corpus.entity_identifier, corpus.entity_merge, taxonomy.entity_kind, corpus.organization, corpus.person, corpus.product, corpus.ai_model, corpus.ai_model_version, corpus.model_offering]
functions: [api.entity_card, api.resolve_entity]
tasks: [compose-ingestion-intent, find-entity-by-identifier, resolve-or-create-entity, stage-uncertain-candidate, what-do-we-know-about-entity]
summary: "One canonical row per industry identity; typed attributes live in corpus.<kind>."
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# Identities

One canonical row per industry identity; typed attributes live in corpus.<kind>.

> curated (model_assisted, unreviewed) — `corpus.entity` is the identity. `kind` is a foreign key to `taxonomy.entity_kind` and
> picks the typed child table (`canonical_schema` / `canonical_table`). Thirty-six kinds
> share the composite key `(tenant_id, id, kind)`. Display name and slug live on the
> identity row as projections; the authoritative name series is the
> `temporal.stream_kind:entity_name` stream.
> 
> Resolve before creating. `q:entity.resolve` (`api.resolve_entity`) matches display
> name, alias, and identifier value and returns at most 25 active rows. Prefer
> `q:entity.by_identifier` when the source prints a schemed id: `(scheme, value)` is
> unique per tenant. `q:entity.typed_row` joins the kind-dispatched child. `q:entity.card`
> is the current overview for agents on `app_reader`.
> 
> Aliases are typed (`alias_kind` in synonym, acronym, former_name, handle, ticker, slug,
> misspelling, translation, model_alias) and unique per entity, not globally. Identifiers
> use a closed `scheme` check; unknown namespaces belong in `other`. Merges are
> `corpus.entity_merge` rows: the loser becomes `lifecycle='merged'` with `merged_into_id`.
> Resolve excludes merged rows.
> 
> Writers are `executor_service` only, and every entity needs `created_by_receipt_id`.
> Agents author entity.create / entity.alias / entity.identifier proposals. If
> resolve is ambiguous, use candidate.stage rather than guessing a new id. Common
> traps: treating display_name as a unique key; inventing identifier schemes; creating
> a `corpus.model_offering` without the parent `corpus.ai_model_version`.

## Relations that matter

| Relation | Summary | Enforced | Direct writers |
| --- | --- | --- | --- |
| [`corpus.entity`](../relations/corpus/entity.md) | One row per canonical identity; typed attributes live in corpus.<kind>. | PK (id); unique (tenant_id, id), (tenant_id, id, kind), (tenant_id, kind, slug); RLS | `executor_service` |
| [`corpus.entity_alias`](../relations/corpus/entity_alias.md) | Typed alternate name for one entity; unique per entity, not globally. | PK (id); unique (tenant_id, entity_id, alias_normalized, alias_kind), (tenant_id, id); RLS | `executor_service` |
| [`corpus.entity_identifier`](../relations/corpus/entity_identifier.md) | Schemed external identifier; unique per tenant on (scheme, value). | PK (id); unique (tenant_id, id), (tenant_id, scheme, value); RLS | `executor_service` |
| [`corpus.entity_merge`](../relations/corpus/entity_merge.md) | Durable merge of two entities; loser becomes lifecycle merged. | PK (id); unique (tenant_id, id); RLS | `executor_service` |
| [`taxonomy.entity_kind`](../relations/taxonomy/entity_kind.md) | Closed list of entity kinds and their canonical typed tables. | PK (code); unique (canonical_schema, canonical_table); RLS | `executor_service` |
| [`corpus.organization`](../relations/corpus/organization.md) | Typed child of corpus.entity for kind organization. | PK (id); unique (tenant_id, id); RLS | `executor_service` |
| [`corpus.person`](../relations/corpus/person.md) | Typed child of corpus.entity for kind person. | PK (id); unique (tenant_id, id); RLS | `executor_service` |
| [`corpus.product`](../relations/corpus/product.md) | table | PK (id); unique (tenant_id, id); RLS | `executor_service` |
| [`corpus.ai_model`](../relations/corpus/ai_model.md) | Typed child for an AI model family (not a version or offering). | PK (id); unique (tenant_id, id); RLS | `executor_service` |
| [`corpus.ai_model_version`](../relations/corpus/ai_model_version.md) | Typed child for one version of an ai_model. | PK (id); unique (tenant_id, id); RLS | `executor_service` |
| [`corpus.model_offering`](../relations/corpus/model_offering.md) | A priced, deployable offering of an ai_model_version from a provider. | PK (id); unique (tenant_id, id); RLS | `executor_service` |

## Functions

[`api.entity_card`](../functions/api/entity_card.md), [`api.resolve_entity`](../functions/api/resolve_entity.md)

## Named queries

[`q:entity.by_identifier`](../queries/README.md), [`q:entity.card`](../queries/README.md), [`q:entity.resolve`](../queries/README.md), [`q:entity.typed_row`](../queries/README.md)

## Tasks

[`compose-ingestion-intent`](../tasks/compose-ingestion-intent.md), [`find-entity-by-identifier`](../tasks/find-entity-by-identifier.md), [`resolve-or-create-entity`](../tasks/resolve-or-create-entity.md), [`stage-uncertain-candidate`](../tasks/stage-uncertain-candidate.md), [`what-do-we-know-about-entity`](../tasks/what-do-we-know-about-entity.md)

Schemas: [`corpus`](../schemas/corpus/README.md).
