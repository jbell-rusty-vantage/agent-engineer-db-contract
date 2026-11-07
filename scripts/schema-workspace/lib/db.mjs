import { readdirSync } from "node:fs";
import pg from "pg";
import { ErrorCode, WorkspaceError } from "./errors.mjs";

const { Pool } = pg;
const MIGRATION_FILE = /^(\d{14})_.*\.sql$/;

const LOOPBACK_HOSTS = new Set(["127.0.0.1", "localhost", "::1", "[::1]"]);

/** True when the DSN addresses the machine itself; the only kind AIENG_DB_LOCAL_DSN may hold. */
export function isLoopbackUrl(value) {
  try { return LOOPBACK_HOSTS.has(new URL(value).hostname); } catch { return false; }
}

/**
 * Connection precedence: --db-url, then AIENG_DB_ADMIN_DSN (the schema owner login), then AIENG_DB_LOCAL_DSN, which must be
 * loopback (a remote value there is refused, never used). Returns null when none is set.
 */
export function optionalDatabaseUrl(explicitUrl, env = process.env) {
  if (explicitUrl) return explicitUrl;
  if (env.AIENG_DB_ADMIN_DSN) return env.AIENG_DB_ADMIN_DSN;
  const local = env.AIENG_DB_LOCAL_DSN;
  if (!local) return null;
  if (!isLoopbackUrl(local)) {
    throw new WorkspaceError(ErrorCode.DB_UNREACHABLE, "AIENG_DB_LOCAL_DSN must address a loopback host (127.0.0.1, localhost or ::1).");
  }
  return local;
}

export function resolveDatabaseUrl(explicitUrl, env = process.env) {
  const url = optionalDatabaseUrl(explicitUrl, env);
  if (!url) {
    throw new WorkspaceError(ErrorCode.DB_UNREACHABLE, "No database URL: pass --db-url or set AIENG_DB_ADMIN_DSN (or a loopback AIENG_DB_LOCAL_DSN).");
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

export function repositoryMigrationHead(migrationsDir) {
  const versions = readdirSync(migrationsDir)
    .map((name) => name.match(MIGRATION_FILE)?.[1])
    .filter(Boolean)
    .sort();
  return versions.at(-1) ?? null;
}

/** Fails when the connected database is not at the repository's latest migration. */
export async function assertHeadMatches(pool, migrationsDir) {
  const [database, repository] = [await databaseMigrationHead(pool), repositoryMigrationHead(migrationsDir)];
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
