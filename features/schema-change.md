# Schema change: the procedure as practised today

> **As practised today; the owner's schema session decides the rules.** This page describes how a schema change has
> actually moved through this repository up to contract 0.10.0 (2026-11-18), assembled from the
> [README](../README.md), the review workspace's
> [FINAL-SCHEMA-PROCESS](../../../platform/ai-engineer-research-2026-11-02/10-review-workspace/process/FINAL-SCHEMA-PROCESS.md)
> and [AGENT-SESSION-PROTOCOL](../../../platform/ai-engineer-research-2026-11-02/10-review-workspace/process/AGENT-SESSION-PROTOCOL.md),
> and the CI workflow. It is input for step S4 of the
> [schema brief](../../../platform/ai-engineer-research-2026-11-02/10-review-workspace/process/OFFICIAL-SCHEMA-SEQUENCE.md#s2)
> ("Encode how to mutate the schema", AS-D68), not a new rule. Where practice and the written process disagree, both are
> stated.

<a id="steps"></a>
## The steps

| # | Step | Where and with what | Who decides |
| --- | --- | --- | --- |
| 1 | **Recommend** | One cycle record under the review workspace's `reviews/` (Build 08: [BUILD-08-KNOWLEDGE-LOOP](../../../platform/ai-engineer-research-2026-11-02/10-review-workspace/reviews/BUILD-08-KNOWLEDGE-LOOP.md)): scope, keep/change/add/remove schema, affected consumers, targets, proof plan, budget (protocol Stage A) | agent prepares |
| 2 | **Approve** | John's answer bound to the exact recommendation revision, targets and spend (Stage B). Recorded in the cycle record; from the schema session on, as a `B08-S<n>` answers file with `D-<n>` rows | John |
| 3 | **Draft** | The migration as a lab draft `supabase/drafts/<14 digits>_<name>.sql` (`workspace.config.json` `paths.draftMigrations`) | agent |
| 4 | **Lab trial** | `node scripts/apply-disposable-migration.mjs --project-dir=<lab workdir> --migration=<file> --source-dir=supabase/drafts` on the populated lab `disposable-aieng-build04` (refuses a non-`disposable-*` project or a container whose labels name another workdir); sample data; the affected suites on the lab | agent, under the approval |
| 5 | **Determine** | `LEAVE AS IS`, `ADD THESE CHANGES` or `BLOCKED / INCOMPLETE`, with evidence, in the cycle record; routine repairs loop back to 3-4 without a new approval | agent; John reviews |
| 6 | **Promote to the chain** | Copy the draft to `supabase/migrations/` with the version of the last draft it folds (the "draft twin" is kept), regenerate `src/database.generated.ts`, update `src/api.ts`, `workspace-enrichment/` and the generated `workspace/` (`npm run workspace:build -- --db-url <lab DSN>`); commit migration and types together | agent |
| 7 | **Version cut** | Bump `package.json`, `node scripts/check-contract-version.mjs --write`, rebuild the workspace, add the README version row ([version and release](version-and-release.md)) | agent (see "Where practice drifted") |
| 8 | **Fresh install from empty** | The root installer on a `disposable-*` stack, twice; the repeat must report `changed: false` ([install a target](install-a-target.md)). Locally optional; CI runs it on every push to `main` | CI |
| 9 | **All suites** | Every `supabase/tests/*.sql` but the named exceptions ([SQL suites](sql-suites.md)), then `generate-types.mjs --check`, `workspace:check`, `workspace:validate` against that install | CI |
| 10 | **Push** | One repository at a time; read CI before the next push (owner rule 2026-11-07, [worktree routing](../../../docs/navigation/WORKTREES.md#github-move-and-clean-slate-2026-11-06)) | John's go |
| 11 | **Consumer re-pin** | `npm run pack:contract`; Knowledge Services re-vendors `vendor/aiengineer-database-contract-<v>.tgz` and updates its docs; Mission Control and the AI Engineer service have no pin today | agent per consumer repo |
| 12 | **Remote apply** | Checkpoint and identity evidence; `wipe --dry-run`, `wipe --from-dry-run`, then `install-ai-engineer.mjs --remote-reinstall --target <MC target.toml> --confirm-target <ref>:<installation_id>` with the seal key and the Mission Control release; the three gates of `install-target.mjs` | John's explicit go (a separate authority) |
| 13 | **Readback** | `supabase_migrations.schema_migrations` on the target equals the frozen head; a consumer write and read (Mission Control W1 native write with readback); update Mission Control `deployments/ai-engineer/release.lock.json` | agent, evidence to John |
| 14 | **Record** | Disposition and evidence in the cycle record; unit and feature rows in [REVIEW-LEDGER](../../../platform/ai-engineer-research-2026-11-02/10-review-workspace/REVIEW-LEDGER.md) (the only progress authority); commit trailers name the session and decisions | agent |

One step per line:

1. Recommend in one cycle record (Stage A).
2. John approves that exact revision, targets and budget (Stage B).
3. Write the migration as a lab draft in `supabase/drafts/`.
4. Apply it to the disposable lab with `apply-disposable-migration.mjs --source-dir=supabase/drafts` and run the affected suites.
5. Record the determination; repair within the approval and rerun.
6. Promote the draft into `supabase/migrations/` with regenerated types, `src/api.ts`, enrichment and workspace, in one commit.
7. Cut the version (`package.json`, `check-contract-version.mjs --write`, workspace rebuild, README row).
8. Prove a fresh install from empty and a repeat that applies nothing (CI on push).
9. Run every SQL suite, the type check and the workspace check and validate against that install (CI).
10. Push one repository at a time and read CI.
11. Pack the tarball and re-pin the consumers (Knowledge Services vendors it; MC and the AE service do not pin yet).
12. Apply to `aieng-db` through the installer's wipe and remote-reinstall gates, with John's explicit go.
13. Read back the remote migration head and one consumer write, and update Mission Control's release lock.
14. Record the result in the cycle record and the review ledger.

<a id="drift"></a>
## Where practice drifted from the written process

- **Approval before the cut.** The five 2026-11-16 changes (`6106723`, then the cuts 0.7.0, 0.8.0, 0.9.0 and 0.10.0) were
  committed without the Stage B stop; John reviews them at S0 (brief §2 S0, §4).
- **Fresh install after the cut.** For 0.8.0-0.10.0 no fresh install from empty ran before the commit; CI proved it only
  at the push of `d240fd0` (2026-11-18: fresh install, repeat applied nothing, 30 suites passed, 6 left out).
- **The lab is built from drafts, not the installer.** `disposable-aieng-build04` was never installed by
  `install-ai-engineer.mjs`; the replay `disposable-aieng-b08replay` is occupied by `course_demo`, which blocked a fresh
  install at loop 7.
- **Lab scripts bypass the governed writes.** The lab scripts and Mission Control's watch fixtures `docker exec psql -U
  postgres` into the lab instead of calling the 0.8.0 `api.*` writes.
- **Consumers drift.** Knowledge Services vendors 0.10.0 but its docs say 0.6.0; Mission Control and the AI Engineer
  service pin nothing.
- **The remote is four versions behind.** `aieng-db` is at 0.6.0 (187 migrations, head `20261031010000`).

<a id="open"></a>
## Open for the schema session (brief §3)

Who approves a change and in which record; forward-only migrations once `aieng-db` holds real data; whether the fresh
install must pass locally before a commit or CI is enough; when a version is cut (per change or per freeze); which
consumers must re-pin before a remote apply; when `aieng-db` flips from `disposable` to `protected` (after which wipes
are refused); where the answers live (the review workspace is not versioned; §3 k).

## Proven by

Nothing runs this page. Its commands are proven where they live: `npm run version:check`, `npm test`, and the CI
workflow's install, suite and workspace steps (`./dev slow` prints them).
