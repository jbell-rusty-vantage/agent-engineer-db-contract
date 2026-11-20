#!/usr/bin/env node
// The database release (VER-S1): which release a database is, and whether a service may start on it.
//
// A release is the contract version. contract.version.json records it (migration head, count, digest and the pinned
// components) and releases/<version>.json keeps a copy per release. The installer stamps the record into the database
// (util.database_release); api.database_release() returns the stamp, what is observed now and one state word.
//
// This file holds the rule every consumer applies (inRange, releaseVerdict; the same cases, release-check.cases.json,
// run in each consumer's tests) and two commands:
//
//   node scripts/database-release.mjs show  (--workdir <supabase workdir> | --db-url <loopback DSN>) [--range <range>]
//       What the database says, the record of this checkout and the verdict. Exit 0 when a service pinned to the range
//       (default: exactly this checkout's version) would start, 1 otherwise. Reads only.
//   node scripts/database-release.mjs stamp --workdir <disposable supabase workdir>
//       Stamps a database that the installer did not build (the lab, which is built from drafts) with this checkout's
//       record. Refuses unless the database head is the record's head. Disposable local projects only.
//
// A range is an exact version (X.Y.Z) or ">=A.B.C <D.E.F". Until 1.0.0 every consumer pins the exact version.
import { existsSync, readFileSync, realpathSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

export const RELEASE_FORMAT = "ai-engineer-database-release/1";
export const CHECK_VARIABLE = "AIENG_DB_RELEASE_CHECK";
const VERSION = /^(\d+)\.(\d+)\.(\d+)$/;
const RANGE = /^>=(\d+\.\d+\.\d+) <(\d+\.\d+\.\d+)$/;
const repository = resolve(dirname(fileURLToPath(import.meta.url)), "..");

function parts(version) {
  const match = VERSION.exec(String(version));
  if (!match) throw new Error(`not a release version: ${version}`);
  return match.slice(1).map(Number);
}

/** -1, 0 or 1: numeric comparison of two X.Y.Z versions. */
export function compareVersions(a, b) {
  const [x, y] = [parts(a), parts(b)];
  for (let i = 0; i < 3; i += 1) if (x[i] !== y[i]) return x[i] < y[i] ? -1 : 1;
  return 0;
}

/** Whether a release is inside a consumer's range: an exact version, or ">=A.B.C <D.E.F". */
export function inRange(version, range) {
  if (VERSION.test(range)) return compareVersions(version, range) === 0;
  const match = RANGE.exec(range);
  if (!match) throw new Error(`not a release range: ${range} (write X.Y.Z or ">=A.B.C <D.E.F")`);
  return compareVersions(version, match[1]) >= 0 && compareVersions(version, match[2]) < 0;
}

/**
 * The verdict on what api.database_release() returned (null when the database gave no answer) for a consumer's range.
 * `start` says whether a service in enforce mode starts; `warning` that it starts on a database that is not exactly
 * the stamped release.
 */
export function releaseVerdict(observed, range) {
  const facts = { range, release: observed?.release ?? null, state: observed?.state ?? null };
  const refuse = (verdict, reason) => ({ verdict, start: false, warning: false, ...facts, reason });
  if (!observed || observed.format !== RELEASE_FORMAT) return refuse("unknown", "the database does not state a release (api.database_release() is missing or answered in another format)");
  if (observed.release == null) return refuse("unstamped", "the database has never been stamped with a release");
  if (!inRange(observed.release, range)) return refuse("incompatible", `the database is release ${observed.release}; this service works with ${range}`);
  if (observed.state === "inconsistent") return refuse("inconsistent", `the database is stamped ${observed.release} but its migrations are behind that release`);
  if (observed.state === "current") return { verdict: "ok", start: true, warning: false, ...facts, reason: `the database is release ${observed.release}` };
  const why = {
    ahead: "migrations were applied after the stamp (unreleased changes)",
    component_drift: "a guest component differs from the version the release pins",
    unverifiable: "the migration list could not be read, so the stamp is unchecked",
  }[observed.state] ?? `state ${observed.state}`;
  return { verdict: "ok", start: true, warning: true, ...facts, reason: `the database is release ${observed.release}; ${why}` };
}

/** enforce (default), warn or off, from AIENG_DB_RELEASE_CHECK. */
export function checkMode(env = process.env) {
  const mode = String(env[CHECK_VARIABLE] ?? "enforce").trim().toLowerCase();
  if (!["enforce", "warn", "off"].includes(mode)) throw new Error(`${CHECK_VARIABLE} must be enforce, warn or off (got ${env[CHECK_VARIABLE]})`);
  return mode;
}

/** What the database says: the JSON of api.database_release(), or null when the function is not there. */
export async function readDatabaseRelease(client) {
  const present = (await client.query("select to_regprocedure('api.database_release()') is not null as ok")).rows[0].ok;
  return present ? (await client.query("select api.database_release() as r")).rows[0].r : null;
}

export function loadRecord(root = repository) {
  return JSON.parse(readFileSync(join(root, "contract.version.json"), "utf8"));
}

function option(argv, name) {
  const inline = argv.find((a) => a.startsWith(`--${name}=`));
  if (inline) return inline.slice(name.length + 3);
  const index = argv.indexOf(`--${name}`);
  return index >= 0 ? argv[index + 1] : undefined;
}

async function target(argv, { disposableOnly }) {
  const installer = await import("./install-ai-engineer.mjs");
  const workdirArg = option(argv, "workdir");
  if (workdirArg) {
    const workdir = realpathSync(resolve(workdirArg));
    if (disposableOnly) installer.assertDisposableWorkdir(workdir);
    return { installer, dsn: installer.resolveDsn(workdir).dsn };
  }
  const dsn = option(argv, "db-url");
  if (!dsn || disposableOnly) throw new installer.Refused("TARGET_REQUIRED", disposableOnly ? "--workdir <disposable supabase workdir>" : "--workdir <supabase workdir> or --db-url <loopback DSN>");
  if (!["127.0.0.1", "localhost"].includes(new URL(dsn).hostname)) throw new installer.Refused("LOOPBACK_REQUIRED", "a remote plane is read with ./dev db query --plane <plane>");
  return { installer, dsn };
}

async function show(argv) {
  const { installer, dsn } = await target(argv, { disposableOnly: false });
  const record = loadRecord();
  const range = option(argv, "range") ?? record.version;
  const database = await installer.withClient(dsn, readDatabaseRelease);
  const verdict = releaseVerdict(database, range);
  process.stdout.write(`${JSON.stringify({ record: { version: record.version, migration_head: record.migration_head, components: record.components ?? null }, database, verdict }, null, 2)}\n`);
  return verdict.start ? 0 : 1;
}

async function stamp(argv) {
  const { installer, dsn } = await target(argv, { disposableOnly: true });
  const { migrationChain } = await import("./check-contract-version.mjs");
  const record = loadRecord();
  const chain = migrationChain(repository);
  if (record.migration_head !== chain.head?.replace(/\.sql$/, "") || record.migrations !== chain.count || record.migrations_sha256 !== `sha256:${chain.sha256}`) {
    throw new installer.Refused("RELEASE_RECORD_STALE", `contract.version.json names ${record.version} at ${record.migration_head}; the chain ends at ${chain.head}`);
  }
  const result = await installer.withClient(dsn, async (client) => {
    const supported = (await client.query("select to_regprocedure('util.stamp_database_release(text,text,integer,text,jsonb,text)') is not null as ok")).rows[0].ok;
    if (!supported) throw new installer.Refused("RELEASE_TABLE_MISSING", "this database predates util.database_release; apply the migration first");
    const stamped = (await client.query("select util.stamp_database_release($1, $2, $3, $4, $5::jsonb, $6) as r",
      [record.version, record.migration_head, record.migrations, record.migrations_sha256, JSON.stringify(record.components), "database-release.mjs stamp"])).rows[0].r;
    const missionControlReaders = await installer.grantReleaseReaders(client);
    return { stamped, missionControlReaders, database: await readDatabaseRelease(client) };
  });
  process.stdout.write(`${JSON.stringify(result, null, 2)}\n`);
  return 0;
}

if (process.argv[1] && existsSync(process.argv[1]) && realpathSync(resolve(process.argv[1])) === realpathSync(fileURLToPath(import.meta.url))) {
  const [command, ...argv] = process.argv.slice(2);
  const run = { show, stamp }[command];
  if (!run) {
    process.stderr.write("usage: node scripts/database-release.mjs show (--workdir <dir> | --db-url <loopback DSN>) [--range <range>]\n       node scripts/database-release.mjs stamp --workdir <disposable supabase workdir>\n");
    process.exitCode = 2;
  } else {
    run(argv).then(
      (code) => { process.exitCode = code; },
      (error) => {
        if (error?.code && error?.detail !== undefined) { process.stdout.write(`${JSON.stringify({ status: "refused", code: error.code, detail: error.detail })}\n`); process.exitCode = 2; return; }
        process.stderr.write(`${error instanceof Error ? error.message : String(error)}\n`);
        process.exitCode = 1;
      },
    );
  }
}
