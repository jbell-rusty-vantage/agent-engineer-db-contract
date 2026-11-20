# Version and release

One release number covers the whole AI Engineer database: the contract version. A release names exactly one migration
chain and pins the two guest components installed beside it (the Knowledge Services verification component and the
Mission Control component). The database states its release, and every service checks it before it starts (VER-S1,
2026-11-20).

- Code: [`scripts/check-contract-version.mjs`](../scripts/check-contract-version.mjs) (the record, `--write` to cut),
  [`scripts/database-release.mjs`](../scripts/database-release.mjs) (the startup rule, `show`, `stamp`),
  [`scripts/install-ai-engineer.mjs`](../scripts/install-ai-engineer.mjs) (the `database-release` step, `--release`),
  [`scripts/pack-contract.mjs`](../scripts/pack-contract.mjs).
- Schema: [`20261120120000_database_release_record`](../supabase/migrations/20261120120000_database_release_record.sql)
  (`util.database_release`, `util.stamp_database_release`, `api.database_release`).
- Tests: `scripts/check-contract-version.test.mjs` and `scripts/database-release.test.mjs` (in `npm test`),
  [`supabase/tests/database_release.sql`](../supabase/tests/database_release.sql).
- Version table and per-version notes: [README](../README.md#versions-and-where-they-are-installed-2026-11-01-main-row-added-2026-11-15-070-080-090-and-0100-rows-added-2026-11-16-0110-row-added-2026-11-19).

<a id="record"></a>
## The record

[`contract.version.json`](../contract.version.json) is the record of the current release: `version`, `migration_head`,
`migrations`, `migrations_sha256` and `components` (the pins the installer holds for `knowledge_verification` and
`mission_control`). [`releases/<version>.json`](../releases) keeps a copy per release, so an earlier release can be
named and reinstalled. The records for 0.7.0 to 0.11.0 were restored from this repository's history as they were.

```sh
npm run version:check     # fails when supabase/migrations is past the recorded head, a file below it changed, the
                          # record's components are not the installer's pins, releases/<version>.json is missing or
                          # differs, or workspace/ was generated under another version or head (in npm test and CI)
# to cut a version:
#   bump package.json "version"
node scripts/check-contract-version.mjs --write      # writes the record and releases/<version>.json
npm run workspace:build -- --db-url <loopback DSN at the new head>
#   add a row to the README version table
npm run pack:contract     # stages a copy with LF migrations, pnpm pack -> .scratch/release/aiengineer-database-contract-<v>.tgz,
                          # prints name, path, size and sha256 (JSON); refuses a stale version or a non-ignored output dir
```

To change a pinned component, change the pin in `scripts/install-ai-engineer.mjs` (`KS_COMPONENT_PIN`, `PINS`) and cut a
version: the check refuses a record whose components are not the installer's.

<a id="numbers"></a>
## What the numbers mean

| Part | Lane | Meaning for a service |
| --- | --- | --- |
| patch | vocabulary | lookup rows and seed data; nothing a service compiled against changes |
| minor | additive | new tables, columns, functions; a service built on an earlier minor still works |
| major | breaking | a service must be rebuilt for it |

Until 1.0.0 every bump may break, so each service pins the exact version. The freeze cuts 1.0.0; from then a service
states a range such as `>=1.2.0 <2.0.0`.

<a id="database"></a>
## The database states its release

The installer's `database-release` step stamps the record into `util.database_release` (append-only, one row per
stamp) after the migrations and both components are in. `api.database_release()` returns the newest stamp
(`declared`), what is in the database when asked (`observed`: the live migration version and count and each installed
component version) and one `state`:

| State | Meaning |
| --- | --- |
| `current` | the live head is the stamped head and every component that is present matches its pin |
| `ahead` | migrations were applied after the stamp (the lab during a unit session) |
| `inconsistent` | the live head is behind the stamp |
| `component_drift` | a component that is present differs from its pin |
| `unstamped` | no stamp |
| `unverifiable` | the migration list cannot be read |

A component that is not installed in this database is reported as null and is not drift.

```sh
node scripts/database-release.mjs show --workdir <supabase workdir> [--range <range>]   # what the database says and the verdict; exit 1 when a service would refuse
node scripts/database-release.mjs stamp --workdir <disposable supabase workdir>         # stamp a database the installer did not build (the lab)
node scripts/install-ai-engineer.mjs --workdir <disposable workdir> --release 0.11.0 ...  # install a named earlier release, then rerun without --release to prove the upgrade
```

A stamp may not claim a head the database is not at. The lab is built from drafts, so its migration count differs from
the chain's; the state is decided by the head.

<a id="check"></a>
## The startup check

Every service applies the same rule to what `api.database_release()` returns. The rule's reference implementation is
`inRange` and `releaseVerdict` in `scripts/database-release.mjs`; the shared cases are
[`release-check.cases.json`](../release-check.cases.json), shipped in the package, and each consumer runs them in its
own tests.

| Database answers | Verdict | In `enforce` mode |
| --- | --- | --- |
| nothing (function missing or another format) | `unknown` | refuse |
| `release` is null | `unstamped` | refuse |
| release outside the service's range | `incompatible` | refuse |
| in range, state `inconsistent` | `inconsistent` | refuse |
| in range, state `ahead`, `component_drift` or `unverifiable` | `ok`, with a warning | start |
| in range, state `current` | `ok` | start |

`AIENG_DB_RELEASE_CHECK` sets the mode: `enforce` (default), `warn` (start and log the verdict), `off` (do not ask).

One pre-check sits outside the rule. A consumer that can be bound to a database with no AI Engineer contract in it
(no `api` schema: Mission Control's own local database, or a component-only database in a drill) reports
`not_applicable` and starts. A database that has the `api` schema but no `api.database_release()` is `unknown`.
Mission Control and Knowledge Services apply the pre-check; the AI Engineer service always needs the contract and
does not.

<a id="consumers"></a>
## Consumers (as of 2026-11-20)

| Consumer | How it takes the contract | Startup check |
| --- | --- | --- |
| Knowledge Services | vendors the tarball: `vendor/aiengineer-database-contract-<v>.tgz`, referenced from [`packages/knowledge-db/package.json`](../../../platform/knowledge-services/packages/knowledge-db/package.json) | its range is the vendored record's version; see its feature map |
| AI Engineer service | pins the package; see its feature map | its range is the pinned record's version |
| Mission Control | declares the release it works with in [`deployments/ai-engineer/application.toml`](../../../platform/mission-control/deployments/ai-engineer/application.toml); its own component is pinned by this repository's installer | checks the database it is bound to when that database holds the contract |

Each consumer's own commit is the evidence for its row; this page does not prove them.

## Gotchas

- Tarballs are never tracked (`*.tgz` is ignored); the four in the root are old local leftovers. The tracked evidence
  of a release is `releases/<version>.json` and, after a push, its git tag.
- The committed workspace records one head, and CI compares it with the fresh install: build it from a database at
  exactly the migration head (keep one lab draft per promotion, or give the promoted migration the last draft's version).
- Mission Control's runtime roles are created by its component after this repository's migrations, so the migration
  cannot grant to them. The `database-release` step and the `stamp` command grant USAGE on schema `api` and EXECUTE
  on `api.database_release()` to `mission_control_runtime` and `mission_control_readonly` when they exist. Mission
  Control's login role inherits from `mission_control_runtime`. USAGE opens nothing else: every `api` view and
  function is granted by name.
- The installer pins Mission Control component 1.9.0. Mission Control's local stack uses 1.16.0 and `aieng-db` ran
  1.13.0 when last read (2026-11-18). Today's Mission Control refuses a database whose component lacks its migrations
  0070 to 0072, which 1.9.0 does, so it would not start on a database this installer builds; on a newer component
  the database reports `component_drift`. Which version the AI Engineer release should pin is the owner's decision.
- The wipe manifest `scripts/install-manifest.json` is pinned at 191 migrations (2026-11-05) and was not regenerated
  for Build 08 or later, so five `npm run test:installer` cases fail with `WIPE_MANIFEST_STALE` and a wipe is refused
  until it is regenerated (`scripts/install-manifest.mjs`).
- The intent contract changed shape under one label (`typedPayload` became `attributes`, still
  `knowledge-ingestion-intent/v1`): an open decision for the schema session (brief §3 g).
