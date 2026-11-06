// Remote targets and the wipe step of the AI Engineer root installer (Sprint OC WI-24; MC sprint-oc IMPLEMENTATION.md
// §4.1). A remote target is an explicit Mission Control `deployments/ai-engineer/target.toml` (format_version 1).
// Every use of one passes these gates, in order, before anything mutates:
//
//   1. confirm    `--confirm-target <project_ref>:<installation_id>` equals the target file exactly
//   2. endpoint   the credential in the env var NAMED by `database_url_env` addresses exactly the declared
//                 host/port/user/database, with TLS (sslmode require|verify-ca|verify-full) for a non-loopback host;
//                 the value is never printed, logged or written
//   3. identity   a read-only probe and `mission-db inspect`: stored installation rows must all carry this project ref,
//                 installation id and application. `--identity-evidence` (management-API observation under 24 h old:
//                 ref, name, installation id, and the system_identifier this DSN's pg_control_system() reports) is
//                 checked in full whenever supplied, and is the only proof for a pre-1.6.0 legacy `mission_control`
//                 without an installation row. With no `mission_control` at all, the exact route (`postgres.<ref>`
//                 pooler login or `db.<ref>.supabase.co`) or that evidence proves it.
//   4. inventory  a wipe drops only WIPE_SCHEMAS whose owner is the target's session user and whose relations are the
//                 ones this repository's migrations create (install-manifest.json), plus the manifest's `public`
//                 objects and `storage.objects` triggers/policies by name. It never drops a database, the `public`
//                 schema, extension-owned objects, buckets or storage objects. Unknown `public` objects or relations
//                 refuse unless named (`--drop-public-extra`, `--keep-public-extra`, `--allow-extra-relations`).
//   5. sessions   non-platform sessions on the database refuse a real wipe unless `--allow-sessions`.
//   6. plan       a real wipe needs `--from-dry-run` (a clean dry-run of the same target and flags, under 2 h old),
//                 re-runs the whole plan as a dry-run first, and commits nothing unless that is clean and its inventory
//                 digest equals the receipt's (all or nothing).
//
// Each step is its own transaction (Mission Control last, so an interrupted wipe keeps the identity row). Inside it a
// catalog diff of everything outside the step's own objects refuses (rolls back) a cascade that would remove a table,
// column, sequence, composite/standalone type, domain constraint, extension, cast, operator, operator class/family,
// event trigger, publication, default ACL, function, view, policy, trigger or constraint the plan does not remove;
// only policies/triggers/constraints of the manifest's own tables are recorded and allowed (kept extras always hold).
// `--dry-run` runs every gate and every step with a 5 s lock timeout, then rolls each back.
import { spawnSync } from "node:child_process";
import { createHash, randomBytes } from "node:crypto";
import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { hostname, userInfo } from "node:os";
import { join, resolve } from "node:path";

export class Refused extends Error {
  constructor(code, detail) { super(`${code}: ${detail}`); this.code = code; this.detail = detail; }
}

// AI Engineer domain schemas: exactly the schemas created by supabase/migrations/*.sql (a test pins this equality).
export const DOMAIN_SCHEMAS = Object.freeze([
  "access", "api", "authoring", "content", "conversation", "corpus", "curriculum", "dataset", "evaluation", "evidence", "inquiry", "knowledge",
  "learning", "library", "observability", "orchestration", "product", "provenance", "ranking", "research", "research_private", "retrieval", "staging",
  "taxonomy", "temporal", "util",
]);
// knowledge_service: this repository's binding/custody schema; knowledge_verification: the KS component.
export const KNOWLEDGE_SCHEMAS = Object.freeze(["knowledge_service", "knowledge_verification"]);
// capability_search: Mission Control's removed legacy capability-search schema (MC docs/REMOVAL_GUIDE.md);
// mission_control_runtime: the LangGraph saver; mission_control_search + mission_control: the MC common component.
export const MISSION_CONTROL_SCHEMAS = Object.freeze(["capability_search", "mission_control_runtime", "mission_control_search", "mission_control"]);
export const WIPE_SCHEMAS = Object.freeze([...DOMAIN_SCHEMAS, ...KNOWLEDGE_SCHEMAS, ...MISSION_CONTROL_SCHEMAS]);
// Schemas whose relations this repository's migrations create (checked against the manifest before a drop).
export const MANIFEST_SCHEMAS = Object.freeze([...DOMAIN_SCHEMAS, "knowledge_service"]);
export const PROTECTED_SCHEMAS = Object.freeze([
  "public", "auth", "storage", "extensions", "graphql", "graphql_public", "realtime", "_realtime", "vault", "pgsodium",
  "pgsodium_masks", "net", "cron", "pgbouncer", "information_schema", "_analytics", "supabase_functions",
  "supabase_migrations",
]);
const LOOPBACK = new Set(["127.0.0.1", "localhost", "::1"]);
const PROJECT_REF = /^[a-z0-9-]{1,63}$/;
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/;
const ENV_NAME = /^[A-Z][A-Z0-9_]*$/;
const IDENT = /^[a-z_][a-z0-9_]*$/;
const EVIDENCE_MAX_AGE_MS = 24 * 3600 * 1000;
const TARGET_FIELDS = ["app", "application_id", "project_label", "project_ref", "installation_id", "environment",
  "database_host", "database_port", "database_name", "database_user", "database_url_env"];

export function isProtectedSchema(name) {
  return PROTECTED_SCHEMAS.includes(name) || /^pg_/.test(name) || /^supabase_/.test(name);
}

// ------------------------------------------------------------------------------------------------- target.toml
export function parseTargetToml(text) {
  const tables = {};
  let current = null;
  for (const raw of text.split(/\r?\n/)) {
    const line = raw.trim();
    if (!line || line.startsWith("#")) continue;
    const table = /^\[([a-z_]+)\]$/.exec(line);
    if (table) { current = tables[table[1]] ??= {}; continue; }
    const pair = /^([a-z_]+)\s*=\s*(?:"((?:[^"\\]|\\.)*)"|(\d+))\s*(?:#.*)?$/.exec(line);
    if (!pair) throw new Refused("TARGET_INVALID", "unsupported target.toml line");
    const value = pair[2] !== undefined ? pair[2].replace(/\\(.)/g, "$1") : Number(pair[3]);
    (current ?? (tables[""] ??= {}))[pair[1]] = value;
  }
  return tables;
}

export function loadTarget(path, { app } = {}) {
  let text;
  try { text = readFileSync(path, "utf8"); } catch { throw new Refused("TARGET_REQUIRED", `cannot read ${path}`); }
  const tables = parseTargetToml(text);
  if (tables[""]?.format_version !== 1 || !tables.target) throw new Refused("TARGET_INVALID", "format_version 1 with [target]");
  const t = tables.target;
  for (const name of TARGET_FIELDS) {
    if (t[name] === undefined || t[name] === "") throw new Refused("TARGET_INVALID", `missing ${name}`);
  }
  const target = Object.fromEntries(TARGET_FIELDS.map((n) => [n, String(t[n])]));
  target.database_session_user = t.database_session_user ?? target.database_user;
  if (app && (target.app !== app || target.application_id !== app)) throw new Refused("TARGET_INVALID", `app must be ${app}`);
  if (!PROJECT_REF.test(target.project_ref)) throw new Refused("TARGET_INVALID", "project_ref");
  if (!UUID.test(target.installation_id)) throw new Refused("TARGET_INVALID", "installation_id must be a canonical lowercase UUID");
  if (!ENV_NAME.test(target.database_url_env)) throw new Refused("TARGET_INVALID", "database_url_env must be an env var NAME");
  if (!/^\d+$/.test(target.database_port)) throw new Refused("TARGET_INVALID", "database_port");
  return { ...target, path: resolve(path) };
}

export function confirmTarget(confirmation, target) {
  if (!confirmation) throw new Refused("CONFIRM_TARGET_REQUIRED", "--confirm-target <project_ref>:<installation_id>");
  const expected = `${target.project_ref}:${target.installation_id}`;
  if (confirmation !== expected) throw new Refused("CONFIRM_TARGET_MISMATCH", `confirmation does not equal ${target.path} project_ref:installation_id`);
  return expected;
}

// Mirrors mission-db target_dsn, plus TLS for anything that is not loopback.
export function resolveTargetDsn(target, env = process.env) {
  const dsn = env[target.database_url_env];
  if (!dsn) throw new Refused("TARGET_DSN_MISSING", `environment variable ${target.database_url_env} is not set`);
  let url;
  try { url = new URL(dsn); } catch { throw new Refused("TARGET_DSN_MISMATCH", `${target.database_url_env} is not a URL`); }
  const options = [...url.searchParams.keys()];
  const host = url.hostname.replace(/^\[|\]$/g, "");
  const matches = ["postgres:", "postgresql:"].includes(url.protocol)
    && host === target.database_host
    && Number(url.port || 5432) === Number(target.database_port)
    && decodeURIComponent(url.username) === target.database_user
    && decodeURIComponent(url.pathname.slice(1)) === target.database_name
    && options.every((k) => ["sslmode", "sslrootcert", "sslcert", "sslkey"].includes(k))
    && new Set(options).size === options.length && !url.hash;
  if (!matches) throw new Refused("TARGET_DSN_MISMATCH", `${target.database_url_env} does not address the declared host/port/user/database`);
  const sslmode = url.searchParams.get("sslmode");
  if (!LOOPBACK.has(host) && !["require", "verify-ca", "verify-full"].includes(sslmode ?? "")) {
    throw new Refused("TARGET_DSN_TLS_REQUIRED", `${target.database_url_env} needs sslmode=require|verify-ca|verify-full for a non-loopback host`);
  }
  return { dsn, host: target.database_host, port: target.database_port, user: target.database_user, database: target.database_name, sslmode: sslmode ?? null };
}

// node-postgres config with libpq sslmode semantics (node-postgres alone treats `require` as verify-full).
export function pgConfig(dsn) {
  const url = new URL(dsn);
  const mode = url.searchParams.get("sslmode");
  const rootcert = url.searchParams.get("sslrootcert");
  for (const k of ["sslmode", "sslrootcert", "sslcert", "sslkey"]) url.searchParams.delete(k);
  let ssl = false;
  if (mode === "require") ssl = { rejectUnauthorized: false };
  else if (mode === "verify-ca" || mode === "verify-full") {
    ssl = { rejectUnauthorized: true, ...(rootcert ? { ca: readFileSync(rootcert, "utf8") } : {}) };
    if (mode === "verify-ca") ssl.checkServerIdentity = () => undefined;
  }
  return { connectionString: url.toString(), ssl };
}

export function redactor(dsn) {
  let password = "";
  try { password = decodeURIComponent(new URL(dsn).password); } catch { /* not a URL: the whole value is scrubbed */ }
  let raw = "";
  try { raw = new URL(dsn).password; } catch { /* idem */ }
  const secrets = [dsn, password, raw].filter((s) => s && s.length >= 4);
  return (text) => secrets.reduce((out, s) => out.split(s).join("<redacted>"), String(text ?? ""));
}

// Exact route proof (S6): the Supabase pooler login or direct host names this project ref.
export function routeProof(target) {
  const ref = target.project_ref;
  if (target.database_user === `postgres.${ref}`) return `pooler login postgres.${ref}`;
  if (target.database_host === `db.${ref}.supabase.co`) return `direct host db.${ref}.supabase.co`;
  if (target.environment === "disposable" && LOOPBACK.has(target.database_host)) return "disposable loopback target";
  return null;
}

export function loadIdentityEvidence(path) {
  if (!path) return null;
  let body;
  try { body = JSON.parse(readFileSync(path, "utf8")); } catch { throw new Refused("IDENTITY_EVIDENCE_INVALID", `cannot read JSON ${path}`); }
  return { ...body, path: resolve(path) };
}

// --identity-evidence: {source: "management-api", project_ref, name, region, installation_id, system_identifier,
// observed_at}. Whenever supplied it must hold entirely: fresh, the target's ref/label/installation id, a route that
// carries the ref, and the system identifier read over this very DSN (binding the observation to this database).
export function evaluateEvidence(evidence, target, probe, now = Date.now()) {
  if (!evidence) return { ok: false, reason: "no --identity-evidence" };
  if (evidence.source !== "management-api") return { ok: false, reason: "source must be management-api" };
  if (evidence.project_ref !== target.project_ref) return { ok: false, reason: "evidence project_ref differs from target.toml" };
  if (evidence.name !== target.project_label) return { ok: false, reason: "evidence name differs from target project_label" };
  if (evidence.installation_id !== target.installation_id) return { ok: false, reason: "evidence installation_id differs from target.toml" };
  if (typeof evidence.region !== "string" || !evidence.region) return { ok: false, reason: "evidence region missing" };
  if (typeof evidence.system_identifier !== "string" || !/^\d+$/.test(evidence.system_identifier)) return { ok: false, reason: "evidence system_identifier (text digits) missing" };
  const at = Date.parse(evidence.observed_at ?? "");
  if (Number.isNaN(at)) return { ok: false, reason: "observed_at is not an ISO timestamp" };
  if (now - at > EVIDENCE_MAX_AGE_MS) return { ok: false, reason: "evidence is older than 24 h" };
  if (at - now > 5 * 60 * 1000) return { ok: false, reason: "observed_at is in the future" };
  const route = routeProof(target);
  if (!route) return { ok: false, reason: "the route (login/host) does not carry the evidence project ref" };
  if (!probe?.systemIdentifier) return { ok: false, code: "TARGET_SYSTEM_IDENTIFIER_UNREADABLE", reason: `pg_control_system() not readable over the DSN (${probe?.systemIdentifierError ?? "?"})` };
  if (probe.systemIdentifier !== evidence.system_identifier) return { ok: false, code: "TARGET_SYSTEM_IDENTIFIER_MISMATCH", reason: "the database's system_identifier differs from the evidence" };
  return {
    ok: true, route,
    evidence: { source: evidence.source, project_ref: evidence.project_ref, name: evidence.name, region: evidence.region, installation_id: evidence.installation_id, system_identifier: evidence.system_identifier, observed_at: evidence.observed_at, file: evidence.path },
  };
}

// Read-only probe that works on any Mission Control version (legacy installs may predate the identity table).
export async function probeTarget(client) {
  await client.query("begin read only");
  try {
    const schemas = (await client.query("select nspname from pg_namespace where nspname = any($1)", [WIPE_SCHEMAS])).rows.map((r) => r.nspname);
    const missionControl = schemas.includes("mission_control");
    let rows = [];
    let lastMigration = null;
    if (missionControl && (await client.query("select to_regclass('mission_control.application_installation') is not null as ok")).rows[0].ok) {
      rows = (await client.query("select to_jsonb(i) as r from mission_control.application_installation i")).rows.map((r) => r.r);
    }
    if (missionControl && (await client.query("select to_regclass('mission_control.component_release') is not null as ok")).rows[0].ok) {
      lastMigration = (await client.query("select max(migration_key) as k from mission_control.component_release")).rows[0].k;
    }
    let systemIdentifier = null;
    let systemIdentifierError = null;
    await client.query("savepoint sysid");
    try { systemIdentifier = (await client.query("select system_identifier::text as id from pg_control_system()")).rows[0].id; } catch (error) {
      systemIdentifierError = `SQLSTATE ${error?.code ?? "?"}`;
      await client.query("rollback to savepoint sysid");
    }
    return { schemasPresent: schemas, missionControl, identityRows: rows, lastMissionControlMigration: lastMigration, systemIdentifier, systemIdentifierError };
  } finally { await client.query("rollback"); }
}

const refuseEvidence = (verdict, prefix) => new Refused(verdict.code ?? "TARGET_IDENTITY_UNPROVEN", `${prefix}${verdict.reason}`);

// Pure decision over the probe, the optional `mission-db inspect` document and optional evidence.
export function evaluateIdentity({ probe, inspection, inspectError, evidence }, target, now = Date.now()) {
  if (inspection && (inspection.target?.project_ref !== target.project_ref || inspection.target?.installation_id !== target.installation_id)) {
    throw new Refused("TARGET_IDENTITY_MISMATCH", "mission-db inspected a different target");
  }
  // Evidence, when supplied, is always checked in full (F3), whatever else proves identity.
  const verdict = evidence ? evaluateEvidence(evidence, target, probe, now) : null;
  if (verdict && !verdict.ok) throw refuseEvidence(verdict, "--identity-evidence: ");
  const withEvidence = verdict ? { evidence: verdict.evidence } : {};
  const rows = probe.identityRows;
  if (rows.length) {
    const foreign = rows.filter((r) => r.installation_id !== target.installation_id || r.supabase_project_ref !== target.project_ref
      || r.application_id !== target.application_id);
    if (foreign.length || (inspection && inspection.identity_matches_target !== true)) {
      throw new Refused("TARGET_IDENTITY_MISMATCH", `live installation ${JSON.stringify(rows.map((r) => `${r.supabase_project_ref}:${r.installation_id}:${r.application_id}:${r.environment}`))} != target.toml`);
    }
    return { status: "matched", source: "mission_control.application_installation", rows: rows.length, inspect: inspection ? "inspected" : `failed: ${inspectError}`, ...withEvidence };
  }
  if (probe.missionControl) {
    if (!verdict) throw new Refused("TARGET_IDENTITY_UNPROVEN", `mission_control exists (last ${probe.lastMissionControlMigration ?? "?"}) without an installation row: --identity-evidence with system_identifier is required`);
    return { status: "evidence", source: "management-api", legacyMissionControl: probe.lastMissionControlMigration, route: verdict.route, inspect: inspection ? "inspected" : `failed: ${inspectError}`, ...withEvidence };
  }
  if (!inspection && inspectError) throw new Refused("TARGET_INSPECT_FAILED", inspectError);
  if (verdict) return { status: "evidence", source: "management-api", route: verdict.route, ...withEvidence };
  const route = routeProof(target);
  if (!route) throw new Refused("TARGET_IDENTITY_UNPROVEN", "no mission_control and the route does not carry the project ref");
  return { status: "absent", source: "route", proof: route };
}

export function missionDbInspect({ missionDb, mcRoot, targetPath, scrub = (t) => t }) {
  const r = spawnSync(missionDb, ["inspect", "--target", targetPath], { cwd: mcRoot, env: process.env, encoding: "utf8", windowsHide: true, timeout: 120_000 });
  if (r.error) throw new Refused("TOOL_MISSING", `mission-db: ${r.error.code ?? "failed to start"}`);
  let body;
  try { body = JSON.parse(r.stdout.slice(r.stdout.indexOf("{"))); } catch { body = null; }
  if (r.status !== 0 || body?.status !== "inspected") {
    return { error: scrub(JSON.stringify(body ?? (r.stdout + r.stderr).slice(-400))).slice(0, 400) };
  }
  return { inspection: body };
}

// Gates 1–3. `connect` and `inspect` are injectable so the decision is testable without a database.
export async function identifyTarget({ target, confirmation, env = process.env, connect, inspect, evidence, now }) {
  const confirmed = confirmTarget(confirmation, target);
  const endpoint = resolveTargetDsn(target, env);
  const scrub = redactor(endpoint.dsn);
  const probe = await connect(endpoint, probeTarget);
  const { inspection = null, error: inspectError = null } = inspect({ scrub });
  const identity = evaluateIdentity({ probe, inspection, inspectError, evidence }, target, now);
  return { confirmed, endpoint, identity, probe, scrub };
}

export function selectSchemas(list) {
  const requested = list === undefined ? [...WIPE_SCHEMAS] : String(list).split(",").map((s) => s.trim()).filter(Boolean);
  if (!requested.length) throw new Refused("WIPE_SCHEMA_NOT_ALLOWED", "empty --schemas");
  const outside = requested.filter((s) => !WIPE_SCHEMAS.includes(s) || isProtectedSchema(s));
  if (outside.length) throw new Refused("WIPE_SCHEMA_NOT_ALLOWED", outside.join(","));
  return WIPE_SCHEMAS.filter((s) => requested.includes(s)); // canonical order: domain, knowledge, Mission Control last
}

export const parseNames = (value) => (value ? String(value).split(",").map((s) => s.trim()).filter(Boolean) : []);

// ------------------------------------------------------------------------------------------------- sessions (F4)
// Supabase platform sessions are not application traffic; everything else is.
export const PLATFORM_ROLES = Object.freeze([
  "authenticator", "dashboard_user", "supabase_admin", "supabase_auth_admin", "supabase_storage_admin", "supabase_realtime_admin",
  "pgbouncer", "supabase_replication_admin", "supabase_read_only_user",
]);
const PLATFORM_POSTGRES_APPS = /supabase.?studio|^studio|pg.?meta|postgres.?meta|postgrest/i;
export function isPlatformSession(s) {
  return PLATFORM_ROLES.includes(s.usename ?? "") || (s.usename === "postgres" && PLATFORM_POSTGRES_APPS.test(s.application_name ?? ""));
}

// Every other client session on the database (never the query text). Background workers such as autovacuum carry
// a NULL usename and are not sessions, so they are filtered by backend_type.
export async function listSessions(client) {
  return (await client.query(`select pid, usename, application_name, state, backend_type, backend_start::text as backend_start
     from pg_stat_activity where datname = current_database() and pid <> pg_backend_pid() and backend_type = 'client backend'
     order by pid`)).rows
    .map((r) => ({ ...r, platform: isPlatformSession(r) }));
}

// ------------------------------------------------------------------------------------------------- plan (F1)
export const DRY_RUN_MAX_AGE_MS = 2 * 3600 * 1000;
export const DRY_RUN_LOCK_TIMEOUT_MS = 5_000;
const sorted = (xs) => [...(xs ?? [])].map((x) => (typeof x === "string" ? x : JSON.stringify(x))).sort();

// Digest of what a wipe would remove: per step its objects (relation sets, counts by kind, owner, unexpected
// relations, cascade dependents), public manifest/extra sets, ledger versions and graph counts. Row counts of
// PostgreSQL tables, sessions and timestamps are deliberately out: they are reported, not bound.
export function inventoryDigest(steps) {
  const norm = steps.map((s) => ({
    step: s.step, status: s.status, owner: s.owner ?? null, counts: s.counts ?? null, relations: sorted(s.relations),
    unexpectedRelations: sorted(s.unexpectedRelations), cascadedOutside: sorted(s.cascadedOutside),
    manifestMatched: s.manifestMatched ?? null,
    extra: s.extra ? { relations: sorted(s.extra.relations?.map((r) => `${r.kind}:${r.name}`)), functions: sorted(s.extra.functions), types: sorted(s.extra.types) } : null,
    storageNamed: sorted(s.storageNamed), versions: sorted(s.versions),
    graph: s.step === "graph" ? { host: normalizeHost(s.host), nodes: s.nodesBefore ?? null, relationships: s.relationshipsBefore ?? null, labels: s.labels ?? null, markers: sorted(s.markersBefore) } : null,
  }));
  return `sha256:${createHash("sha256").update(JSON.stringify(norm)).digest("hex")}`;
}

// `--from-dry-run`: a clean dry-run of the same target and flags, under 2 h old. Its digest is compared with the real
// run's own internal pre-check after this call.
export const normalizeHost = (host) => (host ? String(host).trim().toLowerCase().replace(/\.$/, "") : null);
// Flags compare order-insensitively: keys sorted, list values sorted.
export const normalizeFlags = (flags) => Object.fromEntries(Object.keys(flags ?? {}).sort().map((k) => [k, Array.isArray(flags[k]) ? [...flags[k]].sort() : flags[k]]));

export function checkDryRunReceipt(path, { target, flags, requestedSchemas, format, graphHost = null }, now = Date.now()) {
  if (!path) throw new Refused("WIPE_DRY_RUN_REQUIRED", "a real wipe needs --from-dry-run <clean dry-run receipt.json>");
  let receipt;
  try { receipt = JSON.parse(readFileSync(path, "utf8")); } catch { throw new Refused("WIPE_DRY_RUN_REQUIRED", `cannot read ${path}`); }
  if (receipt.format !== format || receipt.dryRun !== true) throw new Refused("WIPE_DRY_RUN_MISMATCH", "not a dry-run receipt of this installer");
  if (receipt.status !== "dry-run-clear" || (receipt.blockers ?? []).length) throw new Refused("WIPE_DRY_RUN_BLOCKED", `the dry-run reported ${(receipt.blockers ?? []).length} blocker(s): status ${receipt.status}`);
  const at = Date.parse(receipt.finishedAt ?? "");
  if (Number.isNaN(at) || now - at > DRY_RUN_MAX_AGE_MS || at - now > 5 * 60 * 1000) throw new Refused("WIPE_DRY_RUN_STALE", "the dry-run receipt is older than 2 h (or undated)");
  const same = receipt.target?.project_ref === target.project_ref && receipt.target?.installation_id === target.installation_id
    && receipt.target?.target_file === target.path;
  if (!same) throw new Refused("WIPE_DRY_RUN_MISMATCH", "the dry-run receipt is for another target or installation");
  if (normalizeHost(receipt.graphHost) !== normalizeHost(graphHost)) throw new Refused("WIPE_DRY_RUN_MISMATCH", "the dry-run was for another graph host");
  if (JSON.stringify(normalizeFlags(receipt.flags)) !== JSON.stringify(normalizeFlags(flags))
    || JSON.stringify([...(receipt.requestedSchemas ?? [])].sort()) !== JSON.stringify([...requestedSchemas].sort())) {
    throw new Refused("WIPE_DRY_RUN_MISMATCH", "the dry-run used different flags or schemas");
  }
  if (!/^sha256:[0-9a-f]{64}$/.test(receipt.inventoryDigest ?? "")) throw new Refused("WIPE_DRY_RUN_MISMATCH", "the dry-run receipt has no inventory digest");
  return { file: resolve(path), finishedAt: receipt.finishedAt, inventoryDigest: receipt.inventoryDigest };
}

// ------------------------------------------------------------------------------------------------- catalog diff
// Everything outside `$1` (schema names) that a cascade could remove. Non-schema objects carry schema ''.
export const OUTSIDE_OBJECTS = `
  select n.nspname::text as schema, case c.relkind when 'v' then 'view' when 'S' then 'sequence' when 'm' then 'materialized_view'
         when 'f' then 'foreign_table' when 'c' then 'composite_type' else 'table' end::text as kind, c.relname::text as name
    from pg_class c join pg_namespace n on n.oid = c.relnamespace
   where not n.nspname = any($1) and c.relkind in ('r','p','v','m','S','f','c')
  union all
  select n.nspname, 'column', c.relname || '.' || a.attname from pg_attribute a
    join pg_class c on c.oid = a.attrelid join pg_namespace n on n.oid = c.relnamespace
   where not n.nspname = any($1) and c.relkind in ('r','p','f','c') and a.attnum > 0 and not a.attisdropped
  union all
  select n.nspname, 'function', p.proname || '(' || pg_get_function_identity_arguments(p.oid) || ')'
    from pg_proc p join pg_namespace n on n.oid = p.pronamespace where not n.nspname = any($1)
  union all
  select n.nspname, 'type', t.typname from pg_type t join pg_namespace n on n.oid = t.typnamespace
   where not n.nspname = any($1) and t.typrelid = 0 and t.typelem = 0
  union all
  select n.nspname, 'domain_constraint', con.conname || ' on ' || t.typname from pg_constraint con
    join pg_type t on t.oid = con.contypid join pg_namespace n on n.oid = t.typnamespace where not n.nspname = any($1)
  union all
  select n.nspname, 'policy', pol.polname || ' on ' || c.relname from pg_policy pol
    join pg_class c on c.oid = pol.polrelid join pg_namespace n on n.oid = c.relnamespace where not n.nspname = any($1)
  union all
  select n.nspname, 'trigger', tg.tgname || ' on ' || c.relname from pg_trigger tg
    join pg_class c on c.oid = tg.tgrelid join pg_namespace n on n.oid = c.relnamespace
   where not n.nspname = any($1) and not tg.tgisinternal
  union all
  select n.nspname, 'constraint', con.conname || ' on ' || c.relname from pg_constraint con
    join pg_class c on c.oid = con.conrelid join pg_namespace n on n.oid = c.relnamespace where not n.nspname = any($1)
  union all
  select n.nspname, 'extension', e.extname from pg_extension e join pg_namespace n on n.oid = e.extnamespace
   where not n.nspname = any($1)
  union all
  select n.nspname, 'operator', o.oprname || '(' || o.oprleft::regtype::text || ',' || o.oprright::regtype::text || ')' from pg_operator o
    join pg_namespace n on n.oid = o.oprnamespace where not n.nspname = any($1) and o.oid >= 16384
  union all
  select n.nspname, 'operator_class', oc.opcname || ' ' || am.amname from pg_opclass oc join pg_am am on am.oid = oc.opcmethod
    join pg_namespace n on n.oid = oc.opcnamespace where not n.nspname = any($1) and oc.oid >= 16384
  union all
  select n.nspname, 'operator_family', f.opfname || ' ' || am.amname from pg_opfamily f join pg_am am on am.oid = f.opfmethod
    join pg_namespace n on n.oid = f.opfnamespace where not n.nspname = any($1) and f.oid >= 16384
  union all
  select '', 'cast', c.castsource::regtype::text || '->' || c.casttarget::regtype::text from pg_cast c where c.oid >= 16384
  union all
  select n.nspname, 'index', ci.relname || ' on ' || ct.relname from pg_index i join pg_class ci on ci.oid = i.indexrelid
    join pg_class ct on ct.oid = i.indrelid join pg_namespace n on n.oid = ci.relnamespace
   where not n.nspname = any($1) and left(n.nspname, 8) <> 'pg_toast' -- TOAST indexes go with their tables
  union all
  select n.nspname, 'column_default', c.relname || '.' || a.attname from pg_attrdef d join pg_class c on c.oid = d.adrelid
    join pg_attribute a on a.attrelid = d.adrelid and a.attnum = d.adnum join pg_namespace n on n.oid = c.relnamespace
   where not n.nspname = any($1)
  union all
  select n.nspname, 'rule', r.rulename || ' on ' || c.relname from pg_rewrite r join pg_class c on c.oid = r.ev_class
    join pg_namespace n on n.oid = c.relnamespace where not n.nspname = any($1) and r.rulename <> '_RETURN'
  union all
  select n.nspname, 'statistics', st.stxname || ' on ' || c.relname from pg_statistic_ext st join pg_class c on c.oid = st.stxrelid
    join pg_namespace n on n.oid = st.stxnamespace where not n.nspname = any($1)
  union all
  select '', 'event_trigger', evtname from pg_event_trigger
  union all
  select '', 'publication', pubname from pg_publication
  union all
  select n.nspname, 'publication_member', p.pubname || ' on ' || c.relname from pg_publication_rel pr
    join pg_publication p on p.oid = pr.prpubid join pg_class c on c.oid = pr.prrelid join pg_namespace n on n.oid = c.relnamespace
   where not n.nspname = any($1)
  union all
  select coalesce(n.nspname, ''), 'default_acl', d.defaclrole::regrole::text || ':' || d.defaclobjtype::text || ':' || d.defaclacl::text
    from pg_default_acl d left join pg_namespace n on n.oid = d.defaclnamespace where n.nspname is null or not n.nspname = any($1)`;

const key = (o) => `${o.kind}\u0000${o.schema}\u0000${o.name}`;
const onTable = (o) => (/ on (.+)$/.exec(o.name)?.[1] ?? null);
const columnTable = (o) => (["column", "column_default"].includes(o.kind) ? o.name.split(".")[0] : null);
// Objects that live on one table and go with it ("<name> on <table>").
const TABLE_DEPENDENT_KINDS = ["constraint", "trigger", "policy", "publication_member", "index", "rule", "statistics"];

// `owned`: per schema, what the current step drops on purpose ({ relations, functions, types: Set; named:
// Set("<kind>\u0000<name>") }) and `parents` (relations whose own policies/triggers/constraints/publication membership
// may go with them, e.g. the manifest's public tables). Anything else outside the step blocks, whatever its kind (F2):
// a kept extra view, or a trigger on a kept table calling a dropped function, is never removed by CASCADE.
export function cascadeVerdict(removed, owned = {}) {
  const isOwned = (o) => {
    const own = owned[o.schema];
    if (!own) return false;
    const relations = own.relations ?? new Set();
    if (["table", "view", "materialized_view", "sequence", "foreign_table", "composite_type"].includes(o.kind)) return relations.has(o.name);
    if (o.kind === "column" || o.kind === "column_default") return relations.has(columnTable(o));
    if (TABLE_DEPENDENT_KINDS.includes(o.kind)) {
      return relations.has(onTable(o)) || (own.named ?? new Set()).has(`${o.kind}\u0000${o.name}`);
    }
    if (o.kind === "function") return (own.functions ?? new Set()).has(o.name);
    if (o.kind === "type") return (own.types ?? new Set()).has(o.name);
    if (o.kind === "domain_constraint") return (own.types ?? new Set()).has(onTable(o));
    return false;
  };
  const onParent = (o) => TABLE_DEPENDENT_KINDS.includes(o.kind) && Boolean(owned[o.schema]?.parents?.has(onTable(o)));
  const expected = removed.filter(isOwned);
  const rest = removed.filter((o) => !isOwned(o));
  const recorded = rest.filter(onParent);
  return { forbidden: rest.filter((o) => !onParent(o)), recorded, expected: expected.length };
}

async function inSchemaInventory(client, schema) {
  const rels = (await client.query(`select c.relname as name, case c.relkind when 'r' then 'table' when 'p' then 'table' when 'v' then 'view'
      when 'm' then 'materialized_view' when 'S' then 'sequence' when 'f' then 'foreign_table' when 'c' then 'composite_type' when 'i' then 'index' when 'I' then 'index' else c.relkind::text end as kind,
      coalesce(s.n_live_tup, 0)::bigint as rows
    from pg_class c join pg_namespace n on n.oid = c.relnamespace left join pg_stat_user_tables s on s.relid = c.oid
   where n.nspname = $1 order by 2, 1`, [schema])).rows;
  const functions = (await client.query("select count(*)::int as n from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname = $1", [schema])).rows[0].n;
  const types = (await client.query("select count(*)::int as n from pg_type t join pg_namespace n on n.oid = t.typnamespace where n.nspname = $1 and t.typrelid = 0 and t.typelem = 0", [schema])).rows[0].n;
  const counts = {};
  for (const r of rels) counts[r.kind] = (counts[r.kind] ?? 0) + 1;
  return {
    counts: { ...counts, function: functions, type: types },
    relations: rels.filter((r) => r.kind !== "index").map((r) => r.name),
    estimatedRows: rels.reduce((n, r) => n + Number(r.rows), 0),
  };
}

// One step = one transaction: check, drop, diff, then commit (or roll back on dry-run / refusal).
async function runStep(client, step, { dryRun, lockTimeoutMs, statementTimeoutMs, outsideOf, owned, check, drop }) {
  await client.query("begin");
  try {
    await client.query(`set local lock_timeout = ${Number(lockTimeoutMs)}`);
    await client.query(`set local statement_timeout = ${Number(statementTimeoutMs)}`);
    const pre = await check();
    if (pre.status === "absent") { await client.query("rollback"); return { step, status: "absent" }; }
    const before = (await client.query(OUTSIDE_OBJECTS, [outsideOf])).rows;
    const dropped = await drop();
    const after = new Set((await client.query(OUTSIDE_OBJECTS, [outsideOf])).rows.map(key));
    const { forbidden, recorded, expected } = cascadeVerdict(before.filter((o) => !after.has(key(o))), typeof owned === "function" ? owned() : owned);
    const blockers = [...(pre.blockers ?? [])];
    if (forbidden.length) blockers.push({ code: "WIPE_CASCADE_OUTSIDE_ALLOW_LIST", objects: forbidden.slice(0, 50).map((o) => `${o.kind} ${o.schema ? `${o.schema}.` : ""}${o.name}`), total: forbidden.length });
    const result = { step, status: dryRun ? "would-drop" : "dropped", ...pre.inventory, ...dropped, cascadedOutside: recorded, expectedOutsideRemovals: expected, blockers };
    if (dryRun || blockers.length) {
      await client.query("rollback");
      if (!dryRun) {
        const first = blockers[0];
        throw new Refused(first.code, `${step}: ${first.objects?.join(", ") ?? first.detail}`);
      }
      return result;
    }
    await client.query("commit");
    return result;
  } catch (error) {
    try { await client.query("rollback"); } catch { /* connection gone; the transaction did not commit */ }
    if (error instanceof Refused) throw error;
    if (error?.code === "55P03") throw new Refused("WIPE_LOCK_TIMEOUT", `${step}: stop the services holding locks, then rerun`);
    throw new Error(`${step} failed (SQLSTATE ${error?.code ?? "?"})`);
  }
}

function schemaStep(client, schema, { expectedOwner, manifest, allowExtraRelations, owned, options }) {
  if (!WIPE_SCHEMAS.includes(schema) || isProtectedSchema(schema) || !IDENT.test(schema)) throw new Refused("WIPE_SCHEMA_NOT_ALLOWED", schema);
  return runStep(client, `schema:${schema}`, {
    ...options,
    outsideOf: WIPE_SCHEMAS,
    owned: owned ?? manifestParents(manifest),
    check: async () => {
      const row = (await client.query("select pg_get_userbyid(nspowner) as owner from pg_namespace where nspname = $1", [schema])).rows[0];
      if (!row) return { status: "absent" };
      const inventory = await inSchemaInventory(client, schema);
      const blockers = [];
      if (row.owner !== expectedOwner) blockers.push({ code: "WIPE_SCHEMA_OWNER_UNEXPECTED", detail: `owner ${row.owner}, expected ${expectedOwner}` });
      let unexpected = [];
      if (manifest && MANIFEST_SCHEMAS.includes(schema)) {
        const known = new Set(manifest.schemas[schema]?.relations ?? []);
        unexpected = inventory.relations.filter((r) => !known.has(r) && !allowExtraRelations.has(`${schema}.${r}`));
        if (unexpected.length) blockers.push({ code: "WIPE_UNEXPECTED_RELATION", objects: unexpected.map((r) => `${schema}.${r}`), total: unexpected.length });
      }
      return { status: "present", inventory: { schema, owner: row.owner, ...inventory, unexpectedRelations: unexpected }, blockers };
    },
    drop: async () => { await client.query(`drop schema if exists "${schema}" cascade`); return {}; },
  });
}

// Policies/triggers/constraints on the manifest's public tables may go with a domain schema they depend on.
const manifestParents = (manifest) => (manifest ? { public: { parents: new Set(manifest.public.relations.map((r) => r.name)) } } : {});

// Everything the public step of a full plan removes: the manifest's public objects, the extras named in
// --drop-public-extra, and the manifest's storage/auth triggers and policies (by name).
export function plannedOutside(manifest, dropExtra = new Set()) {
  const extra = [...dropExtra];
  const named = new Set([
    ...(manifest.storage.triggers ?? []).map((o) => `trigger\u0000${o.name} on ${o.table}`),
    ...(manifest.storage.policies ?? []).map((o) => `policy\u0000${o.name} on ${o.table}`),
  ]);
  return {
    public: {
      relations: new Set([...manifest.public.relations.map((r) => r.name), ...extra]),
      functions: new Set([...manifest.public.functions, ...extra]),
      types: new Set([...manifest.public.types, ...extra]),
      named: new Set(),
    },
    storage: { named },
    auth: { named },
  };
}

// `public` and `storage.objects` objects the repository's migrations create (install-manifest.json), plus extras the
// operator named. Never the schema, extension-owned objects, buckets or stored objects.
export async function publicInventory(client, manifest) {
  const rels = (await client.query(`select c.relname as name, case c.relkind when 'v' then 'view' when 'm' then 'materialized_view' when 'S' then 'sequence'
      when 'f' then 'foreign_table' when 'c' then 'composite_type' else 'table' end as kind, coalesce(s.n_live_tup, 0)::bigint as rows,
      exists(select 1 from pg_depend d where d.classid = 'pg_class'::regclass and d.objid = c.oid and d.deptype = 'e') as extension_owned
    from pg_class c join pg_namespace n on n.oid = c.relnamespace left join pg_stat_user_tables s on s.relid = c.oid
   where n.nspname = 'public' and c.relkind in ('r','p','v','m','S','f','c') order by 1`)).rows;
  const functions = (await client.query(`select p.proname || '(' || pg_get_function_identity_arguments(p.oid) || ')' as name,
      exists(select 1 from pg_depend d where d.classid = 'pg_proc'::regclass and d.objid = p.oid and d.deptype = 'e') as extension_owned
    from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname = 'public' order by 1`)).rows;
  const types = (await client.query(`select t.typname as name,
      exists(select 1 from pg_depend d where d.classid = 'pg_type'::regclass and d.objid = t.oid and d.deptype = 'e') as extension_owned
    from pg_type t join pg_namespace n on n.oid = t.typnamespace where n.nspname = 'public' and t.typrelid = 0 and t.typelem = 0 order by 1`)).rows;
  for (const r of rels.filter((x) => ["table", "materialized_view"].includes(x.kind) && !x.extension_owned)) {
    r.exact_rows = Number((await client.query(`select count(*)::bigint as n from public."${r.name.replaceAll('"', '""')}"`)).rows[0].n);
  }
  const m = manifest.public;
  const relSet = new Set(m.relations.map((r) => r.name));
  const fnSet = new Set(m.functions);
  const typeSet = new Set(m.types);
  const split = (rows, set) => ({
    manifest: rows.filter((r) => set.has(r.name) && !r.extension_owned),
    extra: rows.filter((r) => !set.has(r.name) && !r.extension_owned),
    extensionOwnedInManifest: rows.filter((r) => set.has(r.name) && r.extension_owned).map((r) => r.name),
  });
  const storageNamed = [];
  for (const [kind, list] of [["trigger", "triggers"], ["policy", "policies"]]) {
    for (const o of manifest.storage[list] ?? []) {
      const present = kind === "trigger"
        ? (await client.query("select 1 from pg_trigger tg join pg_class c on c.oid = tg.tgrelid join pg_namespace n on n.oid = c.relnamespace where n.nspname = $1 and c.relname = $2 and tg.tgname = $3", [o.schema, o.table, o.name])).rowCount
        : (await client.query("select 1 from pg_policy p join pg_class c on c.oid = p.polrelid join pg_namespace n on n.oid = c.relnamespace where n.nspname = $1 and c.relname = $2 and p.polname = $3", [o.schema, o.table, o.name])).rowCount;
      if (present) storageNamed.push({ kind, ...o });
    }
  }
  let orphaned = [];
  if ((await client.query("select to_regclass('storage.objects') is not null as ok")).rows[0].ok) {
    orphaned = (await client.query("select bucket_id, count(*)::bigint as objects from storage.objects where bucket_id = any($1) group by 1 order by 1", [manifest.storage.buckets])).rows
      .map((r) => ({ bucket: r.bucket_id, objects: Number(r.objects) }));
  }
  return { relations: split(rels, relSet), functions: split(functions, fnSet), types: split(types, typeSet), storageNamed, orphanedStorageObjects: orphaned };
}

function publicStep(client, manifest, { dropExtra, keepExtra, options }) {
  return runStep(client, "public", {
    ...options,
    outsideOf: WIPE_SCHEMAS,
    owned: () => {
      const plan = this_plan.get(client);
      const named = new Set(plan.storage.map((o) => `${o.kind}\u0000${o.name} on ${o.table}`));
      return {
        public: { relations: new Set(plan.relations.map((r) => r.name)), functions: new Set(plan.functions.map((f) => f.name)), types: new Set(plan.types.map((t) => t.name)), named: new Set() },
        storage: { relations: new Set(), functions: new Set(), types: new Set(), named },
        auth: { relations: new Set(), functions: new Set(), types: new Set(), named },
      };
    },
    check: async () => {
      const inv = await publicInventory(client, manifest);
      const extras = [...inv.relations.extra.map((r) => r.name), ...inv.functions.extra.map((r) => r.name), ...inv.types.extra.map((r) => r.name)];
      const undecided = extras.filter((n) => !dropExtra.has(n) && !keepExtra.has(n));
      const blockers = [];
      if (undecided.length) blockers.push({ code: "WIPE_PUBLIC_EXTRA", objects: undecided.map((n) => `public.${n}`), total: undecided.length });
      const extOwned = [...inv.relations.extensionOwnedInManifest, ...inv.functions.extensionOwnedInManifest, ...inv.types.extensionOwnedInManifest];
      if (extOwned.length) blockers.push({ code: "WIPE_EXTENSION_OBJECT", objects: extOwned.map((n) => `public.${n}`), total: extOwned.length });
      const pick = (group) => [...group.manifest, ...group.extra.filter((r) => dropExtra.has(r.name))];
      const plan = { relations: pick(inv.relations), functions: pick(inv.functions), types: pick(inv.types), storage: inv.storageNamed };
      this_plan.set(client, plan);
      return {
        status: "present",
        blockers,
        inventory: {
          manifestMatched: { relations: inv.relations.manifest.length, functions: inv.functions.manifest.length, types: inv.types.manifest.length, storageTriggersPolicies: inv.storageNamed.length },
          exactRows: inv.relations.manifest.reduce((n, r) => n + (r.exact_rows ?? 0), 0),
          rowCounts: Object.fromEntries(inv.relations.manifest.filter((r) => r.exact_rows !== undefined).map((r) => [r.name, r.exact_rows])),
          extra: { relations: inv.relations.extra.map((r) => ({ name: r.name, kind: r.kind, rows: r.exact_rows ?? null })), functions: inv.functions.extra.map((r) => r.name), types: inv.types.extra.map((r) => r.name) },
          dropExtra: [...dropExtra], keepExtra: [...keepExtra],
          storageNamed: inv.storageNamed.map((o) => `${o.kind} ${o.name} on ${o.schema}.${o.table}`),
          orphanedStorageObjects: inv.orphanedStorageObjects,
        },
      };
    },
    drop: async () => {
      const plan = this_plan.get(client);
      for (const o of plan.storage) {
        await client.query(`drop ${o.kind} if exists "${o.name}" on "${o.schema}"."${o.table}"`);
      }
      const order = ["view", "materialized_view", "table", "foreign_table", "sequence", "composite_type"];
      const rels = [...plan.relations].sort((a, b) => order.indexOf(a.kind) - order.indexOf(b.kind));
      for (const r of rels) {
        const ddl = { view: "view", materialized_view: "materialized view", table: "table", foreign_table: "foreign table", sequence: "sequence", composite_type: "type" }[r.kind];
        await client.query(`drop ${ddl} if exists public."${r.name}" cascade`);
      }
      for (const f of plan.functions) {
        const exists = (await client.query("select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname = 'public' and p.proname || '(' || pg_get_function_identity_arguments(p.oid) || ')' = $1", [f.name])).rowCount;
        if (exists) await client.query(`drop function public.${f.name.replace(/^([^(]+)/, '"$1"')} cascade`);
      }
      for (const t of plan.types) await client.query(`drop type if exists public."${t.name}" cascade`);
      return { dropped: { relations: rels.length, functions: plan.functions.length, types: plan.types.length, storageTriggersPolicies: plan.storage.length } };
    },
  }).then((r) => {
    this_plan.delete(client);
    const n = r.dropped ? r.dropped.relations + r.dropped.functions + r.dropped.types + r.dropped.storageTriggersPolicies : null;
    if (n === 0) r.status = "empty"; // nothing of the manifest (or named extras) left: a rerun after a completed wipe
    return r;
  });
}
const this_plan = new WeakMap();

// The Supabase CLI ledger is the disposable project's history: a fresh install starts from an empty one.
async function ledgerStep(client, { dryRun }) {
  const exists = (await client.query("select to_regclass('supabase_migrations.schema_migrations') is not null as ok")).rows[0].ok;
  if (!exists) return { step: "migration-ledger", status: "absent", versions: [] };
  await client.query("begin");
  try {
    const versions = (await client.query("select version from supabase_migrations.schema_migrations order by version")).rows.map((r) => r.version);
    await client.query("delete from supabase_migrations.schema_migrations");
    await client.query(dryRun ? "rollback" : "commit");
    return { step: "migration-ledger", status: dryRun ? "would-delete" : versions.length ? "deleted" : "empty", rows: versions.length, versions };
  } catch (error) {
    try { await client.query("rollback"); } catch { /* ignore */ }
    throw new Error(`migration-ledger failed (SQLSTATE ${error?.code ?? "?"})`);
  }
}

// Ordered wipe: public objects → domain schemas → ledger → knowledge → Mission Control (last). `onStep` journals
// each step before (`start`) and after (`done`); `results` accumulates so a failure still reports what finished.
export async function wipePostgres(client, {
  schemas, manifest, expectedOwner, dryRun = false, dropExtra = new Set(), keepExtra = new Set(), allowExtraRelations = new Set(),
  lockTimeoutMs = 15_000, statementTimeoutMs = 600_000, onStep = () => {}, results = [],
}) {
  // Dry-runs (and the real run's internal pre-check) wait at most 5 s for a lock.
  const options = { dryRun, lockTimeoutMs: dryRun ? DRY_RUN_LOCK_TIMEOUT_MS : lockTimeoutMs, statementTimeoutMs };
  const domain = schemas.filter((s) => DOMAIN_SCHEMAS.includes(s));
  const fullDomain = domain.length === DOMAIN_SCHEMAS.length;
  const run = async (name, fn) => {
    onStep({ event: "start", step: name });
    const r = await fn();
    results.push(r);
    onStep({ event: "done", step: name, status: r.status, blockers: r.blockers?.length ?? 0 });
    return r;
  };
  // With the public step in the plan, later steps may see what it removes: a real run has already removed it, and a
  // dry-run (each step rolled back) must judge each step against the same sequence. Kept extras are never owned.
  const owned = fullDomain ? plannedOutside(manifest, dropExtra) : undefined;
  if (fullDomain) await run("public", () => publicStep(client, manifest, { dropExtra, keepExtra, options }));
  for (const s of domain) await run(`schema:${s}`, () => schemaStep(client, s, { expectedOwner, manifest, allowExtraRelations, owned, options }));
  if (fullDomain) await run("migration-ledger", () => ledgerStep(client, { dryRun }));
  for (const s of schemas.filter((x) => !DOMAIN_SCHEMAS.includes(x))) await run(`schema:${s}`, () => schemaStep(client, s, { expectedOwner, manifest, allowExtraRelations, owned, options }));
  return results;
}

// ------------------------------------------------------------------------------------------------- evidence
export function assertIgnored(repository, dir) {
  const r = spawnSync("git", ["-C", repository, "check-ignore", "-q", join(resolve(dir), "wipe-receipt.json")], { encoding: "utf8", windowsHide: true });
  if (r.status !== 0) throw new Refused("EVIDENCE_DIR_NOT_IGNORED", `${dir} is not ignored by ${repository}'s git (receipts never enter commits)`);
}

export function defaultActor() {
  let user = "unknown";
  try { user = userInfo().username; } catch { /* no passwd entry */ }
  return `${user}@${hostname()}`;
}

export function receiptStem(dir, kind, ref, startedAt) {
  mkdirSync(dir, { recursive: true });
  // Millisecond stamp plus a random tag, so two runs in one second never overwrite each other's receipt.
  return join(dir, `${kind}-${ref}-${startedAt.replace(/[-:]/g, "")}-${randomBytes(2).toString("hex")}`);
}

export function writeJson(path, body) {
  writeFileSync(path, `${JSON.stringify(body, null, 2)}\n`);
  return path;
}

export function publicTarget(target) {
  return {
    app: target.app, project_label: target.project_label, project_ref: target.project_ref, installation_id: target.installation_id,
    environment: target.environment, database_host: target.database_host, database_port: target.database_port,
    database_name: target.database_name, database_user: target.database_user, target_file: target.path,
  };
}

// Short human summary of a wipe or dry-run receipt (also written next to it as .txt).
export function summarize(receipt) {
  const lines = [];
  lines.push(`${receipt.dryRun ? "DRY RUN" : "WIPE"} ${receipt.target.app} ${receipt.target.project_ref}:${receipt.target.installation_id} (${receipt.target.project_label}) status=${receipt.status}`);
  lines.push(`identity: ${receipt.identity?.status ?? "not established"}${receipt.identity?.legacyMissionControl ? ` (legacy MC at ${receipt.identity.legacyMissionControl})` : ""}${receipt.identity?.evidence ? ` evidence system_identifier ${receipt.identity.evidence.system_identifier}` : ""}`);
  if (receipt.dryRun || receipt.preCheck) lines.push(`lock_timeout: ${DRY_RUN_LOCK_TIMEOUT_MS / 1000} s for every dry-run step${receipt.dryRun ? "" : " (internal pre-check)"}; inventory digest ${receipt.inventoryDigest ?? receipt.preCheck?.inventoryDigest ?? "-"}`);
  const sessions = receipt.sessions ?? [];
  lines.push(`sessions: ${sessions.length} other (${sessions.filter((s) => !s.platform).length} application)`);
  for (const x of sessions) lines.push(`  ${x.platform ? "platform" : "APPLICATION"} pid ${x.pid} ${x.usename ?? "?"} app=${x.application_name || "-"} state=${x.state ?? "-"} since ${x.backend_start ?? "-"}`);
  for (const s of receipt.steps ?? []) {
    if (s.step === "public") {
      lines.push(`public: manifest ${JSON.stringify(s.manifestMatched ?? {})} rows ${s.exactRows ?? "-"}, extra relations ${JSON.stringify(s.extra?.relations ?? [])}, functions ${JSON.stringify(s.extra?.functions ?? [])}, types ${JSON.stringify(s.extra?.types ?? [])}; storage orphaned ${JSON.stringify(s.orphanedStorageObjects ?? [])}`);
    } else if (s.step === "migration-ledger") {
      lines.push(`ledger: ${s.status} ${s.rows ?? 0} rows`);
    } else if (s.step === "graph") {
      lines.push(`graph ${s.host ?? ""}: ${s.status} nodes ${s.nodesBefore ?? 0} markers ${JSON.stringify(s.markersBefore ?? [])} labels ${JSON.stringify(s.labels ?? {})}`);
    } else {
      lines.push(`${s.step}: ${s.status}${s.counts ? ` ${JSON.stringify(s.counts)} rows~${s.estimatedRows}` : ""}${s.cascadedOutside?.length ? ` cascades ${s.cascadedOutside.length}` : ""}`);
    }
    for (const b of s.blockers ?? []) lines.push(`  BLOCKER ${b.code}: ${b.objects ? `${b.objects.slice(0, 12).join(", ")}${b.total > 12 ? ` … (${b.total})` : ""}` : b.detail}`);
  }
  if (receipt.error) lines.push(`error: ${receipt.error.code ?? ""} ${receipt.error.message}`);
  if (receipt.failedStep) lines.push(`failed step: ${receipt.failedStep}`);
  return `${lines.join("\n")}\n`;
}
