#!/usr/bin/env node
// The contract version identifies one migration chain. `contract.version.json` records, for the version in package.json,
// the migration head, the number of migrations and a digest of the chain. This check fails when the label and the chain
// disagree, so a migration added (or changed) without cutting a version cannot ship under the old label:
//
//   VERSION_MISMATCH        package.json and contract.version.json name different versions
//   MIGRATION_HEAD_STALE    supabase/migrations holds a migration newer than the recorded head
//   MIGRATION_HEAD_MISSING  the recorded head file is not in supabase/migrations
//   MIGRATION_CHAIN_CHANGED same head, but a file was added, removed or edited below it
//   WORKSPACE_VERSION_STALE the committed schema workspace was generated under another version or head
//
// Usage (from the repository root):
//   node scripts/check-contract-version.mjs            exit 0 current, 1 stale (JSON report on stdout)
//   node scripts/check-contract-version.mjs --write    record the present chain for the version in package.json
// Cutting a version: bump package.json, run --write, rebuild the schema workspace, add the README row.
// The digest reads file contents with CRLF folded to LF, so a Windows checkout and a Linux checkout agree.
import { createHash } from "node:crypto";
import { existsSync, readFileSync, readdirSync, writeFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

export const RECORD_FILE = "contract.version.json";
export const RECORD_FORMAT = "ai-engineer-contract-version/1";
const MIGRATION_FILE = /^(\d{14})_[a-z0-9_]+\.sql$/;
const sha256 = (text) => createHash("sha256").update(text).digest("hex");

/** The ordered migration chain of a repository root: head file, count and a line-ending-insensitive digest. */
export function migrationChain(root) {
  const directory = join(root, "supabase", "migrations");
  const files = readdirSync(directory).filter((name) => MIGRATION_FILE.test(name)).sort();
  const lines = files.map((name) => `${name}:${sha256(readFileSync(join(directory, name), "utf8").replaceAll("\r\n", "\n"))}`);
  return { head: files.at(-1) ?? null, count: files.length, sha256: sha256(lines.join("\n")) };
}

export function recordFor(root) {
  const { version } = JSON.parse(readFileSync(join(root, "package.json"), "utf8"));
  const chain = migrationChain(root);
  return { format: RECORD_FORMAT, version, migration_head: chain.head?.replace(/\.sql$/, "") ?? null, migrations: chain.count, migrations_sha256: `sha256:${chain.sha256}` };
}

/** Every disagreement between the label and the chain; an empty list means the version identifies the schema. */
export function checkContractVersion(root) {
  const problems = [];
  const expected = recordFor(root);
  const recordPath = join(root, RECORD_FILE);
  if (!existsSync(recordPath)) return { ok: false, expected, recorded: null, problems: [{ code: "VERSION_RECORD_MISSING", detail: `${RECORD_FILE} is missing; run this script with --write` }] };
  const recorded = JSON.parse(readFileSync(recordPath, "utf8"));
  if (recorded.format !== RECORD_FORMAT) problems.push({ code: "VERSION_RECORD_FORMAT", detail: String(recorded.format) });
  if (recorded.version !== expected.version) {
    problems.push({ code: "VERSION_MISMATCH", detail: `package.json says ${expected.version}, ${RECORD_FILE} says ${recorded.version}` });
  }
  const versionOf = (name) => String(name ?? "").slice(0, 14);
  if (versionOf(expected.migration_head) > versionOf(recorded.migration_head)) {
    problems.push({ code: "MIGRATION_HEAD_STALE", detail: `supabase/migrations is at ${expected.migration_head}; contract ${recorded.version} was cut at ${recorded.migration_head}. Cut a new version (bump package.json, then --write).` });
  } else if (expected.migration_head !== recorded.migration_head) {
    problems.push({ code: "MIGRATION_HEAD_MISSING", detail: `contract ${recorded.version} records head ${recorded.migration_head}; supabase/migrations ends at ${expected.migration_head}` });
  } else if (expected.migrations !== recorded.migrations || expected.migrations_sha256 !== recorded.migrations_sha256) {
    problems.push({ code: "MIGRATION_CHAIN_CHANGED", detail: `the chain below ${recorded.migration_head} differs from the one contract ${recorded.version} was cut from (${recorded.migrations} files recorded, ${expected.migrations} present); promoted migrations are not edited, add a new one and cut a version` });
  }
  const manifestPath = join(root, "workspace", "manifest.json");
  if (existsSync(manifestPath)) {
    const build = JSON.parse(readFileSync(manifestPath, "utf8")).build ?? {};
    if (build.contract_version !== expected.version || build.migration_head !== versionOf(expected.migration_head)) {
      problems.push({ code: "WORKSPACE_VERSION_STALE", detail: `workspace/manifest.json was generated for contract ${build.contract_version} at head ${build.migration_head}; rebuild it (npm run workspace:build)` });
    }
  }
  return { ok: problems.length === 0, expected, recorded, problems };
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  const root = resolve(dirname(fileURLToPath(import.meta.url)), "..");
  if (process.argv.includes("--write")) {
    const record = recordFor(root);
    writeFileSync(join(root, RECORD_FILE), `${JSON.stringify(record, null, 2)}\n`);
    process.stdout.write(`${JSON.stringify({ written: RECORD_FILE, ...record })}\n`);
  } else {
    const result = checkContractVersion(root);
    process.stdout.write(`${JSON.stringify(result.ok ? { ok: true, ...result.recorded } : result, null, 2)}\n`);
    process.exitCode = result.ok ? 0 : 1;
  }
}
