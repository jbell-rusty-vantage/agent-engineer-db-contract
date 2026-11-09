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
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
---
# catalog.entity

table in domain `identity`, lens `corpus` — One canonical row per industry identity. kind -> taxonomy.entity_kind; attributes validated per kind; display_name/slug are projections (entity_name stream is authoritative)..

> curated (model_assisted, unreviewed) — Build 08 dropped the thirty-six thin typed tables (corpus.organization, corpus.person,
> corpus.ai_model, corpus.ai_model_version, corpus.model_offering, …). What they carried now
> lives in `attributes`, validated per kind by `catalog.validate_entity_attributes`:
> organization → legal_name, org_kind (frontier_lab, model_provider, cloud, tooling_vendor,
> startup, enterprise, academic, nonprofit, media, event_organizer, investor, other),
> website_url, country_code, founded_on; person → given_name, family_name, title,
> affiliation_text, orcid, profile_url (also store scheme orcid on entity_identifier);
> ai_model → model_family, modalities, description; ai_model_version (parent ai_model) →
> version_label (required), provider_model_id, modalities, open_weights, model_page_url;
> model_offering (parent ai_model_version) → offering_key (required; the provider-side SKU
> or API model id), region, tier, pricing_url, provider_model_id; library → ecosystem,
> package_name, repository_url, docs_url, category; paper → arxiv_id, doi, published_on,
> venue; talk → talk_kind, track, level, session_id, video_url, slides_url, edition.
> Anything that changes over time (price, context window, stars, headcount, availability)
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

4 outbound and 61 inbound foreign keys; full list in [details](entity.details.md).

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
- Exposed through: [`api.benchmark_scores`](../api/benchmark_scores.md), [`api.claim_candidates`](../api/claim_candidates.md), [`api.concepts`](../api/concepts.md), [`api.entities`](../api/entities.md), [`api.events`](../api/events.md), [`api.model_offerings`](../api/model_offerings.md), [`api.models`](../api/models.md), [`api.organizations`](../api/organizations.md), [`api.papers`](../api/papers.md), [`api.people`](../api/people.md), [`api.software`](../api/software.md), [`api.software_releases`](../api/software_releases.md), [`api.talks`](../api/talks.md), [`api.works_authored`](../api/works_authored.md).
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
