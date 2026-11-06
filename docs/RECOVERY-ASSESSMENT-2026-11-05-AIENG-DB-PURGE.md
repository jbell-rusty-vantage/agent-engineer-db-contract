# AI Engineer database purge: what is recoverable (2026-11-05)

Scope: `aieng-db` = Supabase `supabase-blue-ocean` (ref `wkythqbofmckbuoothhn`). Read-only inspection on 2026-11-05 through the claude.ai Supabase connector plus local files. Nothing was written, restored or deleted. No secret values appear here.

Goal this serves: re-ingest the AI Engineer World's Fair videos into the new optimized schema (in development) and rebuild the research-starter / pre-research capability as a stronger Vercel Eve agent under AI Engineer and Mission Control. This is an inventory, not a restore plan that has been executed.

## Bottom line

- **Verified now:** the tables are empty (`research_starter_videos`, `research_starter_channels`, `research_pre_research_run`, `research_video_analysis`, `research_ingestion_intent` all count 0). Storage was **not** purged.
- **The expensive, irreplaceable parts survived:** the Apify-paid transcripts (1,125 AI Engineer + 1,095 Matthew Berman) and every GLM 5.2 pre-research packet (12,784 objects) are still in Storage, and 89 run packets also sit on disk.
- **The video catalog is cheap to rebuild** from the YouTube Data API with the existing OAuth/API-key process (not exercised today, see "Not verified").
- **Row-level state** (video lifecycle, intent rows, event logs, web-search events) is gone from the live DB. A Sep 11 `pg_dump` and per-table digests exist locally and may recover a snapshot. Supabase's own backups/PITR are unchecked and are the one thing worth looking at in the dashboard.

## 1. Verified recoverable in Supabase Storage (aieng-db)

| Bucket | Objects | Size | What it holds |
| --- | --- | --- | --- |
| `ai-engineer-transcripts` | 1,125 | 20 MB | `ai-dot-engineer/<video_id>.txt`, the paid Apify transcripts. Created 2026-08-14 to 2026-10-01. |
| `matthew-berman-transcripts` | 1,095 | 17 MB | Second channel, ingested 2026-09-02. |
| `research-ingestion-intents` | 32,292 | 528 MB | See below. |
| `ai-engineer-cloud-bucket` | 252 | 5.8 MB | Mission run outputs (Tavily query captures under `missions/ai-engineer-video-u3nofyystay/...`, `intents/u3NofYYstaY/...`) and content-addressed blobs. |
| `capability-bundles` | 106 | 321 kB | Mission Control bundles (2026-10-28 to 11-02). |
| `research-reports`, `content-derivatives`, `source-captures` | 5 / 3 / 1 | tiny | Sep 9 and Sep 13 test artifacts. |

`research-ingestion-intents` breakdown, which is the real GLM 5.2 research record:

| Prefix | Objects | Meaning |
| --- | --- | --- |
| `pre-research/v2/<video_id>/<run_id>/` | 12,784 | Full run packets: `00-run-manifest`, `10-transcript-analysis`, `20-taxonomy-classification`, `30-web-context`, `35-organization-research`, `40-source-verification`, `50-curriculum-signals`, `90-ingestion-intent`, `99-execution-receipt`, plus `initial-summary/`, `organization-profile/`, `technology-library-summary/`. |
| `_stage-execution/v1/...` | 17,374 | Per-stage inputs/outputs. |
| `_controller-cache/v2/...` | 2,132 | Controller cache per run. |
| `_quarantine/...` | 2 | Bad-manifest intents set aside on 2026-08-24. |

The 12,784 `pre-research` objects equal the 12,784 rows of `research_pre_research_artifact` in the Sep 11 snapshot (`aiengineer/internal/knowledge-model-migration/protected-before.json`). That match is strong evidence the artifact table was a pure index over the bucket and the bucket is complete as of that snapshot.

## 2. Verified recoverable on this machine

- `research_starter_pre_research_agent/outputs/pre-research/v2/`: 89 video directories with complete run packets (13 MB). A local mirror, not the full set.
- `outputs/jev-sweep/{audit,backlog}-20260925T0040/`: items/results JSONL, review queue CSV, reports from the Sep 24 sweep.
- `experiments/embedding-bundle-seed-2026-09-01/`: embedding-bundle seeds and drafts for specific videos.
- `outputs/local-drain/`: drain logs (Aug 24 to 29).
- `aiengineer/internal/knowledge-model-migration/local-before.dump` (7.5 MB, PGDMP custom format, 2026-09-11 12:43): a Postgres dump taken before the knowledge-model migration. **Its contents were not verified**: `pg_restore` was not found at the PostgreSQL 16 path, so I could not list it. Run `pg_restore -l` first.
- Same folder: `protected-before.json` / `protected-after.json` give row counts and md5 digests per table at that date. Use them to prove any restore is exact.

Row counts at Sep 11 (what a restore of that snapshot should show): `research_starter_videos` 2,252; `research_video_lifecycle` 2,064; `research_pre_research_run` 1,109; `research_pre_research_video_state` 2,252; `research_video_analysis` 1,050; `research_video_technology_summary` 4,169; `research_ingestion_intent` 1,062; `research_ingestion_intent_event` 12,600; `research_organization_candidate` 1,201; `research_entity_candidate` 1,760; `research_evidence_anchor` 11,772; `research_resource_candidate` 7,998; `research_web_search_event` 6,216; `research_starter_channels` 2.

Also local: migrations (`ai-engineer-db-contract/supabase/migrations/`, including `20260814025347_research_starter_videos.sql`, the pre-research schema, `20260902010518_research_starter_channels.sql`) and the generated workspace docs, so the old schema can be recreated exactly if wanted.

## 3. What is gone from the live DB (unless a backup exists)

- Catalog rows and per-video lifecycle/qualification state, including `transcript_status`, `transcript_path`, `transcript_char_count`.
- Run/session/stage-execution tables, the ingestion-intent and event tables, candidate/evidence/resource tables, web-search event log.
- Whatever was written after Sep 11 (for example transcripts added up to Oct 1, and runs after the dump). Their files are in Storage but their rows are not in the dump.

Most of this is **derivable** from Storage because the packets and manifests carry video id and run id. A re-index from `pre-research/v2/<video_id>/<run_id>/00-run-manifest.json` plus the transcript object names reconstructs the video-to-run-to-artifact graph without any backup.

## 4. Catalog and transcript pipeline still intact (code and process)

- Catalog: `npm run catalog:sync` (`scripts/catalog/sync-research-starter-videos.mts`, OAuth helpers `youtube-auth.mts`, `youtube-oauth-login.mts`). Inserts missing videos for `@aiDotEngineer` via the YouTube Data API.
- Transcripts: `npm run apify:ingest-transcripts` (`apify-transcript-ingest/ingest.mts`, actor `starvibe/youtube-video-transcript`). It checks the bucket first (`objectExists`) and skips with `bucket_object_exists`, so re-running **will not re-buy transcripts that already exist**. Path rule: `<channel prefix>/<video_id>.txt`.
- Credentials: `aiengineer/internal/secrets/` contains `credentials.json` and `token.json` (Google OAuth) and a README naming `YOUTUBE_API_KEY` and `APIFY_API_KEY`. Presence verified by file listing only; I did not read values and did not test the token.
- Docs note the skill says "Do not use the YouTube Transcript API"; captions come from Apify, which is why the bucket is the asset to protect.

## 5. Gaps and cautions

1. **Catalog vs transcripts:** the Sep 11 catalog had 2,252 videos across two channels; the buckets hold 1,125 + 1,095 = 2,220 transcripts. Which videos lack one is derivable only once the catalog is rebuilt.
2. **Order of operations matters for spend.** Rebuild the catalog first, then backfill `transcript_path` from existing objects *before* running the ingest, otherwise the "missing path" query lists everything as needing transcripts. The ingest's bucket-exists check is a second safety net, but do not rely on it alone.
3. **Pipeline code depends on the old schema** (`agent/lib/postgres`, claim functions in `research_private`). Pointing it at the new schema needs the adapter work you already planned; restoring old tables is only needed if you want the old pipeline to run unchanged.
4. **Do not run the old claim/drain loops against a blank DB** without a spend ceiling; they would reprocess from scratch.
5. `aieng-graph` (`4773dc72`) was untouched by this and remains never-write.

## 6. Not verified (check before relying on)

- Supabase **backups / PITR** for `wkythqbofmckbuoothhn`: no connector tool exposes them. Dashboard (via Vercel Storage/Integrations, not GitHub) > Database > Backups. If PITR is on, a point just before the purge restores the rows exactly; do it to a new/branch project, not in place.
- That `local-before.dump` restores, and which database it came from. It is labelled "local" in the migration folder; its time (Sep 11) matches the protected snapshot.
- That the Google OAuth token is still valid and the YouTube Data API quota is available.
- Whether the 89 local packets are a subset of the bucket (expected) rather than extra.

## 7. Suggested order (no spend until step 5)

1. Check dashboard backups/PITR. If a pre-purge point exists, restore to a **separate** target and compare against `protected-before.json` digests.
2. `pg_restore -l` the Sep 11 dump; restore into the disposable local Postgres (`sprint-v-pg17`, `127.0.0.1:55433`) to read old rows without touching cloud.
3. Copy the buckets' packets locally (or leave in place) and snapshot the object listing (names, sizes) so Storage becomes a recorded asset inventory. Consider bucket versioning/soft-delete to avoid a repeat.
4. Rebuild the catalog with the YouTube API into the **new** schema, keyed by `video_id`; reconcile against transcript object names.
5. Only then ingest genuinely missing transcripts with Apify, under a stated cost cap.
6. Re-link old GLM 5.2 packets to the new schema by `video_id`/`run_id` rather than re-running the model.

## 8. Eve agent note (design input, unverified against current Vercel pricing)

The re-ingest and research stages above are good fits for the Eve agent you described: the stage artifacts already have stable file contracts (`10-` to `99-`), so a provider-neutral model selection layer can swap GLM for OpenAI/Anthropic models per stage. Vercel's free-credit offers and model catalog change often; confirm current terms before budgeting. Mission Control's Deep Agents priority is unaffected.
