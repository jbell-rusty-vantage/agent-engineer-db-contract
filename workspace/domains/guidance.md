---
id: "dom:guidance"
kind: domain
lens: corpus
schemas: [guidance]
aliases: [engineering records, technical records, failure modes, solution patterns, how-to]
relations: [guidance.item, guidance.item_subject, guidance.item_kind, guidance.assurance_level]
functions: []
tasks: [modules-covering-concept, what-do-we-know-about-entity]
summary: "Typed expert knowledge items (problem, pattern, failure mode, constraint, practice, example, security, usage) bound to entities, created only with a receipt."
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# Expert guidance items

Typed expert knowledge items (problem, pattern, failure mode, constraint, practice, example, security, usage) bound to entities, created only with a receipt.

> curated (model_assisted, unreviewed) — `guidance.item` (formerly knowledge.record) is one expert knowledge statement: `kind` from
> `guidance.item_kind` (technical_problem, solution_pattern, failure_mode,
> compatibility_constraint, operational_practice, implementation_example,
> security_consideration, advanced_usage_pattern, setup_guide_step, research_direction),
> title, statement, `scope`, `assurance_level` (`guidance.assurance_level`), a provenance
> claim, `applies_to_version_ids` and a typed `payload` validated by the kind's
> `payload_schema`. `guidance.item_subject` names the entities it is about and their role
> (subject, component, version, alternative). `source_node_id` anchors it on the typed unit
> it was learned from.
> 
> Read with `q:guidance.items` (`api.guidance_items`, lens corpus, filter by kind, entity or
> text) or through `api.concepts.guidance_items` counts. Items are also retrieval projection
> targets (`retrieval.projection_target.record_id`) and evidence-packet members, so
> `q:retrieval.search_unified` finds them by text.
> 
> Only `executor_service` creates items, and `created_by_receipt_id` is required. These are
> not temporal segments: a price or availability fact belongs in `temporal.segment`; a
> how-to-call-the-API pattern belongs here, linked to the library entity and backed by a
> claim. Course content cites these rows rather than restating them. Trap: writing a
> benchmark number here when it is a `benchmark_score` stream fact.

## Relations that matter

| Relation | Summary | Enforced | Direct writers |
| --- | --- | --- | --- |
| [`guidance.item`](../relations/guidance/item.md) | One expert knowledge item typed by guidance.item_kind with assurance, provenance claim and a kind-validated p… | PK (id); unique (tenant_id, id), (tenant_id, id, kind); RLS | `executor_service` |
| [`guidance.item_subject`](../relations/guidance/item_subject.md) | Which entities an item is about and in which role (subject, component, version, alternative). | PK (tenant_id, item_id, entity_id, role); RLS | `executor_service` |
| [`guidance.item_kind`](../relations/guidance/item_kind.md) | Vocabulary of guidance item kinds; payload_schema validates guidance.item.payload. | PK (code) | helpers only |
| [`guidance.assurance_level`](../relations/guidance/assurance_level.md) | table | PK (code); unique (rank); RLS | `executor_service` |

## Named queries

[`q:entity.card`](../queries/README.md), [`q:guidance.items`](../queries/README.md)

## Tasks

[`modules-covering-concept`](../tasks/modules-covering-concept.md), [`what-do-we-know-about-entity`](../tasks/what-do-we-know-about-entity.md)

Schemas: [`guidance`](../schemas/guidance/README.md).
