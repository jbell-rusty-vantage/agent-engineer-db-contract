import { execFileSync, spawnSync } from "node:child_process";
import { readFileSync, realpathSync, renameSync, rmSync, writeFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import path from "node:path";

const schemas = [
  "public",
  "api",
  "util",
  "research_private",
  "orchestration",
  "evidence",
  "taxonomy",
  "corpus",
  "knowledge",
  "staging",
  "ranking",
  "research",
  "retrieval",
  "evaluation",
  "observability",
  "curriculum",
  "provenance",
  "content",
  "knowledge_service",
  "temporal",
];

const scriptDirectory = path.dirname(fileURLToPath(import.meta.url));
const repositoryRoot = path.resolve(scriptDirectory, "..");
const outputPath = path.join(repositoryRoot, "src", "database.generated.ts");
const temporaryPath = `${outputPath}.tmp`;
const checkOnly = process.argv.includes("--check");
const nativeLocal = process.argv.includes("--local-node");
const projectIdArgument = process.argv.find((value) => value.startsWith("--project-id="));
const projectId = projectIdArgument?.slice("--project-id=".length);
const workdirArgument = process.argv.find((value) => value.startsWith("--workdir="));
const workdir = workdirArgument ? realpathSync(workdirArgument.slice("--workdir=".length)) : undefined;
if (workdir) {
  if (nativeLocal || projectId || process.argv.includes("--linked")) throw new Error("DISPOSABLE_LOCAL_GENERATION_ONLY");
  const config = readFileSync(path.join(workdir, "supabase/config.toml"), "utf8");
  const projects = [...config.matchAll(/^project_id\s*=\s*"([^"\r\n]+)"\s*$/gm)];
  const project = projects[0]?.[1];
  if (projects.length !== 1 || !/^(?:disposable|vfy)-[a-z0-9][a-z0-9-]{5,63}$/.test(project ?? "")) throw new Error("DISPOSABLE_PROJECT_REQUIRED");
  const [container] = JSON.parse(execFileSync("docker", ["inspect", `supabase_db_${project}`], { encoding: "utf8", windowsHide: true }));
  if (!container.State.Running || container.Config.Labels["com.supabase.cli.project"] !== project
    || realpathSync(container.Config.Labels["com.supabase.cli.workdir"]) !== workdir) throw new Error("DISPOSABLE_CONTAINER_IDENTITY_MISMATCH");
}
if (nativeLocal && (projectId || process.argv.includes("--linked"))) {
  throw new Error("Native type generation supports local PostgreSQL only.");
}
if (nativeLocal && !process.env.POSTGRES_URL) {
  throw new Error("Native local type generation requires POSTGRES_URL; no .env file is loaded.");
}
const connectionArgs = projectId
  ? ["--project-id", projectId]
  : [process.argv.includes("--linked") ? "--linked" : "--local"];

const command = process.execPath;
const cliEntryPoint = path.join(
  repositoryRoot,
  "node_modules",
  "supabase",
  "dist",
  "supabase.js",
);
const args = nativeLocal
  ? [path.join(scriptDirectory, "generate-types-native.mjs"), JSON.stringify(schemas)]
  : [cliEntryPoint, "gen", "types", "typescript", ...connectionArgs];
if (!nativeLocal) for (const schema of schemas) args.push("--schema", schema);
if (workdir) args.push("--workdir", workdir);
const nativeEnvironmentNames = new Set(["PATH", "PATHEXT", "SYSTEMROOT", "WINDIR", "COMSPEC", "TEMP", "TMP", "USERPROFILE", "APPDATA", "LOCALAPPDATA", "POSTGRES_URL"]);

const result = spawnSync(command, args, {
  cwd: repositoryRoot,
  encoding: "utf8",
  maxBuffer: 128 * 1024 * 1024,
  ...(nativeLocal ? { timeout: 60_000, env: Object.fromEntries(Object.entries(process.env).filter(([key]) => nativeEnvironmentNames.has(key.toUpperCase()))) } : {}),
});

if (result.status !== 0) {
  process.stderr.write(result.stderr || result.stdout);
  process.exit(result.status ?? 1);
}

const generated = `${result.stdout.replaceAll("\r\n", "\n").trimEnd()}\n`;

if (checkOnly) {
  const existing = readFileSync(outputPath, "utf8").replaceAll("\r\n", "\n");
  if (existing !== generated) {
    process.stderr.write(
      "Generated database types are stale. Run npm run types:generate and commit the result.\n",
    );
    process.exit(1);
  }
  process.stdout.write("Generated database types are current.\n");
  process.exit(0);
}

try {
  writeFileSync(temporaryPath, generated, "utf8");
  renameSync(temporaryPath, outputPath);
} finally {
  rmSync(temporaryPath, { force: true });
}

process.stdout.write(`Generated ${path.relative(repositoryRoot, outputPath)}.\n`);
