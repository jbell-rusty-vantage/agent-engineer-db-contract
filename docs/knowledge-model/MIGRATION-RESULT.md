# Knowledge model migration result

**Target:** `supabase-blue-ocean` / `wkythqbofmckbuoothhn`. **Applied:** 2026-09-11. **Contract:** 0.3.0.

All thirteen migrations `20260912010000` through `20260912011200` are recorded in the cloud migration ledger. The local shared `aiengineer` database was not migrated or reset. Disposable PostgreSQL 17 databases were used for proofs.

## Preservation

All 25 `public.research_*` tables have identical complete-row digests and row counts before and after deployment. This includes both research-starter channels, all 2,252 videos, pre-research state, summaries, evidence anchors and ingestion intents. Matthew Berman's channel is `UCawZsQWqfGSbCI5yjkdVkTA`. No protected table DDL/DML or transcript-storage mutations were issued during cloud deployment.

The importer is installed as `corpus.import_research_starter_catalog(receipt_id)` but was **not run on the cloud catalog**. Its disposable tests prove repeatable, read-only use of starter tables. It creates media identities, playlist relationships and transcript document/source identities. Materializing transcript captures requires verified artifact bytes; the helper does not invent hashes or claim that catalog text is identical to an external storage object.

## Decisions made while implementing the schematic recommendation

- Preserve existing faithful content and its runtime lineage; document kinds are admitted into the routing vocabulary before adding the FK. A wholesale content/retrieval truncate was unnecessary and would have affected retained runtime dependencies.
- Preserve `knowledge.assurance_level`, `knowledge.record_reconciliation` and eleven ranking control tables required by orchestration/evaluation. Rebuild the identity/relationship/engineering-record domain and entity-keyed metric tables. All inventoried foreign keys are explicitly removed and reattached; no implicit `DROP ... CASCADE` is used.
- Keep `ai_model_version_spec` as a descriptor child, consistent with the 36-kind registry. `temporal.segment.specification_id` references it directly: Appendix B references a specification as an entity while omitting it from the entity-kind list.
- Use transaction identity in the locked knowledge head instead of trusting a writable session GUC. Deferred constraints reject unsealed batches, including empty ones. Full JSON Schema validation uses `pg_jsonschema`.
- Monetary streams require currency; percentage and limit streams require amount/unit without an artificial currency. Corrections preserve unaffected interval fragments. Overlapping revisions within one batch must be consolidated before admission.
- API views are invoker views backed by tenant-filtered definer readers, allowing application access without underlying table grants. Embedding child partitions deny direct bounded-role access; retrieval goes through their parent.
- Keep the published-version guard on hybrid search. New filter arguments narrow that authorized version. Projection helpers create candidate search projections; embeddings and publication remain governed runtime operations.

## Validation

- Fresh replay: 143 canonical baseline migrations plus the 13 migration files applied on disposable PostgreSQL 17.
- Populated upgrade: existing baseline plus an old corpus identity, faithful content and a Matthew Berman transcript fixture; all 13 files applied, with content and protected fixture preserved.
- Eight pgTAP-compatible behavioral test files cover temporal splitting/history/events, relationship kinds, role restrictions, media coordinates, summaries, repository lineage, unsealed batches/tenant checks/partitions, and catalog replay/preservation.
- New PL/pgSQL entry points were checked with `plpgsql_check`; application view reads were exercised as `app_reader`.
- Cloud generated types include `temporal`; `npm run typecheck` and cloud `types:check` pass.
- Cloud security advisors report existing public/Auth warnings and informational no-policy notices for deliberately inaccessible embedding child partitions. Protected public routines/policies were not changed. [Advisor reference](https://supabase.com/docs/guides/database/database-linter).

The first deployment stopped at `km_10` because the cloud search path did not resolve an unqualified `halfvec` argument. That file rolled back. Qualifying `extensions.halfvec` allowed the remaining three migrations to apply. No applied migration was rewritten.

## Deployment and consumption

Historical cloud migrations use some different timestamps from canonical replay files. Deployment used an isolated directory containing **metadata-only markers for already-applied cloud versions** plus exact copies of the thirteen new files. The dry run selected only those thirteen files; it did not repair history, replay old migrations, seed data, or update Vault. That temporary directory is not a replayable chain.

The canonical `supabase/migrations` directory remains the replay source. Generate types from the intended target explicitly:

```sh
node scripts/generate-types.mjs --project-id=wkythqbofmckbuoothhn
node scripts/generate-types.mjs --project-id=wkythqbofmckbuoothhn --check
npm run typecheck
```

Contract 0.3.0 is a breaking database contract. Existing application repositories were not rewritten or repinned by this database migration task; consumers must adopt the new entity/record/projection/document contracts before using their changed write paths. No application-local type copies were generated.

Machine-readable preservation and deployment receipts are in [migration-proof](migration-proof/). The compact [schema summary](SCHEMA-SUMMARY.md) describes the actual deployed database.
