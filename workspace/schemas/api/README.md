---
id: "sch:api"
kind: schema
name: api
lens: corpus
domains: [api-surface, authoring, guidance]
relations: 25
functions: 39
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
---
# api

Views and functions only. The sole surface exposed to apps and agents. Lens `corpus`. Domains: [`api-surface`](../../domains/api-surface.md), [`authoring`](../../domains/authoring.md), [`guidance`](../../domains/guidance.md).

| Relation | Kind | Rows | Summary | Key edges |
| --- | --- | --- | --- | --- |
| [`agent_skills`](../../relations/api/agent_skills.md) | view | unknown | — | — |
| [`benchmark_scores`](../../relations/api/benchmark_scores.md) | view | unknown | L1: benchmark results as facts (one home for numbers): subject version, benchmark, score/… | — |
| [`claim_candidates`](../../relations/api/claim_candidates.md) | view | unknown | L3/evidence: every claim with its path (deterministic_first_party = cheap path, L1_candid… | — |
| [`claim_conflicts`](../../relations/api/claim_conflicts.md) | view | unknown | Kept disagreements between a first-party claim and another statement (value, scope or sub… | — |
| [`concepts`](../../relations/api/concepts.md) | view | unknown | L1: concepts and techniques (RAG, context engineering, harness, sandbox, MCP, skills ...)… | — |
| [`current_facts`](../../relations/api/current_facts.md) | view | unknown | Current segments whose valid_during contains now(). | — |
| [`current_relationships`](../../relations/api/current_relationships.md) | view | unknown | Current relationships, hiding inactive temporal edges. | — |
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
| [`papers`](../../relations/api/papers.md) | view | unknown | L1: papers with identifiers, authors, code repositories, techniques introduced and the ta… | — |
| [`people`](../../relations/api/people.md) | view | unknown | L1: people with current affiliations (employed_by, as of now) and how many talks/works th… | — |
| [`repositories`](../../relations/api/repositories.md) | view | unknown | — | — |
| [`review_queue`](../../relations/api/review_queue.md) | view | unknown | — | — |
| [`software`](../../relations/api/software.md) | view | unknown | L1 — libraries, repositories, MCP servers, agent skills, products and protocols in one ta… | — |
| [`software_releases`](../../relations/api/software_releases.md) | view | unknown | L1/L2 — every known release of a software thing with date, breaking flag, highlights and … | — |
| [`talks`](../../relations/api/talks.md) | view | unknown | L1: conference talks with event, track, speakers and their affiliations, topics (about), … | — |
| [`works_authored`](../../relations/api/works_authored.md) | view | unknown | L1 (lens ours, tier 1) — our courses, modules, lessons, activities, reports and templates… | — |

Functions: [`changes_since`](../../functions/api/changes_since.md), [`current_event_rows`](../../functions/api/current_event_rows.md), [`current_fact_rows`](../../functions/api/current_fact_rows.md), [`current_relationship_rows`](../../functions/api/current_relationship_rows.md), [`document_digest`](../../functions/api/document_digest.md), [`document_units`](../../functions/api/document_units.md), [`entity_aliases`](../../functions/api/entity_aliases.md), [`entity_at`](../../functions/api/entity_at.md), [`entity_card`](../../functions/api/entity_card.md), [`entity_rows`](../../functions/api/entity_rows.md), [`entity_timeline`](../../functions/api/entity_timeline.md), [`evidence_packet`](../../functions/api/evidence_packet.md), [`fact_amount`](../../functions/api/fact_amount.md), [`fact_locators`](../../functions/api/fact_locators.md), [`fact_payload`](../../functions/api/fact_payload.md), [`fact_status`](../../functions/api/fact_status.md), [`hybrid_knowledge_search_1536`](../../functions/api/hybrid_knowledge_search_1536.md), [`hybrid_knowledge_search_history_1536`](../../functions/api/hybrid_knowledge_search_history_1536.md), [`knowledge_head`](../../functions/api/knowledge_head.md), [`leaderboard`](../../functions/api/leaderboard.md), [`model_offerings_at`](../../functions/api/model_offerings_at.md), [`models_at`](../../functions/api/models_at.md), [`modules_affected_by_release`](../../functions/api/modules_affected_by_release.md), [`modules_using_software`](../../functions/api/modules_using_software.md), [`names`](../../functions/api/names.md), [`price_history`](../../functions/api/price_history.md), [`price_per_1m`](../../functions/api/price_per_1m.md), [`product_command`](../../functions/api/product_command.md), [`product_read`](../../functions/api/product_read.md), [`product_worker`](../../functions/api/product_worker.md), [`related`](../../functions/api/related.md), [`relationships`](../../functions/api/relationships.md), [`resolve_entity`](../../functions/api/resolve_entity.md), [`search_knowledge_1536`](../../functions/api/search_knowledge_1536.md), [`search_unified`](../../functions/api/search_unified.md), [`submit_intent`](../../functions/api/submit_intent.md), [`summary_evidence`](../../functions/api/summary_evidence.md), [`talk_segments`](../../functions/api/talk_segments.md), [`what_changed`](../../functions/api/what_changed.md).

Types: none.
