---
id: "dom:acquisition"
kind: domain
lens: corpus
schemas: [acquisition]
aliases: [fetch, fetch ledger, refresh, daily refresh, spend, unchanged]
relations: [acquisition.fetch, evidence.source_capture, content.refresh_check, content.unit_change, evidence.source]
functions: []
tasks: [what-changed-since]
summary: Every fetch is a ledger row before it becomes a capture; refreshes record unchanged/changed/failed even when nothing moved.
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# Acquisition and refresh

Every fetch is a ledger row before it becomes a capture; refreshes record unchanged/changed/failed even when nothing moved.

> curated (model_assisted, unreviewed) — `acquisition.fetch` is one attempt to obtain bytes from a URL: who (origin_kind,
> origin_label, actor or Mission Control run), with what tool and version, when, HTTP status,
> outcome, content hash, media type, size, credits and USD spent, failure class. It exists so
> spend and honesty are visible before any document is created. When bytes are kept, the
> capture row (`evidence.source_capture.acquisition_fetch_id`) points back at the fetch.
> 
> `outcome = unchanged` means the same bytes as `prior_capture_id`: no new
> `content.document_version` is created and `content.refresh_check` records `unchanged` for
> the document. `changed` creates a version and a refresh_check with `new_version_id`; the
> unit grammar then diffs the two versions by logical key into `content.unit_change`, which
> `api.changes_since` reports beside fact changes and which drives update proposals for facts.
> 
> Read `q:acquisition.fetches_for_url` for a URL's history and spend,
> `q:content.refresh_checks` for a document's refresh outcomes, `q:content.unit_changes` for
> what moved. Search/provider attempts (`evidence.source_query`, `evidence.provider_result`)
> stay in `evidence` for now. Writers are `executor_service`; harness fetches are recorded by
> the product worker, never by agents directly.

## Relations that matter

| Relation | Summary | Enforced | Direct writers |
| --- | --- | --- | --- |
| [`acquisition.fetch`](../relations/acquisition/fetch.md) | One attempt to obtain bytes from a URL — who, with what tool, outcome, hash, spend — recorded before any capt… | PK (id); RLS | `executor_service` |
| [`evidence.source_capture`](../relations/evidence/source_capture.md) | One immutable capture of a source, hashed and stored as an artifact; points at the acquisition fetch that pro… | PK (id); unique (tenant_id, id); RLS | `executor_service`, `pipeline_agent` |
| [`content.refresh_check`](../relations/content/refresh_check.md) | Each refresh of a document — unchanged (same bytes), changed (new version) or failed — written even when noth… | PK (id); RLS | `executor_service` |
| [`content.unit_change`](../relations/content/unit_change.md) | Unit-level diff between two versions matched by logical_key; drives update proposals for facts. | PK (id); RLS | `executor_service` |
| [`evidence.source`](../relations/evidence/source.md) | Canonical source (URL/domain) with revisit and publisher pointers. | PK (id); unique (tenant_id, id), (tenant_id, source_class, logical_identity); RLS | `executor_service`, `pipeline_agent` |

## Named queries

[`q:acquisition.fetches_for_url`](../queries/README.md), [`q:content.refresh_checks`](../queries/README.md), [`q:content.unit_changes`](../queries/README.md), [`q:evidence.captures_for_source`](../queries/README.md)

## Tasks

[`what-changed-since`](../tasks/what-changed-since.md)

Schemas: [`acquisition`](../schemas/acquisition/README.md).
