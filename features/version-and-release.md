# Version and release

A contract version names exactly one migration chain. `package.json` carries the version;
[`contract.version.json`](../contract.version.json) records its migration head, file count and digest (0.10.0: head
`20261116150000_build08_capture_receipt_unit_text`, 203 migrations, on `main` at `d240fd0`). Consumers pin a version.

- Code: [`scripts/check-contract-version.mjs`](../scripts/check-contract-version.mjs) (with `--write` to record a cut),
  [`scripts/pack-contract.mjs`](../scripts/pack-contract.mjs).
- Tests: `scripts/check-contract-version.test.mjs` (in `npm test`).
- Version table and per-version notes: [README](../README.md#versions-and-where-they-are-installed-2026-11-01-main-row-added-2026-11-15-070-080-090-and-0100-rows-added-2026-11-16).

## Drive it

```sh
npm run version:check     # fails when supabase/migrations is past the recorded head, a file below it changed,
                          # or workspace/ was generated under another version or head (also in npm test and CI)
# to cut a version:
#   bump package.json "version"
node scripts/check-contract-version.mjs --write
npm run workspace:build -- --db-url <loopback DSN at the new head>
#   add a row to the README version table
npm run pack:contract     # stages a copy with LF migrations, pnpm pack -> .scratch/release/aiengineer-database-contract-<v>.tgz,
                          # prints name, path, size and sha256 (JSON); refuses a stale version or a non-ignored output dir
```

Proven by: `npm run version:check` (passes on `main`).

## Consumers (as of 2026-11-18)

| Consumer | How it takes the contract |
| --- | --- |
| Knowledge Services | vendors the tarball: `vendor/aiengineer-database-contract-<v>.tgz`, referenced from [`packages/knowledge-db/package.json`](../../../platform/knowledge-services/packages/knowledge-db/package.json); it vendors 0.10.0, byte-identical to this repository's tarball |
| Mission Control | no pin; its watch fixtures run this repository's lab scripts, and [`deployments/ai-engineer/release.lock.json`](../../../platform/mission-control/deployments/ai-engineer/release.lock.json) pins its own component |
| AI Engineer service | no pin; its result shapes cite an older lab head |

## Gotchas

- Tarballs are never tracked (`*.tgz` is ignored); the four in the root are old local leftovers.
- The committed workspace records one head, and CI compares it with the fresh install: build it from a database at
  exactly the migration head (keep one lab draft per promotion, or give the promoted migration the last draft's version).
- The intent contract changed shape under one label (`typedPayload` became `attributes`, still
  `knowledge-ingestion-intent/v1`): an open decision for the schema session (brief §3 g).
