import { existsSync, readdirSync } from "node:fs";
import pg from "pg";
import { ErrorCode, WorkspaceError } from "./errors.mjs";

const { Pool } = pg;
const MIGRATION_FILE = /^(\d{14})_.*\.sql$/;

const LOOPBACK_HOSTS = new Set(["127.0.0.1", "localhost", "::1", "[::1]"]);

/** True when the DSN addresses the machine itself; the only kind AIENG_DB_LOCAL_DSN may hold. */
export function isLoopbackUrl(value) {
  try { return LOOPBACK_HOSTS.has(new URL(value).hostname); } catch { return false; }
}

export const TARGETS = Object.freeze(["local", "remote"]);

/**
 * Which database a schema-workspace command reads. Local by default (SPEC-03 K3):
 * - `--db-url <url>` wins; it is an explicit request for that database, whatever its host;
 * - else `--target remote` reads `AIENG_DB_ADMIN_DSN` (the schema owner login), and only then;
 * - else (no target, or `--target local`) a loopback `AIENG_DB_LOCAL_DSN`; a remote value there is refused, never used.
 * `AIENG_DB_ADMIN_DSN` is never read without `--target remote`, so a command run with no target never reaches the remote.
 * Returns null when the chosen source is unset (validate then runs without a database).
 */
export function optionalDatabaseUrl({ url, target } = {}, env = process.env) {
  if (target !== undefined && !TARGETS.includes(target)) {
    throw new WorkspaceError(ErrorCode.USAGE, `--target must be local or remote, not "${target}".`);
  }
  if (url) return url;
  if (target === "remote") {
    if (!env.AIENG_DB_ADMIN_DSN) {
      throw new WorkspaceError(ErrorCode.DB_UNREACHABLE, "--target remote needs AIENG_DB_ADMIN_DSN (the remote schema owner login); it is unset.");
    }
    return env.AIENG_DB_ADMIN_DSN;
  }
  const local = env.AIENG_DB_LOCAL_DSN;
  if (!local) return null;
  if (!isLoopbackUrl(local)) {
    throw new WorkspaceError(ErrorCode.DB_UNREACHABLE, "AIENG_DB_LOCAL_DSN must address a loopback host (127.0.0.1, localhost or ::1).");
  }
  return local;
}

export function resolveDatabaseUrl(selection = {}, env = process.env) {
  const url = optionalDatabaseUrl(selection, env);
  if (!url) {
    const hint = env.AIENG_DB_ADMIN_DSN ? " AIENG_DB_ADMIN_DSN is set but is read only with --target remote." : "";
    throw new WorkspaceError(
      ErrorCode.DB_UNREACHABLE,
      `No local database URL: pass --db-url, or set a loopback AIENG_DB_LOCAL_DSN; the remote needs --target remote.${hint}`,
    );
  }
  return url;
}

export async function openPool(databaseUrl) {
  const pool = new Pool({
    connectionString: databaseUrl,
    max: 2,
    statement_timeout: 120_000,
    application_name: "ai-engineer-schema-workspace",
  });
  try {
    await pool.query("select 1");
  } catch (error) {
    await pool.end().catch(() => undefined);
    throw new WorkspaceError(ErrorCode.DB_UNREACHABLE, `Cannot reach database: ${error.message}`);
  }
  return pool;
}

export async function databaseMigrationHead(pool) {
  const { rows } = await pool.query(
    "select version from supabase_migrations.schema_migrations order by version desc limit 1",
  );
  return rows[0]?.version ?? null;
}

/** Highest ordered migration version across the given directories (a missing directory contributes nothing). */
export function repositoryMigrationHead(...migrationDirs) {
  const versions = migrationDirs
    .filter((dir) => dir && existsSync(dir))
    .flatMap((dir) => readdirSync(dir).map((name) => name.match(MIGRATION_FILE)?.[1]))
    .filter(Boolean)
    .sort();
  return versions.at(-1) ?? null;
}

/**
 * Fails when the connected database is not at the repository's latest migration. `draftDirs` are
 * lab draft directories (workspace.config.json `paths.draftMigrations`) whose ordered files count as
 * repository migrations, so a disposable lab at a draft head can be described.
 */
export async function assertHeadMatches(pool, migrationsDir, draftDirs = []) {
  const [database, repository] = [await databaseMigrationHead(pool), repositoryMigrationHead(migrationsDir, ...draftDirs)];
  if (database !== repository) {
    throw new WorkspaceError(ErrorCode.HEAD_MISMATCH, "Database head differs from repository migrations.", {
      database,
      repository,
    });
  }
  return repository;
}

export function describeSource(databaseUrl) {
  const url = new URL(databaseUrl);
  const local = ["127.0.0.1", "localhost", "host.docker.internal"].includes(url.hostname);
  if (local) return { kind: "local_disposable" };
  const projectRef = url.username.match(/\.([a-z]{20})$/)?.[1] ?? url.hostname.match(/^db\.([a-z]{20})\./)?.[1];
  return projectRef ? { kind: "project", project_ref: projectRef } : { kind: "project" };
}
