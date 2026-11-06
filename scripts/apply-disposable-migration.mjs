import { execFileSync } from "node:child_process";
import { createHash } from "node:crypto";
import { readFileSync, realpathSync } from "node:fs";
import { basename, resolve } from "node:path";

const argument = (name) => process.argv.find((value) => value.startsWith(`--${name}=`))?.slice(name.length + 3);
const projectDirectory = realpathSync(argument("project-dir") ?? "");
const migration = argument("migration");
if (!migration || basename(migration) !== migration || !/^\d{14}_[a-z0-9_]+\.sql$/.test(migration)) throw new Error("CANONICAL_MIGRATION_FILENAME_REQUIRED");
const config = readFileSync(resolve(projectDirectory, "supabase/config.toml"), "utf8");
const ids = [...config.matchAll(/^project_id\s*=\s*"([^"\r\n]+)"\s*$/gm)];
const project = ids[0]?.[1];
if (ids.length !== 1 || !/^(?:disposable|vfy)-[a-z0-9][a-z0-9-]{5,63}$/.test(project ?? "")) throw new Error("DISPOSABLE_PROJECT_REQUIRED");
const containerName = `supabase_db_${project}`;
const [container] = JSON.parse(execFileSync("docker", ["inspect", containerName], { encoding: "utf8", windowsHide: true }));
if (!container.State.Running || container.Name !== `/${containerName}`
  || container.Config.Labels["com.supabase.cli.project"] !== project
  || realpathSync(container.Config.Labels["com.supabase.cli.workdir"]) !== projectDirectory) throw new Error("DISPOSABLE_CONTAINER_IDENTITY_MISMATCH");
const run = (sql) => execFileSync("docker", ["exec", "-i", containerName, "psql", "-X", "-U", "postgres", "-d", "postgres", "-v", "ON_ERROR_STOP=1", "-At"],
  { input: sql, encoding: "utf8", windowsHide: true, timeout: 60_000 });
const version = migration.slice(0, 14);
const source = readFileSync(resolve(import.meta.dirname, "../supabase/migrations", migration), "utf8");
const quote = (text) => `'${text.replaceAll("'", "''")}'`;
const existing = run(`select statements[1] from supabase_migrations.schema_migrations where version=${quote(version)};`).trim();
if (existing) {
  if (existing !== source.trim()) throw new Error("APPLIED_MIGRATION_BYTES_DIFFER");
  console.log(JSON.stringify({ project, version, status: "already_applied", sha256: createHash("sha256").update(source).digest("hex") }));
} else {
  const head = run("select max(version) from supabase_migrations.schema_migrations;").trim();
  if (head >= version) throw new Error("MIGRATION_ORDER_DENIED");
  const body = source.replace(/^\s*begin\s*;/im, "").replace(/commit\s*;\s*$/im, "");
  run(`begin;\n${body}\ninsert into supabase_migrations.schema_migrations(version,statements,name) values(${quote(version)},array[${quote(source.trim())}],${quote(migration.slice(15, -4))});\ncommit;`);
  console.log(JSON.stringify({ project, version, previousHead: head, status: "applied", sha256: createHash("sha256").update(source).digest("hex") }));
}
