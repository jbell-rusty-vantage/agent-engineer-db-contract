---
id: "dom:knowledge-records"
kind: domain
schemas: [knowledge]
aliases: [engineering records, technical records]
relations: [knowledge.record, knowledge.record_entity_link, knowledge.technical_problem, knowledge.solution_pattern, knowledge.implementation_example, knowledge.failure_mode, knowledge.assurance_level, knowledge.benchmark_result, knowledge.operational_practice, knowledge.security_consideration]
functions: []
tasks: [what-do-we-know-about-entity]
summary: "Typed engineering records linked to entities, created only with a receipt."
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# Knowledge records

Typed engineering records linked to entities, created only with a receipt.

> curated (model_assisted, unreviewed) — `knowledge.record` is the identity of an engineering statement (kind, title,
> statement, assurance_level, scope, provenance_claim_id). Nine typed children hold
> problems, solution patterns, implementation examples, failure modes, benchmark
> results, compatibility constraints, operational practices, security considerations,
> and advanced usage patterns. `knowledge.record_entity_link` attaches records to
> corpus entities.
> 
> Only `executor_service` creates records, and `created_by_receipt_id` is required.
> `api.technical_record_search` exposes `knowledge.record` to `app_reader`. Assurance
> vocabulary (`knowledge.assurance_level`) is shared with retrieval filters.
> 
> These records are not temporal segments. A price or availability fact belongs in
> `temporal.segment`. A how-to-call-the-API pattern belongs here, linked to the
> product or library entity and backed by a claim. Curriculum lessons point at these
> typed rows through `curriculum.lesson_backed_by`. `knowledge.record_reconciliation`
> remains for runtime repair of older records. Reach for this domain after
> `q:entity.card` when the question is an engineering practice rather than a dated
> world fact; then follow `knowledge.record_entity_link` to the subject entity.
> 
> Invariant: no record without `created_by_receipt_id`. Trap: writing a benchmark
> number here when it is actually a `ranking.metric_observation` or a
> `corpus.benchmark_run`. Agents do not DML these tables; they author a knowledge
> record proposal after `what-do-we-know-about-entity` shows the linked identity.

## Relations that matter

| Relation | Summary | Enforced | Direct writers |
| --- | --- | --- | --- |
| [`knowledge.record`](../relations/knowledge/record.md) | Identity of a typed engineering record with assurance and a creating receipt. | PK (id); unique (tenant_id, id), (tenant_id, id, kind); RLS | `executor_service` |
| [`knowledge.record_entity_link`](../relations/knowledge/record_entity_link.md) | table | PK (tenant_id, record_id, entity_id, role); RLS | `executor_service` |
| [`knowledge.technical_problem`](../relations/knowledge/technical_problem.md) | table | PK (id); unique (tenant_id, id); RLS | `executor_service` |
| [`knowledge.solution_pattern`](../relations/knowledge/solution_pattern.md) | table | PK (id); unique (tenant_id, id); RLS | `executor_service` |
| [`knowledge.implementation_example`](../relations/knowledge/implementation_example.md) | table | PK (id); unique (tenant_id, id); RLS | `executor_service` |
| [`knowledge.failure_mode`](../relations/knowledge/failure_mode.md) | table | PK (id); unique (tenant_id, id); RLS | `executor_service` |
| [`knowledge.assurance_level`](../relations/knowledge/assurance_level.md) | table | PK (code); unique (rank); RLS | `executor_service` |
| [`knowledge.benchmark_result`](../relations/knowledge/benchmark_result.md) | table | PK (id); unique (tenant_id, id); RLS | `executor_service` |
| [`knowledge.operational_practice`](../relations/knowledge/operational_practice.md) | table | PK (id); unique (tenant_id, id); RLS | `executor_service` |
| [`knowledge.security_consideration`](../relations/knowledge/security_consideration.md) | table | PK (id); unique (tenant_id, id); RLS | `executor_service` |

## Named queries

[`q:entity.card`](../queries/README.md)

## Tasks

[`what-do-we-know-about-entity`](../tasks/what-do-we-know-about-entity.md)

Schemas: [`knowledge`](../schemas/knowledge/README.md).
