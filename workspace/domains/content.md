---
id: "dom:content"
kind: domain
lens: corpus
schemas: [content]
aliases: [documents, units, nodes, grammar, census, digests, summaries, transcripts, refresh]
relations: [content.document, content.document_version, content.document_representation, content.document_node, content.unit_kind, content.document_type, content.document_kind_assignment, content.format, content.source_role, content.structure_census, content.unit_entity_role, content.unit_assertion_mapping, content.unit_change, content.refresh_check, content.document_digest, content.digest_item, content.document_summary, content.document_summary_source, content.document_about_entity, content.transformation_run]
functions: [api.digest_item_passages, api.document_digest, api.document_units, api.release_digest, api.summary_evidence, api.symbol_history, api.talk_segments, api.talks_about, api.unit_entities, content.current_kind, content.validate_unit_attributes, content.validate_unit_entity_role]
tasks: [build-evidence-packet, find-stale-facts, price-with-locator, talk-passage-at-timecode, talks-on-topic, what-changed-since]
summary: "Faithful documents decomposed into typed units with stable logical keys; census before kind, digests anchored to units, refresh as data."
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
---
# Documents, typed units, census and digests

Faithful documents decomposed into typed units with stable logical keys; census before kind, digests anchored to units, refresh as data.

> curated (model_assisted, unreviewed) — `content.document` is the identity of a captured work (`work_entity_id` for talks, papers
> and other work entities; `source_role_code` says who speaks: first_party, filer, academic,
> registry, third_party_editorial, community, own, system). Kinds are open-world:
> `content.document_type` rows can be `candidate` until their grammar settles, assignments
> are append-only in `content.document_kind_assignment` (current one has
> `superseded_by_id` null), and `unclassified` is always valid. Versions carry the
> `format_code` axis (`content.format`: html, pdf, markdown, timed_text, slides, json, …) that
> decides parser and locator kinds; representations carry the `grammar_version` that produced
> their units.
> 
> Before a kind or grammar is assigned, `content.structure_census` records what a
> representation structurally contains (headings, tables, lists, code, timecodes, speakers,
> figures). The grammar is data: `content.unit_kind` lists the typed units a document kind
> decomposes into (price_row, transcript_segment, slide, release_entry, table_row, section,
> code_block, …) with a JSON Schema for attributes, the `logical_key_attributes` that make a
> unit stable across captures, the selector kind and the retrieval role. `content.document_node`
> is the typed unit: `unit_kind` (+version), validated `attributes`, `logical_key`, and typed
> position (offsets, page, bbox, `start_ms`/`end_ms`). `content.unit_entity_role` says which
> entity a unit is about and in what role; `content.unit_assertion_mapping` says how a unit
> kind's attributes become an assertion.
> 
> Read units with `q:content.document_units`, a talk's transcript window with
> `q:content.talk_segments`, and the structured digest with `q:content.document_digest`:
> `content.document_digest` items are records anchored to unit node ids (key points, entity
> roles, assertion references, changes, open questions, research directions); prose summaries
> (`content.document_summary.digest_id`) render a digest and are never evidence.
> `api.summary_evidence` expands a summary into faithful nodes and locators.
> 
> Refresh is data: `content.refresh_check` records unchanged/changed/failed per document and
> `content.unit_change` the unit-level diff between two versions matched by logical key.
> Agents read structure to compose locators and packets; they do not rewrite faithful content
> or write units. Trap: treating a transcript segment as a fact — the world interval still
> lives on a `temporal.segment`; the unit only locates the quote.

## Relations that matter

| Relation | Summary | Enforced | Direct writers |
| --- | --- | --- | --- |
| [`content.document`](../relations/content/document.md) | Identity of a captured work; typed open-world (document_type_code is the initial kind), with who speaks (sour… | PK (id); unique (tenant_id, id); RLS | `executor_service` |
| [`content.document_version`](../relations/content/document_version.md) | table | PK (id); unique (tenant_id, document_id, version_label), (tenant_id, id); RLS | `executor_service` |
| [`content.document_representation`](../relations/content/document_representation.md) | table | PK (id); unique (tenant_id, id); RLS | `executor_service` |
| [`content.document_node`](../relations/content/document_node.md) | A typed unit of a representation — unit_kind from the grammar, validated attributes, a logical_key stable acr… | PK (id); unique (tenant_id, id), (tenant_id, representation_id, parent_id, ordinal), (tenant_id, representation_id, stable_local_key), (tenant_id, representation_id, id); RLS | `executor_service` |
| [`content.unit_kind`](../relations/content/unit_kind.md) | Grammar as data — the typed units a document kind decomposes into, with JSON Schema, logical-key attributes, … | PK (code, version) | helpers only |
| [`content.document_type`](../relations/content/document_type.md) | table | PK (code) | `executor_service`, `pipeline_agent` |
| [`content.document_kind_assignment`](../relations/content/document_kind_assignment.md) | Append-only kind assignments of a document; the current one has superseded_by_id null. | PK (id); RLS | `executor_service` |
| [`content.format`](../relations/content/format.md) | Media/format axis of a captured version; decides the parser and the locator kinds. | PK (code) | helpers only |
| [`content.source_role`](../relations/content/source_role.md) | Who speaks — first party about itself, filer, academic, registry, third-party editorial, community, own, syst… | PK (code) | helpers only |
| [`content.structure_census`](../relations/content/structure_census.md) | What a representation structurally contains before a kind or grammar is assigned; promotion candidates come f… | PK (id); unique (tenant_id, representation_id, census_version); RLS | `executor_service` |
| [`content.unit_entity_role`](../relations/content/unit_entity_role.md) | Which entity a unit is about and in what role from the unit kind's role vocabulary; anchored on units, never … | PK (node_id, entity_id, role); RLS | `executor_service` |
| [`content.unit_assertion_mapping`](../relations/content/unit_assertion_mapping.md) | Declarative act 3 — how a unit kind's attributes become an assertion (stream kind, relationship, event or att… | PK (id) | helpers only |
| [`content.unit_change`](../relations/content/unit_change.md) | Unit-level diff between two versions matched by logical_key; drives update proposals for facts. | PK (id); RLS | `executor_service` |
| [`content.refresh_check`](../relations/content/refresh_check.md) | Each refresh of a document — unchanged (same bytes), changed (new version) or failed — written even when noth… | PK (id); RLS | `executor_service` |
| [`content.document_digest`](../relations/content/document_digest.md) | Structured digest of a version (or section/entity view); items are records anchored to units, prose summaries… | PK (id); RLS | `executor_service` |
| [`content.digest_item`](../relations/content/digest_item.md) | One digest item — key point, entity role, assertion reference, change, open question, limitation or research … | PK (id); unique (digest_id, ordinal); RLS | `executor_service` |
| [`content.document_summary`](../relations/content/document_summary.md) | Prose rendering of a digest for an audience; never evidence by itself. | PK (id); unique (tenant_id, id); RLS | `executor_service`, `pipeline_agent` |
| [`content.document_summary_source`](../relations/content/document_summary_source.md) | table | PK (tenant_id, summary_id, node_id); RLS | `executor_service`, `pipeline_agent` |
| [`content.document_about_entity`](../relations/content/document_about_entity.md) | table | PK (tenant_id, document_id, entity_id); RLS | `executor_service`, `pipeline_agent` |
| [`content.transformation_run`](../relations/content/transformation_run.md) | table | PK (id); unique (tenant_id, id), (tenant_id, idempotency_key); RLS | `executor_service` |

## Functions

[`api.digest_item_passages`](../functions/api/digest_item_passages.md), [`api.document_digest`](../functions/api/document_digest.md), [`api.document_units`](../functions/api/document_units.md), [`api.release_digest`](../functions/api/release_digest.md), [`api.summary_evidence`](../functions/api/summary_evidence.md), [`api.symbol_history`](../functions/api/symbol_history.md), [`api.talk_segments`](../functions/api/talk_segments.md), [`api.talks_about`](../functions/api/talks_about.md), [`api.unit_entities`](../functions/api/unit_entities.md), [`content.current_kind`](../functions/content/current_kind.md), [`content.validate_unit_attributes`](../functions/content/validate_unit_attributes.md), [`content.validate_unit_entity_role`](../functions/content/validate_unit_entity_role.md)

## Named queries

[`q:content.document_digest`](../queries/README.md), [`q:content.document_units`](../queries/README.md), [`q:content.refresh_checks`](../queries/README.md), [`q:content.talk_segments`](../queries/README.md), [`q:content.unit_changes`](../queries/README.md), [`q:retrieval.evidence_packet`](../queries/README.md), [`q:vocab.unit_kind`](../queries/README.md)

## Tasks

[`build-evidence-packet`](../tasks/build-evidence-packet.md), [`find-stale-facts`](../tasks/find-stale-facts.md), [`price-with-locator`](../tasks/price-with-locator.md), [`talk-passage-at-timecode`](../tasks/talk-passage-at-timecode.md), [`talks-on-topic`](../tasks/talks-on-topic.md), [`what-changed-since`](../tasks/what-changed-since.md)

Schemas: [`content`](../schemas/content/README.md).
