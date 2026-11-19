#!/usr/bin/env node
// Lab schema: the current schema of a running disposable lab database, as pages a person can read and as TypeScript
// types. It reads the lab only (introspection and `supabase gen types`), writes only into <lab workdir>/schema, and
// never touches supabase/migrations, src/ or workspace/ of this repository.
//
//   node scripts/lab-schema.mjs [--workdir <lab workdir>] [--out <dir>] [--no-start] [--keep-running] [--no-types]
//
// --workdir       the lab's Supabase workdir (the folder that holds supabase/config.toml). Default: KNOWLEDGE_LAB_WORKDIR,
//                 else platform/ai-engineer-research-2026-11-02/11-build04-lab next to this repository.
// --out           output folder. Default: <workdir>/schema.
// --no-start      refuse when the lab database is not running, instead of starting it.
// --keep-running  leave the database running when this command started it (default: stop it again, volumes kept).
// --no-types      skip database.types.ts.
//
// Gates: the project id must be disposable-*, and the database container's labels must name that project and workdir.
// Unlike workspace:build, a lab whose migration head differs from the repository's is reported, not refused: showing
// that difference is part of the point. Exit: 0 written, 1 refused gate, 2 error.
import { execFileSync, spawnSync } from "node:child_process";
import { createHash } from "node:crypto";
import { existsSync, mkdirSync, readFileSync, readdirSync, realpathSync, rmSync, writeFileSync } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { loadConfig } from "./schema-workspace/lib/config.mjs";
import { databaseMigrationHead, describeSource, openPool, repositoryMigrationHead } from "./schema-workspace/lib/db.mjs";
import { buildIr } from "./schema-workspace/lib/ir/build-ir.mjs";
import { indexGeneratedTypes, indexMigrations } from "./schema-workspace/lib/ir/repository-inputs.mjs";
import { introspect } from "./schema-workspace/lib/introspect.mjs";

const scriptDirectory = path.dirname(fileURLToPath(import.meta.url));
const repositoryRoot = path.resolve(scriptDirectory, "..");
const supabaseCli = path.join(repositoryRoot, "node_modules", "supabase", "dist", "supabase.js");
const DEFAULT_WORKDIR = path.resolve(repositoryRoot, "..", "..", "platform", "ai-engineer-research-2026-11-02", "11-build04-lab");

class Refused extends Error {}

function parseArgs(argv) {
  const options = { start: true, keepRunning: false, types: true };
  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    if (arg === "--workdir") options.workdir = argv[++i];
    else if (arg === "--out") options.out = argv[++i];
    else if (arg === "--no-start") options.start = false;
    else if (arg === "--keep-running") options.keepRunning = true;
    else if (arg === "--no-types") options.types = false;
    else throw new Refused(`USAGE: unknown argument ${arg}`);
  }
  return options;
}

/** The lab's identity from its config file: project id (disposable-* only) and the database port. */
export function readLabConfig(workdir) {
  const file = path.join(workdir, "supabase", "config.toml");
  if (!existsSync(file)) throw new Refused(`LAB_WORKDIR_INVALID: no supabase/config.toml under ${workdir}`);
  const text = readFileSync(file, "utf8");
  const projects = [...text.matchAll(/^project_id\s*=\s*"([^"\r\n]+)"\s*$/gm)].map((m) => m[1]);
  if (projects.length !== 1 || !/^disposable-[a-z0-9][a-z0-9-]{5,63}$/.test(projects[0])) throw new Refused("DISPOSABLE_PROJECT_REQUIRED");
  const dbSection = text.split(/^\[db\]\s*$/m)[1] ?? "";
  const port = Number((dbSection.match(/^port\s*=\s*(\d+)\s*$/m) ?? [])[1]);
  if (!Number.isInteger(port)) throw new Refused("LAB_DB_PORT_UNKNOWN");
  return { project: projects[0], port };
}

function inspectContainer(project) {
  const result = spawnSync("docker", ["inspect", `supabase_db_${project}`], { encoding: "utf8", windowsHide: true });
  if (result.status !== 0) return null;
  return JSON.parse(result.stdout)[0];
}

function runSupabase(args, workdir) {
  return spawnSync(process.execPath, [supabaseCli, ...args, "--workdir", workdir], { cwd: repositoryRoot, encoding: "utf8", maxBuffer: 256 * 1024 * 1024, windowsHide: true });
}

/** Makes sure the lab database runs and is the lab it claims to be. Returns whether this call started it. */
function ensureRunning(workdir, project, allowStart) {
  let container = inspectContainer(project);
  let started = false;
  if (!container?.State?.Running) {
    if (!allowStart) throw new Refused(`LAB_NOT_RUNNING: start it with \`npx supabase db start --workdir "${workdir}"\` or drop --no-start`);
    const result = runSupabase(["db", "start"], workdir);
    if (result.status !== 0) throw new Error(`LAB_START_FAILED: ${(result.stderr || result.stdout).trim().slice(-800)}`);
    container = inspectContainer(project);
    started = true;
  }
  const labels = container?.Config?.Labels ?? {};
  if (!container?.State?.Running || labels["com.supabase.cli.project"] !== project || realpathSync(labels["com.supabase.cli.workdir"] ?? ".") !== workdir) {
    throw new Refused("DISPOSABLE_CONTAINER_IDENTITY_MISMATCH");
  }
  return started;
}

const cell = (value) => String(value ?? "").replace(/\r?\n/g, " ").replace(/\|/g, "\\|").trim();
const code = (value) => `\`${String(value).replace(/`/g, "'")}\``;
const anchor = (name) => name.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "");
/** A link to a relation's entry, or plain code when the relation is outside the rendered schemas (auth.users). */
const relLink = (id, fromSchema, ir) => {
  const [schema, name] = id.replace(/^rel:/, "").split(".");
  if (!ir.relations[`rel:${schema}.${name}`]) return code(`${schema}.${name}`);
  const file = schema === fromSchema ? "" : `${schema}.md`;
  return `[${schema}.${name}](${file}#${anchor(name)})`;
};
const clip = (text, max) => (text.length > max ? `${text.slice(0, max - 1)}…` : text);
const sha256 = (text) => `sha256:${createHash("sha256").update(text).digest("hex")}`;

/** One page per schema: tables, views, functions and enums, each with what a reader needs to use it. */
export function renderSchemaPage(schema, ir, enrichment) {
  const relations = Object.values(ir.relations).filter((r) => r.schema === schema).sort((a, b) => a.name.localeCompare(b.name));
  const functions = Object.values(ir.functions).filter((f) => f.schema === schema).sort((a, b) => a.id.localeCompare(b.id));
  const types = Object.values(ir.types).filter((t) => t.schema === schema).sort((a, b) => a.name.localeCompare(b.name));
  const domain = enrichment.domains?.[enrichment.schema_domains?.[schema]];
  const lines = [`# ${schema}`, ""];
  if (domain) lines.push(`**${domain.title}.** ${domain.summary}`, "");
  lines.push(`[Back to the lab schema](../README.md#schemas). ${relations.filter((r) => r.kind !== "view").length} tables, ${relations.filter((r) => r.kind === "view").length} views, ${functions.length} functions, ${types.length} enums.`, "");
  if (domain?.body) lines.push("## How this part works", "", domain.body.trim(), "");

  const section = (title, list) => {
    if (list.length === 0) return;
    lines.push(`## ${title}`, "");
    for (const r of list) {
      const overlay = enrichment.relation_overlays?.[r.id] ?? {};
      const notes = overlay.column_notes ?? {};
      lines.push(`<a id="${anchor(r.name)}"></a>`, `### ${schema}.${r.name}`, "");
      const summary = overlay.summary ?? r.comment;
      if (summary) lines.push(cell(summary), "");
      const facts = [];
      if (r.kind !== "view") {
        facts.push(`Rows in the lab: ${ir.volatile?.row_count_class?.[r.id] ?? "unknown"}`);
        const path_ = ir.derived?.write_paths?.[r.id];
        const direct = path_?.direct_dml_roles ?? [];
        facts.push(`Written directly by: ${direct.length ? direct.join(", ") : "no role"}`);
        if (path_?.via_functions?.length) facts.push(`Written through: ${path_.via_functions.slice(0, 6).map((f) => code(f.replace(/^fn:/, ""))).join(", ")}${path_.via_functions.length > 6 ? ` and ${path_.via_functions.length - 6} more` : ""}`);
        const policies = r.rls?.policies?.length ?? 0;
        facts.push(`Row security: ${r.rls?.enabled ? `on, ${policies} ${policies === 1 ? "policy" : "policies"}` : "off"}`);
      }
      facts.push(`Read by: ${r.readers?.length ? r.readers.join(", ") : "no role"}`);
      if (r.defined_in?.length) facts.push(`Last changed in: ${code(r.defined_in[r.defined_in.length - 1])}`);
      lines.push(...facts.map((f) => `- ${f}`), "");
      lines.push("| Column | Type | Null | Default | Notes |", "| --- | --- | --- | --- | --- |");
      for (const c of r.columns) {
        const bits = [];
        if (r.primary_key?.includes(c.name)) bits.push("primary key");
        if (c.fk) bits.push(`→ ${relLink(c.fk.to, schema, ir)}`);
        if (notes[c.name]) bits.push(cell(notes[c.name]));
        else if (c.comment) bits.push(cell(c.comment));
        lines.push(`| ${code(c.name)} | ${code(c.type)} | ${c.nullable ? "yes" : "no"} | ${c.default ? code(clip(cell(c.default), 60)) : ""} | ${bits.join("; ")} |`);
      }
      lines.push("");
      const unique = (r.unique ?? []).map((u) => `(${u.join(", ")})`);
      if (unique.length) lines.push(`Unique: ${unique.join("; ")}.`, "");
      if (r.checks?.length) lines.push(`Checks: ${r.checks.map((k) => code(clip(cell(k.expression), 160))).join("; ")}.`, "");
      if (r.inbound_foreign_keys?.length) {
        const from = [...new Set(r.inbound_foreign_keys.map((k) => k.from ?? k.relation ?? k.id).filter(Boolean))];
        if (from.length) lines.push(`Referenced by: ${from.slice(0, 12).map((id) => relLink(id, schema, ir)).join(", ")}${from.length > 12 ? ` and ${from.length - 12} more` : ""}.`, "");
      }
    }
  };
  section("Tables", relations.filter((r) => r.kind !== "view"));
  section("Views", relations.filter((r) => r.kind === "view"));

  if (functions.length) {
    lines.push("## Functions", "");
    for (const f of functions) {
      const args = (f.arguments ?? []).filter((a) => a.mode !== "table" && a.mode !== "out").map((a) => `${a.name ?? ""} ${a.type}${a.default ? ` = ${a.default}` : ""}`.trim());
      lines.push(`### ${schema}.${f.name}`, "", "```", `${f.name}(${args.join(", ")})`, `returns ${f.returns_set ? "set of " : ""}${clip(String(f.returns ?? "void"), 400)}`, "```", "");
      if (f.comment) lines.push(cell(f.comment), "");
      lines.push(`- Runs as: ${f.security === "definer" ? "its owner (security definer)" : "the caller"}; ${f.volatility}`, `- May be called by: ${f.executors?.length ? f.executors.join(", ") : "no role"}`);
      if (f.raises?.length) lines.push(`- Raises: ${f.raises.slice(0, 12).map((e) => code(typeof e === "string" ? e : e.code ?? e.message ?? JSON.stringify(e))).join(", ")}`);
      lines.push("");
    }
  }
  if (types.length) {
    lines.push("## Enums", "", "| Enum | Values |", "| --- | --- |");
    for (const t of types) lines.push(`| ${code(t.name)} | ${(t.labels ?? []).map(code).join(", ")} |`);
    lines.push("");
  }
  return `${lines.join("\n").trimEnd()}\n`;
}

/** The vocabularies carry most of the domain since Build 08: one table per vocabulary, code and meaning. */
export function renderVocabularies(ir) {
  const lines = ["# Vocabularies", "", "[Back to the lab schema](README.md#schemas). Since Build 08 most of the domain is rows in these tables, not tables of its own: an entity kind, a stream kind or a unit kind is added as a row.", ""];
  for (const v of Object.values(ir.vocabularies).sort((a, b) => a.id.localeCompare(b.id))) {
    const key = v.key ?? "code";
    const columns = v.columns ?? [];
    const label = ["label", "display_name", "title"].find((c) => columns.includes(c));
    const describe = ["description", "summary", "meaning"].find((c) => columns.includes(c));
    lines.push(`<a id="${anchor(`${v.schema}-${v.table}`)}"></a>`, `## ${v.schema}.${v.table}`, "", `${v.rows?.length ?? 0} rows.`, "");
    lines.push(`| ${key} |${label ? " Label |" : ""}${describe ? " Meaning |" : ""}`, `| --- |${label ? " --- |" : ""}${describe ? " --- |" : ""}`);
    for (const row of v.rows ?? []) lines.push(`| ${code(row[key])} |${label ? ` ${cell(row[label])} |` : ""}${describe ? ` ${cell(clip(String(row[describe] ?? ""), 300))} |` : ""}`);
    lines.push("");
  }
  return `${lines.join("\n").trimEnd()}\n`;
}

/** What the lab has that the committed contract workspace does not, and the reverse. */
export function compareWithContract(ir, contract) {
  const diff = (a, b) => Object.keys(a).filter((id) => !(id in b)).sort();
  const shape = (r) => r.columns.map((c) => `${c.name}:${c.type}:${c.nullable}`).join(",");
  const changedRelations = Object.keys(ir.relations).filter((id) => contract.relations[id] && shape(ir.relations[id]) !== shape(contract.relations[id])).sort();
  const changedFunctions = Object.keys(ir.functions).filter((id) => contract.functions[id] && ir.functions[id].body_sha256 !== contract.functions[id].body_sha256).sort();
  const vocabularies = Object.keys(ir.vocabularies).filter((id) => contract.vocabularies[id] && ir.vocabularies[id].rows_sha256 !== contract.vocabularies[id].rows_sha256).sort();
  return {
    relations_only_in_lab: diff(ir.relations, contract.relations), relations_only_in_contract: diff(contract.relations, ir.relations), relations_with_different_columns: changedRelations,
    functions_only_in_lab: diff(ir.functions, contract.functions), functions_only_in_contract: diff(contract.functions, ir.functions), functions_with_different_bodies: changedFunctions,
    vocabularies_with_different_rows: vocabularies,
  };
}

function renderFrontPage({ stamp, ir, enrichment, comparison, schemas, relativeWorkdir, relativeContract }) {
  const list = (ids) => (ids.length ? ids.slice(0, 40).map((id) => code(id.replace(/^(rel|fn|voc):/, ""))).join(", ") + (ids.length > 40 ? ` and ${ids.length - 40} more` : "") : "none");
  const same = Object.values(comparison).every((ids) => ids.length === 0);
  const lines = [
    `# Lab schema: ${stamp.project}`, "",
    `Generated ${stamp.generated_at} from the running lab database by \`npm run lab:schema\` in the [contract repository](${relativeContract}/AGENTS.md). Do not edit these files; run the command again.`, "",
    "<a id=\"where\"></a>", "## Where the lab schema lives", "",
    "| Form | Where | Notes |", "| --- | --- | --- |",
    `| The live database | Docker volume ${code(`supabase_db_${stamp.project}`)}, loopback port ${stamp.db_port} | The data survives a stop. Its Supabase workdir is this folder's parent (${code(relativeWorkdir)}) |`,
    `| As SQL | [supabase/migrations](${relativeContract}/supabase/migrations) and [supabase/drafts](${relativeContract}/supabase/drafts) in the contract repository | The only place a schema change is written. ${stamp.repository.migration_files} migrations, head ${code(stamp.repository.migration_head)} |`,
    "| Readable, current | this folder: [schemas](#schemas), [vocabularies](VOCABULARIES.md) | Rebuilt from the database on every run |",
    "| TypeScript types, current | [database.types.ts](database.types.ts) | Generated from the database by the pinned Supabase CLI |",
    `| For agents | [workspace](${relativeContract}/workspace/START_HERE.md) in the contract repository | Rebuilt only when a change is promoted, so it can lag the lab |`,
    `| The first lab (2026-11-03) | [09-disposable-postgres-lab](../../09-disposable-postgres-lab/README.md) | Historical. Its 640-relation tables report is the design before Build 08, not this schema |`, "",
    "<a id=\"stamp\"></a>", "## Stamp", "",
    "| | |", "| --- | --- |",
    `| Lab migration head | ${code(stamp.lab.migration_head)} |`,
    `| Repository head (migrations and drafts) | ${code(stamp.repository.migration_head)} |`,
    `| Contract version in the repository | ${code(stamp.repository.contract_version)} at ${code(stamp.repository.contract_head)} |`,
    `| Lab and repository head agree | ${stamp.heads_agree ? "yes" : "**no**"} |`,
    `| Schemas, tables, views, functions, enums, vocabularies | ${stamp.counts.schemas}, ${stamp.counts.tables}, ${stamp.counts.views}, ${stamp.counts.functions}, ${stamp.counts.enums}, ${stamp.counts.vocabularies} |`,
    `| Columns | ${stamp.counts.columns} |`,
    `| Types file | ${stamp.types_sha256 ? code(stamp.types_sha256) : "not generated"} |`, "",
    "<a id=\"compare\"></a>", "## The lab compared with the contract workspace", "",
    same ? "The lab's relations, columns, function bodies and vocabulary rows are the same as the committed contract workspace."
      : "The lab differs from the committed contract workspace. Anything listed here has not been promoted, or was promoted without rebuilding the workspace.", "",
    "| | |", "| --- | --- |",
    `| Relations only in the lab | ${list(comparison.relations_only_in_lab)} |`,
    `| Relations only in the contract | ${list(comparison.relations_only_in_contract)} |`,
    `| Relations with different columns | ${list(comparison.relations_with_different_columns)} |`,
    `| Functions only in the lab | ${list(comparison.functions_only_in_lab)} |`,
    `| Functions only in the contract | ${list(comparison.functions_only_in_contract)} |`,
    `| Functions with different bodies | ${list(comparison.functions_with_different_bodies)} |`,
    `| Vocabularies with different rows | ${list(comparison.vocabularies_with_different_rows)} |`, "",
    "<a id=\"schemas\"></a>", "## Schemas", "",
    "| Schema | What it holds | Tables | Views | Functions |", "| --- | --- | --- | --- | --- |",
  ];
  for (const schema of schemas) {
    const relations = Object.values(ir.relations).filter((r) => r.schema === schema);
    const domain = enrichment.domains?.[enrichment.schema_domains?.[schema]];
    lines.push(`| [${schema}](schemas/${schema}.md) | ${cell(domain?.summary ?? "")} | ${relations.filter((r) => r.kind !== "view").length} | ${relations.filter((r) => r.kind === "view").length} | ${Object.values(ir.functions).filter((f) => f.schema === schema).length} |`);
  }
  lines.push("", "Roles that appear on the pages: " + Object.keys(ir.roles ?? {}).map(code).join(", ") + ".", "");
  return `${lines.join("\n").trimEnd()}\n`;
}

async function main(argv) {
  const options = parseArgs(argv);
  const workdir = realpathSync(path.resolve(options.workdir ?? process.env.KNOWLEDGE_LAB_WORKDIR ?? DEFAULT_WORKDIR));
  const outDir = path.resolve(options.out ?? path.join(workdir, "schema"));
  const { project, port } = readLabConfig(workdir);
  const startedHere = ensureRunning(workdir, project, options.start);
  const databaseUrl = `postgresql://postgres:postgres@127.0.0.1:${port}/postgres`;
  try {
    const config = loadConfig();
    const pool = await openPool(databaseUrl);
    let ir;
    let labHead;
    try {
      labHead = await databaseMigrationHead(pool);
      const raw = await introspect(pool, config);
      const generatedTypes = indexGeneratedTypes(config.paths.generatedTypes);
      ({ ir } = buildIr(raw, {
        config,
        migrationIndex: indexMigrations(config.paths.migrations, ...config.paths.draftMigrations),
        typePaths: generatedTypes.paths,
        build: { contract_version: config.contractVersion, migration_head: labHead, generated_types_sha256: generatedTypes.sha256, enrichment_sha256: null, renderer_version: config.rendererVersion, source: describeSource(databaseUrl) },
      }));
    } finally {
      await pool.end();
    }
    const contract = JSON.parse(readFileSync(path.join(config.paths.workspace, "schema-ir.json"), "utf8"));
    const enrichment = contract.enrichment ?? {};
    const version = JSON.parse(readFileSync(path.join(repositoryRoot, "contract.version.json"), "utf8"));

    let types = null;
    if (options.types) {
      const args = ["gen", "types", "typescript", "--local"];
      for (const schema of config.schemas) args.push("--schema", schema);
      const result = runSupabase(args, workdir);
      if (result.status !== 0) throw new Error(`TYPES_FAILED: ${(result.stderr || result.stdout).trim().slice(-800)}`);
      types = `${result.stdout.replaceAll("\r\n", "\n").trimEnd()}\n`;
    }

    const schemas = [...new Set(Object.values(ir.relations).map((r) => r.schema).concat(Object.values(ir.functions).map((f) => f.schema)))].sort();
    const relations = Object.values(ir.relations);
    const repositoryHead = repositoryMigrationHead(config.paths.migrations, ...config.paths.draftMigrations);
    const stamp = {
      format: "ai-engineer-lab-schema/1",
      generated_at: new Date().toISOString().replace(/\.\d+Z$/, "Z"),
      project,
      db_port: port,
      lab: { migration_head: labHead },
      repository: { migration_head: repositoryHead, migration_files: readdirSync(config.paths.migrations).filter((f) => f.endsWith(".sql")).length, contract_version: version.version, contract_head: version.migration_head },
      heads_agree: labHead === repositoryHead,
      counts: {
        schemas: schemas.length, tables: relations.filter((r) => r.kind !== "view").length, views: relations.filter((r) => r.kind === "view").length,
        columns: relations.reduce((n, r) => n + r.columns.length, 0), functions: Object.keys(ir.functions).length, enums: Object.keys(ir.types).length, vocabularies: Object.keys(ir.vocabularies).length,
      },
      schema_fingerprint: ir.fingerprint ?? null,
      types_sha256: types ? sha256(types) : null,
    };
    const comparison = compareWithContract(ir, contract);
    stamp.same_as_contract_workspace = Object.values(comparison).every((ids) => ids.length === 0);

    rmSync(path.join(outDir, "schemas"), { recursive: true, force: true });
    mkdirSync(path.join(outDir, "schemas"), { recursive: true });
    const relative = (to) => path.relative(outDir, to).split(path.sep).join("/");
    const write = (file, text) => writeFileSync(path.join(outDir, file), text, "utf8");
    write("README.md", renderFrontPage({ stamp, ir, enrichment, comparison, schemas, relativeWorkdir: relative(workdir) || ".", relativeContract: relative(repositoryRoot) }));
    for (const schema of schemas) write(path.join("schemas", `${schema}.md`), renderSchemaPage(schema, ir, enrichment));
    write("VOCABULARIES.md", renderVocabularies(ir));
    if (types) write("database.types.ts", types);
    write("STAMP.json", `${JSON.stringify({ ...stamp, comparison }, null, 2)}\n`);
    process.stdout.write(`${JSON.stringify({ written: outDir, started_database: startedHere, ...stamp }, null, 2)}\n`);
  } finally {
    if (startedHere && !options.keepRunning) {
      const result = runSupabase(["stop"], workdir);
      if (result.status !== 0) process.stderr.write(`LAB_STOP_FAILED: ${(result.stderr || result.stdout).trim().slice(-400)}\n`);
    }
  }
}

if (process.argv[1] && realpathSync(process.argv[1]) === fileURLToPath(import.meta.url)) {
  main(process.argv.slice(2)).then(() => process.exit(0)).catch((error) => {
    process.stderr.write(`${error.message}\n`);
    process.exit(error instanceof Refused ? 1 : 2);
  });
}
