# Build 08 loop 4: source intelligence, attention allocation, experiments, design interviews

**Status: lab-proven on `disposable-aieng-build04` (2026-11-13) and promoted as [`supabase/migrations/20261113120000_build08_loop4_source_intelligence_experiments.sql`](../supabase/migrations/20261113120000_build08_loop4_source_intelligence_experiments.sql) (the union of drafts `20261113120000` to `20261113120400`). Fresh install from an empty database on `disposable-aieng-b08replay` through `scripts/install-ai-engineer.mjs` (component, 193 domain migrations, custody grants; Mission Control and the seal key skipped) gave a schema dump identical to the lab except the dump's restrict token. Not integrated into `ai-engineer-service`, Knowledge Services or Mission Control, not applied to remote `aieng-db`. Owner review pending (John approved and pre-approved the run on 2026-11-12/13).** Cycle record: Build 08 §22 in the AI Engineer review workspace (`platform/ai-engineer-research-2026-11-02/10-review-workspace/reviews/BUILD-08-KNOWLEDGE-LOOP.md`).

Units: **RV09** (sources, attention), **RV10** (claims, verdicts), **RV13** (experiments), **RV22** (watch missions), RV06 (actors), RV12 (digests space), RV14 (the module binds the libraries), RV23 (the due-list as a mission contract).

## A. What the migration does

Seven new tables, two columns, vocabulary rows, views and functions.

| Area | Change |
| --- | --- |
| Registry | entity kinds `source_channel` (issue tracker, forum, Q&A, aggregator, blog, docs site, social, registry) and `community_actor` (platform + handle + the platform's role label, `additionalProperties: false`: no enrichment); relationship kinds `operates_channel`, `active_on`, `same_actor_as` (only when the platform states it); `evidence.source.channel_entity_id`; source role `own_experiment` (85, tier 1); table `evidence.source_assessment` (append-only, per subject × topic × as-of, components: role, conflict of interest, method disclosure, track record, lead days, noise, derived score, suggested watch level); `evidence.derive_source_assessment(subject, topic)`; views `api.source_registry` (latest row per source and topic), `api.source_track_record`, `api.community_claims` |
| Attention | tables `acquisition.attention_policy` (scope, channels, subjects, watch level W0–W3, ISO-8601 cadence, depth, selection rules, triggers, budgets, `inquiry_watch_id`, `mission_id`, `designed_in_thread_id`) and `acquisition.attention_sweep` (trigger, window, seen / selected / captured, rejections by reason, spend, `origin_kind` standalone or mission); `acquisition.fetch.sweep_id`; view `api.attention_policies`; function `api.attention_due(as_of)`: due by cadence, or by a trigger event since the last non-backfill sweep inside the trigger window (`"only": "major"` counts x.0.0 releases only) |
| Experiments | tables `verification.probe` (hypothesis, kind executed / static_docs / resolution / registry_check / live_model, script path + sha256, matrix of cells, model policy, budget, `designed_in_thread_id`), `verification.probe_claim`, `verification.probe_run` (cell, resolved versions, lock sha, outcome, observations, output capture + locator, tokens, cost, sweep, mission), `verification.probe_verdict` (support verdict per claim, per-cell summary, `agent_proposed` / `human_confirmed` / `human_rejected`); capture method `probe_execution`; document types `issue_thread`, `forum_thread` (moved to family `community`), `comparison_article`, `probe_report`; unit kinds `thread_post`, `probe_observation`; views `api.probes`, `api.claim_verdicts`; function `api.probe_matrix(probe)` |
| Interviews | `conversation.thread` purpose `interview` and mode `elicit`; `api.interview_outputs(thread)` (probes and policies a design interview produced, with run counts) |
| Report | `api.library_dossier(library)` (jsonb: releases, claims by status, open community claims, probes with per-cell outcomes and verdicts, ranked sources) |
| Candidate B | claim type `assertion` (D-47); the D-50 cross-reference on `api.talks_about`; `retrieval.retire_deterministic_digest_items()` (the digests space holds model-written digests; deterministic items stay in `knowledge_text`); entity kind `benchmark_run` and its three relationship kinds removed (0 rows) |

## B. Rules the pipeline applies (not enforced by DDL)

- A probe verdict is evidence, not verification: `evidence.enforce_verified_claim_gate` lets only a receipt bound to an admitted Knowledge Services use decision set `verified` (D-55). Supported claims stay `proposed` with their verdict; a deterministic contradiction sets `disputed`. Live arms and community claims never verify alone.
- Cells are dates (`uv pip install --exclude-newer <date>`) unless pinned; every run records the resolved versions and the lockfile digest.
- A community claim is stored only if its quote is found verbatim in one post; it is attributed to the handle and the channel's source. Not reproduced, unverifiable and insufficient evidence are observed, not checked (D-59).
- Sweep rejections carry counted reasons (rules over titles and repositories) or the label `not_selected_by_reviewer_phase_a`; never estimates.

## C. Consumers

[`src/api.ts`](../src/api.ts) gains 9 types; [`src/database.generated.ts`](../src/database.generated.ts) is regenerated; the workspace gained pages for the new relations, views and functions (884 files). `knowledge-db` (Knowledge Services) is still not cut over (RV21); the probe-verdict-to-admission path is the next Knowledge Services seam.

## D. Scripts

[`loop4_scout.py`](../scripts/knowledge-lab/loop4_scout.py) (Phase A), [`loop4_probes.py`](../scripts/knowledge-lab/loop4_probes.py) and [`probes/`](../scripts/knowledge-lab/probes/) (environments and runs), [`loop4_process.py`](../scripts/knowledge-lab/loop4_process.py) (registry, attention, captures, claims, probe registration and verdicts, assessments, projections; model `claude-opus-5-5` for thread claim candidates only), [`loop4_product.py`](../scripts/knowledge-lab/loop4_product.py) (design interview and course module through the product API), [`loop4_questions.py`](../scripts/knowledge-lab/loop4_questions.py), [`loop4_traversal.py`](../scripts/knowledge-lab/loop4_traversal.py), [`loop4_promote.py`](../scripts/knowledge-lab/loop4_promote.py). Drafts: `supabase/drafts/20261113120000..20261113120400`.
