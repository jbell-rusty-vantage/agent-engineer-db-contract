#!/usr/bin/env node
// AI Engineer root installer (Sprint V SV-17). One ordered, idempotent, interrupt-safe install of everything the
// AI Engineer application database needs, against an explicitly DISPOSABLE local Supabase workdir only:
//
//   1. preflight          disposable identity (project id + container labels), pins, tools
//   2. component          knowledge_verification via the KS CLI (pinned version + component digest), then inspect
//   3. domain-migrations  this repository's supabase/migrations via `supabase migration up --local --workdir`
//   4. custody-grants     verify (never re-issue) the binding pin row, capability-role grants, forced RLS on custody
//                         and on the research admission/projection tables,
//                         and that the withdrawn legacy verification objects are absent
//   5. seal-key           (OVE-169 W1 D25) pin the PUBLIC half of the KS executor's run-seal key in
//                         knowledge_verification.seal_signing_key via the KS CLI `knowledge-db seal-key` (derived from the
//                         private PEM path, never printed); current on repeat, refuses another key for the id, optionally
//                         retires earlier ids. Skipped when no seal key is named (report.seal then refuses
//                         `seal_key_unregistered`). Inputs: --seal-key-id/--seal-key-file/--seal-issuer/--retire-seal-key-ids,
//                         else KS_KNOWLEDGE_SEAL_KEY_ID/KS_KNOWLEDGE_SEAL_KEY_FILE/KS_KNOWLEDGE_SEAL_ISSUER/
//                         KS_KNOWLEDGE_SEAL_RETIRE_KEY_IDS (the generator's install.env). --remote-reinstall
//                         refuses SEAL_KEY_REQUIRED without a key unless --no-seal-key; local mode warns on stderr
//   6. mission-control    MC common release via `mission-db plan/apply/verify` with the pinned target lock
//   7. receipt            JSON receipt (no DSN, no secret); `changed: false` when the run applied nothing
//
// Every step is idempotent on its own, so an interrupted run is completed by rerunning the same command. A state
// lock (`install.lock`, pid inside) refuses a concurrent installer and is taken over when its owner is dead.
//
// Remote reinstall (Sprint OC WI-24): `--remote-reinstall --target <deployments/ai-engineer/target.toml>` replaces the
// disposable-workdir gate (DISPOSABLE_PROJECT_REQUIRED) with the target gates of scripts/install-target.mjs: the exact
// `--confirm-target <project_ref>:<installation_id>`, the credential endpoint named by `database_url_env` (TLS off
// loopback), and live identity (installation row, or `--identity-evidence` for a legacy Mission Control). Domain
// migrations then run through `supabase migration up --db-url`, and Mission Control uses that target file and its
// installation id. `wipe [--dry-run]` removes what the repository and its components own behind the same gates (see
// scripts/install-target.mjs and README "Remote reinstall and wipe").
//
// Usage (from this repository root):
//   node scripts/install-ai-engineer.mjs --workdir <disposable supabase workdir> \
//     --component-installation-id <uuid> --mc-installation-id <uuid> [--receipt <file>] [--state-dir <dir>] \
//     [--seal-key-id <id> --seal-key-file <executor PKCS#8 PEM> [--seal-issuer <name>] [--retire-seal-key-ids <a,b>] | --no-seal-key] \
//     [--ks-root <dir>] [--ks-component-root <dir>] [--mc-root <dir>] [--mc-lock <release.lock.json>] [--mc-release-root <dir>] \
//     [--skip-mission-control] \
//     [--interrupt-after <step>]
//   node scripts/install-ai-engineer.mjs --remote-reinstall --target <target.toml> --confirm-target <ref>:<installation_id> \
//     --component-installation-id <uuid> [--identity-evidence <json>] [--mc-installation-id <same as target>] \
//     [--state-dir <dir>] [--receipt <file>] [--ks-root <dir>] [--mc-root <dir>] [--mc-lock <file>] [--mc-release-root <dir>] \
//     [--skip-mission-control] \
//     [--interrupt-after <step>]
//   node scripts/install-ai-engineer.mjs wipe [--dry-run] --target <target.toml> --confirm-target <ref>:<installation_id> \
//     [--identity-evidence <json>] [--schemas <a,b,...>] [--drop-public-extra <a,b>] [--keep-public-extra <a,b>] \
//     [--allow-extra-relations <schema.rel,...>] [--allow-sessions] [--evidence-dir <git-ignored dir>] [--actor <name>]
//     A real wipe also needs --from-dry-run <clean dry-run receipt.json> (same target and flags, under 2 h old); it
//     re-runs the whole plan as a dry-run first and commits nothing unless that is clean and unchanged.
// Exit: 0 passed, 2 refused gate, 1 error. Credentials are resolved into child environments and never printed.
import { spawnSync, execFileSync } from "node:child_process";
import { createHash } from "node:crypto";
import { closeSync, copyFileSync, existsSync, mkdirSync, openSync, readFileSync, readdirSync, realpathSync, rmSync, writeFileSync } from "node:fs";
import { createRequire } from "node:module";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { loadManifest, migrationsDigest } from "./install-manifest.mjs";
import {
  Refused, assertIgnored, checkDryRunReceipt, defaultActor, identifyTarget, inventoryDigest, listSessions, loadIdentityEvidence, loadTarget, missionDbInspect,
  parseNames, pgConfig, publicTarget, receiptStem, redactor, selectSchemas, summarize, wipePostgres, writeJson,
} from "./install-target.mjs";

export { Refused };

// KS knowledge_verification component pin: the one line to change for a new KS release (version + component digest,
// from `node <ks-root>/packages/knowledge-db-contract/dist/cli.js manifest` on the merged release).
export const KS_COMPONENT_PIN = Object.freeze({ version: "2.5.0", digest: "sha256:00550d59a2fe487a80e97d746d1897234e2f98c246091c06e5d2d5a07b108b88" });
export const PINS = Object.freeze({
  component: {
    name: "knowledge_verification",
    ...KS_COMPONENT_PIN,
    application: "ai-engineer",
    binding: "aiengineer-postgres",
  },
  // Sprint OC target lock (mission-db lock against releases/1.9.0/component, generated at its committed location under
  // sprint-oc/release/locks-190; the 1.8.0 locks stay for the installed W1 state). 1.9.0 adds 0066 and 0067 to the
  // installed 1.8.0, so an installed target upgrades in place by applying exactly those two. The
  // installer also passes the release root explicitly (same directory as the lock's release_root; a test pins that);
  // mission-db verifies every digest in the lock against it.
  missionControl: {
    version: "1.9.0",
    lockPath: "docs/specs/provider-consolidation-2026-10/sprint-oc/release/locks-190/ai-engineer/release.lock.json",
    lockFileSha256: "b3ecf3f8e68c4e015731e62ad5398ab8ef195ba51e6929595b6b5f2989222885",
    releaseRoot: "packages/mission-control-db-contract/releases/1.9.0/component",
    readerVersion: "mission-control-runtime/1",
    writerVersion: "mission-control-runtime/1",
  },
});
// Capability-role grants declared by 20261024010000_knowledge_component_binding.sql (the owner); verified here only.
export const EXPECTED_GRANTS = Object.freeze([
  ["knowledge_verification_reader", "app_reader"], ["knowledge_verification_reader", "pipeline_agent"],
  ["knowledge_verification_writer", "executor_service"], ["knowledge_verification_reviewer", "executor_service"],
  ["knowledge_verification_outbox_worker", "executor_service"], ["knowledge_verification_writer", "verifier_agent"],
  ["knowledge_verification_reader", "control_plane"], ["knowledge_verification_reviewer", "control_plane"],
  ["knowledge_verification_outbox_worker", "control_plane"],
]);
const WITHDRAWN = Object.freeze([
  "evidence.verification_run", "evidence.verification_finding", "evidence.claim_evidence_assessment",
  "evidence.verification_adjudication_decision", "orchestration.verification_drift_revalidation_outbox",
  "research.report_package_seal", "research.report_assessment", "research.report_ingestion_link",
  "knowledge_service.recovery_case",
]);
const STEPS = ["preflight", "component", "domain-migrations", "custody-grants", "seal-key", "mission-control", "receipt"];
const DISPOSABLE_PROJECT = /^(?:disposable|vfy)-[a-z0-9][a-z0-9-]{5,63}$/;
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/;

const sha256 = (bytes) => createHash("sha256").update(bytes).digest("hex");
const repository = resolve(dirname(fileURLToPath(import.meta.url)), "..");

function option(argv, name) {
  const index = argv.indexOf(`--${name}`);
  return index >= 0 ? argv[index + 1] : undefined;
}

function run(command, args, { env, cwd, allowFailure = false, timeout = 600_000 } = {}) {
  const result = spawnSync(command, args, { cwd, env: { ...process.env, ...env }, encoding: "utf8", windowsHide: true, timeout, shell: false });
  if (result.error) throw new Error(`${command} failed to start: ${result.error.message}`);
  if (!allowFailure && result.status !== 0) {
    throw new Error(`${command} ${args[0] ?? ""} exited ${result.status}: ${scrubOutput((result.stderr || result.stdout || "").slice(-800), Object.values(env ?? {}))}`);
  }
  return result;
}

function lastJson(text) {
  const start = text.indexOf("{");
  if (start < 0) throw new Error("expected JSON output");
  return JSON.parse(text.slice(start));
}

function supabaseBin() {
  const bin = join(repository, "node_modules", ".bin", process.platform === "win32" ? "supabase.cmd" : "supabase");
  if (!existsSync(bin)) throw new Refused("TOOL_MISSING", "pinned supabase CLI (pnpm install)");
  return bin;
}

function supabase(args, options) {
  // .cmd shims need a shell on Windows; arguments are fixed flags and validated paths.
  if (process.platform === "win32") {
    const quoted = [supabaseBin(), ...args].map((a) => (/[\s"]/.test(a) ? `"${a.replaceAll('"', '\\"')}"` : a)).join(" ");
    const result = spawnSync(quoted, { ...options, encoding: "utf8", windowsHide: true, shell: true, timeout: 600_000 });
    if (result.status !== 0 && !options?.allowFailure) throw new Error(`supabase ${args[0]} exited ${result.status}: ${(result.stderr || result.stdout || "").slice(-800)}`);
    return result;
  }
  return run(supabaseBin(), args, options);
}

// Remote path: the CLI's own entry under node with shell: false, so a credential argument never meets a shell; output
// is scrubbed of it before any error leaves this process.
export function supabaseDbUrl(args, dsn, { cwd = repository } = {}) {
  const pkg = createRequire(join(repository, "package.json")).resolve("supabase/package.json");
  const entry = join(dirname(pkg), JSON.parse(readFileSync(pkg, "utf8")).bin.supabase);
  const result = spawnSync(process.execPath, [entry, ...args, "--db-url", dsn], { cwd, encoding: "utf8", windowsHide: true, shell: false, timeout: 1_800_000 });
  let password = "";
  try { password = decodeURIComponent(new URL(dsn).password); } catch { /* not a URL: the whole value is scrubbed */ }
  const scrub = (text) => [dsn, password].filter(Boolean).reduce((out, s) => out.split(s).join("<redacted>"), String(text ?? ""));
  if (result.error) throw new Error(`supabase failed to start: ${result.error.code ?? "error"}`);
  if (result.status !== 0) throw new Error(`supabase ${args.join(" ")} exited ${result.status}: ${scrub(`${result.stderr ?? ""} ${result.stdout ?? ""}`.trim().slice(-800))}`);
  return { status: result.status, stdout: scrub(result.stdout), stderr: scrub(result.stderr) };
}

export function assertDisposableWorkdir(workdir) {
  const config = readFileSync(join(workdir, "supabase", "config.toml"), "utf8");
  const ids = [...config.matchAll(/^project_id\s*=\s*"([^"\r\n]+)"\s*$/gm)];
  const project = ids[0]?.[1];
  if (ids.length !== 1 || !DISPOSABLE_PROJECT.test(project ?? "")) throw new Refused("DISPOSABLE_PROJECT_REQUIRED", "project_id must be disposable-* or vfy-*");
  if (realpathSync(workdir) === realpathSync(repository)) throw new Refused("DISPOSABLE_PROJECT_REQUIRED", "the repository's own workdir is the shared project");
  const containerName = `supabase_db_${project}`;
  let container;
  try {
    [container] = JSON.parse(execFileSync("docker", ["inspect", containerName], { encoding: "utf8", windowsHide: true }));
  } catch {
    throw new Refused("DISPOSABLE_CONTAINER_MISSING", `${containerName} (start it with supabase db start --workdir)`);
  }
  if (!container.State.Running || container.Name !== `/${containerName}`
    || container.Config.Labels["com.supabase.cli.project"] !== project
    || realpathSync(container.Config.Labels["com.supabase.cli.workdir"]) !== realpathSync(workdir)) {
    throw new Refused("DISPOSABLE_CONTAINER_IDENTITY_MISMATCH", containerName);
  }
  return { project, containerName };
}

function resolveDsn(workdir) {
  const out = supabase(["status", "-o", "env", "--workdir", workdir], { allowFailure: false }).stdout;
  const line = out.split(/\r?\n/).find((l) => l.startsWith("DB_URL="));
  if (!line) throw new Refused("DSN_UNRESOLVED", "supabase status did not report DB_URL");
  const dsn = line.slice("DB_URL=".length).replace(/^"|"$/g, "");
  const url = new URL(dsn);
  if (!["127.0.0.1", "localhost"].includes(url.hostname)) throw new Refused("LOOPBACK_REQUIRED", url.hostname);
  return { dsn, host: url.hostname === "localhost" ? "127.0.0.1" : url.hostname, port: url.port || "5432", user: decodeURIComponent(url.username), database: url.pathname.slice(1) };
}

async function withClient(dsn, fn) {
  const { default: pg } = await import("pg");
  const client = new pg.Client({ ...pgConfig(dsn), application_name: "install-ai-engineer" });
  await client.connect();
  try { return await fn(client); } finally { await client.end(); }
}

function acquireLock(stateDir) {
  mkdirSync(stateDir, { recursive: true });
  const lockPath = join(stateDir, "install.lock");
  for (let attempt = 0; attempt < 2; attempt += 1) {
    try {
      const fd = openSync(lockPath, "wx");
      writeFileSync(fd, JSON.stringify({ pid: process.pid, startedAt: new Date().toISOString() }));
      closeSync(fd);
      return { lockPath, tookOver: attempt > 0 };
    } catch (error) {
      if (error.code !== "EEXIST") throw error;
      let owner;
      try { owner = JSON.parse(readFileSync(lockPath, "utf8")); } catch { owner = {}; }
      let alive = false;
      try { process.kill(owner.pid, 0); alive = true; } catch { alive = false; }
      if (alive) throw new Refused("INSTALL_IN_PROGRESS", `pid ${owner.pid}`);
      rmSync(lockPath, { force: true }); // previous run was interrupted; its steps are idempotent
    }
  }
  throw new Refused("INSTALL_LOCK_UNAVAILABLE", lockPath);
}

function journal(stateDir, entry) {
  const path = join(stateDir, "progress.jsonl");
  writeFileSync(path, `${JSON.stringify({ at: new Date().toISOString(), ...entry })}\n`, { flag: "a" });
}

// ---------------------------------------------------------------------------------------------------------- steps
export function componentCli(ksRoot) {
  const cli = join(ksRoot, "packages", "knowledge-db-contract", "dist", "cli.js");
  if (!existsSync(cli)) throw new Refused("TOOL_MISSING", "KS packages/knowledge-db-contract/dist/cli.js (build the KS component package)");
  return cli;
}

function preflight(context) {
  const manifest = lastJson(run(process.execPath, [componentCli(context.ksRoot), "manifest", ...context.ksComponentArgs]).stdout);
  if (manifest.component !== PINS.component.name || manifest.component_version !== PINS.component.version
    || manifest.component_digest !== PINS.component.digest) {
    throw new Refused("COMPONENT_PIN_MISMATCH", `${manifest.component}@${manifest.component_version} ${manifest.component_digest}`);
  }
  const details = { component: { version: manifest.component_version, digest: manifest.component_digest, migrations: manifest.ordered_migrations.map((m) => m.key) } };
  if (!context.skipMissionControl) {
    const lockBytes = readFileSync(context.mcLock);
    const lockSha = sha256(lockBytes);
    const lock = JSON.parse(lockBytes.toString("utf8"));
    if (lockSha !== PINS.missionControl.lockFileSha256 || lock.component_version !== PINS.missionControl.version || lock.app !== "ai-engineer") {
      throw new Refused("MISSION_CONTROL_LOCK_PIN_MISMATCH", `${lock.app}@${lock.component_version} sha256:${lockSha}`);
    }
    if (!existsSync(context.missionDb)) throw new Refused("TOOL_MISSING", "MC .venv mission-db");
    let release;
    try { release = JSON.parse(readFileSync(join(context.mcReleaseRoot, "manifest.json"), "utf8")); } catch { release = null; }
    if (release?.component_version !== PINS.missionControl.version) {
      throw new Refused("MISSION_CONTROL_RELEASE_MISSING", `${context.mcReleaseRoot} is not the ${PINS.missionControl.version} release`);
    }
    details.missionControl = { version: lock.component_version, lockFileSha256: `sha256:${lockSha}`, sourceRevision: lock.source_revision };
  }
  return { status: "checked", details };
}

function component(context) {
  const env = { KDB_INSTALL_ADMIN_DSN: context.target.dsn };
  const common = ["--admin-dsn-env", "KDB_INSTALL_ADMIN_DSN"];
  const install = run(process.execPath, [componentCli(context.ksRoot), "install", ...common, ...context.ksComponentArgs,
    "--installation-id", context.componentInstallationId, "--application", PINS.component.application,
    "--binding", PINS.component.binding, "--applied-by", "install-ai-engineer"], { env, allowFailure: true });
  const receipt = lastJson(install.stdout);
  if (install.status !== 0) throw new Refused(receipt.refused ?? "COMPONENT_INSTALL_FAILED", scrubOutput(receipt.detail ?? install.stderr.slice(-400), [context.target.dsn]));
  if (receipt.componentVersion !== PINS.component.version || receipt.componentDigest !== PINS.component.digest) {
    throw new Refused("COMPONENT_PIN_MISMATCH", `${receipt.componentVersion} ${receipt.componentDigest}`);
  }
  const inspection = lastJson(run(process.execPath, [componentCli(context.ksRoot), "inspect", ...common, ...context.ksComponentArgs], { env }).stdout);
  if (!inspection.complete) throw new Refused("COMPONENT_INCOMPLETE", JSON.stringify(inspection.receipts?.map((r) => r.migration_key)));
  return { status: receipt.applied.length ? "applied" : "current", details: { applied: receipt.applied, skipped: receipt.skipped, componentDigest: receipt.componentDigest, installationId: receipt.installationId, serverVersion: receipt.serverVersion } };
}

export function migrationFiles(root = repository) {
  return readdirSync(join(root, "supabase", "migrations")).filter((f) => f.endsWith(".sql")).sort();
}

export async function domainMigrations(context) {
  // migrationsRoot is this repository; only tests substitute a fixture tree to exercise the remote CLI path.
  const migrationsRoot = context.migrationsRoot ?? repository;
  const source = join(migrationsRoot, "supabase", "migrations");
  const repoFiles = migrationFiles(migrationsRoot);
  let copied = 0;
  if (!context.remote) {
    const destination = join(context.workdir, "supabase", "migrations");
    mkdirSync(destination, { recursive: true });
    const present = new Set(readdirSync(destination).filter((f) => f.endsWith(".sql")));
    for (const file of present) {
      if (!repoFiles.includes(file)) throw new Refused("WORKDIR_MIGRATION_UNKNOWN", file);
    }
    for (const file of repoFiles) {
      const bytes = readFileSync(join(source, file));
      if (present.has(file)) {
        if (sha256(readFileSync(join(destination, file))) !== sha256(bytes)) throw new Refused("WORKDIR_MIGRATION_BYTES_DIFFER", file);
      } else { copyFileSync(join(source, file), join(destination, file)); copied += 1; }
    }
  }
  const versions = repoFiles.map((f) => f.slice(0, 14));
  const appliedBefore = await withClient(context.target.dsn, async (c) => {
    const exists = (await c.query("select to_regclass('supabase_migrations.schema_migrations') is not null as ok")).rows[0].ok;
    return exists ? (await c.query("select version from supabase_migrations.schema_migrations")).rows.map((r) => r.version) : [];
  });
  const unknown = appliedBefore.filter((v) => !versions.includes(v));
  if (unknown.length) throw new Refused("DATABASE_MIGRATION_UNKNOWN", unknown.join(","));
  const pending = versions.filter((v) => !appliedBefore.includes(v));
  if (pending.length) {
    if (context.remote) supabaseDbUrl(["migration", "up", "--workdir", migrationsRoot], context.target.dsn, { cwd: migrationsRoot });
    else supabase(["migration", "up", "--local", "--workdir", context.workdir], {});
  }
  const appliedAfter = await withClient(context.target.dsn, async (c) =>
    (await c.query("select version from supabase_migrations.schema_migrations order by version")).rows.map((r) => r.version));
  const missing = versions.filter((v) => !appliedAfter.includes(v));
  if (missing.length) throw new Refused("MIGRATIONS_INCOMPLETE", missing.join(","));
  return { status: pending.length ? "applied" : "current", details: { files: repoFiles.length, copiedToWorkdir: copied, applied: pending, head: versions.at(-1), headFile: repoFiles.at(-1), migrationsSha256: sha256(repoFiles.map((f) => `${f}:${sha256(readFileSync(join(source, f)))}`).join("\n")) } };
}

async function custodyGrants(context) {
  return withClient(context.target.dsn, async (c) => {
    const pin = (await c.query("select component_version, migration_keys from knowledge_service.verification_component_binding where component = 'knowledge_verification'")).rows[0];
    const receipts = (await c.query("select migration_key from knowledge_verification.component_release order by migration_key")).rows.map((r) => r.migration_key);
    // The pin records the component the binding saw at migration time; it must be a prefix-compatible subset of
    // the installed receipts (an upgraded component keeps it valid) and of major version 2.
    if (!pin || !/^2\./.test(pin.component_version) || !pin.migration_keys.every((k) => receipts.includes(k))) {
      throw new Refused("BINDING_PIN_INVALID", JSON.stringify(pin ?? null));
    }
    const memberships = (await c.query(`select g.rolname as role, r.rolname as member from pg_auth_members m
      join pg_roles g on g.oid = m.roleid join pg_roles r on r.oid = m.member where g.rolname like 'knowledge_verification_%'`)).rows;
    const missing = EXPECTED_GRANTS.filter(([role, member]) => !memberships.some((m) => m.role === role && m.member === member));
    if (missing.length) throw new Refused("GRANTS_DRIFT", JSON.stringify(missing));
    const custody = (await c.query("select relrowsecurity, relforcerowsecurity from pg_class where oid = 'knowledge_verification.artifact_custody'::regclass")).rows[0];
    if (!custody?.relrowsecurity || !custody.relforcerowsecurity) throw new Refused("CUSTODY_RLS_NOT_FORCED", "knowledge_verification.artifact_custody");
    const publicCustody = (await c.query("select has_table_privilege('anon', 'knowledge_verification.artifact_custody', 'select') or has_table_privilege('authenticated', 'knowledge_verification.artifact_custody', 'select') as leak")).rows[0].leak;
    if (publicCustody) throw new Refused("CUSTODY_EXPOSED", "anon/authenticated can read artifact_custody");
    const unforced = (await c.query(`select c.relname from pg_class c join pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'research' and c.relname = any($1) and not (c.relrowsecurity and c.relforcerowsecurity)`,
      [["use_admission", "report_v2_revision", "report_v2_assertion", "report_v2_ingestion"]])).rows.map((r) => r.relname);
    if (unforced.length) throw new Refused("RESEARCH_RLS_NOT_FORCED", unforced.join(","));
    const survivors = [];
    for (const name of WITHDRAWN) {
      if ((await c.query("select to_regclass($1) is not null as present", [name])).rows[0].present) survivors.push(name);
    }
    if (survivors.length) throw new Refused("LEGACY_VERIFICATION_PRESENT", survivors.join(","));
    return { status: "verified", details: { pin: { version: pin.component_version, keys: pin.migration_keys }, grants: EXPECTED_GRANTS.length, custodyRlsForced: true, researchRlsForced: 4, withdrawnAbsent: WITHDRAWN.length } };
  });
}

/** The seal-key inputs: flags first, else the generator's environment names (install.env). */
export function sealKeyOptions(argv, env = process.env) {
  const pick = (flag, name) => option(argv, flag) ?? (env[name]?.trim() || undefined);
  return {
    keyId: pick("seal-key-id", "KS_KNOWLEDGE_SEAL_KEY_ID"),
    keyFile: pick("seal-key-file", "KS_KNOWLEDGE_SEAL_KEY_FILE"),
    issuer: pick("seal-issuer", "KS_KNOWLEDGE_SEAL_ISSUER") ?? "knowledge-services",
    retire: pick("retire-seal-key-ids", "KS_KNOWLEDGE_SEAL_RETIRE_KEY_IDS"),
    skip: argv.includes("--no-seal-key"),
    flagged: ["--seal-key-id", "--seal-key-file", "--retire-seal-key-ids"].some((flag) => argv.includes(flag)),
  };
}

// Checked before any write (main) and again in the step: a remote reinstall names the executor's seal key, or says
// explicitly that it registers none (--no-seal-key); a local run without one only warns.
export function checkSealKeyInputs(inputs, { remote }) {
  const { keyId, keyFile, skip, flagged } = inputs ?? {};
  if (skip) {
    if (flagged) throw new Refused("SEAL_KEY_FLAGS_CONFLICT", "--no-seal-key with --seal-key-id/--seal-key-file/--retire-seal-key-ids");
    return "skip";
  }
  if (!keyId && !keyFile) {
    if (remote) {
      throw new Refused("SEAL_KEY_REQUIRED", "name the KS executor's seal key (--seal-key-id/--seal-key-file, or KS_KNOWLEDGE_SEAL_KEY_ID/_FILE from install.env) or pass --no-seal-key");
    }
    return "absent";
  }
  if (!keyId || !keyFile) throw new Refused("SEAL_KEY_INCOMPLETE", "name both the seal key id and its private key file");
  if (!existsSync(keyFile)) throw new Refused("SEAL_KEY_FILE_MISSING", keyFile);
  return "register";
}

// OVE-169 W1 D25 review S2: a child's output tail never carries the DSN, its password or any URL credential.
const URL_CREDENTIALS = /([a-z][a-z0-9+.-]*:\/\/[^\s:/@]*):[^\s@]*@/gi;
export function scrubOutput(text, secrets = []) {
  const scrubbed = secrets.filter(Boolean).reduce((out, secret) => redactor(secret)(out), String(text ?? ""));
  return scrubbed.replace(URL_CREDENTIALS, "$1:<redacted>@");
}

// OVE-169 W1 D25: the executor's seal key, registered by the component owner's CLI (one implementation for both apps).
export function sealKey(context) {
  const { keyId, keyFile, issuer, retire } = context.sealKey ?? {};
  const decision = checkSealKeyInputs(context.sealKey, { remote: Boolean(context.remote) });
  if (decision === "skip") return { status: "skipped", details: { reason: "--no-seal-key" } };
  if (decision === "absent") {
    process.stderr.write("warning: seal-key skipped: no seal key named; report.seal refuses seal_key_unregistered until one is registered\n");
    return { status: "skipped", details: { reason: "no seal key named; report.seal refuses seal_key_unregistered until one is registered" } };
  }
  const args = [componentCli(context.ksRoot), "seal-key", "--admin-dsn-env", "KDB_INSTALL_ADMIN_DSN", ...(context.ksComponentArgs ?? []),
    "--key-id", keyId, "--key-file", keyFile, "--issuer", issuer, ...(retire ? ["--retire", retire] : [])];
  const result = run(process.execPath, args, { env: { KDB_INSTALL_ADMIN_DSN: context.target.dsn }, allowFailure: true });
  if (result.status === 2) {
    const body = lastJson(result.stdout);
    throw new Refused(body.refused ?? "SEAL_KEY_REFUSED", scrubOutput(body.detail ?? "", [context.target.dsn]));
  }
  if (result.status !== 0) throw new Error(`knowledge-db seal-key exited ${result.status}: ${scrubOutput((result.stderr || "").slice(-400), [context.target.dsn])}`);
  const receipt = lastJson(result.stdout);
  return { status: receipt.status, details: { keyId: receipt.keyId, issuer: receipt.issuer, publicKeySha256: receipt.publicKeySha256, registered: receipt.registered, retired: receipt.retired } };
}

function writeMcTarget(context) {
  const t = context.target;
  const toml = `# Written by install-ai-engineer.mjs for a DISPOSABLE local Supabase workdir; never a live target.
format_version = 1

[target]
app = "ai-engineer"
application_id = "ai-engineer"
project_label = "${t.project}"
project_ref = "${t.project}"
installation_id = "${context.mcInstallationId}"
environment = "disposable"
database_host = "${t.host}"
database_port = ${Number(t.port)}
database_name = "${t.database}"
database_user = "${t.user}"
database_url_env = "AIENG_DB_LOCAL_DSN"

[approval]
approved_by = "install-ai-engineer.mjs disposable proof target (container ${t.containerName})"
identity_evidence = "docker labels com.supabase.cli.project=${t.project} and com.supabase.cli.workdir match the workdir"
`;
  const path = join(context.stateDir, "mc-target.toml");
  writeFileSync(path, toml);
  return path;
}

function missionDb(context, args) {
  // A remote target names its own credential variable (database_url_env), already present in this environment.
  const env = context.remote ? {} : { AIENG_DB_LOCAL_DSN: context.target.dsn };
  const result = run(context.missionDb, args, { env, cwd: context.mcRoot, allowFailure: true });
  let body;
  try { body = lastJson(result.stdout); } catch { body = { raw: (result.stdout + result.stderr).slice(-600) }; }
  return { code: result.status, body };
}

export function missionControl(context) {
  const target = context.remote ? context.remote.target.path : writeMcTarget(context);
  const versions = ["--reader-version", PINS.missionControl.readerVersion, "--writer-version", PINS.missionControl.writerVersion];
  const selection = ["--target", target, "--lock", context.mcLock, "--release-root", context.mcReleaseRoot];
  const planPath = join(context.stateDir, "mc-plan.json");
  const plan = missionDb(context, ["plan", ...selection, ...versions, "--out", planPath]);
  if (plan.code !== 0) throw new Refused("MISSION_CONTROL_PLAN_BLOCKED", JSON.stringify(plan.body).slice(0, 600));
  const pending = plan.body.pending_migrations ?? plan.body.plan?.pending_migrations ?? [];
  let apply = null;
  if (pending.length) {
    apply = missionDb(context, ["apply", ...selection, ...versions, "--confirm-target", `${context.target.project}:${context.mcInstallationId}`, "--expected-plan-digest", plan.body.plan_digest]);
    if (apply.code !== 0) throw new Refused("MISSION_CONTROL_APPLY_BLOCKED", JSON.stringify(apply.body).slice(0, 600));
  }
  const verify = missionDb(context, ["verify", ...selection, ...versions]);
  if (verify.code !== 0) throw new Refused("MISSION_CONTROL_VERIFY_BLOCKED", JSON.stringify(verify.body).slice(0, 600));
  writeFileSync(join(context.stateDir, "mc-verify.json"), JSON.stringify(verify.body, null, 2));
  if (apply) writeFileSync(join(context.stateDir, "mc-apply.json"), JSON.stringify(apply.body, null, 2));
  return { status: pending.length ? "applied" : "current", details: { componentVersion: PINS.missionControl.version, planDigest: plan.body.plan_digest, applied: pending, verifyStatus: verify.body.status, installationId: context.mcInstallationId } };
}

// ---------------------------------------------------------------------------------------------------------- main
const missionDbPath = (mcRoot) => join(mcRoot, ".venv", process.platform === "win32" ? "Scripts/mission-db.exe" : "bin/mission-db");
const DEFAULT_EVIDENCE = join(repository, ".scratch", "sprint-oc", "evidence");

// Gates 1–3 of install-target.mjs for a remote target file (the confirm string is checked before any connection).
async function remoteGate(argv, mcRoot, target = loadRemoteTarget(argv)) {
  const missionDb = missionDbPath(mcRoot);
  if (!existsSync(missionDb)) throw new Refused("TOOL_MISSING", "MC .venv mission-db (identity inspection)");
  const gate = await identifyTarget({
    target, confirmation: option(argv, "confirm-target"), evidence: loadIdentityEvidence(option(argv, "identity-evidence")),
    connect: (endpoint, fn) => withClient(endpoint.dsn, fn),
    inspect: ({ scrub }) => missionDbInspect({ missionDb, mcRoot, targetPath: target.path, scrub }),
  });
  return { target, ...gate };
}

function loadRemoteTarget(argv) {
  const targetArg = option(argv, "target");
  if (!targetArg) throw new Refused("TARGET_REQUIRED", "--target <deployments/ai-engineer/target.toml>");
  return loadTarget(resolve(targetArg), { app: "ai-engineer" });
}

// `wipe [--dry-run]`: drop the manifest's public objects, the allow-listed schemas and the CLI ledger of an identified
// target. The receipt (JSON + .txt summary) and a step journal are written in `finally`, also for a refusal or failure.
export async function wipe(argv) {
  const dryRun = argv.includes("--dry-run");
  const mcRoot = resolve(option(argv, "mc-root") ?? join(repository, "..", "..", "platform", "mission-control"));
  const schemas = selectSchemas(option(argv, "schemas"));
  const evidenceDir = resolve(option(argv, "evidence-dir") ?? join(DEFAULT_EVIDENCE, "wipe"));
  assertIgnored(repository, evidenceDir);
  const manifest = loadManifest();
  if (manifest.migrations.sha256 !== migrationsDigest().sha256) throw new Refused("WIPE_MANIFEST_STALE", "scripts/install-manifest.json predates supabase/migrations; run scripts/install-manifest.mjs");
  const target = loadRemoteTarget(argv);
  const startedAt = new Date().toISOString();
  const stem = receiptStem(evidenceDir, dryRun ? "dry-run" : "wipe", target.project_ref, startedAt);
  const journalPath = `${stem}.journal.jsonl`;
  const journalLine = (entry) => writeFileSync(journalPath, `${JSON.stringify({ at: new Date().toISOString(), ...entry })}\n`, { flag: "a" });
  const flags = {
    dropPublicExtra: parseNames(option(argv, "drop-public-extra")), keepPublicExtra: parseNames(option(argv, "keep-public-extra")),
    allowExtraRelations: parseNames(option(argv, "allow-extra-relations")), allowSessions: argv.includes("--allow-sessions"),
  };
  const receipt = {
    format: "ai-engineer-wipe-receipt.v2", dryRun, status: "started", target: publicTarget(target), graphHost: null,
    actor: option(argv, "actor") ?? defaultActor(), requestedSchemas: schemas, flags,
    manifest: { file: "scripts/install-manifest.json", migrations: manifest.migrations }, steps: [], startedAt,
  };
  let scrub = (t) => t;
  let current = null;
  try {
    journalLine({ event: "start", dryRun });
    current = "identity";
    const gate = await remoteGate(argv, mcRoot, target);
    scrub = gate.scrub;
    receipt.identity = gate.identity;
    receipt.probe = { schemasPresent: gate.probe.schemasPresent, lastMissionControlMigration: gate.probe.lastMissionControlMigration };
    journalLine({ event: "done", step: "identity", status: gate.identity.status });
    current = "sessions";
    receipt.sessions = await withClient(gate.endpoint.dsn, listSessions);
    const application = receipt.sessions.filter((x) => !x.platform);
    const sessionBlocker = application.length && !flags.allowSessions
      ? [{ step: "sessions", code: "WIPE_SESSIONS_ACTIVE", objects: application.map((x) => `${x.usename ?? "?"}:${x.pid}:${x.application_name || "-"}`), total: application.length }] : [];
    const plan = (results, asDryRun, onStep = () => {}) => withClient(gate.endpoint.dsn, (client) => wipePostgres(client, {
      schemas, manifest, expectedOwner: target.database_session_user, dryRun: asDryRun, results,
      dropExtra: new Set(flags.dropPublicExtra), keepExtra: new Set(flags.keepPublicExtra), allowExtraRelations: new Set(flags.allowExtraRelations),
      onStep,
    }));
    const blockersOf = (steps) => [...steps.flatMap((x) => (x.blockers ?? []).map((b) => ({ step: x.step, ...b }))), ...sessionBlocker];
    if (!dryRun) {
      // F1: all-or-nothing. A clean dry-run receipt for this exact target and these flags, then an internal dry-run of
      // the whole plan (every step rolled back) whose inventory digest must equal the receipt's; only then commits.
      current = "dry-run-receipt";
      receipt.fromDryRun = checkDryRunReceipt(option(argv, "from-dry-run"), { target, flags, requestedSchemas: schemas, format: receipt.format });
      if (sessionBlocker.length) throw new Refused("WIPE_SESSIONS_ACTIVE", `${application.length} other application session(s) on the database (see the receipt); stop them or pass --allow-sessions`);
      current = "pre-check";
      journalLine({ event: "start", step: "pre-check" });
      const preSteps = [];
      await plan(preSteps, true);
      const preBlockers = blockersOf(preSteps);
      receipt.preCheck = { inventoryDigest: inventoryDigest(preSteps), blockers: preBlockers, steps: preSteps.map((x) => `${x.step}:${x.status}`) };
      journalLine({ event: "done", step: "pre-check", blockers: preBlockers.length });
      if (preBlockers.length) throw new Refused("WIPE_PLAN_BLOCKED", `nothing was changed; blockers: ${preBlockers.map((b) => `${b.step}:${b.code}`).join(", ")}`);
      if (receipt.preCheck.inventoryDigest !== receipt.fromDryRun.inventoryDigest) {
        throw new Refused("WIPE_DRY_RUN_MISMATCH", "nothing was changed; the target's inventory differs from the dry-run's (dry-run again)");
      }
    }
    current = null;
    await plan(receipt.steps, dryRun, (e) => { current = e.event === "start" ? e.step : null; journalLine(e); });
    receipt.blockers = blockersOf(receipt.steps);
    receipt.inventoryDigest = dryRun ? inventoryDigest(receipt.steps) : receipt.preCheck.inventoryDigest;
    receipt.status = dryRun ? (receipt.blockers.length ? "dry-run-blocked" : "dry-run-clear") : "complete";
    receipt.changed = !dryRun && receipt.steps.some((x) => ["dropped", "deleted"].includes(x.status));
    return receipt;
  } catch (error) {
    receipt.status = "failed";
    receipt.failedStep = current;
    receipt.error = { code: error instanceof Refused ? error.code : "ERROR", message: scrub(error instanceof Error ? error.message : String(error)).slice(0, 800) };
    receipt.changed = receipt.steps.some((x) => ["dropped", "deleted"].includes(x.status));
    throw error;
  } finally {
    receipt.finishedAt = new Date().toISOString();
    receipt.path = writeJson(`${stem}.json`, receipt);
    receipt.summaryPath = `${stem}.txt`;
    writeFileSync(receipt.summaryPath, summarize(receipt));
    journalLine({ event: "receipt", status: receipt.status });
  }
}

export async function main(argv = process.argv.slice(2)) {
  if (argv[0] === "wipe") return wipe(argv.slice(1));
  const remoteMode = argv.includes("--remote-reinstall");
  if (!remoteMode && (option(argv, "target") || option(argv, "confirm-target"))) {
    throw new Refused("REMOTE_REINSTALL_FLAG_REQUIRED", "--target/--confirm-target install only with --remote-reinstall");
  }
  const componentInstallationId = option(argv, "component-installation-id");
  const skipMissionControl = argv.includes("--skip-mission-control");
  if (!UUID.test(componentInstallationId ?? "")) throw new Refused("INSTALLATION_ID_REQUIRED", "--component-installation-id <uuid>");
  const interruptAfter = option(argv, "interrupt-after");
  if (interruptAfter && !STEPS.includes(interruptAfter)) throw new Refused("UNKNOWN_STEP", interruptAfter);
  const ksRoot = resolve(option(argv, "ks-root") ?? join(repository, "..", "..", "platform", "knowledge-services"));
  const mcRoot = resolve(option(argv, "mc-root") ?? join(repository, "..", "..", "platform", "mission-control"));
  let workdir = null;
  let mcInstallationId = option(argv, "mc-installation-id");
  let remote = null;
  let endpoint;
  let identityTarget;
  let stateDir;
  if (remoteMode) {
    if (option(argv, "workdir")) throw new Refused("REMOTE_REINSTALL_CONFLICT", "--workdir names a disposable local project; drop it with --remote-reinstall");
    remote = await remoteGate(argv, mcRoot);
    if (mcInstallationId && mcInstallationId !== remote.target.installation_id) throw new Refused("MC_INSTALLATION_ID_MISMATCH", "--mc-installation-id differs from target.toml");
    mcInstallationId = remote.target.installation_id;
    endpoint = remote.endpoint;
    identityTarget = { project: remote.target.project_ref, containerName: null };
    stateDir = resolve(option(argv, "state-dir") ?? join(DEFAULT_EVIDENCE, "install-state", remote.target.project_ref));
  } else {
    const workdirArg = option(argv, "workdir");
    if (!workdirArg) throw new Refused("WORKDIR_REQUIRED", "--workdir <disposable supabase workdir> (or --remote-reinstall --target)");
    workdir = realpathSync(resolve(workdirArg));
    if (!skipMissionControl && !UUID.test(mcInstallationId ?? "")) throw new Refused("INSTALLATION_ID_REQUIRED", "--mc-installation-id <uuid>");
    stateDir = resolve(option(argv, "state-dir") ?? join(workdir, ".install-state"));
    identityTarget = assertDisposableWorkdir(workdir);
  }
  const { project, containerName } = identityTarget;
  const sealKeyInputs = sealKeyOptions(argv);
  checkSealKeyInputs(sealKeyInputs, { remote: remoteMode });
  const receiptPath = resolve(option(argv, "receipt") ?? join(stateDir, "install-receipt.json"));
  const lock = acquireLock(stateDir);
  const startedAt = new Date().toISOString();
  try {
    endpoint ??= resolveDsn(workdir);
    const context = {
      workdir, ksRoot, mcRoot, stateDir, componentInstallationId, mcInstallationId, skipMissionControl, remote,
      // --ks-component-root: the KS CLI's --component-root (default: the component inside --ks-root); the pin still applies.
      ksComponentArgs: option(argv, "ks-component-root") ? ["--component-root", resolve(option(argv, "ks-component-root"))] : [],
      mcLock: resolve(option(argv, "mc-lock") ?? join(mcRoot, PINS.missionControl.lockPath)),
      mcReleaseRoot: resolve(option(argv, "mc-release-root") ?? join(mcRoot, PINS.missionControl.releaseRoot)),
      missionDb: missionDbPath(mcRoot),
      target: { ...endpoint, project, containerName },
      sealKey: sealKeyInputs,
    };
    const steps = [];
    const handlers = {
      preflight: () => preflight(context),
      component: () => component(context),
      "domain-migrations": () => domainMigrations(context),
      "custody-grants": () => custodyGrants(context),
      "seal-key": () => sealKey(context),
      "mission-control": () => (skipMissionControl ? { status: "skipped", details: { reason: "--skip-mission-control" } } : missionControl(context)),
    };
    journal(stateDir, { event: "start", pid: process.pid, resumedAfterInterruption: lock.tookOver, mode: remote ? "remote-reinstall" : "disposable" });
    for (const name of STEPS.slice(0, -1)) {
      const t0 = Date.now();
      const outcome = await handlers[name]();
      steps.push({ step: name, ...outcome, ms: Date.now() - t0 });
      journal(stateDir, { event: "step", step: name, status: outcome.status });
      if (interruptAfter === name) {
        journal(stateDir, { event: "interrupt", after: name });
        process.kill(process.pid, "SIGKILL"); // abrupt: no lock release, no receipt (simulated crash)
      }
    }
    const receipt = {
      format: "ai-engineer-install-receipt.v1",
      target: remote
        ? { mode: "remote-reinstall", ...publicTarget(remote.target), identity: remote.identity }
        : { project, container: containerName, host: endpoint.host, port: endpoint.port, database: endpoint.database, environment: "disposable" },
      pins: PINS,
      steps,
      changed: steps.some((s) => s.status === "applied"),
      resumedAfterInterruption: lock.tookOver,
      startedAt,
      finishedAt: new Date().toISOString(),
    };
    writeFileSync(receiptPath, `${JSON.stringify(receipt, null, 2)}\n`);
    journal(stateDir, { event: "receipt", path: receiptPath, changed: receipt.changed });
    return receipt;
  } finally {
    rmSync(lock.lockPath, { force: true });
  }
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  main().then(
    (receipt) => {
      if (receipt.format === "ai-engineer-wipe-receipt.v2") {
        process.stderr.write(summarize(receipt));
        process.stdout.write(`${JSON.stringify({ status: receipt.status, changed: receipt.changed, identity: receipt.identity.status, steps: receipt.steps.map((s) => `${s.step}:${s.status}`), blockers: receipt.blockers.length, receipt: receipt.path, summary: receipt.summaryPath })}\n`);
        return;
      }
      process.stdout.write(`${JSON.stringify({ status: "installed", changed: receipt.changed, steps: receipt.steps.map((s) => `${s.step}:${s.status}`) })}\n`);
    },
    (error) => {
      if (error instanceof Refused) { process.stdout.write(`${JSON.stringify({ status: "refused", code: error.code, detail: error.detail })}\n`); process.exitCode = 2; return; }
      process.stderr.write(`${error instanceof Error ? error.message : String(error)}\n`);
      process.exitCode = 1;
    },
  );
}
