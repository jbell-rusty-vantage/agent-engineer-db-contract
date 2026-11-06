import { writeFileSync } from "node:fs";
import path from "node:path";
import { prettyJson } from "../canonical.mjs";
import { loadConfig } from "../config.mjs";
import { openPool, resolveDatabaseUrl } from "../db.mjs";
import { ExitCode } from "../errors.mjs";
import { assembleWorkspace, buildFromDatabase, introspectToIr } from "../pipeline.mjs";
import { fullSelection } from "../render/model.mjs";
import { readTree, writeTree } from "../write-tree.mjs";
import { loadCommittedWorkspace } from "./committed.mjs";

function summarize(validation, manifest) {
  return {
    ok: validation.ok,
    errors: validation.error_count,
    warnings: validation.warning_count,
    examples_executed: validation.examples.executed,
    files: validation.files,
    total_bytes: validation.total_bytes,
    largest: validation.largest,
    layers: manifest.layers,
    fingerprint: manifest.build.fingerprint,
    workspace_fingerprint: manifest.build.workspace_fingerprint,
  };
}

export async function runIntrospect(values) {
  const config = loadConfig();
  const databaseUrl = resolveDatabaseUrl(values["db-url"]);
  const pool = await openPool(databaseUrl);
  try {
    const { ir } = await introspectToIr(pool, config, databaseUrl);
    const json = prettyJson(ir);
    if (values.out) writeFileSync(values.out, json, "utf8");
    else process.stdout.write(json);
    return ExitCode.OK;
  } finally {
    await pool.end();
  }
}

export async function runBuild(values) {
  const config = loadConfig({ enrichment: values.enrichment, workspace: values.out });
  const { files, validation, manifest } = await buildFromDatabase(config, { databaseUrl: values["db-url"] });
  const summary = summarize(validation, manifest);
  if (!validation.ok) {
    const failedDir = path.join(config.repositoryRoot, ".schema-workspace-failed");
    writeTree(failedDir, files);
    process.stderr.write(`${JSON.stringify({ code: "VALIDATION_FAILED", message: `${validation.error_count} validation error(s); tree written to ${failedDir}`, errors: validation.errors.slice(0, 40) }, null, 2)}\n`);
    process.stdout.write(`${JSON.stringify(summary, null, 2)}\n`);
    return ExitCode.DOMAIN;
  }
  if (!values["dry-run"]) writeTree(config.paths.workspace, files);
  process.stdout.write(`${JSON.stringify({ ...summary, written: values["dry-run"] ? null : config.paths.workspace }, null, 2)}\n`);
  return ExitCode.OK;
}

/** Re-renders from the committed IR and compares with the committed tree; executes examples when a DB is reachable. */
export async function runValidate(values) {
  const config = loadConfig({ workspace: values.workspace });
  const { ir, enrichment } = loadCommittedWorkspace(config);
  const databaseUrl = values["db-url"] ?? process.env.POSTGRES_URL_NON_POOLING ?? process.env.POSTGRES_URL;
  const pool = databaseUrl ? await openPool(databaseUrl) : null;
  try {
    const committed = readTree(config.paths.workspace);
    const { files, validation } = await assembleWorkspace({ ir, enrichment, selection: fullSelection(ir, enrichment), config, pool, introspectedAt: JSON.parse(committed.get("manifest.json")).build.volatile.introspected_at });
    const differing = [...files].filter(([file, content]) => file !== "validation.json" && committed.get(file) !== content).map(([file]) => file);
    const missing = [...committed.keys()].filter((file) => !files.has(file));
    const result = { ...validation, rerender_differences: differing, files_not_rerendered: missing };
    process.stdout.write(`${JSON.stringify({ ok: result.ok && differing.length === 0 && missing.length === 0, errors: result.error_count, rerender_differences: differing.length, files_not_rerendered: missing.length, examples_executed: validation.examples.executed, details: result.errors.slice(0, 40) }, null, 2)}\n`);
    return result.ok && differing.length === 0 && missing.length === 0 ? ExitCode.OK : ExitCode.DOMAIN;
  } finally {
    await pool?.end();
  }
}
