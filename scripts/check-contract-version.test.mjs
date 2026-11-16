import assert from "node:assert/strict";
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import { test } from "node:test";
import { fileURLToPath } from "node:url";
import { RECORD_FILE, checkContractVersion, migrationChain, recordFor } from "./check-contract-version.mjs";

const repository = resolve(dirname(fileURLToPath(import.meta.url)), "..");

/** A throwaway repository root: package.json at `version`, the given migrations, and a record written for them. */
function fixture(version, migrations) {
  const root = mkdtempSync(join(tmpdir(), "contract-version-"));
  mkdirSync(join(root, "supabase", "migrations"), { recursive: true });
  writeFileSync(join(root, "package.json"), JSON.stringify({ name: "fixture", version }));
  for (const [name, sql] of Object.entries(migrations)) writeFileSync(join(root, "supabase", "migrations", name), sql);
  writeFileSync(join(root, RECORD_FILE), JSON.stringify(recordFor(root)));
  return root;
}
const codes = (root) => checkContractVersion(root).problems.map((problem) => problem.code);

test("the committed record identifies the committed chain", () => {
  const result = checkContractVersion(repository);
  assert.deepEqual(result.problems, []);
  assert.equal(result.recorded.version, recordFor(repository).version);
});

test("a migration newer than the recorded head fails", () => {
  const root = fixture("1.0.0", { "20260101000000_first.sql": "select 1;\n" });
  try {
    assert.deepEqual(codes(root), []);
    writeFileSync(join(root, "supabase", "migrations", "20260102000000_second.sql"), "select 2;\n");
    assert.deepEqual(codes(root), ["MIGRATION_HEAD_STALE"]);
  } finally { rmSync(root, { recursive: true, force: true }); }
});

test("a version bump without a new record fails, and so does an edited migration", () => {
  const root = fixture("1.0.0", { "20260101000000_first.sql": "select 1;\n", "20260102000000_second.sql": "select 2;\n" });
  try {
    writeFileSync(join(root, "package.json"), JSON.stringify({ name: "fixture", version: "1.1.0" }));
    assert.deepEqual(codes(root), ["VERSION_MISMATCH"]);
    writeFileSync(join(root, "package.json"), JSON.stringify({ name: "fixture", version: "1.0.0" }));
    writeFileSync(join(root, "supabase", "migrations", "20260101000000_first.sql"), "select 11;\n");
    assert.deepEqual(codes(root), ["MIGRATION_CHAIN_CHANGED"]);
  } finally { rmSync(root, { recursive: true, force: true }); }
});

test("a removed head fails, and files that are not ordered migrations do not count", () => {
  const root = fixture("1.0.0", { "20260101000000_first.sql": "select 1;\n", "20260102000000_second.sql": "select 2;\n" });
  try {
    rmSync(join(root, "supabase", "migrations", "20260102000000_second.sql"));
    assert.deepEqual(codes(root), ["MIGRATION_HEAD_MISSING"]);
  } finally { rmSync(root, { recursive: true, force: true }); }
  const other = fixture("1.0.0", { "20260101000000_first.sql": "select 1;\n" });
  try {
    mkdirSync(join(other, "supabase", "migrations", "deferred"));
    writeFileSync(join(other, "supabase", "migrations", "notes.sql"), "select 0;\n");
    assert.deepEqual(codes(other), []);
    assert.equal(migrationChain(other).count, 1);
  } finally { rmSync(other, { recursive: true, force: true }); }
});

test("the digest is the same for a CRLF checkout and an LF checkout", () => {
  const lf = fixture("1.0.0", { "20260101000000_first.sql": "begin;\nselect 1;\ncommit;\n" });
  const crlf = fixture("1.0.0", { "20260101000000_first.sql": "begin;\r\nselect 1;\r\ncommit;\r\n" });
  try {
    assert.equal(migrationChain(lf).sha256, migrationChain(crlf).sha256);
  } finally { rmSync(lf, { recursive: true, force: true }); rmSync(crlf, { recursive: true, force: true }); }
});

test("a workspace generated under another version fails", () => {
  const root = fixture("1.0.0", { "20260101000000_first.sql": "select 1;\n" });
  try {
    mkdirSync(join(root, "workspace"));
    writeFileSync(join(root, "workspace", "manifest.json"), JSON.stringify({ build: { contract_version: "1.0.0", migration_head: "20260101000000" } }));
    assert.deepEqual(codes(root), []);
    writeFileSync(join(root, "workspace", "manifest.json"), JSON.stringify({ build: { contract_version: "0.9.0", migration_head: "20260101000000" } }));
    assert.deepEqual(codes(root), ["WORKSPACE_VERSION_STALE"]);
  } finally { rmSync(root, { recursive: true, force: true }); }
});
