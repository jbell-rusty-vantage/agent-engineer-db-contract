---
id: "dom:content"
kind: domain
schemas: [content]
aliases: [documents, nodes, summaries, transformations]
relations: [content.document, content.document_version, content.document_representation, content.document_node, content.document_summary, content.document_summary_source, content.document_type, content.transformation_run, content.document_about_entity]
functions: [api.summary_evidence]
tasks: [build-evidence-packet]
summary: "Faithful documents, versions, nodes, and summaries with transformation lineage."
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# Documents and representations

Faithful documents, versions, nodes, and summaries with transformation lineage.

> curated (model_assisted, unreviewed) — `content.document` is typed by `content.document_type` (family, default chunking,
> default retrieval spaces). Versions and representations keep the bytes and parse
> trees; `content.document_node` is the addressable unit (headings, table cells,
> transcript windows with `start_ms` / `end_ms`). Summaries (`content.document_summary`)
> must cite `content.document_summary_source` nodes so `api.summary_evidence` can expand
> a summary into faithful nodes, chunks, and locators.
> 
> Transformations (`content.transformation_run` and kind vocabulary) record html_to_markdown,
> asr_transcript, summarize, and similar steps. `content.document_about_entity` links a
> document to corpus identities. Document types route into retrieval spaces; they are
> not spaces themselves.
> 
> Agents read document structure when composing locators and packets. They do not
> rewrite faithful content. New document kinds must be admitted into the routing
> vocabulary before a foreign key is added. Runtime conversion evaluations live beside
> the document tables and are not a write path for research agents.
> 
> Invariant: a summary without `content.document_summary_source` rows is not
> expandable. Trap: treating a transcript window as a fact — the world interval
> still lives on a `temporal.segment`; the node only locates the quote. Use
> `q:retrieval.evidence_packet` and `build-evidence-packet` when a question needs
> cited nodes, then follow `content.document_about_entity` to the corpus identity
> those nodes are about. `api.summary_evidence` is the RPC that turns one summary
> id into the faithful node and locator set.

## Relations that matter

| Relation | Summary | Enforced | Direct writers |
| --- | --- | --- | --- |
| [`content.document`](../relations/content/document.md) | table | PK (id); unique (tenant_id, id); RLS | `executor_service` |
| [`content.document_version`](../relations/content/document_version.md) | table | PK (id); unique (tenant_id, document_id, version_label), (tenant_id, id); RLS | `executor_service` |
| [`content.document_representation`](../relations/content/document_representation.md) | table | PK (id); unique (tenant_id, id); RLS | `executor_service` |
| [`content.document_node`](../relations/content/document_node.md) | table | PK (id); unique (tenant_id, id), (tenant_id, representation_id, parent_id, ordinal), (tenant_id, representation_id, stable_local_key), (tenant_id, representation_id, id); RLS | `executor_service` |
| [`content.document_summary`](../relations/content/document_summary.md) | table | PK (id); unique (tenant_id, id); RLS | `executor_service`, `pipeline_agent` |
| [`content.document_summary_source`](../relations/content/document_summary_source.md) | table | PK (tenant_id, summary_id, node_id); RLS | `executor_service`, `pipeline_agent` |
| [`content.document_type`](../relations/content/document_type.md) | table | PK (code) | `executor_service`, `pipeline_agent` |
| [`content.transformation_run`](../relations/content/transformation_run.md) | table | PK (id); unique (tenant_id, id), (tenant_id, idempotency_key); RLS | `executor_service` |
| [`content.document_about_entity`](../relations/content/document_about_entity.md) | table | PK (tenant_id, document_id, entity_id); RLS | `executor_service`, `pipeline_agent` |

## Functions

[`api.summary_evidence`](../functions/api/summary_evidence.md)

## Named queries

[`q:retrieval.evidence_packet`](../queries/README.md)

## Tasks

[`build-evidence-packet`](../tasks/build-evidence-packet.md)

Schemas: [`content`](../schemas/content/README.md).
