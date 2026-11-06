#!/usr/bin/env node
// Pinned wipe manifest (scripts/install-manifest.json): every object this repository's migration chain creates outside
// the wiped schemas (`public` relations/functions/types, `storage`/`auth` triggers and policies, bucket ids) and the
// relation names it creates inside each AI Engineer schema. Derived, never hand-written: on a throwaway loopback
// PostgreSQL database with the local Supabase stub (scripts/supabase-stub/), it snapshots the catalog after the stub
// and the pinned KS component, replays the whole chain with `supabase migration up --db-url`, and diffs.
//
//   node scripts/install-manifest.mjs --admin-dsn-env <NAME> [--container <name>]            regenerate install-manifest.json
//   node scripts/install-manifest.mjs --admin-dsn-env <NAME> [--container <name>] --check    exit 1 if the pinned file is stale
// The admin DSN must be loopback and published by the named local container (--container or INSTALL_WIPE_PG_CONTAINER);
// the stub's roles and extension files are installed for the run and removed afterwards (see openStubCluster).
import { spawnSync } from "node:child_process";
import { createHash, randomUUID } from "node:crypto";
import { existsSync, readFileSync, readdirSync, writeFileSync } from "node:fs";
import { createRequire } from "node:module";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const repository = resolve(dirname(fileURLToPath(import.meta.url)), "..");
export const MANIFEST_PATH = join(repository, "scripts", "install-manifest.json");
const STUB = join(repository, "scripts", "supabase-stub", "prerequisites.sql");
const sha256 = (b) => createHash("sha256").update(b).digest("hex");

export function migrationsDigest(root = repository) {
  const dir = join(root, "supabase", "migrations");
  const files = readdirSync(dir).filter((f) => f.endsWith(".sql")).sort();
  return { files: files.length, head: files.at(-1), sha256: sha256(files.map((f) => `${f}:${sha256(readFileSync(join(dir, f)))}`).join("\n")) };
}

export function loadManifest(path = MANIFEST_PATH) {
  return JSON.parse(readFileSync(path, "utf8"));
}

// Normalized catalog (no OIDs) of every non-system schema, plus cluster objects the chain can touch.
export async function catalogSnapshot(client) {
  const q = async (sql) => (await client.query(sql)).rows;
  const ns = "n.nspname not like 'pg\\_%' and n.nspname <> 'information_schema'";
  return {
    schemas: await q(`select n.nspname as name, pg_get_userbyid(n.nspowner) as owner, coalesce(n.nspacl::text, '') as acl from pg_namespace n where ${ns} order by 1`),
    relations: await q(`select n.nspname as schema, c.relname as name, c.relkind as kind, pg_get_userbyid(c.relowner) as owner,
        c.relrowsecurity as rls, c.relforcerowsecurity as force_rls, coalesce(c.relacl::text, '') as acl, coalesce(obj_description(c.oid, 'pg_class'), '') as comment
      from pg_class c join pg_namespace n on n.oid = c.relnamespace where ${ns} and c.relkind in ('r','p','v','m','S','f','c') order by 1, 2`),
    columns: await q(`select n.nspname as schema, c.relname as rel, a.attname as name, format_type(a.atttypid, a.atttypmod) as type, a.attnotnull as notnull,
        coalesce(pg_get_expr(d.adbin, d.adrelid), '') as def, a.attgenerated as generated, a.attidentity as identity, coalesce(a.attacl::text, '') as acl
      from pg_attribute a join pg_class c on c.oid = a.attrelid join pg_namespace n on n.oid = c.relnamespace
      left join pg_attrdef d on d.adrelid = a.attrelid and d.adnum = a.attnum
      where ${ns} and c.relkind in ('r','p','v','m','f','c') and a.attnum > 0 and not a.attisdropped order by 1, 2, a.attnum`),
    constraints: await q(`select n.nspname as schema, coalesce(c.relname, t.typname) as rel, con.conname as name, pg_get_constraintdef(con.oid) as def
      from pg_constraint con join pg_namespace n on n.oid = con.connamespace left join pg_class c on c.oid = con.conrelid
      left join pg_type t on t.oid = con.contypid where ${ns} order by 1, 2, 3`),
    indexes: await q(`select n.nspname as schema, c.relname as name, pg_get_indexdef(c.oid) as def from pg_class c join pg_namespace n on n.oid = c.relnamespace
      where ${ns} and c.relkind in ('i','I') order by 1, 2`),
    views: await q(`select n.nspname as schema, c.relname as name, pg_get_viewdef(c.oid) as def from pg_class c join pg_namespace n on n.oid = c.relnamespace
      where ${ns} and c.relkind in ('v','m') order by 1, 2`),
    functions: await q(`select n.nspname as schema, p.proname || '(' || pg_get_function_identity_arguments(p.oid) || ')' as name, p.prokind as kind,
        pg_get_userbyid(p.proowner) as owner, p.prosecdef as secdef,
        md5(case when p.prokind in ('f', 'p') then pg_get_functiondef(p.oid) else p.prosrc || pg_get_function_result(p.oid) end) as def, coalesce(p.proacl::text, '') as acl,
        exists(select 1 from pg_depend d where d.classid = 'pg_proc'::regclass and d.objid = p.oid and d.deptype = 'e') as extension_owned
      from pg_proc p join pg_namespace n on n.oid = p.pronamespace where ${ns} order by 1, 2`),
    types: await q(`select n.nspname as schema, t.typname as name, t.typtype as kind,
        coalesce((select string_agg(e.enumlabel, ',' order by e.enumsortorder) from pg_enum e where e.enumtypid = t.oid), '') as labels,
        exists(select 1 from pg_depend d where d.classid = 'pg_type'::regclass and d.objid = t.oid and d.deptype = 'e') as extension_owned
      from pg_type t join pg_namespace n on n.oid = t.typnamespace where ${ns} and t.typrelid = 0 and t.typelem = 0 order by 1, 2`),
    triggers: await q(`select n.nspname as schema, c.relname as rel, tg.tgname as name, pg_get_triggerdef(tg.oid) as def from pg_trigger tg
      join pg_class c on c.oid = tg.tgrelid join pg_namespace n on n.oid = c.relnamespace where ${ns} and not tg.tgisinternal order by 1, 2, 3`),
    policies: await q(`select schemaname as schema, tablename as rel, policyname as name, permissive, roles::text, cmd, coalesce(qual, '') as qual, coalesce(with_check, '') as with_check
      from pg_policies order by 1, 2, 3`),
    extensions: await q("select e.extname as name, n.nspname as schema, e.extversion as version from pg_extension e join pg_namespace n on n.oid = e.extnamespace order by 1"),
    roles: await q(`select r.rolname as name, r.rolsuper as super, r.rolinherit as inherit, r.rolcreaterole as createrole, r.rolcanlogin as login, r.rolbypassrls as bypassrls,
        array(select g.rolname from pg_auth_members m join pg_roles g on g.oid = m.roleid where m.member = r.oid order by 1)::text as member_of
      from pg_roles r where r.rolname not like 'pg\\_%' order by 1`),
    defaultAcls: await q(`select d.defaclrole::regrole::text as role, coalesce(n.nspname, '') as schema, d.defaclobjtype as objtype, d.defaclacl::text as acl
      from pg_default_acl d left join pg_namespace n on n.oid = d.defaclnamespace order by 1, 2, 3, 4`),
    casts: await q("select c.castsource::regtype::text as source, c.casttarget::regtype::text as target from pg_cast c where c.oid >= 16384 order by 1, 2"),
    eventTriggers: await q("select evtname as name, evtevent as event from pg_event_trigger order by 1"),
    publications: await q("select p.pubname as name, coalesce((select string_agg(pr.prrelid::regclass::text, ',' order by 1) from pg_publication_rel pr where pr.prpubid = p.oid), '') as members from pg_publication p order by 1"),
    buckets: (await client.query("select to_regclass('storage.buckets') is not null as ok")).rows[0].ok ? await q("select id, name, public, coalesce(file_size_limit, 0)::bigint as limit from storage.buckets order by 1") : [],
    ledger: (await client.query("select to_regclass('supabase_migrations.schema_migrations') is not null as ok")).rows[0].ok ? await q("select version from supabase_migrations.schema_migrations order by 1") : [],
  };
}

const created = (before, after, keyOf) => {
  const seen = new Set(before.map(keyOf));
  return after.filter((x) => !seen.has(keyOf(x)));
};

export function deriveManifest(before, after, digest) {
  const relKind = { r: "table", p: "table", v: "view", m: "materialized_view", S: "sequence", f: "foreign_table", c: "composite_type" };
  const newRels = created(before.relations, after.relations, (r) => `${r.schema}.${r.name}`);
  // supabase_migrations is the CLI's ledger schema, not an application schema.
  const newSchemas = created(before.schemas, after.schemas, (s) => s.name).map((s) => s.name).filter((s) => !s.startsWith("supabase_"));
  const schemas = {};
  for (const s of newSchemas.sort()) schemas[s] = { relations: newRels.filter((r) => r.schema === s).map((r) => r.name).sort() };
  const outsideNamed = (rows) => rows.filter((r) => ["storage", "auth"].includes(r.schema)).map((r) => ({ schema: r.schema, table: r.rel, name: r.name }));
  return {
    format: "ai-engineer-wipe-manifest.v1",
    generatedBy: "scripts/install-manifest.mjs",
    migrations: digest,
    public: {
      relations: newRels.filter((r) => r.schema === "public").map((r) => ({ name: r.name, kind: relKind[r.kind] })).sort((a, b) => a.name.localeCompare(b.name)),
      functions: created(before.functions, after.functions, (f) => `${f.schema}.${f.name}`).filter((f) => f.schema === "public" && !f.extension_owned).map((f) => f.name).sort(),
      types: created(before.types, after.types, (t) => `${t.schema}.${t.name}`).filter((t) => t.schema === "public" && !t.extension_owned).map((t) => t.name).sort(),
    },
    storage: {
      triggers: outsideNamed(created(before.triggers, after.triggers, (t) => `${t.schema}.${t.rel}.${t.name}`)),
      policies: outsideNamed(created(before.policies, after.policies, (p) => `${p.schema}.${p.rel}.${p.name}`)),
      buckets: created(before.buckets, after.buckets, (b) => b.id).map((b) => b.id).sort(),
    },
    schemas,
    // Recorded, never dropped by a wipe. Roles are cluster-wide and survive too, but are not listed: whether the chain
    // creates them depends on the cluster, so they cannot be pinned.
    retained: {
      extensions: created(before.extensions, after.extensions, (e) => e.name).map((e) => `${e.name}@${e.schema}`).sort(),
    },
  };
}

// ---------------------------------------------------------------------------------------- local Supabase stub
// The stub must leave no shared state on the PostgreSQL server (other projects' proofs use it too):
//   - roles: STUB_ROLES the chain grants to, plus CHAIN_ROLES the chain creates; openStubCluster() records which exist,
//     creates missing stub roles, and close() drops only the ones this run created (after every stub database is gone);
//   - the stub pg_jsonschema extension files exist on the server only while one stub database registers the extension
//     (copy → CREATE EXTENSION in that database → delete, in a finally), so no other database can ever create it;
//   - auth/storage stub objects live only inside the per-run `disposable_*` databases, which the caller drops.
export const STUB_ROLES = Object.freeze(["anon", "authenticated", "service_role", "postgres"]);
export const CHAIN_ROLES = Object.freeze(["app_reader", "control_plane", "executor_service", "pipeline_agent", "verifier_agent"]);
const STUB_EXTENSION_FILES = Object.freeze(["pg_jsonschema.control", "pg_jsonschema--0.0.0.sql"]);
const docker = (args, opts = {}) => spawnSync("docker", args, { encoding: "utf8", windowsHide: true, timeout: 60_000, env: { ...process.env, MSYS_NO_PATHCONV: "1" }, ...opts });

export async function openStubCluster({ adminDsn, container }) {
  const admin = new URL(adminDsn);
  if (!["127.0.0.1", "localhost"].includes(admin.hostname)) throw new Error("LOOPBACK_REQUIRED");
  if (!container) throw new Error("STUB_CONTAINER_REQUIRED: name the local PostgreSQL container (INSTALL_WIPE_PG_CONTAINER)");
  const port = docker(["port", container, "5432/tcp"]);
  if (port.status !== 0 || !port.stdout.split(/\r?\n/).some((l) => l.trim().endsWith(`:${admin.port || 5432}`))) {
    throw new Error(`STUB_CONTAINER_MISMATCH: ${container} does not publish the admin DSN's port`);
  }
  const sharedir = docker(["exec", container, "pg_config", "--sharedir"]).stdout.trim();
  if (!/^\/[\w/.-]+$/.test(sharedir)) throw new Error("STUB_CONTAINER_SHAREDIR_UNKNOWN");
  const extensionDir = `${sharedir}/extension`;
  const present = docker(["exec", container, "sh", "-c", `ls ${extensionDir} | grep -c '^pg_jsonschema' || true`]).stdout.trim();
  if (present !== "0") throw new Error(`STUB_EXTENSION_PRESENT: ${extensionDir} already has pg_jsonschema files; refusing to shadow or remove them`);
  const pg = createRequire(join(repository, "package.json"))("pg");
  const a = new pg.Client({ connectionString: adminDsn });
  await a.connect();
  let preexisting;
  const created = [];
  try {
    preexisting = new Set((await a.query("select rolname from pg_roles where rolname = any($1)", [[...STUB_ROLES, ...CHAIN_ROLES]])).rows.map((r) => r.rolname));
    for (const role of STUB_ROLES.filter((r) => !preexisting.has(r))) {
      await a.query(`create role ${role} nologin`);
      created.push(role);
    }
  } finally { await a.end(); }
  return {
    pg, container, extensionDir, preexisting: [...preexisting].sort(), createdStubRoles: created,
    // Copy the stub extension, register it in one database, delete the files again whatever happens.
    async registerJsonSchemaStub(dsn) {
      try {
        for (const f of STUB_EXTENSION_FILES) {
          const r = docker(["cp", join(repository, "scripts", "supabase-stub", f), `${container}:${extensionDir}/${f}`]);
          if (r.status !== 0) throw new Error(`STUB_EXTENSION_COPY_FAILED: ${f}`);
        }
        const c = new pg.Client({ connectionString: dsn });
        await c.connect();
        try { await c.query("create extension if not exists pg_jsonschema with schema extensions"); } finally { await c.end(); }
      } finally {
        docker(["exec", container, "rm", "-f", ...STUB_EXTENSION_FILES.map((f) => `${extensionDir}/${f}`)]);
      }
    },
    // Drop the roles this run created (stub roles, and chain roles that did not exist before). Call it last, after the
    // stub databases are dropped; a role still referenced elsewhere is reported, never forced.
    async close() {
      docker(["exec", container, "rm", "-f", ...STUB_EXTENSION_FILES.map((f) => `${extensionDir}/${f}`)]);
      const c = new pg.Client({ connectionString: adminDsn });
      await c.connect();
      const dropped = [];
      const failed = [];
      try {
        const now = new Set((await c.query("select rolname from pg_roles where rolname = any($1)", [[...STUB_ROLES, ...CHAIN_ROLES]])).rows.map((r) => r.rolname));
        for (const role of [...CHAIN_ROLES, ...STUB_ROLES].filter((r) => now.has(r) && !preexisting.has(r))) {
          try { await c.query(`drop role ${role}`); dropped.push(role); } catch (error) { failed.push({ role, sqlstate: error.code }); }
        }
      } finally { await c.end(); }
      const left = docker(["exec", container, "sh", "-c", `ls ${extensionDir} | grep -c '^pg_jsonschema' || true`]).stdout.trim();
      return { dropped, failed, extensionFilesLeft: Number(left) };
    },
  };
}

// Stub + (optionally) KS component on a fresh loopback `disposable_*` database inside an open stub cluster.
export async function prepareStubDatabase({ cluster, adminDsn, database, ksCli, componentInstallationId = randomUUID(), installComponent = true }) {
  if (!/^disposable_[a-z0-9_]{3,48}$/.test(database)) throw new Error("DISPOSABLE_DATABASE_REQUIRED");
  const { pg } = cluster;
  const a = new pg.Client({ connectionString: adminDsn });
  await a.connect();
  try {
    await a.query(`drop database if exists ${database} with (force)`);
    await a.query(`create database ${database}`);
  } finally { await a.end(); }
  const url = new URL(adminDsn); url.pathname = `/${database}`; url.hostname = "127.0.0.1";
  const dsn = url.toString();
  const c = new pg.Client({ connectionString: dsn });
  await c.connect();
  try { await c.query(readFileSync(STUB, "utf8")); } finally { await c.end(); }
  await cluster.registerJsonSchemaStub(dsn);
  if (!installComponent) return { dsn, pg, componentInstallationId };
  const ks = spawnSync(process.execPath, [ksCli, "install", "--admin-dsn-env", "INSTALL_MANIFEST_DSN", "--installation-id", componentInstallationId,
    "--application", "ai-engineer", "--binding", "aiengineer-postgres", "--applied-by", "install-manifest"], { env: { ...process.env, INSTALL_MANIFEST_DSN: dsn }, encoding: "utf8", windowsHide: true, timeout: 600_000 });
  if (ks.status !== 0) throw new Error(`KS component install failed (${ks.status})`);
  return { dsn, pg, componentInstallationId };
}

export async function dropStubDatabase(cluster, adminDsn, database) {
  const a = new cluster.pg.Client({ connectionString: adminDsn });
  await a.connect();
  try { await a.query(`drop database if exists ${database} with (force)`); } finally { await a.end(); }
}

export async function snapshot(pg, dsn) {
  const c = new pg.Client({ connectionString: dsn });
  await c.connect();
  try { return await catalogSnapshot(c); } finally { await c.end(); }
}

export async function generate({ adminDsn, ksCli, container }) {
  const { domainMigrations } = await import("./install-ai-engineer.mjs");
  const database = `disposable_manifest_${randomUUID().slice(0, 8)}`;
  const cluster = await openStubCluster({ adminDsn, container });
  try {
    const { dsn, pg } = await prepareStubDatabase({ cluster, adminDsn, database, ksCli });
    const before = await snapshot(pg, dsn);
    await domainMigrations({ remote: {}, target: { dsn: `${dsn}?sslmode=disable` } });
    const after = await snapshot(pg, dsn);
    return deriveManifest(before, after, migrationsDigest());
  } finally {
    await dropStubDatabase(cluster, adminDsn, database);
    const cleanup = await cluster.close();
    if (cleanup.failed.length || cleanup.extensionFilesLeft) process.stderr.write(`stub cleanup incomplete: ${JSON.stringify(cleanup)}\n`);
  }
}

// No top-level await: install-ai-engineer.mjs imports this module, and generate() imports it back.
async function cli() {
  const argv = process.argv.slice(2);
  const i = argv.indexOf("--admin-dsn-env");
  const adminDsn = process.env[argv[i + 1] ?? ""];
  if (i < 0 || !adminDsn) { process.stderr.write("--admin-dsn-env <NAME of a loopback admin DSN> is required\n"); process.exit(2); }
  const c = argv.indexOf("--container");
  const container = c >= 0 ? argv[c + 1] : process.env.INSTALL_WIPE_PG_CONTAINER;
  const ksCli = resolve(repository, "..", "..", "platform", "knowledge-services", "packages", "knowledge-db-contract", "dist", "cli.js");
  if (!existsSync(ksCli)) { process.stderr.write("KS knowledge-db-contract dist/cli.js is not built\n"); process.exit(2); }
  const manifest = await generate({ adminDsn, ksCli, container });
  const text = `${JSON.stringify(manifest, null, 2)}\n`;
  if (argv.includes("--check")) {
    const ok = existsSync(MANIFEST_PATH) && readFileSync(MANIFEST_PATH, "utf8") === text;
    process.stdout.write(`${JSON.stringify({ status: ok ? "current" : "stale", path: MANIFEST_PATH })}\n`);
    process.exit(ok ? 0 : 1);
  }
  writeFileSync(MANIFEST_PATH, text);
  process.stdout.write(`${JSON.stringify({ status: "written", path: MANIFEST_PATH, public: { relations: manifest.public.relations.length, functions: manifest.public.functions.length, types: manifest.public.types.length }, storage: { triggers: manifest.storage.triggers.length, policies: manifest.storage.policies.length, buckets: manifest.storage.buckets.length }, schemas: Object.keys(manifest.schemas).length })}\n`);
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  cli().catch((error) => { process.stderr.write(`${error instanceof Error ? error.message : String(error)}\n`); process.exit(1); });
}
