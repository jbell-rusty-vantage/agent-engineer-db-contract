// Wipe and remote-reinstall gates of the AI Engineer root installer (Sprint OC WI-24).
//
//   node --test scripts/install-target.test.mjs                      unit gates (no database)
//   INSTALL_WIPE_PG_ADMIN_DSN=<loopback admin DSN> INSTALL_WIPE_PG_CONTAINER=<its container> node --test ...
//                                                                     + real PostgreSQL 17 with the local Supabase stub
//                                                                     (scripts/supabase-stub/; its roles and extension
//                                                                     files are installed for the run and removed in the
//                                                                     file-level `after`, also on failure): the real
//                                                                     installer in --remote-reinstall mode over the FULL
//                                                                     migration chain, a remote-like state, dry-run,
//                                                                     refusals, wipe, re-wipe, reinstall, and catalog
//                                                                     equality with the fresh install. Never a remote host.
//   INSTALL_SEAL_PG_ADMIN_DSN=<loopback admin DSN> [AIDB_TEST_KS_ROOT=<KS checkout with dist built>] node --test ...
//                                                                     + the seal-key step (OVE-169 W1 D25) on its own
//                                                                     throwaway database: KS component install, applied,
//                                                                     current, conflict, rotation with retire.
//   AIDB_TEST_MC_ROOT=<MC checkout>                                   the Mission Control checkout to test against (default
//                                                                     ../../platform/mission-control; a worktree holding a
//                                                                     release before it is merged); passed as --mc-root.
import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { createHash, generateKeyPairSync, randomUUID } from "node:crypto";
import { existsSync, mkdirSync, mkdtempSync, readFileSync, readdirSync, rmSync, writeFileSync } from "node:fs";
import { createRequire } from "node:module";
import { tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import { after, before, describe, it } from "node:test";
import { fileURLToPath, pathToFileURL } from "node:url";
import { CHAIN_ROLES, STUB_ROLES, catalogSnapshot, loadManifest, migrationsDigest, openStubCluster, prepareStubDatabase } from "./install-manifest.mjs";
import {
  DOMAIN_SCHEMAS, MISSION_CONTROL_SCHEMAS, PROTECTED_SCHEMAS, Refused, WIPE_SCHEMAS, cascadeVerdict, checkDryRunReceipt,
  confirmTarget, evaluateIdentity, identifyTarget, inventoryDigest, isPlatformSession, isProtectedSchema, listSessions, loadTarget,
  normalizeFlags, pgConfig,
  redactor, resolveTargetDsn, routeProof, selectSchemas, summarize,
} from "./install-target.mjs";
import { KS_COMPONENT_PIN, PINS, componentCli, checkSealKeyInputs, main, scrubOutput, sealKey, sealKeyOptions } from "./install-ai-engineer.mjs";

const repository = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const mcRoot = resolve(process.env.AIDB_TEST_MC_ROOT ?? join(repository, "..", "..", "platform", "mission-control"));
const mcRootArgs = process.env.AIDB_TEST_MC_ROOT ? ["--mc-root", mcRoot] : [];
const ksCli = resolve(repository, "..", "..", "platform", "knowledge-services", "packages", "knowledge-db-contract", "dist", "cli.js");
const missionDb = join(mcRoot, ".venv", process.platform === "win32" ? "Scripts/mission-db.exe" : "bin/mission-db");
const scratch = join(repository, ".scratch", "sprint-oc", "test-install-target");
const refusal = (code) => (error) => { assert.ok(error instanceof Refused, String(error)); assert.equal(error.code, code); return true; };

function targetToml({ ref, id, host = "127.0.0.1", port = 5432, user = "postgres", database = "postgres", env = "INSTALL_WIPE_TARGET_DSN", environment = "disposable", label = ref }) {
  return `format_version = 1

[target]
app = "ai-engineer"
application_id = "ai-engineer"
project_label = "${label}"
project_ref = "${ref}"
installation_id = "${id}"
environment = "${environment}"
database_host = "${host}"
database_port = ${port}
database_name = "${database}"
database_user = "${user}"
database_url_env = "${env}"

[approval]
approved_by = "install-target.test.mjs"
identity_evidence = "disposable loopback test database"
`;
}
function writeTarget(dir, name, fields) {
  mkdirSync(dir, { recursive: true });
  const path = join(dir, name);
  writeFileSync(path, targetToml(fields));
  return path;
}
const SYSID = "7300000000000000001";
const probe = (rows = [], missionControl = rows.length > 0) => ({ schemasPresent: missionControl ? ["mission_control"] : [], missionControl, identityRows: rows, lastMissionControlMigration: missionControl ? "0044_x" : null, systemIdentifier: SYSID, systemIdentifierError: null });
const inspection = (target, matches = true) => ({ status: "inspected", target: { project_ref: target.project_ref, installation_id: target.installation_id }, identity_matches_target: matches });
const row = (ref, id, app = "ai-engineer") => ({ installation_id: id, application_id: app, supabase_project_ref: ref, environment: "production" });
const evidenceFor = (t, over = {}) => ({ source: "management-api", project_ref: t.project_ref, name: t.project_label, region: "us-east-1", installation_id: t.installation_id, system_identifier: SYSID, observed_at: new Date().toISOString(), ...over });

// --------------------------------------------------------------------------------------------------------- unit
describe("allow-list and manifest", () => {
  it("names exactly the schemas this repository's migrations create", () => {
    const dir = join(repository, "supabase", "migrations");
    const created = new Set();
    for (const f of readdirSync(dir).filter((n) => n.endsWith(".sql"))) {
      for (const m of readFileSync(join(dir, f), "utf8").matchAll(/create\s+schema\s+(?:if\s+not\s+exists\s+)?"?([a-z_][a-z0-9_]*)"?/gi)) created.add(m[1].toLowerCase());
    }
    assert.deepEqual([...created].filter((s) => s !== "knowledge_service").sort(), [...DOMAIN_SCHEMAS].sort());
  });
  it("includes MC's legacy capability_search and never a protected schema", () => {
    assert.deepEqual([...MISSION_CONTROL_SCHEMAS], ["capability_search", "mission_control_runtime", "mission_control_search", "mission_control"]);
    for (const s of WIPE_SCHEMAS) assert.equal(isProtectedSchema(s), false, s);
    for (const s of [...PROTECTED_SCHEMAS, "pg_catalog", "pg_toast", "supabase_migrations"]) assert.equal(isProtectedSchema(s), true, s);
  });
  it("refuses any schema outside the allow-list", () => {
    for (const list of ["public", "auth", "storage", "extensions", "supabase_migrations", "research,public", "not_ours", ""]) {
      assert.throws(() => selectSchemas(list), refusal("WIPE_SCHEMA_NOT_ALLOWED"), list);
    }
    assert.deepEqual(selectSchemas("mission_control, research"), ["research", "mission_control"]);
  });
  it("pins a manifest generated from the current migrations (regenerate with scripts/install-manifest.mjs)", () => {
    const manifest = loadManifest();
    assert.deepEqual(manifest.migrations, migrationsDigest());
    assert.equal(manifest.public.relations.length, 41);
    for (const s of [...DOMAIN_SCHEMAS, "knowledge_service"]) assert.ok(manifest.schemas[s], s);
    assert.ok(manifest.storage.triggers.some((t) => t.name === "registered_storage_delete_guard"));
  });
});

describe("target gates", () => {
  const dir = mkdtempSync(join(tmpdir(), "aidb-target-"));
  after(() => rmSync(dir, { recursive: true, force: true }));
  const ref = "wkythqbofmckbuoothhn";
  const id = "01a103c0-9a9e-70f3-9398-eb1573a98324";
  const pooler = loadTarget(writeTarget(dir, "pooler.toml", { ref, id, host: "aws-1-us-east-1.pooler.supabase.com", user: `postgres.${ref}`, env: "AIDB_TEST_URL", environment: "production", label: "supabase-blue-ocean" }), { app: "ai-engineer" });
  const base = `postgresql://postgres.${ref}:s3cr%2Fet@aws-1-us-east-1.pooler.supabase.com:5432/postgres`;

  it("reads the real MC ai-engineer target's identity fields", { skip: !existsSync(join(mcRoot, "deployments", "ai-engineer", "target.toml")) }, () => {
    const t = loadTarget(join(mcRoot, "deployments", "ai-engineer", "target.toml"), { app: "ai-engineer" });
    assert.match(t.project_ref, /^[a-z0-9-]+$/);
    assert.ok(routeProof(t), "the real target's route carries its ref");
  });
  it("requires --confirm-target and its exact value", () => {
    assert.throws(() => confirmTarget(undefined, pooler), refusal("CONFIRM_TARGET_REQUIRED"));
    for (const wrong of [ref, id, `${id}:${ref}`, `${ref}:01a103c0-9a9e-7a95-961b-29dda83c842b`, `bxnetwiimwhtlrjlbtab:${id}`, ` ${ref}:${id}`]) {
      assert.throws(() => confirmTarget(wrong, pooler), refusal("CONFIRM_TARGET_MISMATCH"), wrong);
    }
  });
  it("requires the declared endpoint and TLS off loopback", () => {
    assert.throws(() => resolveTargetDsn(pooler, {}), refusal("TARGET_DSN_MISSING"));
    for (const wrong of [base.replace("aws-1", "aws-0"), base.replace(":5432", ":6543"), base.replace(`postgres.${ref}`, "postgres"), `${base}?options=x`, `${base}?sslmode=require&sslmode=disable`]) {
      assert.throws(() => resolveTargetDsn(pooler, { AIDB_TEST_URL: wrong }), refusal("TARGET_DSN_MISMATCH"), wrong);
    }
    for (const mode of ["", "?sslmode=disable", "?sslmode=allow", "?sslmode=prefer"]) {
      assert.throws(() => resolveTargetDsn(pooler, { AIDB_TEST_URL: `${base}${mode}` }), refusal("TARGET_DSN_TLS_REQUIRED"), mode);
    }
    assert.equal(resolveTargetDsn(pooler, { AIDB_TEST_URL: `${base}?sslmode=require` }).sslmode, "require");
  });
  it("maps sslmode to node-postgres with libpq semantics", () => {
    assert.deepEqual(pgConfig(`${base}?sslmode=require`).ssl, { rejectUnauthorized: false });
    assert.equal(pgConfig("postgresql://u:p@127.0.0.1:5432/d").ssl, false);
    assert.ok(!pgConfig(`${base}?sslmode=require`).connectionString.includes("sslmode"));
  });
  it("scrubs the password on its own, not only the whole DSN", () => {
    const scrub = redactor(`${base}?sslmode=require`);
    assert.equal(scrub("auth failed for s3cr/et and s3cr%2Fet"), "auth failed for <redacted> and <redacted>");
  });
  it("route proof is exact", () => {
    assert.match(routeProof(pooler), /pooler login/);
    assert.equal(routeProof({ ...pooler, database_user: `postgres.x${ref}` }), null);
    assert.equal(routeProof({ ...pooler, database_user: `other.${ref}` }), null);
    assert.match(routeProof({ ...pooler, database_user: "postgres", database_host: `db.${ref}.supabase.co` }), /direct host/);
    assert.equal(routeProof({ ...pooler, database_user: "postgres", database_host: `${ref}.example.com` }), null);
    assert.equal(routeProof({ ...pooler, database_user: "postgres", database_host: "127.0.0.1" }), null, "loopback only when disposable");
  });
  it("matched identity rows pass, and any disagreement refuses", () => {
    assert.equal(evaluateIdentity({ probe: probe([row(ref, id)]), inspection: inspection(pooler) }, pooler).status, "matched");
    for (const rows of [[row(ref, randomUUID())], [row("otherref", id)], [row(ref, id, "biotech")], [row(ref, id), row(ref, randomUUID())]]) {
      assert.throws(() => evaluateIdentity({ probe: probe(rows), inspection: inspection(pooler) }, pooler), refusal("TARGET_IDENTITY_MISMATCH"));
    }
    assert.throws(() => evaluateIdentity({ probe: probe([row(ref, id)]), inspection: inspection(pooler, false) }, pooler), refusal("TARGET_IDENTITY_MISMATCH"));
    assert.equal(evaluateIdentity({ probe: probe([row(ref, id)]), inspection: null, inspectError: "legacy" }, pooler).status, "matched");
  });
  it("legacy mission_control without an identity row needs full, fresh management-API evidence (no route fallback)", () => {
    const legacy = { probe: probe([], true), inspection: null, inspectError: "inspect failed" };
    assert.throws(() => evaluateIdentity(legacy, pooler), refusal("TARGET_IDENTITY_UNPROVEN"));
    const bad = [
      { source: "dashboard" }, { project_ref: "bxnetwiimwhtlrjlbtab" }, { name: "other-name" }, { region: "" },
      { installation_id: randomUUID() }, { system_identifier: undefined }, { system_identifier: 7300000000000000001 },
      { observed_at: "yesterday" }, { observed_at: new Date(Date.now() - 25 * 3600e3).toISOString() },
      { observed_at: new Date(Date.now() + 3600e3).toISOString() },
    ];
    for (const over of bad) assert.throws(() => evaluateIdentity({ ...legacy, evidence: evidenceFor(pooler, over) }, pooler), refusal("TARGET_IDENTITY_UNPROVEN"), JSON.stringify(over));
    const anonymous = { ...pooler, database_user: "postgres" };
    assert.throws(() => evaluateIdentity({ ...legacy, evidence: evidenceFor(anonymous) }, anonymous), refusal("TARGET_IDENTITY_UNPROVEN"));
    const ok = evaluateIdentity({ ...legacy, evidence: evidenceFor(pooler) }, pooler);
    assert.equal(ok.status, "evidence");
    assert.equal(ok.legacyMissionControl, "0044_x");
    assert.equal(ok.evidence.system_identifier, SYSID);
  });
  it("binds evidence to the database by system_identifier, whenever evidence is supplied", () => {
    const legacy = { probe: probe([], true), inspection: null, inspectError: "legacy" };
    assert.throws(() => evaluateIdentity({ ...legacy, evidence: evidenceFor(pooler, { system_identifier: "7300000000000000002" }) }, pooler), refusal("TARGET_SYSTEM_IDENTIFIER_MISMATCH"));
    assert.throws(() => evaluateIdentity({ ...legacy, probe: { ...probe([], true), systemIdentifier: null, systemIdentifierError: "SQLSTATE 42501" }, evidence: evidenceFor(pooler) }, pooler), refusal("TARGET_SYSTEM_IDENTIFIER_UNREADABLE"));
    // Matched identity rows do not excuse bad evidence.
    const matched = { probe: probe([row(ref, id)]), inspection: inspection(pooler) };
    assert.throws(() => evaluateIdentity({ ...matched, evidence: evidenceFor(pooler, { system_identifier: "1" }) }, pooler), refusal("TARGET_SYSTEM_IDENTIFIER_MISMATCH"));
    assert.equal(evaluateIdentity({ ...matched, evidence: evidenceFor(pooler) }, pooler).evidence.system_identifier, SYSID);
  });
  it("with no mission_control, the exact route or evidence proves identity", () => {
    assert.equal(evaluateIdentity({ probe: probe(), inspection: inspection(pooler) }, pooler).status, "absent");
    const anonymous = { ...pooler, database_user: "postgres" };
    assert.throws(() => evaluateIdentity({ probe: probe(), inspection: inspection(anonymous) }, anonymous), refusal("TARGET_IDENTITY_UNPROVEN"));
    assert.throws(() => evaluateIdentity({ probe: probe(), inspection: null, inspectError: "boom" }, pooler), refusal("TARGET_INSPECT_FAILED"));
    assert.throws(() => evaluateIdentity({ probe: probe(), inspection: { ...inspection(pooler), target: { project_ref: "x", installation_id: id } } }, pooler), refusal("TARGET_IDENTITY_MISMATCH"));
  });
  it("checks the confirmation and endpoint before connecting", async () => {
    let connected = 0;
    const connect = async () => { connected += 1; return probe(); };
    await assert.rejects(identifyTarget({ target: pooler, confirmation: "x:y", env: {}, connect, inspect: () => ({}) }), refusal("CONFIRM_TARGET_MISMATCH"));
    await assert.rejects(identifyTarget({ target: pooler, confirmation: `${ref}:${id}`, env: {}, connect, inspect: () => ({}) }), refusal("TARGET_DSN_MISSING"));
    await assert.rejects(identifyTarget({ target: pooler, confirmation: `${ref}:${id}`, env: { AIDB_TEST_URL: base }, connect, inspect: () => ({}) }), refusal("TARGET_DSN_TLS_REQUIRED"));
    assert.equal(connected, 0);
  });
  it("cascades: owned removals expected, dependents of parent relations recorded, everything else forbidden (F2)", () => {
    const owned = {
      public: { relations: new Set(["t"]), functions: new Set(["f()"]), types: new Set(["e"]), named: new Set(), parents: new Set(["m"]) },
      storage: { named: new Set(["policy\u0000p on objects"]) },
    };
    const { forbidden, recorded, expected } = cascadeVerdict([
      { kind: "table", schema: "public", name: "t" }, { kind: "column", schema: "public", name: "t.c" }, { kind: "constraint", schema: "public", name: "k on t" },
      { kind: "function", schema: "public", name: "f()" }, { kind: "type", schema: "public", name: "e" }, { kind: "policy", schema: "storage", name: "p on objects" },
      { kind: "policy", schema: "public", name: "pm on m" }, { kind: "trigger", schema: "public", name: "tm on m" },
      { kind: "view", schema: "public", name: "kept_view" }, { kind: "trigger", schema: "public", name: "kt on keep_me" }, { kind: "policy", schema: "storage", name: "other on objects" },
      { kind: "constraint", schema: "public", name: "fk on keep_me" }, { kind: "function", schema: "public", name: "g()" }, { kind: "column", schema: "public", name: "m.c" },
      { kind: "table", schema: "public", name: "other" }, { kind: "function", schema: "auth", name: "h()" }, { kind: "composite_type", schema: "public", name: "ct" },
      { kind: "domain_constraint", schema: "public", name: "c on d" }, { kind: "extension", schema: "extensions", name: "vector" }, { kind: "cast", schema: "", name: "a->b" },
      { kind: "operator", schema: "public", name: "=(a,a)" }, { kind: "operator_class", schema: "public", name: "oc btree" }, { kind: "operator_family", schema: "public", name: "of btree" },
      { kind: "event_trigger", schema: "", name: "et" }, { kind: "publication", schema: "", name: "pub" }, { kind: "default_acl", schema: "public", name: "r:r:{}" },
    ], owned);
    assert.equal(expected, 6);
    assert.deepEqual(recorded.map((o) => o.name), ["pm on m", "tm on m"]);
    assert.deepEqual(forbidden.map((o) => o.name), ["kept_view", "kt on keep_me", "other on objects", "fk on keep_me", "g()", "m.c", "other", "h()", "ct", "c on d", "vector", "a->b", "=(a,a)", "oc btree", "of btree", "et", "pub", "r:r:{}"]);
  });
  it("sessions: Supabase platform roles and postgres Studio/pg_meta/PostgREST sessions are not application traffic (F4)", () => {
    for (const s of [{ usename: "authenticator" }, { usename: "dashboard_user" }, { usename: "supabase_admin" }, { usename: "pgbouncer" }, { usename: "supabase_read_only_user" },
      { usename: "postgres", application_name: "supabase/dashboard Supabase Studio" }, { usename: "postgres", application_name: "postgres-meta 0.84" }, { usename: "postgres", application_name: "postgrest" }]) {
      assert.equal(isPlatformSession(s), true, JSON.stringify(s));
    }
    for (const s of [{ usename: "postgres", application_name: "psql" }, { usename: "postgres", application_name: "" }, { usename: "executor_service" }, { usename: null }, { usename: "mission_control_runtime" }]) {
      assert.equal(isPlatformSession(s), false, JSON.stringify(s));
    }
  });
  it("--from-dry-run: clean, fresh, same target and flags, with a digest", () => {
    const dir = mkdtempSync(join(tmpdir(), "aidb-dry-"));
    const flags = { dropPublicExtra: [], keepPublicExtra: [], allowExtraRelations: [], allowSessions: false };
    const good = { format: "ai-engineer-wipe-receipt.v2", dryRun: true, status: "dry-run-clear", blockers: [], finishedAt: new Date().toISOString(), target: { project_ref: ref, installation_id: id, target_file: pooler.path }, flags, requestedSchemas: [...WIPE_SCHEMAS], inventoryDigest: `sha256:${"a".repeat(64)}` };
    const write = (body) => { const p = join(dir, `${randomUUID()}.json`); writeFileSync(p, JSON.stringify(body)); return p; };
    const ctx = { target: pooler, flags, requestedSchemas: [...WIPE_SCHEMAS], format: "ai-engineer-wipe-receipt.v2" };
    assert.throws(() => checkDryRunReceipt(undefined, ctx), refusal("WIPE_DRY_RUN_REQUIRED"));
    assert.throws(() => checkDryRunReceipt(join(dir, "missing.json"), ctx), refusal("WIPE_DRY_RUN_REQUIRED"));
    assert.throws(() => checkDryRunReceipt(write({ ...good, status: "dry-run-blocked", blockers: [{ code: "X" }] }), ctx), refusal("WIPE_DRY_RUN_BLOCKED"));
    assert.throws(() => checkDryRunReceipt(write({ ...good, finishedAt: new Date(Date.now() - 3 * 3600e3).toISOString() }), ctx), refusal("WIPE_DRY_RUN_STALE"));
    assert.throws(() => checkDryRunReceipt(write({ ...good, dryRun: false }), ctx), refusal("WIPE_DRY_RUN_MISMATCH"));
    assert.throws(() => checkDryRunReceipt(write({ ...good, target: { ...good.target, installation_id: randomUUID() } }), ctx), refusal("WIPE_DRY_RUN_MISMATCH"));
    assert.throws(() => checkDryRunReceipt(write({ ...good, flags: { ...flags, allowSessions: true } }), ctx), refusal("WIPE_DRY_RUN_MISMATCH"));
    assert.throws(() => checkDryRunReceipt(write({ ...good, requestedSchemas: ["research"] }), ctx), refusal("WIPE_DRY_RUN_MISMATCH"));
    assert.throws(() => checkDryRunReceipt(write({ ...good, inventoryDigest: undefined }), ctx), refusal("WIPE_DRY_RUN_MISMATCH"));
    assert.equal(checkDryRunReceipt(write(good), ctx).inventoryDigest, good.inventoryDigest);
    rmSync(dir, { recursive: true, force: true });
  });
  it("the inventory digest binds objects, extras, ledger versions and graph counts, not row counts", () => {
    const steps = [{ step: "public", status: "would-drop", manifestMatched: { relations: 41 }, extra: { relations: [{ name: "x", kind: "table", rows: 3 }], functions: [], types: [] }, exactRows: 10 },
      { step: "migration-ledger", status: "would-delete", versions: ["2", "1"] }, { step: "schema:research", status: "would-drop", relations: ["b", "a"], counts: { table: 2 }, estimatedRows: 9 }];
    const d = inventoryDigest(steps);
    assert.equal(inventoryDigest([{ ...steps[0], exactRows: 99, extra: { ...steps[0].extra, relations: [{ name: "x", kind: "table", rows: 4 }] } }, steps[1], { ...steps[2], estimatedRows: 1, relations: ["a", "b"] }]), d);
    assert.notEqual(inventoryDigest([steps[0], { ...steps[1], versions: ["1", "2", "3"] }, steps[2]]), d);
    assert.notEqual(inventoryDigest([steps[0], steps[1], { ...steps[2], relations: ["a"] }]), d);
    assert.notEqual(inventoryDigest([...steps, { step: "graph", status: "would-delete", nodesBefore: 5, relationshipsBefore: 1, labels: { A: 5 }, markersBefore: [] }]),
      inventoryDigest([...steps, { step: "graph", status: "would-delete", nodesBefore: 6, relationshipsBefore: 1, labels: { A: 6 }, markersBefore: [] }]));
  });
  it("lists client backends only: autovacuum and other background workers (NULL usename) are not sessions", async () => {
    const rows = [
      { pid: 1, usename: "postgres", application_name: "psql", state: "idle", backend_type: "client backend", backend_start: "t" },
      { pid: 2, usename: null, application_name: "", state: null, backend_type: "autovacuum worker", backend_start: "t" },
      { pid: 3, usename: null, application_name: "", state: null, backend_type: "parallel worker", backend_start: "t" },
    ];
    let seen = "";
    const fake = { query: async (text) => { seen = text; return { rows: /backend_type = 'client backend'/.test(text) ? rows.filter((r) => r.backend_type === "client backend") : rows }; } };
    const sessions = await listSessions(fake);
    assert.match(seen, /backend_type = 'client backend'/);
    assert.doesNotMatch(seen, /\bquery\b(?!_)/, "never selects query text");
    assert.deepEqual(sessions.map((s) => s.pid), [1]);
  });
  it("compares dry-run flags order-insensitively", () => {
    assert.deepEqual(normalizeFlags({ b: ["y", "x"], a: true }), normalizeFlags({ a: true, b: ["x", "y"] }));
    assert.notDeepEqual(normalizeFlags({ b: ["x"] }), normalizeFlags({ b: ["x", "y"] }));
  });
  it("cascade diff covers indexes, column defaults, rules and extended statistics", () => {
    const owned = { public: { relations: new Set(["t"]), parents: new Set(["m"]) } };
    const { forbidden, recorded, expected } = cascadeVerdict([
      { kind: "index", schema: "public", name: "t_idx on t" }, { kind: "column_default", schema: "public", name: "t.c" },
      { kind: "rule", schema: "public", name: "r on m" }, { kind: "statistics", schema: "public", name: "s on m" }, { kind: "index", schema: "public", name: "m_idx on m" },
      { kind: "index", schema: "public", name: "k_idx on keep_me" }, { kind: "column_default", schema: "public", name: "keep_me.c" },
      { kind: "rule", schema: "public", name: "r on keep_me" }, { kind: "statistics", schema: "public", name: "s on keep_me" },
    ], owned);
    assert.equal(expected, 2);
    assert.deepEqual(recorded.map((o) => o.name), ["r on m", "s on m", "m_idx on m"]);
    assert.deepEqual(forbidden.map((o) => `${o.kind}:${o.name}`), ["index:k_idx on keep_me", "column_default:keep_me.c", "rule:r on keep_me", "statistics:s on keep_me"]);
  });
  it("summarizes a receipt for a human", () => {
    const text = summarize({ dryRun: true, status: "dry-run-blocked", inventoryDigest: "sha256:x", target: { app: "ai-engineer", project_ref: ref, installation_id: id, project_label: "x" }, identity: { status: "evidence", legacyMissionControl: "0044" }, sessions: [{ pid: 1, usename: "postgres", application_name: "psql", state: "idle", backend_start: "2026-10-28", platform: false }], steps: [{ step: "schema:research", status: "would-drop", counts: { table: 2 }, estimatedRows: 5, blockers: [{ code: "WIPE_UNEXPECTED_RELATION", objects: ["research.x"], total: 1 }] }] });
    assert.match(text, /DRY RUN/);
    assert.match(text, /lock_timeout: 5 s/);
    assert.match(text, /APPLICATION pid 1 postgres app=psql state=idle since 2026-10-28/);
    assert.match(text, /BLOCKER WIPE_UNEXPECTED_RELATION: research\.x/);
  });
});

describe("pins", () => {
  const mcLock = join(mcRoot, PINS.missionControl.lockPath);
  it("Mission Control 1.9.0: the Sprint OC lock's bytes and the release root agree", { skip: !existsSync(mcLock) && "MC Sprint OC lock not present" }, () => {
    const bytes = readFileSync(mcLock);
    assert.equal(createHash("sha256").update(bytes).digest("hex"), PINS.missionControl.lockFileSha256);
    const lock = JSON.parse(bytes.toString("utf8"));
    assert.equal(lock.app, "ai-engineer");
    assert.equal(lock.component_version, PINS.missionControl.version);
    assert.equal(resolve(dirname(mcLock), lock.release_root), resolve(mcRoot, PINS.missionControl.releaseRoot), "the lock's release_root is the explicit default");
    const release = JSON.parse(readFileSync(join(mcRoot, PINS.missionControl.releaseRoot, "manifest.json"), "utf8"));
    assert.equal(release.component_version, PINS.missionControl.version);
    assert.ok(release.supported_reader_versions.includes(PINS.missionControl.readerVersion));
  });
  it("the KS pin is one line and matches the component at --ks-root (default: the KS main checkout)", { skip: !existsSync(ksCli) && "KS dist not built" }, () => {
    assert.deepEqual(Object.keys(KS_COMPONENT_PIN), ["version", "digest"]);
    assert.equal(PINS.component.version, KS_COMPONENT_PIN.version);
    assert.equal(componentCli(resolve(repository, "..", "..", "platform", "knowledge-services")), ksCli);
    const manifest = JSON.parse(spawnSync(process.execPath, [ksCli, "manifest"], { encoding: "utf8" }).stdout.replace(/^[^{]*/, ""));
    assert.equal(manifest.component_version, KS_COMPONENT_PIN.version, "update KS_COMPONENT_PIN when --ks-root moves to a new release");
    assert.equal(manifest.component_digest, KS_COMPONENT_PIN.digest);
  });
  it("--ks-root is honoured", () => {
    const empty = mkdtempSync(join(tmpdir(), "aidb-ks-"));
    assert.throws(() => componentCli(empty), refusal("TOOL_MISSING"));
    rmSync(empty, { recursive: true, force: true });
  });
});

describe("CLI refusals before any connection", () => {
  const dir = mkdtempSync(join(tmpdir(), "aidb-cli-"));
  after(() => rmSync(dir, { recursive: true, force: true }));
  const id = randomUUID();
  const target = writeTarget(dir, "t.toml", { ref: "disposable-cli-check", id });
  const evidence = join(scratch, "cli-evidence");
  it("wipe without, or with a wrong, --confirm-target", { skip: !existsSync(missionDb) }, async () => {
    await assert.rejects(main(["wipe", "--target", target, "--evidence-dir", evidence]), refusal("CONFIRM_TARGET_REQUIRED"));
    await assert.rejects(main(["wipe", "--dry-run", "--target", target, "--confirm-target", `disposable-cli-check:${randomUUID()}`, "--evidence-dir", evidence]), refusal("CONFIRM_TARGET_MISMATCH"));
  });
  it("wipe refusals write a failed receipt with the step", { skip: !existsSync(missionDb) }, async () => {
    const before = new Set(existsSync(evidence) ? readdirSync(evidence) : []);
    await assert.rejects(main(["wipe", "--target", target, "--evidence-dir", evidence]), refusal("CONFIRM_TARGET_REQUIRED"));
    const fresh = readdirSync(evidence).filter((f) => !before.has(f) && f.endsWith(".json"));
    const receipt = JSON.parse(readFileSync(join(evidence, fresh[0]), "utf8"));
    assert.equal(receipt.status, "failed");
    assert.equal(receipt.failedStep, "identity");
    assert.equal(receipt.error.code, "CONFIRM_TARGET_REQUIRED");
  });
  it("wipe of a schema outside the allow-list, or receipts into a tracked directory", async () => {
    await assert.rejects(main(["wipe", "--target", target, "--confirm-target", `disposable-cli-check:${id}`, "--schemas", "research,auth"]), refusal("WIPE_SCHEMA_NOT_ALLOWED"));
    await assert.rejects(main(["wipe", "--target", target, "--confirm-target", `disposable-cli-check:${id}`, "--evidence-dir", join(repository, "scripts")]), refusal("EVIDENCE_DIR_NOT_IGNORED"));
  });
  it("unreadable --identity-evidence", { skip: !existsSync(missionDb) }, async () => {
    process.env.INSTALL_WIPE_TARGET_DSN = "postgresql://postgres:x@127.0.0.1:5432/postgres";
    await assert.rejects(main(["wipe", "--target", target, "--confirm-target", `disposable-cli-check:${id}`, "--identity-evidence", join(dir, "missing.json"), "--evidence-dir", evidence]), refusal("IDENTITY_EVIDENCE_INVALID"));
  });
  it("install with --target but without --remote-reinstall, or with a --workdir alongside", async () => {
    await assert.rejects(main(["--target", target, "--confirm-target", `disposable-cli-check:${id}`, "--component-installation-id", randomUUID()]), refusal("REMOTE_REINSTALL_FLAG_REQUIRED"));
    await assert.rejects(main(["--remote-reinstall", "--workdir", dir, "--target", target, "--confirm-target", `disposable-cli-check:${id}`, "--component-installation-id", randomUUID()]), refusal("REMOTE_REINSTALL_CONFLICT"));
  });
  it("still refuses a non-disposable workdir without the flag", async () => {
    mkdirSync(join(dir, "supabase"), { recursive: true });
    writeFileSync(join(dir, "supabase", "config.toml"), 'project_id = "ai-engineer-shared"\n');
    await assert.rejects(main(["--workdir", dir, "--component-installation-id", randomUUID(), "--mc-installation-id", randomUUID()]), refusal("DISPOSABLE_PROJECT_REQUIRED"));
  });
});

// ------------------------------------------------------------------------------------------- seal-key (W1 D25)
const SEAL_ADMIN = process.env.INSTALL_SEAL_PG_ADMIN_DSN;
const sealKsRoot = resolve(process.env.AIDB_TEST_KS_ROOT ?? join(repository, "..", "..", "platform", "knowledge-services"));
const sealKsReady = existsSync(join(sealKsRoot, "packages", "knowledge-db-contract", "dist", "cli.js"));
function sealPem(dir, name) {
  const path = join(dir, name);
  writeFileSync(path, generateKeyPairSync("ed25519").privateKey.export({ format: "pem", type: "pkcs8" }));
  return path;
}
describe("seal-key step (OVE-169 W1 D25)", () => {
  const dir = mkdtempSync(join(tmpdir(), "aidb-seal-"));
  after(() => rmSync(dir, { recursive: true, force: true }));
  it("takes flags first, else the generator's environment names, with the descriptor's default issuer", () => {
    const env = { KS_KNOWLEDGE_SEAL_KEY_ID: "ks-seal-env", KS_KNOWLEDGE_SEAL_KEY_FILE: "/runtime/ks-seal.pem", KS_KNOWLEDGE_SEAL_RETIRE_KEY_IDS: " " };
    assert.deepEqual(sealKeyOptions([], env), { keyId: "ks-seal-env", keyFile: "/runtime/ks-seal.pem", issuer: "knowledge-services", retire: undefined, skip: false, flagged: false });
    assert.deepEqual(sealKeyOptions(["--seal-key-id", "ks-seal-flag", "--seal-issuer", "ks-local", "--retire-seal-key-ids", "a,b"], env),
      { keyId: "ks-seal-flag", keyFile: "/runtime/ks-seal.pem", issuer: "ks-local", retire: "a,b", skip: false, flagged: true });
    assert.deepEqual(sealKeyOptions(["--no-seal-key"], {}), { keyId: undefined, keyFile: undefined, issuer: "knowledge-services", retire: undefined, skip: true, flagged: false });
  });
  it("remote mode requires a seal key or an explicit --no-seal-key; local mode warns (review S1)", () => {
    assert.throws(() => checkSealKeyInputs(sealKeyOptions([], {}), { remote: true }), refusal("SEAL_KEY_REQUIRED"));
    assert.equal(checkSealKeyInputs(sealKeyOptions(["--no-seal-key"], {}), { remote: true }), "skip");
    assert.throws(() => checkSealKeyInputs(sealKeyOptions(["--no-seal-key", "--seal-key-id", "ks-seal-a"], {}), { remote: true }), refusal("SEAL_KEY_FLAGS_CONFLICT"));
    // --no-seal-key wins over install.env's names (they are present whenever the generated file is loaded).
    assert.equal(checkSealKeyInputs(sealKeyOptions(["--no-seal-key"], { KS_KNOWLEDGE_SEAL_KEY_ID: "ks-seal-env", KS_KNOWLEDGE_SEAL_KEY_FILE: "/x.pem" }), { remote: true }), "skip");
    assert.equal(checkSealKeyInputs(sealKeyOptions([], {}), { remote: false }), "absent");
    const remote = { ksRoot: dir, target: { dsn: "postgresql://postgres:x@127.0.0.1:1/none" }, remote: { target: {} } };
    assert.throws(() => sealKey({ ...remote, sealKey: sealKeyOptions([], {}) }), refusal("SEAL_KEY_REQUIRED"));
    assert.deepEqual(sealKey({ ...remote, sealKey: sealKeyOptions(["--no-seal-key"], {}) }), { status: "skipped", details: { reason: "--no-seal-key" } });
    const written = [];
    const write = process.stderr.write;
    process.stderr.write = (chunk) => { written.push(String(chunk)); return true; };
    try {
      assert.equal(sealKey({ ...remote, remote: null, sealKey: sealKeyOptions([], {}) }).status, "skipped");
    } finally { process.stderr.write = write; }
    assert.match(written.join(""), /warning: seal-key skipped/);
  });
  it("scrubs the DSN, its password and any URL credential from an output tail (review S2)", () => {
    const dsn = "postgresql://postgres.abcd:s3cr3t-pw@aws-0.pooler.supabase.com:5432/postgres?sslmode=require";
    const out = scrubOutput(`connect ${dsn} failed; password s3cr3t-pw; graph neo4j+s://neo4j:graph-pw@h.io`, [dsn]);
    assert.doesNotMatch(out, /s3cr3t-pw|graph-pw/);
    assert.match(out, /neo4j\+s:\/\/neo4j:<redacted>@h\.io/);
  });
  it("skips without a key, refuses half a key or a missing file before any connection", () => {
    const context = (sealKey) => ({ ksRoot: dir, target: { dsn: "postgresql://postgres:x@127.0.0.1:1/none" }, sealKey });
    assert.equal(sealKey(context({ issuer: "knowledge-services" })).status, "skipped");
    assert.throws(() => sealKey(context({ keyId: "ks-seal-a", issuer: "knowledge-services" })), refusal("SEAL_KEY_INCOMPLETE"));
    assert.throws(() => sealKey(context({ keyFile: join(dir, "x.pem"), issuer: "knowledge-services" })), refusal("SEAL_KEY_INCOMPLETE"));
    assert.throws(() => sealKey(context({ keyId: "ks-seal-a", keyFile: join(dir, "missing.pem"), issuer: "knowledge-services" })), refusal("SEAL_KEY_FILE_MISSING"));
  });
  it("registers the public half on a real component: applied, current, conflict, rotation", { skip: !(SEAL_ADMIN && sealKsReady) && "set INSTALL_SEAL_PG_ADMIN_DSN (loopback) with a KS checkout whose dist is built (AIDB_TEST_KS_ROOT)" }, async () => {
    const pg = createRequire(join(repository, "package.json"))("pg");
    const database = `aidb_seal_${randomUUID().slice(0, 8)}`;
    const admin = new pg.Client({ connectionString: SEAL_ADMIN }); await admin.connect();
    await admin.query(`create database ${database}`);
    const url = new URL(SEAL_ADMIN); url.pathname = `/${database}`;
    const dsn = url.toString();
    try {
      const install = spawnSync(process.execPath, [componentCli(sealKsRoot), "install", "--admin-dsn-env", "KDB_INSTALL_ADMIN_DSN",
        "--installation-id", randomUUID(), "--application", PINS.component.application, "--binding", PINS.component.binding,
        "--applied-by", "install-target.test.mjs"], { env: { ...process.env, KDB_INSTALL_ADMIN_DSN: dsn }, encoding: "utf8" });
      assert.equal(install.status, 0, install.stderr);
      const context = (sealKey) => ({ ksRoot: sealKsRoot, target: { dsn }, sealKey: { issuer: "knowledge-services", ...sealKey } });
      const keyFile = sealPem(dir, "executor.pem");
      const applied = sealKey(context({ keyId: "ks-seal-d25", keyFile }));
      assert.equal(applied.status, "applied");
      assert.equal(applied.details.keyId, "ks-seal-d25");
      assert.match(applied.details.publicKeySha256, /^sha256:[0-9a-f]{64}$/);
      assert.doesNotMatch(JSON.stringify(applied), /PRIVATE KEY/);
      assert.equal(sealKey(context({ keyId: "ks-seal-d25", keyFile })).status, "current");
      assert.throws(() => sealKey(context({ keyId: "ks-seal-d25", keyFile: sealPem(dir, "other.pem") })), refusal("SEAL_KEY_CONFLICT"));
      const rotated = sealKey(context({ keyId: "ks-seal-d25-2", keyFile: sealPem(dir, "next.pem"), retire: "ks-seal-d25" }));
      assert.deepEqual(rotated.details.retired, [{ keyId: "ks-seal-d25", status: "applied" }]);
      const c = new pg.Client({ connectionString: dsn }); await c.connect();
      const keys = (await c.query("select key_id, status from knowledge_verification.seal_signing_key order by key_id")).rows;
      await c.end();
      assert.deepEqual(keys, [{ key_id: "ks-seal-d25", status: "retiring" }, { key_id: "ks-seal-d25-2", status: "active" }]);
    } finally {
      await admin.query(`drop database if exists ${database} with (force)`);
      await admin.end();
    }
  });
});

// --------------------------------------------------------------------------------------------------- PostgreSQL
const ADMIN = process.env.INSTALL_WIPE_PG_ADMIN_DSN;
const CONTAINER = process.env.INSTALL_WIPE_PG_CONTAINER;
const realReady = Boolean(ADMIN && CONTAINER) && existsSync(missionDb) && existsSync(ksCli);
// The stub's cluster-wide pieces (roles, extension files) are set up once and removed in this file-level `after`,
// which node:test runs after every suite's own `after` (stub databases dropped first), also when tests fail.
let cluster = null;
if (realReady) {
  before(async () => { cluster = await openStubCluster({ adminDsn: ADMIN, container: CONTAINER }); });
  after(async () => {
    if (!cluster) return;
    const cleanup = await cluster.close();
    const pg = cluster.pg;
    const c = new pg.Client({ connectionString: ADMIN }); await c.connect();
    const left = (await c.query("select rolname from pg_roles where rolname = any($1)", [[...STUB_ROLES, ...CHAIN_ROLES]])).rows.map((r) => r.rolname);
    await c.end();
    assert.deepEqual(cleanup.failed, [], "every role this run created is dropped");
    assert.equal(cleanup.extensionFilesLeft, 0, "no stub extension files remain on the server");
    assert.deepEqual(left.sort(), cluster.preexisting, "only roles that existed before the run remain");
  });
}
describe("real PostgreSQL: full chain, remote-like state, dry-run, all-or-nothing wipe, reinstall", { skip: !realReady && "set INSTALL_WIPE_PG_ADMIN_DSN (loopback) and INSTALL_WIPE_PG_CONTAINER, with MC .venv and KS dist built" }, () => {
  const suffix = randomUUID().slice(0, 8);
  const database = `disposable_wipe_${suffix}`;
  const ref = `disposable-wipe-${suffix}`;
  const id = randomUUID();
  const dir = join(scratch, suffix);
  const evidence = join(dir, "evidence");
  const FLAGS = ["--drop-public-extra", "legacy_extra,legacy_view", "--keep-public-extra", "keep_me", "--allow-extra-relations", "evidence.legacy_old"];
  let pg;
  let dsn;
  let targetPath;
  let fresh;
  const confirm = () => ["--target", targetPath, "--confirm-target", `${ref}:${id}`, "--evidence-dir", evidence];
  const plain = () => dsn.replace("?sslmode=disable", "");
  const sql = async (text, params) => {
    const c = new pg.Client({ connectionString: plain() }); await c.connect();
    try { return (await c.query(text, params)).rows; } finally { await c.end(); }
  };
  const schemaPresent = async (name) => (await sql("select 1 from pg_namespace where nspname = $1", [name])).length === 1;
  const ledgerRows = async () => (await sql("select count(*)::int as n from supabase_migrations.schema_migrations"))[0].n;
  const untouched = async () => {
    assert.ok(await schemaPresent("research") && await schemaPresent("mission_control") && await schemaPresent("util"));
    assert.equal((await sql("select to_regclass('public.research_starter_videos') is not null as ok"))[0].ok, true);
    assert.equal(await ledgerRows(), migrationsDigest().files + 2);
  };
  const install = (stateDir, extra = []) => {
    const r = spawnSync(process.execPath, ["scripts/install-ai-engineer.mjs", "--remote-reinstall", "--no-seal-key", "--target", targetPath, "--confirm-target", `${ref}:${id}`, "--component-installation-id", id, "--state-dir", stateDir, ...mcRootArgs, ...extra],
      { cwd: repository, env: process.env, encoding: "utf8", windowsHide: true, timeout: 1_200_000 });
    assert.ok(!(r.stdout + r.stderr).includes(dsn.split("@")[0]), "no credential in installer output");
    let body = null;
    try { body = JSON.parse(r.stdout.trim().split("\n").at(-1)); } catch { /* crashed */ }
    return { status: r.status, body, out: (r.stdout + r.stderr).slice(-1200) };
  };
  const journal = (stateDir) => readFileSync(join(stateDir, "progress.jsonl"), "utf8").trim().split("\n").map((l) => JSON.parse(l));
  const snap = async () => {
    const c = new pg.Client({ connectionString: plain() }); await c.connect();
    try { return await catalogSnapshot(c); } finally { await c.end(); }
  };
  const dryRun = (extra = []) => main(["wipe", "--dry-run", ...confirm(), ...extra]);

  before(async () => {
    assert.ok(["127.0.0.1", "localhost"].includes(new URL(ADMIN).hostname), "loopback only");
    const prepared = await prepareStubDatabase({ cluster, adminDsn: ADMIN, database, ksCli, installComponent: false });
    pg = prepared.pg;
    dsn = `${prepared.dsn}?sslmode=disable`; // plain loopback PostgreSQL has no TLS; the Supabase CLI needs it said
    process.env.INSTALL_WIPE_TARGET_DSN = dsn;
    const url = new URL(dsn);
    targetPath = writeTarget(dir, "target.toml", { ref, id, port: Number(url.port || 5432), user: decodeURIComponent(url.username), database });
  });
  after(async () => {
    if (!pg) return;
    const admin = new pg.Client({ connectionString: ADMIN }); await admin.connect();
    await admin.query(`drop database if exists ${database} with (force)`); await admin.end();
  });

  it("refuses SEAL_KEY_REQUIRED after the identity gates and before any write without a seal key or --no-seal-key", async () => {
    const state = join(dir, "install-noseal");
    const env = { ...process.env };
    for (const name of ["KS_KNOWLEDGE_SEAL_KEY_ID", "KS_KNOWLEDGE_SEAL_KEY_FILE"]) delete env[name];
    const r = spawnSync(process.execPath, ["scripts/install-ai-engineer.mjs", "--remote-reinstall", "--target", targetPath, "--confirm-target", `${ref}:${id}`, "--component-installation-id", id, "--state-dir", state, ...mcRootArgs],
      { cwd: repository, env, encoding: "utf8", windowsHide: true, timeout: 1_200_000 });
    assert.equal(r.status, 2, r.stdout + r.stderr);
    assert.match(r.stdout + r.stderr, /SEAL_KEY_REQUIRED/);
    assert.ok(!existsSync(state), "no state, lock or receipt");
    assert.equal(await schemaPresent("knowledge_verification"), false, "nothing installed");
  });

  it("fresh install of the FULL chain in remote mode: crash after domain migrations, resume, then repeat is changed: false", async () => {
    const state = join(dir, "install-1");
    const crashed = install(state, ["--interrupt-after", "domain-migrations"]);
    assert.notEqual(crashed.status, 0, crashed.out);
    assert.ok(existsSync(join(state, "install.lock")), "a crash leaves the lock");
    const resumed = install(state);
    assert.equal(resumed.status, 0, resumed.out);
    assert.equal(resumed.body.changed, true);
    const events = journal(state);
    assert.deepEqual(events.filter((e) => e.event === "start").map((e) => [e.mode, e.resumedAfterInterruption]), [["remote-reinstall", false], ["remote-reinstall", true]]);
    assert.deepEqual(events.filter((e) => e.step === "domain-migrations").map((e) => e.status), ["applied", "current"]);
    assert.equal(events.filter((e) => e.step === "mission-control").at(-1).status, "applied");
    assert.equal(await ledgerRows(), migrationsDigest().files);
    const repeat = install(join(dir, "install-2"));
    assert.equal(repeat.status, 0, repeat.out);
    assert.equal(repeat.body.changed, false);
    fresh = await snap();
  });

  it("dry-run of a remote-like state lists everything (exact row counts, every session, 5 s locks) and changes nothing", async () => {
    await sql(`insert into storage.objects (bucket_id, name) values ('ai-engineer-transcripts', 't/one.txt'), ('research-reports', 'r/two.json');
      insert into supabase_migrations.schema_migrations (version, name) values ('20260404000000', 'legacy_learner'), ('20260902010655', 'research_starter_channels');
      create table public.keep_me (id int, updated_at timestamptz); insert into public.keep_me values (1, now());
      create table public.legacy_extra (id int); insert into public.legacy_extra values (1), (2);
      create view public.legacy_view as select channel_id from public.research_starter_channels;
      create table evidence.legacy_old (id int);`);
    const other = new pg.Client({ connectionString: plain(), application_name: "other-session" });
    const studio = new pg.Client({ connectionString: plain(), application_name: "postgrest" });
    await other.connect(); await studio.connect();
    try {
      const receipt = await dryRun();
      assert.equal(receipt.status, "dry-run-blocked");
      assert.equal(receipt.identity.status, "matched");
      const codes = receipt.blockers.map((b) => `${b.step}:${b.code}`);
      for (const c of ["public:WIPE_PUBLIC_EXTRA", "schema:evidence:WIPE_UNEXPECTED_RELATION", "sessions:WIPE_SESSIONS_ACTIVE"]) assert.ok(codes.includes(c), codes.join());
      const mine = receipt.sessions.filter((s) => ["other-session", "postgrest"].includes(s.application_name));
      assert.deepEqual(mine.map((s) => [s.application_name, typeof s.backend_start, "query" in s]).sort(), [["other-session", "string", false], ["postgrest", "string", false]]);
      assert.equal(receipt.sessions.find((s) => s.application_name === "other-session").platform, false);
      assert.ok(receipt.sessions.every((s) => s.backend_type === "client backend"), "background workers are never listed");
      const pub = receipt.steps.find((s) => s.step === "public");
      assert.equal(pub.manifestMatched.relations, 41);
      assert.equal(Object.keys(pub.rowCounts).length, 41);
      assert.deepEqual(pub.extra.relations.map((r) => `${r.name}:${r.rows}`).sort(), ["keep_me:1", "legacy_extra:2", "legacy_view:null"]);
      assert.deepEqual(pub.orphanedStorageObjects, [{ bucket: "ai-engineer-transcripts", objects: 1 }, { bucket: "research-reports", objects: 1 }]);
      const ledger = receipt.steps.find((s) => s.step === "migration-ledger");
      assert.equal(ledger.status, "would-delete");
      assert.ok(ledger.versions.includes("20260404000000") && ledger.versions.includes("20260902010655"));
      assert.match(receipt.inventoryDigest, /^sha256:/);
      assert.match(readFileSync(receipt.summaryPath, "utf8"), /lock_timeout: 5 s/);
      await untouched();
    } finally { await other.end(); await studio.end(); }
  });

  it("F2: a kept extra view on a manifest table, and a kept-table trigger calling a manifest function, both block", async () => {
    await sql(`create view public.kept_view as select channel_id from public.research_starter_channels;
      create trigger keep_me_touch before update on public.keep_me for each row execute function public.set_updated_at();`);
    const receipt = await dryRun(["--drop-public-extra", "legacy_extra,legacy_view", "--keep-public-extra", "keep_me,kept_view", "--allow-extra-relations", "evidence.legacy_old"]);
    const cascade = receipt.blockers.find((b) => b.step === "public" && b.code === "WIPE_CASCADE_OUTSIDE_ALLOW_LIST");
    assert.ok(cascade, JSON.stringify(receipt.blockers));
    assert.ok(cascade.objects.includes("view public.kept_view"), cascade.objects.join());
    assert.ok(cascade.objects.includes("trigger public.keep_me_touch on keep_me"), cascade.objects.join());
    assert.equal((await sql("select count(*)::int as n from pg_trigger where tgname = 'keep_me_touch'"))[0].n, 1);
    await sql("drop view public.kept_view; drop trigger keep_me_touch on public.keep_me");
  });

  it("F1: a real wipe needs a clean, fresh, matching dry-run, and a late blocker commits nothing", async () => {
    await assert.rejects(main(["wipe", ...confirm(), ...FLAGS]), refusal("WIPE_DRY_RUN_REQUIRED"));
    const blocked = await dryRun();
    await assert.rejects(main(["wipe", ...confirm(), "--from-dry-run", blocked.path]), refusal("WIPE_DRY_RUN_BLOCKED"));
    const clean = await dryRun(FLAGS);
    assert.equal(clean.status, "dry-run-clear", JSON.stringify(clean.blockers));
    const stale = join(dir, "stale.json");
    writeFileSync(stale, JSON.stringify({ ...JSON.parse(readFileSync(clean.path, "utf8")), finishedAt: new Date(Date.now() - 3 * 3600e3).toISOString() }));
    await assert.rejects(main(["wipe", ...confirm(), ...FLAGS, "--from-dry-run", stale]), refusal("WIPE_DRY_RUN_STALE"));
    await assert.rejects(main(["wipe", ...confirm(), ...FLAGS, "--allow-sessions", "--from-dry-run", clean.path]), refusal("WIPE_DRY_RUN_MISMATCH"));
    // The target changed after the dry-run (one more ledger row): the internal pre-check's digest differs.
    await sql("insert into supabase_migrations.schema_migrations (version, name) values ('20260404000001', 'late_row')");
    await assert.rejects(main(["wipe", ...confirm(), ...FLAGS, "--from-dry-run", clean.path]), (e) => refusal("WIPE_DRY_RUN_MISMATCH")(e) && /nothing was changed/.test(e.detail));
    await sql("delete from supabase_migrations.schema_migrations where version = '20260404000001'");
    // A blocker in the LAST domain schema: the pre-check refuses the whole plan before the public step commits.
    await sql("create table util.late_extra (id int)");
    await assert.rejects(main(["wipe", ...confirm(), ...FLAGS, "--from-dry-run", clean.path]), (e) => refusal("WIPE_PLAN_BLOCKED")(e) && /schema:util:WIPE_UNEXPECTED_RELATION/.test(e.detail));
    await untouched();
    assert.equal((await sql("select count(*)::int as n from public.legacy_extra"))[0].n, 2);
    const failed = readdirSync(evidence).filter((f) => f.startsWith("wipe-") && f.endsWith(".json")).map((f) => JSON.parse(readFileSync(join(evidence, f), "utf8"))).find((r) => r.error?.code === "WIPE_PLAN_BLOCKED");
    assert.equal(failed.failedStep, "pre-check");
    assert.equal(failed.changed, false);
    assert.deepEqual(failed.steps, []);
    await sql("drop table util.late_extra");
    // Another application session refuses the real run too.
    const other = new pg.Client({ connectionString: plain(), application_name: "other-session" }); await other.connect();
    try { await assert.rejects(main(["wipe", ...confirm(), ...FLAGS, "--from-dry-run", clean.path]), refusal("WIPE_SESSIONS_ACTIVE")); } finally { await other.end(); }
    await untouched();
  });

  it("wipes manifest public objects, schemas and the whole ledger; keeps public, buckets, objects and named extras", async () => {
    const clean = await dryRun(FLAGS);
    assert.equal(clean.status, "dry-run-clear", JSON.stringify(clean.blockers));
    const receipt = await main(["wipe", ...confirm(), ...FLAGS, "--from-dry-run", clean.path, "--actor", "install-target.test"]);
    assert.equal(receipt.status, "complete");
    assert.equal(receipt.changed, true);
    assert.equal(receipt.preCheck.inventoryDigest, clean.inventoryDigest);
    for (const s of WIPE_SCHEMAS) assert.equal(await schemaPresent(s), false, s);
    assert.equal(receipt.steps.at(-1).step, "schema:mission_control");
    const pub = receipt.steps.find((s) => s.step === "public");
    assert.deepEqual(pub.dropped, { relations: 43, functions: 3, types: 17, storageTriggersPolicies: 8 });
    assert.equal((await sql("select count(*)::int as n from pg_class c join pg_namespace n on n.oid = c.relnamespace where n.nspname = 'public' and c.relkind in ('r','v')"))[0].n, 1);
    assert.equal((await sql("select count(*)::int as n from public.keep_me"))[0].n, 1);
    assert.equal((await sql("select count(*)::int as n from storage.buckets"))[0].n, 8);
    assert.equal((await sql("select count(*)::int as n from storage.objects"))[0].n, 2);
    assert.equal((await sql("select count(*)::int as n from pg_trigger tg join pg_class c on c.oid = tg.tgrelid where c.relname = 'objects' and not tg.tgisinternal"))[0].n, 0);
    assert.equal((await sql("select count(*)::int as n from pg_policies where schemaname = 'storage'"))[0].n, 0);
    assert.equal(receipt.steps.find((s) => s.step === "migration-ledger").rows, migrationsDigest().files + 2);
    assert.equal(await ledgerRows(), 0);
    assert.ok(await schemaPresent("extensions") && await schemaPresent("public") && await schemaPresent("auth"));
    const text = readFileSync(receipt.path, "utf8");
    const url = new URL(dsn);
    assert.ok(!text.includes(dsn) && !text.includes(decodeURIComponent(url.password)), "receipt carries no credential");
    assert.equal(spawnSync("git", ["-C", repository, "check-ignore", "-q", receipt.path]).status, 0);
    assert.match(readFileSync(receipt.path.replace(/\.json$/, ".journal.jsonl"), "utf8"), /"step":"pre-check"[\s\S]*"step":"schema:mission_control"/);
  });

  it("is idempotent: a re-wipe (after its own dry-run) finds nothing and proves identity by the disposable route", async () => {
    const keep = ["--keep-public-extra", "keep_me"];
    const clean = await dryRun(keep);
    assert.equal(clean.status, "dry-run-clear", JSON.stringify(clean.blockers));
    const receipt = await main(["wipe", ...confirm(), ...keep, "--from-dry-run", clean.path]);
    assert.equal(receipt.identity.status, "absent");
    assert.equal(receipt.changed, false);
    assert.ok(receipt.steps.filter((s) => s.step.startsWith("schema:")).every((s) => s.status === "absent"));
  });

  it("reinstall after the wipe (no mission_control, no identity row) is gated by identity evidence; same installation id; catalog equals the fresh install", async () => {
    await sql("drop table public.keep_me");
    assert.equal(await schemaPresent("mission_control"), false);
    const sysid = (await sql("select system_identifier::text as id from pg_control_system()"))[0].id;
    const evidenceFile = join(dir, "reinstall-evidence.json");
    const write = (over = {}) => writeFileSync(evidenceFile, JSON.stringify({ source: "management-api", project_ref: ref, name: ref, region: "local", installation_id: id, system_identifier: sysid, observed_at: new Date().toISOString(), ...over }));
    write({ system_identifier: "7000000000000000000" });
    const wrong = install(join(dir, "install-3-wrong"), ["--identity-evidence", evidenceFile]);
    assert.equal(wrong.status, 2);
    assert.equal(wrong.body.code, "TARGET_SYSTEM_IDENTIFIER_MISMATCH");
    write();
    const again = install(join(dir, "install-3"), ["--identity-evidence", evidenceFile]);
    assert.equal(again.status, 0, again.out);
    assert.equal(again.body.changed, true);
    const receipt = JSON.parse(readFileSync(join(dir, "install-3", "install-receipt.json"), "utf8"));
    assert.equal(receipt.target.identity.status, "evidence");
    assert.equal(receipt.pins.missionControl.version, "1.9.0");
    assert.deepEqual((await sql("select installation_id::text as id from mission_control.application_installation")).map((r) => r.id), [id]);
    const repeat = install(join(dir, "install-4"), ["--identity-evidence", evidenceFile]);
    assert.equal(repeat.status, 0, repeat.out);
    assert.equal(repeat.body.changed, false);
    const replayed = await snap();
    // Roles are cluster-wide on the shared server (other proofs add theirs concurrently): compare the install's own.
    const ours = (r) => [...STUB_ROLES, ...CHAIN_ROLES].includes(r.name) || /^(knowledge_verification|mission_control)_/.test(r.name);
    for (const snapshot of [fresh, replayed]) snapshot.roles = snapshot.roles.filter(ours);
    for (const k of Object.keys(fresh)) assert.deepEqual(replayed[k], fresh[k], `catalog section ${k}`);
  });
});

describe("real PostgreSQL: legacy Mission Control, identity evidence bound to the database, cascade refusals", { skip: !realReady && "set INSTALL_WIPE_PG_ADMIN_DSN and INSTALL_WIPE_PG_CONTAINER" }, () => {
  const suffix = randomUUID().slice(0, 8);
  const database = `disposable_legacy_${suffix}`;
  const ref = `disposable-legacy-${suffix}`;
  const id = randomUUID();
  const dir = join(scratch, `legacy-${suffix}`);
  const evidenceDir = join(dir, "evidence");
  let pg;
  let dsn;
  let targetPath;
  let systemIdentifier;
  const sql = async (text) => { const c = new pg.Client({ connectionString: dsn }); await c.connect(); try { return (await c.query(text)).rows; } finally { await c.end(); } };
  const confirm = () => ["--target", targetPath, "--confirm-target", `${ref}:${id}`, "--evidence-dir", evidenceDir];
  const writeEvidence = (over = {}) => {
    const path = join(dir, `evidence-${randomUUID().slice(0, 6)}.json`);
    writeFileSync(path, JSON.stringify({ source: "management-api", project_ref: ref, name: "legacy-label", region: "local", installation_id: id, system_identifier: systemIdentifier, observed_at: new Date().toISOString(), ...over }));
    return path;
  };
  before(async () => {
    pg = createRequire(join(repository, "package.json"))("pg");
    const admin = new pg.Client({ connectionString: ADMIN }); await admin.connect();
    await admin.query(`create database ${database}`); await admin.end();
    const url = new URL(ADMIN); url.pathname = `/${database}`; url.hostname = "127.0.0.1";
    dsn = url.toString();
    process.env.INSTALL_WIPE_TARGET_DSN = dsn;
    targetPath = writeTarget(dir, "target.toml", { ref, id, port: Number(url.port || 5432), user: decodeURIComponent(url.username), database, label: "legacy-label" });
    // A pre-1.6.0 Mission Control install as the remotes have it: releases up to 0044, no installation identity table.
    await sql(`create schema mission_control; create table mission_control.component_release (component_version text, migration_key text primary key, migration_digest text);
      insert into mission_control.component_release select '1.4.' || g, lpad(g::text, 4, '0') || '_legacy', md5(g::text) from generate_series(1, 44) g;
      create schema capability_search; create table capability_search.documents (id int);
      create schema research; create type research.kind as enum ('a', 'b'); create schema util;
      create function util.kind_text(research.kind) returns text language sql immutable as 'select $1::text';
      create cast (research.kind as text) with function util.kind_text(research.kind);`);
    systemIdentifier = (await sql("select system_identifier::text as id from pg_control_system()"))[0].id;
  });
  after(async () => {
    if (!pg) return;
    const admin = new pg.Client({ connectionString: ADMIN }); await admin.connect();
    await admin.query(`drop database if exists ${database} with (force)`); await admin.end();
  });

  it("refuses without evidence, with stale, wrong or other-database evidence; dry-runs with bound evidence", async () => {
    await assert.rejects(dryRunOf(["--schemas", "capability_search,mission_control"]), refusal("TARGET_IDENTITY_UNPROVEN"));
    await assert.rejects(dryRunOf(["--identity-evidence", writeEvidence({ observed_at: new Date(Date.now() - 30 * 3600e3).toISOString() })]), refusal("TARGET_IDENTITY_UNPROVEN"));
    await assert.rejects(dryRunOf(["--identity-evidence", writeEvidence({ project_ref: "someone-else" })]), refusal("TARGET_IDENTITY_UNPROVEN"));
    await assert.rejects(dryRunOf(["--identity-evidence", writeEvidence({ installation_id: randomUUID() })]), refusal("TARGET_IDENTITY_UNPROVEN"));
    await assert.rejects(dryRunOf(["--identity-evidence", writeEvidence({ system_identifier: undefined })]), refusal("TARGET_IDENTITY_UNPROVEN"));
    await assert.rejects(dryRunOf(["--identity-evidence", writeEvidence({ system_identifier: "7000000000000000000" })]), refusal("TARGET_SYSTEM_IDENTIFIER_MISMATCH"));
    const receipt = await dryRunOf(["--identity-evidence", writeEvidence(), "--schemas", "capability_search,mission_control"]);
    assert.equal(receipt.identity.status, "evidence");
    assert.equal(receipt.identity.legacyMissionControl, "0044_legacy");
    assert.equal(receipt.identity.evidence.system_identifier, systemIdentifier);
    assert.deepEqual(receipt.steps.map((s) => `${s.step}:${s.status}`), ["schema:capability_search:would-drop", "schema:mission_control:would-drop"]);
    assert.equal((await sql("select count(*)::int as n from mission_control.component_release"))[0].n, 44);
  });
  it("dry-run blocks a cascade that would remove a cast or a column outside the allow-list; the real run refuses", async () => {
    const ev = writeEvidence();
    const castRun = await dryRunOf(["--identity-evidence", ev, "--schemas", "util"]);
    assert.ok(castRun.blockers.some((b) => b.code === "WIPE_CASCADE_OUTSIDE_ALLOW_LIST" && b.objects.some((o) => /^cast .*kind->text$/.test(o))), JSON.stringify(castRun.blockers));
    await assert.rejects(main(["wipe", ...confirm(), "--identity-evidence", ev, "--schemas", "util", "--from-dry-run", castRun.path]), refusal("WIPE_DRY_RUN_BLOCKED"));
    await sql("drop cast (research.kind as text); create table public.uses_kind (id int, k research.kind)");
    const colRun = await dryRunOf(["--identity-evidence", ev, "--schemas", "research"]);
    assert.ok(colRun.blockers.some((b) => b.objects?.includes("column public.uses_kind.k")), JSON.stringify(colRun.blockers));
    assert.equal((await sql("select count(*)::int as n from information_schema.columns where table_name = 'uses_kind'"))[0].n, 2);
    await sql("drop table public.uses_kind");
  });
  it("a late owner change after a clean dry-run is caught by the pre-check; then the legacy wipe completes", async () => {
    const schemas = ["--schemas", "capability_search,mission_control"];
    const clean = await dryRunOf(["--identity-evidence", writeEvidence(), ...schemas]);
    assert.equal(clean.status, "dry-run-clear", JSON.stringify(clean.blockers));
    await sql(`do $do$ begin if not exists (select 1 from pg_roles where rolname = 'wipe_test_owner_x') then create role wipe_test_owner_x nologin; end if; end $do$;
      alter schema mission_control owner to wipe_test_owner_x`);
    try {
      await assert.rejects(main(["wipe", ...confirm(), "--identity-evidence", writeEvidence(), ...schemas, "--from-dry-run", clean.path]), (e) => refusal("WIPE_PLAN_BLOCKED")(e) && /schema:mission_control:WIPE_SCHEMA_OWNER_UNEXPECTED/.test(e.detail));
      assert.ok((await sql("select 1 from pg_namespace where nspname = 'capability_search'")).length, "the earlier step did not commit");
    } finally {
      await sql("alter schema mission_control owner to current_user; drop role wipe_test_owner_x");
    }
    const again = await dryRunOf(["--identity-evidence", writeEvidence(), ...schemas]);
    const receipt = await main(["wipe", ...confirm(), "--identity-evidence", writeEvidence(), ...schemas, "--from-dry-run", again.path]);
    assert.equal(receipt.status, "complete");
    assert.equal(receipt.identity.status, "evidence");
    assert.deepEqual(receipt.steps.map((s) => `${s.step}:${s.status}`), ["schema:capability_search:dropped", "schema:mission_control:dropped"]);
  });
  function dryRunOf(extra) { return main(["wipe", "--dry-run", ...confirm(), ...extra]); }
});

// ------------------------------------------------------------------------------------- KS component upgrade in place
// The remotes run KS 2.4.0; the pin is 2.5.0. A copy of this installer that differs only in the KS pin line installs
// 2.4.0 (component tree from KS history); the real installer then upgrades in place and repeats.
const KS_ROOT = resolve(repository, "..", "..", "platform", "knowledge-services");
const KS_240 = { rev: "b45adf5", version: "2.4.0", digest: "sha256:309a8c9b8ac792a9f9cf1d6b9ff1070bba763f6c7113750847680d4c9c5c64c7" };
const ksHistory = spawnSync("git", ["-C", KS_ROOT, "cat-file", "-e", `${KS_240.rev}^{commit}`]).status === 0;
// The component tree at `rev`, byte for byte from git objects (no tar: portable on Windows).
function extractComponent(rev, dest) {
  const prefix = "packages/knowledge-db-contract/component";
  const list = spawnSync("git", ["-C", KS_ROOT, "ls-tree", "-r", "--name-only", rev, prefix], { encoding: "utf8" });
  assert.equal(list.status, 0, "git ls-tree");
  for (const file of list.stdout.split("\n").filter(Boolean)) {
    const blob = spawnSync("git", ["-C", KS_ROOT, "show", `${rev}:${file}`], { maxBuffer: 64 * 1024 * 1024 });
    assert.equal(blob.status, 0, `git show ${file}`);
    mkdirSync(dirname(join(dest, file)), { recursive: true });
    writeFileSync(join(dest, file), blob.stdout);
  }
  return join(dest, ...prefix.split("/"));
}
function pinnedInstallerCopy(dest, pin) {
  let src = readFileSync(join(repository, "scripts", "install-ai-engineer.mjs"), "utf8");
  const line = /^export const KS_COMPONENT_PIN = .*$/m;
  assert.match(src, line);
  src = src.replace(line, `export const KS_COMPONENT_PIN = Object.freeze({ version: ${JSON.stringify(pin.version)}, digest: ${JSON.stringify(pin.digest)} });`);
  src = src.replace('from "./install-manifest.mjs"', `from ${JSON.stringify(pathToFileURL(join(repository, "scripts", "install-manifest.mjs")).href)}`);
  src = src.replace('from "./install-target.mjs"', `from ${JSON.stringify(pathToFileURL(join(repository, "scripts", "install-target.mjs")).href)}`);
  src = src.replace('const repository = resolve(dirname(fileURLToPath(import.meta.url)), "..");', `const repository = ${JSON.stringify(repository)};`);
  writeFileSync(dest, src);
  return dest;
}

describe("real PostgreSQL: KS component 2.4.0 → 2.5.0 upgrade in place (with MC 1.9.0)", { skip: (!realReady || !ksHistory) && "needs INSTALL_WIPE_PG_ADMIN_DSN, INSTALL_WIPE_PG_CONTAINER and KS git history" }, () => {
  const suffix = randomUUID().slice(0, 8);
  const database = `disposable_ksup_${suffix}`;
  const ref = `disposable-ksup-${suffix}`;
  const id = randomUUID();
  const dir = join(scratch, `ksup-${suffix}`);
  let pg;
  let dsn;
  let targetPath;
  let component240;
  let copy;
  const sql = async (text) => { const c = new pg.Client({ connectionString: dsn.replace("?sslmode=disable", "") }); await c.connect(); try { return (await c.query(text)).rows; } finally { await c.end(); } };
  const run = (script, stateDir, extra = []) => {
    const r = spawnSync(process.execPath, [script, "--remote-reinstall", "--no-seal-key", "--target", targetPath, "--confirm-target", `${ref}:${id}`, "--component-installation-id", id, "--state-dir", stateDir, ...mcRootArgs, ...extra],
      { cwd: repository, env: process.env, encoding: "utf8", windowsHide: true, timeout: 1_200_000 });
    let body = null;
    try { body = JSON.parse(r.stdout.trim().split("\n").at(-1)); } catch { /* crashed */ }
    const receiptFile = join(stateDir, "install-receipt.json");
    return { status: r.status, body, out: (r.stdout + r.stderr).slice(-1200), receipt: existsSync(receiptFile) ? JSON.parse(readFileSync(receiptFile, "utf8")) : null };
  };
  const step = (receipt, name) => receipt.steps.find((s) => s.step === name);
  const componentKeys = async () => (await sql("select migration_key from knowledge_verification.component_release order by 1")).map((r) => r.migration_key);

  before(async () => {
    const prepared = await prepareStubDatabase({ cluster, adminDsn: ADMIN, database, ksCli, installComponent: false });
    pg = prepared.pg;
    dsn = `${prepared.dsn}?sslmode=disable`;
    process.env.INSTALL_WIPE_TARGET_DSN = dsn;
    const url = new URL(dsn);
    targetPath = writeTarget(dir, "target.toml", { ref, id, port: Number(url.port || 5432), user: decodeURIComponent(url.username), database });
    component240 = extractComponent(KS_240.rev, join(dir, "ks-2.4.0"));
    copy = pinnedInstallerCopy(join(dir, "install-ai-engineer.ks-2.4.0.mjs"), KS_240);
  });
  after(async () => {
    if (!pg) return;
    const admin = new pg.Client({ connectionString: ADMIN }); await admin.connect();
    await admin.query(`drop database if exists ${database} with (force)`); await admin.end();
  });

  it("installs 2.4.0 + MC 1.9.0, upgrades to 2.5.0 applying only 0008, then repeats with changed: false", async () => {
    assert.equal(PINS.component.version, "2.5.0");
    const first = run(copy, join(dir, "install-240"), ["--ks-component-root", component240]);
    assert.equal(first.status, 0, first.out);
    assert.equal(first.receipt.pins.component.version, "2.4.0");
    assert.equal(first.receipt.pins.missionControl.version, "1.9.0");
    assert.equal((await componentKeys()).at(-1), "0007_server_clock_and_required_values_digest");
    const upgrade = run(join(repository, "scripts", "install-ai-engineer.mjs"), join(dir, "install-250"));
    assert.equal(upgrade.status, 0, upgrade.out);
    assert.equal(upgrade.body.changed, true);
    const component = step(upgrade.receipt, "component");
    assert.equal(component.status, "applied");
    assert.deepEqual(component.details.applied.map((a) => (typeof a === "string" ? a : a.migration_key ?? a.key)), ["0008_effect_dispatch_journal"]);
    assert.equal(component.details.componentDigest, PINS.component.digest);
    assert.equal(step(upgrade.receipt, "domain-migrations").status, "current");
    assert.equal(step(upgrade.receipt, "custody-grants").status, "verified");
    assert.equal(step(upgrade.receipt, "mission-control").status, "current");
    assert.equal((await componentKeys()).length, 8);
    const repeat = run(join(repository, "scripts", "install-ai-engineer.mjs"), join(dir, "install-250-repeat"));
    assert.equal(repeat.status, 0, repeat.out);
    assert.equal(repeat.body.changed, false);
  });
});

// ----------------------------------------------------------------------------------- MC common upgrade in place
// The remotes run MC 1.8.0; the pin is 1.9.0. A copy of this installer that differs only in the MC pin (the Sprint OC
// 1.8.0 lock, kept beside the 1.9.0 one) installs 1.8.0; the real installer then upgrades in place and repeats.
const MC_180 = {
  version: "1.8.0",
  lockPath: "docs/specs/provider-consolidation-2026-10/sprint-oc/release/locks-180/ai-engineer/release.lock.json",
  lockFileSha256: "c953cccb473d7c7d123dc36b32fdbdd78dd9689e8ea9707335c9bd22f80b3a0a",
  releaseRoot: "packages/mission-control-db-contract/releases/1.8.0/component",
};
function mcPinnedInstallerCopy(dest, pin) {
  let src = readFileSync(pinnedInstallerCopy(dest, KS_COMPONENT_PIN), "utf8");
  for (const key of ["version", "lockPath", "lockFileSha256", "releaseRoot"]) {
    const field = new RegExp(`(missionControl: \\{[\\s\\S]*?\\n    ${key}: )"[^"]*"`);
    assert.match(src, field);
    src = src.replace(field, `$1${JSON.stringify(pin[key])}`);
  }
  writeFileSync(dest, src);
  return dest;
}

describe("real PostgreSQL: MC common 1.8.0 → 1.9.0 upgrade in place", { skip: (!realReady || !existsSync(join(mcRoot, MC_180.lockPath))) && "needs INSTALL_WIPE_PG_ADMIN_DSN, INSTALL_WIPE_PG_CONTAINER and both Sprint OC locks" }, () => {
  const suffix = randomUUID().slice(0, 8);
  const database = `disposable_mcup_${suffix}`;
  const ref = `disposable-mcup-${suffix}`;
  const id = randomUUID();
  const dir = join(scratch, `mcup-${suffix}`);
  let pg;
  let dsn;
  let targetPath;
  let copy;
  const sql = async (text) => { const c = new pg.Client({ connectionString: dsn.replace("?sslmode=disable", "") }); await c.connect(); try { return (await c.query(text)).rows; } finally { await c.end(); } };
  const run = (script, stateDir) => {
    const r = spawnSync(process.execPath, [script, "--remote-reinstall", "--no-seal-key", "--target", targetPath, "--confirm-target", `${ref}:${id}`, "--component-installation-id", id, "--state-dir", stateDir, ...mcRootArgs],
      { cwd: repository, env: process.env, encoding: "utf8", windowsHide: true, timeout: 1_200_000 });
    let body = null;
    try { body = JSON.parse(r.stdout.trim().split("\n").at(-1)); } catch { /* crashed */ }
    const receiptFile = join(stateDir, "install-receipt.json");
    return { status: r.status, body, out: (r.stdout + r.stderr).slice(-1200), receipt: existsSync(receiptFile) ? JSON.parse(readFileSync(receiptFile, "utf8")) : null };
  };
  const step = (receipt, name) => receipt.steps.find((s) => s.step === name);

  before(async () => {
    const prepared = await prepareStubDatabase({ cluster, adminDsn: ADMIN, database, ksCli, installComponent: false });
    pg = prepared.pg;
    dsn = `${prepared.dsn}?sslmode=disable`;
    process.env.INSTALL_WIPE_TARGET_DSN = dsn;
    const url = new URL(dsn);
    targetPath = writeTarget(dir, "target.toml", { ref, id, port: Number(url.port || 5432), user: decodeURIComponent(url.username), database });
    copy = mcPinnedInstallerCopy(join(dir, "install-ai-engineer.mc-1.8.0.mjs"), MC_180);
  });
  after(async () => {
    if (!pg) return;
    const admin = new pg.Client({ connectionString: ADMIN }); await admin.connect();
    await admin.query(`drop database if exists ${database} with (force)`); await admin.end();
  });

  it("installs MC 1.8.0, upgrades to 1.9.0 applying only 0066 and 0067, then repeats with changed: false", async () => {
    assert.equal(PINS.missionControl.version, "1.9.0");
    const first = run(copy, join(dir, "install-180"));
    assert.equal(first.status, 0, first.out);
    assert.equal(first.receipt.pins.missionControl.version, "1.8.0");
    assert.equal((await sql("select max(migration_key) as k from mission_control.component_release"))[0].k, "0064_search_extension_privileges");
    const upgrade = run(join(repository, "scripts", "install-ai-engineer.mjs"), join(dir, "install-190"));
    assert.equal(upgrade.status, 0, upgrade.out);
    assert.equal(upgrade.body.changed, true);
    const mc = step(upgrade.receipt, "mission-control");
    assert.equal(mc.status, "applied");
    assert.deepEqual(mc.details.applied, ["0066_collection_member_assessments", "0067_knowledge_handle_trusted_operations"]);
    assert.equal(mc.details.verifyStatus, "verified");
    assert.equal(step(upgrade.receipt, "component").status, "current");
    assert.equal(step(upgrade.receipt, "domain-migrations").status, "current");
    assert.equal(step(upgrade.receipt, "custody-grants").status, "verified");
    assert.match((await sql("select pg_get_constraintdef(oid) as d from pg_constraint where conname = 'knowledge_operation_handle_operation_check'"))[0].d, /'report\.observe'/);
    const repeat = run(join(repository, "scripts", "install-ai-engineer.mjs"), join(dir, "install-190-repeat"));
    assert.equal(repeat.status, 0, repeat.out);
    assert.equal(repeat.body.changed, false);
    assert.equal(step(repeat.receipt, "mission-control").status, "current");
  });
});
