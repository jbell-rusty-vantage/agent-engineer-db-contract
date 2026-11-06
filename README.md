# AI Engineer database contract

This repository is the canonical contract for the shared AI Engineer Supabase database. It owns:

- ordered Supabase migrations;
- local Supabase configuration;
- generated TypeScript types for every application-relevant schema;
- stable type-only entry points for application consumers.

Applications consume this repository as a pinned dependency. They do not maintain independent generated copies.

Repository: public [`jbell-rusty-vantage/agent-engineer-db-contract`](https://github.com/jbell-rusty-vantage/agent-engineer-db-contract), `main` only. History starts at the 2026-11-06 clean-slate baseline, so commit IDs cited below and in older documents do not resolve here ([repository history](docs/REPOSITORY-HISTORY.md)).

## Versions and where they are installed (2026-11-01)

| Contract | Migration head | Committed | Installed |
| --- | --- | --- | --- |
| **0.6.0** (current) | `20261031010000_operation_receipt_targets` (187 migrations) | yes (`44c980c`; version bump OVE-206) | local disposable `supabase_db_disposable-overnight-20261029` (2026-10-31), and the owner-declared **disposable** remote `wkythqbofmckbuoothhn` on 2026-11-01 (`20261025010200` → `20261031010000`, contract installer `--remote-reinstall --skip-mission-control`; [receipt summary](docs/knowledge-model/SCHEMA-SUMMARY.md#native-ledger-provenance-migration-20261031010000)) |
| 0.5.0 | `20261025010200` (186 migrations) | yes (`25f82ed`, `306efd7`) | Sprint OC W0 (2026-10-28) on the owner-declared **disposable** remote `wkythqbofmckbuoothhn` (`supabase-blue-ocean`), after the WI-24 wipe (Mission Control `docs/specs/provider-consolidation-2026-10/sprint-oc/release/RELEASE-BUNDLE.md`, sections 1 and 4) |
| 0.4.0 / 0.3.0 | `20260913020000` / `20260912011200` | yes | historical: deployed to the same project `wkythqbofmckbuoothhn` in 2026-09; the W0 wipe dropped those schemas and their data |

The remote project `wkythqbofmckbuoothhn` is a disposable target (workspace `docs/navigation/DATA-PLANES-AND-CREDENTIALS.md`,
plane **aieng-db**); it is no longer the populated shared database the 0.3.0/0.4.0 notes below describe. Deployment
claims still require current evidence: read the target's `supabase_migrations.schema_migrations` before asserting a head.

Contract 0.6.0 is the provenance slice 3 schema (OVE-204): `origin_digest`/`origin_kind` and the Mission Control
`mc_*` coordinates on `orchestration.operation_intent`, `origin_digest` on `orchestration.operation_receipt`, the
normalized `orchestration.operation_receipt_target`, `evidence.claim.producer_origin_digest` with
`claim_producer_identity`, and the view `orchestration.mission_run_effects`
([schema summary](docs/knowledge-model/SCHEMA-SUMMARY.md#native-ledger-provenance-migration-20261031010000)).
For type consumers of 0.5.0 it is additive except that `evidence.claim.producer_attempt_id` is now nullable. Knowledge
Services vendors the packed 0.6.0 tarball (`vendor/aiengineer-database-contract-0.6.0.tgz`, produced by `pnpm pack`).

The historical knowledge model is documented in [Schema summary](docs/knowledge-model/SCHEMA-SUMMARY.md) and [Migration result](docs/knowledge-model/MIGRATION-RESULT.md). Contract 0.3.0 targeted the cloud database; the populated local shared database was left unchanged. Use an explicit project ID when regenerating the cloud contract.

Contract **0.4.0** added [research report packages v1](docs/knowledge-model/REPORTS.md), deployed then to the same identified cloud project with migration head `20260913020000`. The private `research-reports` bucket stores immutable report files; table projections retain sections, assertions, coverage and ingestion lineage. [Deployment evidence](docs/knowledge-model/REPORT-CONTRACT-DEPLOYMENT.json) verifies preservation of existing report and protected starter content at that time. Import report row types from `@aiengineer/database-contract/reports`.

## Contract 0.5.0: Sprint V cutover (committed; installed at W0)

Migration `20261025010000_withdraw_legacy_verification_truth` withdraws the AIDB-owned verification,
report-seal and recovery truth now owned by the common `knowledge_verification` component (KS
`packages/knowledge-db-contract`; the cutover pinned 2.4.0, the installer now pins **2.5.0**, component digest `sha256:00550d59…8b88`, see `KS_COMPONENT_PIN` below):
`evidence.verification_run/finding`, `executable_verification`, `claim_evidence_assessment`, the
verification case and adjudication ledgers, the drift revalidation outbox, `research.report_package_seal`,
`report_assessment`, `report_ingestion_link` and the `knowledge_service.recovery_*` ledger. A claim reaches
`verified` only under a receipt bound to an admitted use decision; the v1 report projection is closed for
new rows (`REPORT_V1_WITHDRAWN`). Removed type exports: `ResearchReportSeal`, `ResearchReportIngestionLink`,
`ResearchReportAssessment` (replaced by the `ResearchReportV2*` projection rows). This is a breaking type
change for consumers still pinned to 0.4.16.

The component must be installed **before** these migrations (`20261024010000` refuses otherwise), so
`db:start`/`db:migrate` alone no longer build a fresh database. Use the root installer against an
explicitly disposable workdir (`project_id = "disposable-*"`, database container started first):

```sh
npx supabase db start --workdir <disposable-workdir>
node scripts/install-ai-engineer.mjs --workdir <disposable-workdir>   --component-installation-id <uuid> --mc-installation-id <uuid> [--skip-mission-control]
```

It installs the pinned component (version + digest checked) with the KS CLI, applies this repository's
migrations, verifies the binding pin, capability grants and custody RLS, installs the Mission Control common
release 1.9.0 with `mission-db`, the Sprint OC target lock (`sprint-oc/release/locks-190`; an installed 1.8.0 upgrades in place by applying 0066 and 0067 only) and an explicit release root (`--mc-release-root`, the same
directory as the lock's `release_root`), and writes a JSON receipt. The KS component pin
is the single `KS_COMPONENT_PIN` line (2.5.0: `0008_effect_dispatch_journal`; an installed 2.4.0 upgrades in place by
applying 0008 only, with the same `--component-installation-id`); `--ks-root` selects the KS checkout (default
`../../platform/knowledge-services`) and `--ks-component-root` an explicit component tree (the pin still applies). Every step is
idempotent; rerun after an interruption; a repeat run reports `changed: false`. The `seal-key` step (OVE-169 W1 D25)
pins the PUBLIC half of the KS executor's run-seal key in `knowledge_verification.seal_signing_key` through the KS CLI
`knowledge-db seal-key` (derived from the private PEM, never printed; `current` on repeat, `SEAL_KEY_CONFLICT` for another
key under the id, `--retire-seal-key-ids` moves earlier ids to `retiring`). It reads `--seal-key-id`/`--seal-key-file`/
`--seal-issuer`, else `KS_KNOWLEDGE_SEAL_KEY_ID`/`KS_KNOWLEDGE_SEAL_KEY_FILE`/`KS_KNOWLEDGE_SEAL_ISSUER`/
`KS_KNOWLEDGE_SEAL_RETIRE_KEY_IDS` (the runtime generator's `install.env`). `--remote-reinstall` refuses `SEAL_KEY_REQUIRED` without a key unless
`--no-seal-key` is passed; a local run without one warns on stderr and skips; until a key
is registered `report.seal` refuses `CAPABILITY_UNAVAILABLE` / `seal_key_unregistered`. It refuses the shared
`aiengineer` project (`DISPOSABLE_PROJECT_REQUIRED`) unless the remote-reinstall flag below is used.

### Remote reinstall and wipe (Sprint OC WI-24)

The owner-declared disposable remote (Mission Control `deployments/ai-engineer/target.toml`, OC-D184) is reinstalled
by wiping what this repository and its components own and running the same installer against that target file. Both
commands pass the gates in [`scripts/install-target.mjs`](scripts/install-target.mjs), in order:

1. `--confirm-target` equals the file's `<project_ref>:<installation_id>`.
2. The credential in the variable named by `database_url_env` addresses exactly its host/port/user/database; a
   non-loopback host needs `sslmode=require|verify-ca|verify-full` (`require` encrypts without verifying, as libpq).
3. Identity: installation rows in `mission_control.application_installation` must all carry that ref, id and
   application. `--identity-evidence <file>` is checked in full whenever it is supplied, and is the only proof for a
   pre-1.6.0 Mission Control (`mission_control` present, no row; the remote stops at 0044). With no `mission_control`
   at all (e.g. after a wipe) the exact route (`postgres.<ref>` pooler login or `db.<ref>.supabase.co`) or the
   evidence proves it.

```sh
# from this repository root, with the target's database_url_env exported (admin DSN; values never printed)
T=../../platform/mission-control/deployments/ai-engineer/target.toml
node scripts/install-ai-engineer.mjs wipe --dry-run --target $T --confirm-target <ref>:<installation_id> --identity-evidence <file> [flags]
node scripts/install-ai-engineer.mjs wipe --target $T --confirm-target <ref>:<installation_id> --identity-evidence <file> [same flags] \
  --from-dry-run .scratch/sprint-oc/evidence/wipe/dry-run-<ref>-<stamp>.json
node scripts/install-ai-engineer.mjs --remote-reinstall --target $T --confirm-target <ref>:<installation_id> --component-installation-id <uuid> \
  [--seal-key-id <KS_KNOWLEDGE_SEAL_KEY_ID> --seal-key-file <runtime/ai-engineer/ks-seal.pem>]
```

Flags (identical on the dry-run and the real run, compared order-insensitively): `--drop-public-extra a,b`, `--keep-public-extra c`,
`--allow-extra-relations schema.rel,...`, `--allow-sessions`, `--schemas a,b`.

Identity evidence is JSON written by the operator from the Supabase management API, under 24 h old. Its `project_ref`,
`name` and `installation_id` must equal the target's `project_ref`, `project_label` and `installation_id`, the route
must carry the ref, and `system_identifier` must equal `select system_identifier::text from pg_control_system()` read
over the DSN (`TARGET_SYSTEM_IDENTIFIER_MISMATCH` otherwise):
`{"source": "management-api", "project_ref": "...", "name": "...", "region": "...", "installation_id": "...", "system_identifier": "...", "observed_at": "<ISO-8601>"}`.

- **Wipe**, one transaction per step, Mission Control last: (1) the `public` objects the migration chain creates
  (pinned in [`scripts/install-manifest.json`](scripts/install-manifest.json): 41 tables, 3 functions, 17 types) and
  its `storage.objects` trigger and policies, by name; (2) the 18 domain schemas; (3) every row of
  `supabase_migrations.schema_migrations` (the disposable project's ledger, versions recorded); (4) `knowledge_service`,
  `knowledge_verification`; (5) `capability_search` (MC legacy), `mission_control_runtime`, `mission_control_search`,
  `mission_control`. It never drops a database, the `public` schema, extension-owned objects, buckets or stored objects
  (orphaned objects are counted per bucket in the receipt).
- **All or nothing.** A real wipe requires `--from-dry-run`: a `dry-run-clear` receipt of the same target, installation
  id, schemas and flags, under 2 h old (`WIPE_DRY_RUN_REQUIRED`, `_BLOCKED`, `_STALE`, `_MISMATCH`). Before committing
  anything it re-runs the whole plan as a dry-run; any blocker refuses with `WIPE_PLAN_BLOCKED`, and an inventory
  digest (objects per step, cascade dependents, `public` manifest and extra sets, ledger versions; not row counts)
  different from the receipt's refuses with `WIPE_DRY_RUN_MISMATCH`. Nothing is changed in either case.
- **Blockers**: a `public` object outside the manifest not named in `--drop-public-extra`/`--keep-public-extra`
  (`WIPE_PUBLIC_EXTRA`); an allow-listed schema not owned by the target's session user
  (`WIPE_SCHEMA_OWNER_UNEXPECTED`) or holding a relation the migrations do not create, unless named in
  `--allow-extra-relations` (`WIPE_UNEXPECTED_RELATION`); a non-platform session on the database unless
  `--allow-sessions` (`WIPE_SESSIONS_ACTIVE`; platform = `authenticator`, `dashboard_user`, `supabase_admin`,
  `supabase_auth_admin`, `supabase_storage_admin`, `supabase_realtime_admin`, `pgbouncer`, `supabase_replication_admin`,
  `supabase_read_only_user`, and `postgres` sessions of Supabase Studio, pg_meta or PostgREST); and any cascade that
  would remove something outside what the plan removes (`WIPE_CASCADE_OUTSIDE_ALLOW_LIST`, now also covering indexes,
  column defaults, rules and extended statistics): only the planned objects and the policies, triggers, constraints,
  indexes, rules and statistics of the manifest's own tables may go, so a kept extra view on a manifest table,
  or a trigger on a kept table that calls a manifest function, blocks. Absent objects are no-ops.
- **`--dry-run`** runs every gate and every step with a 5 s lock timeout and rolls each back. Its receipt lists, per
  step, object counts and relation names, estimated rows, cascade dependents and blockers; for `public`, exact
  `count(*)` of every manifest table and extra, and the extra objects; the ledger versions to delete; orphaned storage
  objects per bucket; every other client session (`usename`, `application_name`, state, `backend_start`; never query
  text; background workers such as autovacuum are not sessions);
  and the inventory digest. Status `dry-run-clear` or `dry-run-blocked`.
- Receipts: `.scratch/sprint-oc/evidence/wipe/{dry-run,wipe}-<ref>-<UTC>-<tag>.json` plus a `.txt` summary and a
  `.journal.jsonl` of step starts/ends, always written (also for a refusal or a failure, with `failedStep`); target,
  identity, schemas, timestamp and actor, never a credential. `--evidence-dir` must be git-ignored.
- **Remote reinstall** replaces the disposable-workdir gate with gates 1–3, runs domain migrations through
  `supabase migration up --db-url` (the CLI has no environment-variable form, so the DSN is an argument of a
  shell-less child process; output is scrubbed), and installs Mission Control with the target file and its
  `installation_id`. Fresh = wipe + install; repeat = install again and observe `changed: false`; interrupted =
  kill it, rerun (the dead run's lock is taken over).
- Migrations that touch objects a wipe keeps are idempotent: the `research_starter_videos` channel FK, the
  `factory_runtime_event` checks and the `registered_storage_delete_guard` trigger drop-if-exist before re-adding.
- Refusal codes (exit 2): `CONFIRM_TARGET_REQUIRED`, `CONFIRM_TARGET_MISMATCH`, `TARGET_REQUIRED`, `TARGET_INVALID`,
  `TARGET_DSN_MISSING`, `TARGET_DSN_MISMATCH`, `TARGET_DSN_TLS_REQUIRED`, `TARGET_INSPECT_FAILED`,
  `TARGET_IDENTITY_MISMATCH`, `TARGET_IDENTITY_UNPROVEN`, `TARGET_SYSTEM_IDENTIFIER_MISMATCH`,
  `TARGET_SYSTEM_IDENTIFIER_UNREADABLE`, `IDENTITY_EVIDENCE_INVALID`, `WIPE_SCHEMA_NOT_ALLOWED`, `WIPE_MANIFEST_STALE`,
  `WIPE_PUBLIC_EXTRA`, `WIPE_EXTENSION_OBJECT`, `WIPE_SCHEMA_OWNER_UNEXPECTED`, `WIPE_UNEXPECTED_RELATION`,
  `WIPE_SESSIONS_ACTIVE`, `WIPE_CASCADE_OUTSIDE_ALLOW_LIST`, `WIPE_LOCK_TIMEOUT`, `WIPE_PLAN_BLOCKED`,
  `WIPE_DRY_RUN_REQUIRED`, `WIPE_DRY_RUN_BLOCKED`, `WIPE_DRY_RUN_STALE`, `WIPE_DRY_RUN_MISMATCH`,
  `EVIDENCE_DIR_NOT_IGNORED`, `REMOTE_REINSTALL_FLAG_REQUIRED`, `REMOTE_REINSTALL_CONFLICT`,
  `MC_INSTALLATION_ID_MISMATCH`.
- **Manifest**: regenerate after any migration change with `node scripts/install-manifest.mjs --admin-dsn-env <NAME> --container <name>`
  (`--check` to verify); the wipe refuses a manifest that predates `supabase/migrations` (`WIPE_MANIFEST_STALE`).
- **Tests**: `npm run test:installer`. With `INSTALL_WIPE_PG_ADMIN_DSN` (loopback admin DSN) and `INSTALL_WIPE_PG_CONTAINER` they replay the full
  chain on throwaway `disposable_*` databases: the real installer in remote mode (crash after domain migrations,
  resume, repeat `changed: false`), a remote-like state (foreign ledger rows, extra `public` objects, an unknown
  relation, storage objects, application and platform sessions), dry-run, every refusal, a late blocker after a clean
  dry-run that commits nothing, stale/mismatched/changed receipts, kept extras protected from cascades, wipe,
  re-wipe, reinstall and catalog equality with the fresh install; a simulated legacy Mission Control (0044, no
  identity table) with evidence bound by `system_identifier`; cast, column and owner refusals.
- **Local Supabase stub** (tests and manifest only, never a Supabase project; set `INSTALL_WIPE_PG_CONTAINER` to the
  container that publishes the admin DSN's port): [`scripts/supabase-stub/`](scripts/supabase-stub/) creates, inside
  each throwaway database, schemas `auth`, `storage`, `extensions` and the database `search_path`
  `"$user", public, extensions`; `auth.users(id)` and `auth.jwt()`; `storage.buckets`, `storage.objects` (RLS on) and
  `storage.foldername()`; `pgcrypto` in `extensions`. Cluster-wide pieces leave no shared state: roles `anon`,
  `authenticated`, `service_role`, `postgres` (NOLOGIN) are created only when absent and dropped after the run (so are
  the chain's app roles when the run created them); the stub `pg_jsonschema` extension (its `jsonb_matches_schema()`
  always returns true) has its files on the server only while one test database registers it, then they are deleted,
  so no other database can create it. The run refuses to start if `pg_jsonschema` files already exist there.
  GoTrue, Storage API, PostgREST, Realtime, Vault and Supabase's own grants are not stubbed.

## Schema boundaries

Contract **0.4.16** includes explicit recovery-original references to either a native
`knowledge_service.operation` or an `orchestration.operation_intent` of kind
`verify_claim`. Tenant-scoped foreign keys and an exclusive-source constraint
preserve authority. Equal bindings can retain distinct original claim IDs within
one case; immutable unique binding ownership prevents resetting them through another
case, including under repeatable-read and serializable transactions. Migration
head `20260916020200` is verified on
the guarded pre-Mission-Control disposable databases; this is not a deployment
claim for the populated shared or cloud database.

- `public` contains the existing pre-research pipeline (`public.research_*`) and preserved factory tables.
- `api` is the application-facing Data API surface.
- `research`, `ranking`, `curriculum`, `corpus`, `evidence`, and the other bounded schemas are internal database namespaces.
- `research_private` contains the existing pre-research pipeline routines.

The generated contract includes internal schemas for server-side consumers. This does not expose those schemas through PostgREST; Data API exposure remains controlled by `supabase/config.toml`, grants, and RLS.

## Local workflow

**Release path (integrator decision, SV-17, 2026-10-25).** `scripts/install-ai-engineer.mjs` is the only release
and fresh-install path. `db:start`, `db:migrate` and `scripts/apply-disposable-migration.mjs` remain disposable
development tools for incremental local work; they are never a release, cutover or service-startup path.

Use the pinned Supabase CLI from this repository (development only):

```sh
npm install
npm run db:start
npm run db:migrate
npm run types:generate
```

Commit each migration and its regenerated `src/database.generated.ts` in the same change.

`db:migrate` incrementally applies pending migrations to the local database. The shared `aiengineer` project contains accumulated source captures, provider receipts and accounting evidence; resetting it destroys those registrations even when physical Storage files survive. `db:reset` therefore refuses the shared project and all caller-supplied target arguments. Fresh-chain proofs belong in a separate workspace with an explicit `vfy-` or `disposable-` project identity. Preserve populated data before migration work, and retain isolated proof receipts and volumes. Do not change the shared project identity to bypass this guard.

CI can detect contract drift with:

```sh
npm run types:check
```

When local PostgreSQL is available but Docker management is unavailable, use the
pinned Node generator with an explicit `POSTGRES_URL` supplied by the local runtime:

```sh
corepack pnpm types:generate:native
corepack pnpm types:check:native
```

This opt-in mode accepts only `postgres` on loopback port `54322`, loads no `.env`,
and forces read-only database sessions with bounded queries. It uses the same
canonical schema list and writes the generated file only after successful
introspection. Linked/project targets are rejected. The pinned `postgres-meta`
0.95.2 output is structurally equivalent to the preceding generated contract;
formatting can differ from other CLI generator versions. The usual CLI commands
remain available for their configured environments.

## Consuming the contract

Install a pinned commit or release of this repository. Import only types:

```ts
import type { Database } from "@aiengineer/database-contract";
import type { PreResearchRun } from "@aiengineer/database-contract/pre-research";
```

Supabase-generated types describe rows, inserts, updates, enums, and functions. They do not validate arbitrary SQL strings passed to `pg` at compile time.
