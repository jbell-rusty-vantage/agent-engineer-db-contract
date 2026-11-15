---
id: "rel:catalog.entity"
kind: table
schema: catalog
name: entity
domain: identity
lens: corpus
aliases: [entity, canonical entity, identity row]
tokens: [catalog, entity, catalog.entity, id, tenant_id, kind, display_name, slug, summary, lifecycle, merged_into_id, projection_knowledge_seq, created_by_receipt_id, created_at, updated_at, attributes]
summary: One row per canonical identity; kind-specific attributes are a jsonb validated by taxonomy.entity_kind.attributes_schema.
summary_basis: curated
rls: enabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"catalog\"][\"Tables\"][\"entity\"][\"Row\"]"
defined_in: []
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
---
# catalog.entity

table in domain `identity`, lens `corpus` — One canonical row per industry identity. kind -> taxonomy.entity_kind; attributes validated per kind; display_name/slug are projections (entity_name stream is authoritative)..

> curated (model_assisted, unreviewed) — Build 08 replaced the thin typed tables (corpus.organization, corpus.person, …) with
> `attributes`, validated per kind by `catalog.validate_entity_attributes`; read the kind's
> `taxonomy.entity_kind.attributes_schema` for its keys (e.g. ai_model_version needs
> version_label; model_offering needs offering_key; community_actor is platform + handle only).
> Anything that changes over time (price, context window, stars)
> is a fact stream, never an attribute. Work kinds also have a `catalog.work` row.

## Columns

`id` uuid not null, `tenant_id` uuid not null, `kind` text not null, `display_name` text not null, `slug` text not null, `summary` text, `lifecycle` text not null, `merged_into_id` uuid, `projection_knowledge_seq` bigint, `created_by_receipt_id` uuid not null, `created_at` timestamp with time zone not null, `updated_at` timestamp with time zone not null, `attributes` jsonb not null

Full column table: [details](entity.details.md).

## Constraints

- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, id, kind)
- unique (tenant_id, kind, slug)
- 1 check constraints; see [details](entity.details.md)

## Relationships

4 outbound and 66 inbound foreign keys; full list in [details](entity.details.md).

## Indexes

4 indexes; see [details](entity.details.md).

## Triggers

3 triggers; see [details](entity.details.md).

## Row-level security

Enabled; 1 policies in [details](entity.details.md).

## Grants

`control_plane`: SELECT; `executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: SELECT; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Named queries: `q:catalog.benchmark_scores`, `q:catalog.concepts`, `q:catalog.events`, `q:catalog.model_offerings`, `q:catalog.model_offerings_at`, `q:catalog.models`, `q:catalog.models_at`, `q:catalog.organizations`, `q:catalog.papers`, `q:catalog.people`, `q:catalog.software`, `q:catalog.software_releases`, `q:catalog.talks`, `q:content.document_digest`, `q:entity.at`, `q:entity.attributes`, `q:entity.by_identifier`, `q:entity.card`, `q:entity.resolve`, `q:facts.changes_since`, `q:ours.works_authored`, `q:ranking.leaderboard`.
- Exposed through: [`api.advisories`](../api/advisories.md), [`api.attention_policies`](../api/attention_policies.md), [`api.benchmark_scores`](../api/benchmark_scores.md), [`api.benchmarks`](../api/benchmarks.md), [`api.bundle_files`](../api/bundle_files.md), [`api.capabilities`](../api/capabilities.md), [`api.claim_candidates`](../api/claim_candidates.md), [`api.claim_surfaces`](../api/claim_surfaces.md), [`api.claim_verdicts`](../api/claim_verdicts.md), [`api.community_claims`](../api/community_claims.md), [`api.compute_devices`](../api/compute_devices.md), [`api.compute_offerings`](../api/compute_offerings.md), [`api.concepts`](../api/concepts.md), [`api.digest_items`](../api/digest_items.md), [`api.entities`](../api/entities.md), [`api.events`](../api/events.md), [`api.hook_entries`](../api/hook_entries.md), [`api.model_offerings`](../api/model_offerings.md), [`api.models`](../api/models.md), [`api.organizations`](../api/organizations.md), [`api.papers`](../api/papers.md), [`api.people`](../api/people.md), [`api.probes`](../api/probes.md), [`api.protocol_versions`](../api/protocol_versions.md), [`api.registry_listings`](../api/registry_listings.md), [`api.software`](../api/software.md), [`api.software_releases`](../api/software_releases.md), [`api.source_registry`](../api/source_registry.md), [`api.source_track_record`](../api/source_track_record.md), [`api.talks`](../api/talks.md), [`api.works_authored`](../api/works_authored.md).
- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`.
- Via functions (best effort): [`catalog.import_research_starter_catalog`](../../functions/catalog/import_research_starter_catalog.md), [`catalog.rebuild_entity_projections`](../../functions/catalog/rebuild_entity_projections.md).

## TypeScript

insert: `Database["catalog"]["Tables"]["entity"]["Insert"]`; row: `Database["catalog"]["Tables"]["entity"]["Row"]`; update: `Database["catalog"]["Tables"]["entity"]["Update"]`

## Examples

Resolve OpenAI

```bash
knowledge db query entity.resolve --param text=OpenAI
```
Active rows only; score combines name, alias, and identifier.

Row with validated attributes and the kind schema

```bash
knowledge db query entity.attributes --param entity_id=0192b000-0000-7000-8000-000000000001 --param kind=null
```
attributes_schema tells you which keys the kind expects.

Defined in: unknown.
