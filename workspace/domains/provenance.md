---
id: "dom:provenance"
kind: domain
schemas: [provenance]
aliases: [project objects, bindings, edges]
relations: [provenance.object, provenance.binding, provenance.edge, provenance.revision, orchestration.artifact]
functions: []
tasks: [publish-report]
summary: "Project objects, bindings, edges, and revisions."
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# Project provenance

Project objects, bindings, edges, and revisions.

> curated (model_assisted, unreviewed) — Provenance tracks project-scoped objects, how they bind to other records, edges
> between them, and revisions (`provenance.object`, `provenance.binding`,
> `provenance.edge`, `provenance.revision`). It is the project lineage surface, not
> the research-ingestion evidence chain (that chain is `evidence.source` plus
> `orchestration.artifact`).
> 
> Four tables only. Agents working industry facts should not start here. When a
> generated workspace or report needs a project-level binding, create the artifact
> first, then a provenance object that points at it. Do not confuse a provenance
> revision with a `temporal.knowledge_batch`: the former versions a project object,
> the latter seals tenant knowledge.
> 
> Invariant: four provenance tables plus the artifact they bind to. Trap: starting
> an industry-fact investigation here. Use `publish-report` and `q:artifacts.by_type`
> for stored report bytes; only then create a `provenance.object` if a project
> workspace needs a binding. `provenance.edge` is not `corpus.relationship`.
> `provenance.binding` is not `evidence.segment_support`. Agents on the
> schema-workspace mission should treat this schema as optional project
> bookkeeping, not as a second knowledge graph.

## Relations that matter

| Relation | Summary | Enforced | Direct writers |
| --- | --- | --- | --- |
| [`provenance.object`](../relations/provenance/object.md) | Stable design-object identity. One row per conversation, doc, spec, issue, or PR. | PK (id); unique (tenant_id, kind, key); RLS | `authenticated` |
| [`provenance.binding`](../relations/provenance/binding.md) | Pointer to Linear, GitHub, or a Cursor conversation. The ledger stays here; those systems are projections. | PK (id); unique (tenant_id, system, external_id); RLS | `authenticated` |
| [`provenance.edge`](../relations/provenance/edge.md) | Declared citation. from was informed by / derived from / supersedes to. Not a causal debugger log. | PK (id); unique (from_object_id, from_revision_id, to_object_id, to_revision_id, kind); RLS | `authenticated` |
| [`provenance.revision`](../relations/provenance/revision.md) | Immutable sealed content for one object version. Bytes live at object_path in the provenance bucket. | PK (id); unique (object_id, revision_no), (storage_bucket, object_path, object_id); RLS | `authenticated` |
| [`orchestration.artifact`](../relations/orchestration/artifact.md) | Content-addressed stored object typed by artifact_type. | PK (id); unique (tenant_id, id); RLS | `control_plane`, `executor_service` |

## Named queries

[`q:artifacts.by_type`](../queries/README.md)

## Tasks

[`publish-report`](../tasks/publish-report.md)

Schemas: [`provenance`](../schemas/provenance/README.md).
