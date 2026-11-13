---
id: "dom:api-surface"
kind: domain
lens: corpus
schemas: [api, util]
aliases: [rpc, views, app_reader, L1, catalog views, models table]
relations: [api.models, api.model_offerings, api.software, api.software_releases, api.talks, api.people, api.organizations, api.events, api.concepts, api.papers, api.benchmark_scores, api.works_authored, api.guidance_items, api.libraries, api.repositories, api.mcp_servers, api.agent_skills, api.entities, api.current_facts, api.current_relationships, api.events_current]
functions: [api.changes_since, api.document_digest, api.document_units, api.entity_at, api.entity_card, api.entity_timeline, api.evidence_packet, api.fact_locators, api.knowledge_head, api.leaderboard, api.model_offerings_at, api.models_at, api.modules_affected_by_release, api.price_history, api.product_command, api.product_read, api.product_worker, api.relationships, api.resolve_entity, api.search_unified, api.summary_evidence, api.talk_segments, api.what_changed, util.current_tenant_id]
tasks: [cheapest-qualified-model, check-knowledge-head, compare-models, modules-affected-by-release, modules-covering-concept, price-with-locator, release-history, talk-passage-at-timecode, talk-to-repo-to-paper, talks-on-topic, what-changed-since, what-do-we-know-about-entity]
summary: The only surface apps and agents see; invoker views and definer RPCs organised as the L1–L3 knowledge continuum.
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
---
# API surface (L1 views, L2 and L3 functions)

The only surface apps and agents see; invoker views and definer RPCs organised as the L1–L3 knowledge continuum.

> curated (model_assisted, unreviewed) — `api` has no tables. **L1 catalog views** (lens corpus unless noted) answer filter / compare /
> rank questions with no embeddings: `api.models` (one row per model version with developer,
> release date, context, modalities, capability statuses, cutoff, availability and the minimum
> current price per 1M tokens), `api.model_offerings` (model as sold by a provider, normalized
> USD per 1M tokens for input/output/cached/batch, with the exact claim and locator behind the
> input price), `api.software` (+ the `api.libraries`, `api.repositories`, `api.mcp_servers`,
> `api.agent_skills` slices), `api.software_releases`, `api.talks`, `api.people`,
> `api.organizations`, `api.events`, `api.concepts`, `api.papers`, `api.benchmark_scores`,
> `api.guidance_items`, and `api.works_authored` (lens ours, tier 1: our courses, modules,
> reports at head). Every L1 row carries `as_of_knowledge_seq` or `learned_k` so you can cite
> the head.
> 
> **L2 facts and time**: `api.changes_since(since, stream_kinds, entity_kinds, document_types)`,
> `api.price_history(offering, meter)`, `api.fact_locators(entity, stream_kind, scope_key)`,
> `api.entity_at`, `api.what_changed`, `api.models_at` / `api.model_offerings_at` (L1 replayed
> at a world time), `api.modules_affected_by_release(release)`.
> 
> **L3 scoped semantic**: `api.search_unified` (facets: lens, tier, space, document type, unit
> kind, entity, as-of, workspace), `api.talk_segments(talk, from_ms, to_ms, query)`,
> `api.document_units(document, unit_kinds)`, `api.document_digest(document)`.
> 
> **Product**: `api.product_command(workspace, operation, idempotency_key, expected_head,
> payload)`, `api.product_read(workspace, operation, payload)` for `authenticated`;
> `api.product_worker(operation, payload)` for `service_role`. The operations are one page
> each under `ops/` (see INDEX.md).
> 
> Older surface: `api.entities`, `api.current_facts` (applies `k_to is null` and
> `valid_during @> now()` — the usual trap; historical reads use `api.entity_at`),
> `api.current_relationships`, `api.events_current`, `api.hybrid_knowledge_search_1536`.
> `util.current_tenant_id` reads the app.tenant_id GUC and fails closed; every call needs it.
> Invariant: `app_reader` never SELECTs catalog or temporal tables. Long-tail reads are new
> catalog entries, not raw SQL.

## Relations that matter

| Relation | Summary | Enforced | Direct writers |
| --- | --- | --- | --- |
| [`api.models`](../relations/api/models.md) | L1 — one row per model version with developer, release date, context, modalities, capability statuses, cutoff… | — | helpers only |
| [`api.model_offerings`](../relations/api/model_offerings.md) | L1 — one row per offering with normalized USD per 1M tokens for input/output/cached/batch, availability and t… | — | helpers only |
| [`api.software`](../relations/api/software.md) | L1 — libraries, repositories, MCP servers, agent skills, products and protocols in one table with ecosystem, … | — | helpers only |
| [`api.software_releases`](../relations/api/software_releases.md) | L1/L2 — every known release of a software thing with date, breaking flag, highlights and the knowledge seq it… | — | helpers only |
| [`api.talks`](../relations/api/talks.md) | L1: conference talks with event, track, speakers and their affiliations, topics (about), linked repositories … | — | helpers only |
| [`api.people`](../relations/api/people.md) | L1: people with current affiliations (employed_by, as of now) and how many talks/works they presented or auth… | — | helpers only |
| [`api.organizations`](../relations/api/organizations.md) | L1: organizations with kind, site, country, founding date and counts of what they develop, sell and employ. | — | helpers only |
| [`api.events`](../relations/api/events.md) | L1: industry events (conference editions) with dates, place, series, organizers, tracks and talk counts. | — | helpers only |
| [`api.concepts`](../relations/api/concepts.md) | L1: concepts and techniques (RAG, context engineering, harness, sandbox, MCP, skills ...) with how many works… | — | helpers only |
| [`api.papers`](../relations/api/papers.md) | L1: papers with authors, code, citing talks/papers, cited papers and the ingestion level (P0 reference / P1 d… | — | helpers only |
| [`api.benchmark_scores`](../relations/api/benchmark_scores.md) | L1: current conditioned benchmark scores: subject, benchmark version and parent benchmark, harness, who measu… | — | helpers only |
| [`api.works_authored`](../relations/api/works_authored.md) | L1 (lens ours, tier 1) — our courses, modules, lessons, activities, reports and templates at head revision, r… | — | helpers only |
| [`api.guidance_items`](../relations/api/guidance_items.md) | L1 — expert guidance items with their subject entities. | — | helpers only |
| [`api.libraries`](../relations/api/libraries.md) | view | — | helpers only |
| [`api.repositories`](../relations/api/repositories.md) | view | — | helpers only |
| [`api.mcp_servers`](../relations/api/mcp_servers.md) | view | — | helpers only |
| [`api.agent_skills`](../relations/api/agent_skills.md) | view | — | helpers only |
| [`api.entities`](../relations/api/entities.md) | Invoker view of tenant entities plus alias array. | — | helpers only |
| [`api.current_facts`](../relations/api/current_facts.md) | Current segments whose valid_during contains now(). | — | helpers only |
| [`api.current_relationships`](../relations/api/current_relationships.md) | Current relationships, hiding inactive temporal edges. | — | helpers only |
| [`api.events_current`](../relations/api/events_current.md) | Current event occurrences for the tenant. | — | helpers only |

## Functions

[`api.changes_since`](../functions/api/changes_since.md), [`api.document_digest`](../functions/api/document_digest.md), [`api.document_units`](../functions/api/document_units.md), [`api.entity_at`](../functions/api/entity_at.md), [`api.entity_card`](../functions/api/entity_card.md), [`api.entity_timeline`](../functions/api/entity_timeline.md), [`api.evidence_packet`](../functions/api/evidence_packet.md), [`api.fact_locators`](../functions/api/fact_locators.md), [`api.knowledge_head`](../functions/api/knowledge_head.md), [`api.leaderboard`](../functions/api/leaderboard.md), [`api.model_offerings_at`](../functions/api/model_offerings_at.md), [`api.models_at`](../functions/api/models_at.md), [`api.modules_affected_by_release`](../functions/api/modules_affected_by_release.md), [`api.price_history`](../functions/api/price_history.md), [`api.product_command`](../functions/api/product_command.md), [`api.product_read`](../functions/api/product_read.md), [`api.product_worker`](../functions/api/product_worker.md), [`api.relationships`](../functions/api/relationships.md), [`api.resolve_entity`](../functions/api/resolve_entity.md), [`api.search_unified`](../functions/api/search_unified.md), [`api.summary_evidence`](../functions/api/summary_evidence.md), [`api.talk_segments`](../functions/api/talk_segments.md), [`api.what_changed`](../functions/api/what_changed.md), [`util.current_tenant_id`](../functions/util/current_tenant_id.md)

## Named queries

[`q:catalog.benchmark_scores`](../queries/README.md), [`q:catalog.concepts`](../queries/README.md), [`q:catalog.events`](../queries/README.md), [`q:catalog.model_offerings`](../queries/README.md), [`q:catalog.model_offerings_at`](../queries/README.md), [`q:catalog.models`](../queries/README.md), [`q:catalog.models_at`](../queries/README.md), [`q:catalog.organizations`](../queries/README.md), [`q:catalog.papers`](../queries/README.md), [`q:catalog.people`](../queries/README.md), [`q:catalog.software`](../queries/README.md), [`q:catalog.software_releases`](../queries/README.md), [`q:catalog.talks`](../queries/README.md), [`q:content.document_digest`](../queries/README.md), [`q:content.document_units`](../queries/README.md), [`q:content.talk_segments`](../queries/README.md), [`q:entity.card`](../queries/README.md), [`q:entity.resolve`](../queries/README.md), [`q:facts.changes_since`](../queries/README.md), [`q:facts.locators`](../queries/README.md), [`q:facts.price_history`](../queries/README.md), [`q:guidance.items`](../queries/README.md), [`q:knowledge.head`](../queries/README.md), [`q:ours.modules_affected_by_release`](../queries/README.md), [`q:ours.works_authored`](../queries/README.md), [`q:ranking.leaderboard`](../queries/README.md), [`q:retrieval.search_unified`](../queries/README.md)

## Tasks

[`cheapest-qualified-model`](../tasks/cheapest-qualified-model.md), [`check-knowledge-head`](../tasks/check-knowledge-head.md), [`compare-models`](../tasks/compare-models.md), [`modules-affected-by-release`](../tasks/modules-affected-by-release.md), [`modules-covering-concept`](../tasks/modules-covering-concept.md), [`price-with-locator`](../tasks/price-with-locator.md), [`release-history`](../tasks/release-history.md), [`talk-passage-at-timecode`](../tasks/talk-passage-at-timecode.md), [`talk-to-repo-to-paper`](../tasks/talk-to-repo-to-paper.md), [`talks-on-topic`](../tasks/talks-on-topic.md), [`what-changed-since`](../tasks/what-changed-since.md), [`what-do-we-know-about-entity`](../tasks/what-do-we-know-about-entity.md)

Schemas: [`api`](../schemas/api/README.md), [`util`](../schemas/util/README.md).
