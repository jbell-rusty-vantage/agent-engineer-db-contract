---
id: "sch:api"
kind: schema
name: api
lens: corpus
domains: [api-surface, authoring, guidance, source-intelligence, verified-knowledge]
relations: 51
functions: 68
workspace_fingerprint: "sha256:216c4ae7230478c8e60934da25c852e10680d6caed71a662962ea3c0ac1676d3"
---
# api

Views and functions only. The sole surface exposed to apps and agents. Lens `corpus`. Domains: [`api-surface`](../../domains/api-surface.md), [`authoring`](../../domains/authoring.md), [`guidance`](../../domains/guidance.md), [`source-intelligence`](../../domains/source-intelligence.md), [`verified-knowledge`](../../domains/verified-knowledge.md).

| Relation | Kind | Rows | Summary | Key edges |
| --- | --- | --- | --- | --- |
| [`advisories`](../../relations/api/advisories.md) | view | unknown | L1: security advisories with the affected software, vulnerable range and first patched ve… | — |
| [`agent_skills`](../../relations/api/agent_skills.md) | view | unknown | — | — |
| [`api_symbols`](../../relations/api/api_symbols.md) | view | unknown | L1: public API symbols per repository release (R3). When a release surface was parsed mor… | — |
| [`attention_policies`](../../relations/api/attention_policies.md) | view | unknown | Attention policies (what we watch, watch level W0 to W3, cadence, triggers, budget) with … | — |
| [`benchmark_scores`](../../relations/api/benchmark_scores.md) | view | unknown | L1: current conditioned benchmark scores: subject, benchmark version and parent benchmark… | — |
| [`benchmarks`](../../relations/api/benchmarks.md) | view | unknown | L1: benchmarks with their versions, organizer, metric/score type and how many conditioned… | — |
| [`bundle_files`](../../relations/api/bundle_files.md) | view | unknown | L1: the C1 file manifest of a capability bundle at a pinned commit (path, size, mode, exe… | — |
| [`capabilities`](../../relations/api/capabilities.md) | view | unknown | L1: researched capabilities (skills, MCP servers, plugins) with shared upstream identifie… | — |
| [`claim_candidates`](../../relations/api/claim_candidates.md) | view | unknown | L3/evidence: every claim with its path (deterministic_first_party = cheap path, L1_candid… | — |
| [`claim_conflicts`](../../relations/api/claim_conflicts.md) | view | unknown | Kept disagreements between a first-party claim and another statement (value, scope or sub… | — |
| [`claim_restatements`](../../relations/api/claim_restatements.md) | view | unknown | Loop 7 (D-80): restated claims and the attribution-framed originals they were atomized fr… | — |
| [`claim_surfaces`](../../relations/api/claim_surfaces.md) | view | unknown | Claim candidates from talks (speaker, timecode, exact quote; always proposed, never adjud… | — |
| [`claim_triage`](../../relations/api/claim_triage.md) | view | unknown | Loop 5: the current triage of each claim candidate, with the probe it became and its verd… | — |
| [`claim_verdicts`](../../relations/api/claim_verdicts.md) | view | unknown | Claims that a probe has judged, with who stated them, on which channel, the latest verdic… | — |
| [`community_claims`](../../relations/api/community_claims.md) | view | unknown | Claims stated on a community or editorial channel (issue trackers, forums, aggregators, c… | — |
| [`compute_devices`](../../relations/api/compute_devices.md) | view | unknown | L1: accelerators and systems with first-party spec attributes (sparse figures flagged) an… | — |
| [`compute_offerings`](../../relations/api/compute_offerings.md) | view | unknown | L1: compute offerings (instance types, serverless GPUs, sandboxes, TPU slices) with every… | — |
| [`concepts`](../../relations/api/concepts.md) | view | unknown | L1: concepts and techniques (RAG, context engineering, harness, sandbox, MCP, skills ...)… | — |
| [`current_facts`](../../relations/api/current_facts.md) | view | unknown | Current segments whose valid_during contains now(). | — |
| [`current_relationships`](../../relations/api/current_relationships.md) | view | unknown | Current relationships, hiding inactive temporal edges. | — |
| [`digest_items`](../../relations/api/digest_items.md) | view | unknown | L3 summary level: one row per structured digest item with its anchor units, entity role, … | — |
| [`endpoints`](../../relations/api/endpoints.md) | view | unknown | L1: API operations per captured specification version; diff two versions by logical key (… | — |
| [`entities`](../../relations/api/entities.md) | view | unknown | Invoker view of tenant entities plus alias array. | — |
| [`events`](../../relations/api/events.md) | view | unknown | L1: industry events (conference editions) with dates, place, series, organizers, tracks a… | — |
| [`events_current`](../../relations/api/events_current.md) | view | unknown | Current event occurrences for the tenant. | — |
| [`guidance_items`](../../relations/api/guidance_items.md) | view | unknown | L1 — expert guidance items with their subject entities. | — |
| [`hook_entries`](../../relations/api/hook_entries.md) | view | unknown | — | — |
| [`libraries`](../../relations/api/libraries.md) | view | unknown | — | — |
| [`mcp_prompts`](../../relations/api/mcp_prompts.md) | view | unknown | — | — |
| [`mcp_resources`](../../relations/api/mcp_resources.md) | view | unknown | — | — |
| [`mcp_servers`](../../relations/api/mcp_servers.md) | view | unknown | — | — |
| [`mcp_tools`](../../relations/api/mcp_tools.md) | view | unknown | L1: tools an MCP server exposes per captured version (from a published manifest). Version… | — |
| [`mission_progress`](../../relations/api/mission_progress.md) | view | unknown | — | — |
| [`model_offerings`](../../relations/api/model_offerings.md) | view | unknown | L1 — one row per offering with normalized USD per 1M tokens for input/output/cached/batch… | — |
| [`models`](../../relations/api/models.md) | view | unknown | L1 — one row per model version with developer, release date, context, modalities, capabil… | — |
| [`organizations`](../../relations/api/organizations.md) | view | unknown | L1: organizations with kind, site, country, founding date and counts of what they develop… | — |
| [`papers`](../../relations/api/papers.md) | view | unknown | L1: papers with authors, code, citing talks/papers, cited papers and the ingestion level … | — |
| [`people`](../../relations/api/people.md) | view | unknown | L1: people with current affiliations (employed_by, as of now) and how many talks/works th… | — |
| [`probes`](../../relations/api/probes.md) | view | unknown | Probes (experiments that test stated claims) with their subjects, the number of claims an… | — |
| [`protocol_versions`](../../relations/api/protocol_versions.md) | view | unknown | L1: protocol revisions (MCP) with status, changelog, highlights and the software releases… | — |
| [`registry_listings`](../../relations/api/registry_listings.md) | view | unknown | L1: servers listed in a registry with transports, namespace-inferred first-party flag and… | — |
| [`repositories`](../../relations/api/repositories.md) | view | unknown | — | — |
| [`review_queue`](../../relations/api/review_queue.md) | view | unknown | — | — |
| [`software`](../../relations/api/software.md) | view | unknown | L1 — libraries, repositories, MCP servers, agent skills, products and protocols in one ta… | — |
| [`software_releases`](../../relations/api/software_releases.md) | view | unknown | L1/L2 — every known release of a software thing with date, breaking flag, highlights and … | — |
| [`source_registry`](../../relations/api/source_registry.md) | view | unknown | Latest assessment per source and topic: role prior, conflict of interest, method disclosu… | — |
| [`source_track_record`](../../relations/api/source_track_record.md) | view | unknown | Every claim a source stated, with its latest verdict: the rows behind an assessment's cou… | — |
| [`symbol_docs`](../../relations/api/symbol_docs.md) | view | unknown | L3: the docs sections and code examples that document or mention a public API symbol (R4)… | — |
| [`talks`](../../relations/api/talks.md) | view | unknown | L1: conference talks with event, track, speakers and their affiliations, topics (about), … | — |
| [`verified_claims`](../../relations/api/verified_claims.md) | view | unknown | Loop 6: claims that reached verified through a Knowledge Services admission, with the use… | — |
| [`works_authored`](../../relations/api/works_authored.md) | view | unknown | L1 (lens ours, tier 1) — our courses, modules, lessons, activities, reports and templates… | — |

Functions: [`advisories_for`](../../functions/api/advisories_for.md), [`attention_due`](../../functions/api/attention_due.md), [`changes_since`](../../functions/api/changes_since.md), [`cheapest_compute`](../../functions/api/cheapest_compute.md), [`current_event_rows`](../../functions/api/current_event_rows.md), [`current_fact_rows`](../../functions/api/current_fact_rows.md), [`current_relationship_rows`](../../functions/api/current_relationship_rows.md), [`digest_item_passages`](../../functions/api/digest_item_passages.md), [`document_digest`](../../functions/api/document_digest.md), [`document_units`](../../functions/api/document_units.md), [`document_work`](../../functions/api/document_work.md), [`entity_aliases`](../../functions/api/entity_aliases.md), [`entity_at`](../../functions/api/entity_at.md), [`entity_card`](../../functions/api/entity_card.md), [`entity_rows`](../../functions/api/entity_rows.md), [`entity_timeline`](../../functions/api/entity_timeline.md), [`evidence_packet`](../../functions/api/evidence_packet.md), [`fact_amount`](../../functions/api/fact_amount.md), [`fact_locators`](../../functions/api/fact_locators.md), [`fact_payload`](../../functions/api/fact_payload.md), [`fact_status`](../../functions/api/fact_status.md), [`hybrid_knowledge_search_1536`](../../functions/api/hybrid_knowledge_search_1536.md), [`hybrid_knowledge_search_history_1536`](../../functions/api/hybrid_knowledge_search_history_1536.md), [`interview_outputs`](../../functions/api/interview_outputs.md), [`knowledge_head`](../../functions/api/knowledge_head.md), [`leaderboard`](../../functions/api/leaderboard.md), [`leaderboard_diff`](../../functions/api/leaderboard_diff.md), [`library_dossier`](../../functions/api/library_dossier.md), [`model_offerings_at`](../../functions/api/model_offerings_at.md), [`models_at`](../../functions/api/models_at.md), [`modules_affected_by_release`](../../functions/api/modules_affected_by_release.md), [`modules_using_software`](../../functions/api/modules_using_software.md), [`names`](../../functions/api/names.md), [`price_history`](../../functions/api/price_history.md), [`price_per_1m`](../../functions/api/price_per_1m.md), [`probe_matrix`](../../functions/api/probe_matrix.md), [`probe_revalidation_due`](../../functions/api/probe_revalidation_due.md), [`product_command`](../../functions/api/product_command.md), [`product_read`](../../functions/api/product_read.md), [`product_scope`](../../functions/api/product_scope.md), [`product_worker`](../../functions/api/product_worker.md), [`propose_verdict`](../../functions/api/propose_verdict.md), [`raise_attention_sweep`](../../functions/api/raise_attention_sweep.md), [`record_claim`](../../functions/api/record_claim.md), [`record_probe_run`](../../functions/api/record_probe_run.md), [`record_source_assessment`](../../functions/api/record_source_assessment.md), [`record_triage`](../../functions/api/record_triage.md), [`register_probe`](../../functions/api/register_probe.md), [`related`](../../functions/api/related.md), [`relationships`](../../functions/api/relationships.md), [`release_digest`](../../functions/api/release_digest.md), [`release_order`](../../functions/api/release_order.md), [`releases_needing_review`](../../functions/api/releases_needing_review.md), [`resolve_entity`](../../functions/api/resolve_entity.md), [`restate_claim`](../../functions/api/restate_claim.md), [`search_knowledge`](../../functions/api/search_knowledge.md), [`search_knowledge_1536`](../../functions/api/search_knowledge_1536.md), [`search_unified`](../../functions/api/search_unified.md), [`settle_attention_sweep`](../../functions/api/settle_attention_sweep.md), [`submit_intent`](../../functions/api/submit_intent.md), [`summary_evidence`](../../functions/api/summary_evidence.md), [`symbol_changes`](../../functions/api/symbol_changes.md), [`symbol_history`](../../functions/api/symbol_history.md), [`talk_segments`](../../functions/api/talk_segments.md), [`talks_about`](../../functions/api/talks_about.md), [`timecode_link`](../../functions/api/timecode_link.md), [`unit_entities`](../../functions/api/unit_entities.md), [`what_changed`](../../functions/api/what_changed.md).

Types: none.
