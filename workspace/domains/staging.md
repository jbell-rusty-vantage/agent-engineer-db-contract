---
id: "dom:staging"
kind: domain
lens: corpus
schemas: [staging]
aliases: [candidates, review, identity match]
relations: [staging.candidate, staging.identity_match, staging.resolution_decision, staging.vetting_decision, taxonomy.entity_kind]
functions: [api.resolve_entity]
tasks: [compose-ingestion-intent, resolve-or-create-entity, stage-uncertain-candidate]
summary: "Candidates for new identities, not a staging copy of facts."
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# Staging and identity resolution

Candidates for new identities, not a staging copy of facts.

> curated (model_assisted, unreviewed) — `staging.candidate` holds a proposed kind, payload, optional source, and optional
> resolved entity. It is the identity-resolution zone. It is not a draft `temporal.segment`.
> `staging.identity_match` records scored matches. `staging.resolution_decision`
> (create, match, reject, defer) and `staging.vetting_decision` (admit, reject, defer)
> each require a receipt.
> 
> `q:staging.unresolved` lists candidates with no create/match/reject decision.
> `q:staging.candidates_for_kind` filters by `proposed_kind`. Low-confidence resolve
> results should become candidate.stage (rule stage.when_confidence_below_threshold)
> instead of entity.create.
> 
> `proposed_kind` must exist in `taxonomy.entity_kind`. Pipeline agents may insert
> candidates; only the executor writes decisions with a receipt. Review tasks in
> `evaluation` can point at a candidate. Do not park an uncertain price here — use belief
> disputed or stage only the unknown organization. The source_id on the candidate should
> point at the `evidence.source` that mentioned the name, so later merges have a quote.

## Relations that matter

| Relation | Summary | Enforced | Direct writers |
| --- | --- | --- | --- |
| [`staging.candidate`](../relations/staging/candidate.md) | Proposed identity awaiting resolution; not a draft fact. | PK (id); unique (tenant_id, id); RLS | `executor_service`, `pipeline_agent` |
| [`staging.identity_match`](../relations/staging/identity_match.md) | Scored match between a candidate and an existing entity. | PK (id); unique (tenant_id, id); RLS | `executor_service`, `pipeline_agent` |
| [`staging.resolution_decision`](../relations/staging/resolution_decision.md) | create, match, reject, or defer decision with a receipt. | PK (id); unique (tenant_id, id); RLS | `executor_service`, `pipeline_agent` |
| [`staging.vetting_decision`](../relations/staging/vetting_decision.md) | admit, reject, or defer vetting decision with a receipt. | PK (id); unique (tenant_id, id); RLS | `executor_service`, `pipeline_agent` |
| [`taxonomy.entity_kind`](../relations/taxonomy/entity_kind.md) | Closed list of entity kinds with the JSON Schema that validates catalog.entity.attributes, the parent kind an… | PK (code); RLS | `executor_service` |

## Functions

[`api.resolve_entity`](../functions/api/resolve_entity.md)

## Named queries

[`q:staging.candidates_for_kind`](../queries/README.md), [`q:staging.unresolved`](../queries/README.md)

## Tasks

[`compose-ingestion-intent`](../tasks/compose-ingestion-intent.md), [`resolve-or-create-entity`](../tasks/resolve-or-create-entity.md), [`stage-uncertain-candidate`](../tasks/stage-uncertain-candidate.md)

Schemas: [`staging`](../schemas/staging/README.md).
