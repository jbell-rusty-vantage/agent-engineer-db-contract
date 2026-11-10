---
id: "sch:api"
kind: schema
name: api
lens: corpus
domains: [api-surface, authoring, guidance]
relations: 33
functions: 43
workspace_fingerprint: "sha256:027ab2b6133d5d59318c478f06d832d89f937e563c387539f37fb3d7668818a8"
---
# api

Views and functions only. The sole surface exposed to apps and agents. Lens `corpus`. Domains: [`api-surface`](../../domains/api-surface.md), [`authoring`](../../domains/authoring.md), [`guidance`](../../domains/guidance.md).

| Relation | Kind | Rows | Summary | Key edges |
| --- | --- | --- | --- | --- |
| [`advisories`](../../relations/api/advisories.md) | view | unknown | L1: security advisories with the affected software, vulnerable range and first patched ve… | — |
| [`agent_skills`](../../relations/api/agent_skills.md) | view | unknown | — | — |
| [`api_symbols`](../../relations/api/api_symbols.md) | view | unknown | L1: public symbols per repository release (R3), with how many docs sections document each… | — |
| [`benchmark_scores`](../../relations/api/benchmark_scores.md) | view | unknown | L1: current conditioned benchmark scores: subject, benchmark version and parent benchmark… | — |
| [`benchmarks`](../../relations/api/benchmarks.md) | view | unknown | L1: benchmarks with their versions, organizer, metric/score type and how many conditioned… | — |
| [`claim_candidates`](../../relations/api/claim_candidates.md) | view | unknown | L3/evidence: every claim with its path (deterministic_first_party = cheap path, L1_candid… | — |
| [`claim_conflicts`](../../relations/api/claim_conflicts.md) | view | unknown | Kept disagreements between a first-party claim and another statement (value, scope or sub… | — |
| [`compute_devices`](../../relations/api/compute_devices.md) | view | unknown | L1: accelerators and systems with first-party spec attributes (sparse figures flagged) an… | — |
| [`compute_offerings`](../../relations/api/compute_offerings.md) | view | unknown | L1: compute offerings (instance types, serverless GPUs, sandboxes, TPU slices) with every… | — |
| [`concepts`](../../relations/api/concepts.md) | view | unknown | L1: concepts and techniques (RAG, context engineering, harness, sandbox, MCP, skills ...)… | — |
| [`current_facts`](../../relations/api/current_facts.md) | view | unknown | Current segments whose valid_during contains now(). | — |
| [`current_relationships`](../../relations/api/current_relationships.md) | view | unknown | Current relationships, hiding inactive temporal edges. | — |
| [`endpoints`](../../relations/api/endpoints.md) | view | unknown | L1: API operations per captured specification version; diff two versions by logical key (… | — |
| [`entities`](../../relations/api/entities.md) | view | unknown | Invoker view of tenant entities plus alias array. | — |
| [`events`](../../relations/api/events.md) | view | unknown | L1: industry events (conference editions) with dates, place, series, organizers, tracks a… | — |
| [`events_current`](../../relations/api/events_current.md) | view | unknown | Current event occurrences for the tenant. | — |
| [`guidance_items`](../../relations/api/guidance_items.md) | view | unknown | L1 — expert guidance items with their subject entities. | — |
| [`libraries`](../../relations/api/libraries.md) | view | unknown | — | — |
| [`mcp_servers`](../../relations/api/mcp_servers.md) | view | unknown | — | — |
| [`mission_progress`](../../relations/api/mission_progress.md) | view | unknown | — | — |
| [`model_offerings`](../../relations/api/model_offerings.md) | view | unknown | L1 — one row per offering with normalized USD per 1M tokens for input/output/cached/batch… | — |
| [`models`](../../relations/api/models.md) | view | unknown | L1 — one row per model version with developer, release date, context, modalities, capabil… | — |
| [`organizations`](../../relations/api/organizations.md) | view | unknown | L1: organizations with kind, site, country, founding date and counts of what they develop… | — |
| [`papers`](../../relations/api/papers.md) | view | unknown | L1: papers with authors, code, citing talks/papers, cited papers and the ingestion level … | — |
| [`people`](../../relations/api/people.md) | view | unknown | L1: people with current affiliations (employed_by, as of now) and how many talks/works th… | — |
| [`protocol_versions`](../../relations/api/protocol_versions.md) | view | unknown | L1: protocol revisions (MCP) with status, changelog, highlights and the software releases… | — |
| [`registry_listings`](../../relations/api/registry_listings.md) | view | unknown | L1: servers listed in a registry with transports, namespace-inferred first-party flag and… | — |
| [`repositories`](../../relations/api/repositories.md) | view | unknown | — | — |
| [`review_queue`](../../relations/api/review_queue.md) | view | unknown | — | — |
| [`software`](../../relations/api/software.md) | view | unknown | L1 — libraries, repositories, MCP servers, agent skills, products and protocols in one ta… | — |
| [`software_releases`](../../relations/api/software_releases.md) | view | unknown | L1/L2 — every known release of a software thing with date, breaking flag, highlights and … | — |
| [`talks`](../../relations/api/talks.md) | view | unknown | L1: conference talks with event, track, speakers and their affiliations, topics (about), … | — |
| [`works_authored`](../../relations/api/works_authored.md) | view | unknown | L1 (lens ours, tier 1) — our courses, modules, lessons, activities, reports and templates… | — |

Functions: [`advisories_for`](../../functions/api/advisories_for.md), [`changes_since`](../../functions/api/changes_since.md), [`cheapest_compute`](../../functions/api/cheapest_compute.md), [`current_event_rows`](../../functions/api/current_event_rows.md), [`current_fact_rows`](../../functions/api/current_fact_rows.md), [`current_relationship_rows`](../../functions/api/current_relationship_rows.md), [`document_digest`](../../functions/api/document_digest.md), [`document_units`](../../functions/api/document_units.md), [`entity_aliases`](../../functions/api/entity_aliases.md), [`entity_at`](../../functions/api/entity_at.md), [`entity_card`](../../functions/api/entity_card.md), [`entity_rows`](../../functions/api/entity_rows.md), [`entity_timeline`](../../functions/api/entity_timeline.md), [`evidence_packet`](../../functions/api/evidence_packet.md), [`fact_amount`](../../functions/api/fact_amount.md), [`fact_locators`](../../functions/api/fact_locators.md), [`fact_payload`](../../functions/api/fact_payload.md), [`fact_status`](../../functions/api/fact_status.md), [`hybrid_knowledge_search_1536`](../../functions/api/hybrid_knowledge_search_1536.md), [`hybrid_knowledge_search_history_1536`](../../functions/api/hybrid_knowledge_search_history_1536.md), [`knowledge_head`](../../functions/api/knowledge_head.md), [`leaderboard`](../../functions/api/leaderboard.md), [`leaderboard_diff`](../../functions/api/leaderboard_diff.md), [`model_offerings_at`](../../functions/api/model_offerings_at.md), [`models_at`](../../functions/api/models_at.md), [`modules_affected_by_release`](../../functions/api/modules_affected_by_release.md), [`modules_using_software`](../../functions/api/modules_using_software.md), [`names`](../../functions/api/names.md), [`price_history`](../../functions/api/price_history.md), [`price_per_1m`](../../functions/api/price_per_1m.md), [`product_command`](../../functions/api/product_command.md), [`product_read`](../../functions/api/product_read.md), [`product_worker`](../../functions/api/product_worker.md), [`related`](../../functions/api/related.md), [`relationships`](../../functions/api/relationships.md), [`resolve_entity`](../../functions/api/resolve_entity.md), [`search_knowledge_1536`](../../functions/api/search_knowledge_1536.md), [`search_unified`](../../functions/api/search_unified.md), [`submit_intent`](../../functions/api/submit_intent.md), [`summary_evidence`](../../functions/api/summary_evidence.md), [`symbol_changes`](../../functions/api/symbol_changes.md), [`talk_segments`](../../functions/api/talk_segments.md), [`what_changed`](../../functions/api/what_changed.md).

Types: none.
