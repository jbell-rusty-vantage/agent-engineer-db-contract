# Build 08 R2: knowledge continuum (catalog, typed units, one search stack)

**Status: loop-1 record and this promoted DDL ACCEPTED by John 2026-11-09 ("1. Accepted 2. Accepted 3. Gate readings confirmed. The rest are approved."); R2 direction accepted 2026-11-08; loop 1 executed 2026-11-08/09 on the disposable lab `disposable-aieng-build04`; determination ADD THESE CHANGES, applied in-loop and promoted as `supabase/migrations/20261108120000_build08_r2_knowledge_continuum.sql`; clean replay on `disposable-aieng-b08replay` schema-identical.** Nothing here is integrated into `ai-engineer-service`'s lab proof or Mission Control, and nothing is qualified for the remote `aieng-db`. The cycle record with counts, question verdicts, deltas and the unit-card gap list is [Build 08 §14](../../../platform/ai-engineer-research-2026-11-02/10-review-workspace/reviews/BUILD-08-KNOWLEDGE-LOOP.md).

Units: **RV01, RV02, RV04, RV06, RV09, RV11, RV12** (lab-proven), **RV00, RV03, RV07, RV10 seam, RV13, RV23** (partly), **RV21** (consumer break recorded).

## A. What the migration does

| Area | Change |
| --- | --- |
| `corpus` → `catalog` | 36 thin typed tables dropped; `catalog.entity.attributes` validated per `taxonomy.entity_kind.attributes_schema` (pg_jsonschema); `catalog.work` for paper/talk/media_work/story/case_study; `entity_kind.parent_kind/lens/is_work` |
| `knowledge` → `guidance` | item, item_subject, item_kind, assurance_level |
| Dropped families | `research`, `provenance`, `research_private`, `public.research_*`, `public.factory_*`; `research.use_admission` and the admission guards move to the new `verification` schema |
| `acquisition.fetch` | fetch ledger; `evidence.source_capture.acquisition_fetch_id` as the third capture producer (`native_harness_http`) |
| Numbers | `ranking` 16 → 3 (leaderboard, leaderboard_edition, leaderboard_entry); stream kinds `offering_price` (replaces `model_offering_price`), model context/max-output/capability/knowledge-cutoff/availability, `benchmark_score`, repository stars/forks/open issues, package downloads, media views, paper citations, organization headcount; relationship kinds `has_code`, `compatible_with`, `integrates_with`, `published_in` |
| Content layer | `content.format`, `content.source_role`, document kinds `unclassified`/`aie_talk`/`framework_docs_page`/`github_release`/`course_module`/`guide`, `document_kind_assignment`, `structure_census`, `unit_kind` (31 seeded) with validated `document_node.unit_kind/attributes/logical_key/grammar_version`, `refresh_check`, `unit_change`, `unit_assertion_mapping` (18), `unit_entity_role`, `document_digest` + `digest_item` |
| Retrieval | `projection_target` kinds unit/digest/authored/passage; `vector_item.lens/source_tier/workspace_id/unit_kind/document_id/…/search_tsv_en`; RLS by lens; spaces units/digests/entity_cards/assertions/own_content/learner_notes + `knowledge_text`; `retrieval.index_text_item`, `store_embedding`, `retire_items_for_passages`; `api.search_unified` (RRF of FTS + trigram + ANN, tier boost); `library.passage_embedding_1536` dropped; product `dispatch_read 'search'`, workers `index_passages`/`record_embeddings`, `confirm_removal` on the one stack |
| `api` surface | L1 views models, model_offerings, organizations, people, software (+ libraries/repositories/mcp_servers/agent_skills), software_releases, talks, events, concepts, papers, benchmark_scores, works_authored, guidance_items, claim_candidates, claim_conflicts; L2 functions changes_since, price_history, fact_locators, modules_affected_by_release, modules_using_software, talk_segments, document_units, document_digest, models_at, model_offerings_at, leaderboard; helpers fact_amount/fact_status/fact_payload/price_per_1m/related/names. Views require `app.tenant_id` in the session (not usable through bare PostgREST yet) |

Knowledge-side tables after the migration: 171 (catalog 9, content 29, temporal 9, evidence 26, retrieval 55, guidance 4, acquisition 1, verification 1, ranking 3, library 6, knowledge_service 15, taxonomy 9, dataset 4).

## B. Sources, drafts and promotion

`supabase/drafts/` keeps the lab sources: `part1_renames.sql`, `part2_content.sql`, `part3_retrieval.sql`, `part3b_product.sql`, `part4_views_seeds.sql` (assembled as the draft `20261108120000_build08_r2_knowledge_continuum.sql`) and the in-loop fixups `20261108120100` (retire `dispatch_command` path), `120200` (vector_item guard), `120300` (D-04 `api.modules_using_software`), `120400` (D-07/D-16 reader grants, talk linkage via `document_about_entity`), `120500` (D-10/D-14 `api.claim_candidates`, `api.claim_conflicts`). The promoted migration is their union; a fresh install applies only `supabase/migrations/`. The lab stack's head is `20261108120500` (drafts applied one by one); the workspace generator indexes `supabase/drafts/` as draft migrations (`workspace.config.json` `paths.draftMigrations`) so its head assertion matches the lab. `scripts/apply-disposable-migration.mjs --source-dir=supabase/drafts` applies drafts to a disposable target.

## C. Evidence

| Check | Result |
| --- | --- |
| Clean replay (`scripts/install-ai-engineer.mjs`, `--skip-mission-control --no-seal-key`) | installed; head `20261108120000`, 192 migrations; `pg_dump --schema-only` identical to the lab except one auto-created FK index on `authoring.event` (ordering artefact of `20261105010100`'s FK-index loop) |
| Existing product proof `scripts/product-lab/run_lab.py` | 150/150 on the final schema |
| `npm run typecheck` / `npm test` | 0 errors / 27 passing |
| `npm run workspace:build` / `workspace:check` / `workspace:validate` | 809 files; `same: true`; `ok: true` |
| Loop-1 questions (`reviews/QUERY-LEDGER.jsonl`) | 14 answered, 2 partial (missing content, not schema); max 6 schema calls (Q13), others ≤ 4 |
| Traversal T1–T8 / layouts A vs B | all reached in ≤ 4 reads / equivalent with facets |
| Spend | 6 Firecrawl credits + about USD 0.015 embeddings (ceiling USD 25) |

## D. Consumer impact

- Type contract: `src/api.ts` rewritten for the api views; `src/pre-research.ts`, `src/provenance.ts`, `src/reports.ts` and their package exports removed; `scripts/generate-types.mjs` lists 27 schemas.
- `platform/knowledge-services/packages/knowledge-db` references `corpus.` (about 62) and `research.report*` (about 20) and breaks against this schema. Recorded for RV21; not fixed here.
- `ai-engineer-service`: search payload/response compatible by inspection; its lab proof was not re-run.

## E. Deferred (recorded in the cycle record)

`knowledge_service` → `ks`; `evidence` 26 → 12 split; 65 → 45 relationship verbs; materialized L1 views; PostgREST-facing tenant resolution for the L1 views; paper grammar; format-change diff suppression; page-section labels for duplicate pricing tables.
