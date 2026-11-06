import { existsSync, readFileSync, writeFileSync } from "node:fs";
import path from "node:path";
import { prettyJson } from "../canonical.mjs";
import { loadConfig } from "../config.mjs";
import { ErrorCode, ExitCode, WorkspaceError } from "../errors.mjs";
import { assembleWorkspace } from "../pipeline.mjs";
import { selectionForScope } from "../selection.mjs";
import { writeTree } from "../write-tree.mjs";
import { loadCommittedWorkspace } from "./committed.mjs";

export { selectionForScope };

const SCOPE_FORMAT = "ai-engineer-schema-scope/1";
const FORMAT_TREE = "tree";
const FORMAT_JSON_BUNDLE = "json-bundle";
const BUNDLE_FORMAT = "ai-engineer-schema-workspace-bundle/1";

function loadScope(reference, config) {
  const file = reference.endsWith(".json") ? path.resolve(reference) : path.join(config.paths.scopes, `${reference}.json`);
  if (!existsSync(file)) throw new WorkspaceError(ErrorCode.SCOPE_INVALID, `Scope file not found: ${file}`);
  const scope = JSON.parse(readFileSync(file, "utf8"));
  if (scope.format !== SCOPE_FORMAT || !scope.id) throw new WorkspaceError(ErrorCode.SCOPE_INVALID, `Scope must declare format "${SCOPE_FORMAT}" and an id.`);
  return scope;
}

function writeJsonBundle({ files, manifest, scope, validation, values, config }) {
  const bundle = prettyJson({ format: BUNDLE_FORMAT, manifest, files: Object.fromEntries(files) });
  const target = values.out ?? path.join(config.repositoryRoot, "workspace-bundles", `${scope.id}.json`);
  writeFileSync(target, bundle, "utf8");
  process.stdout.write(`${JSON.stringify({ ok: validation.ok, scope: scope.id, written: target, files: files.size, total_bytes: validation.total_bytes }, null, 2)}\n`);
}

function writeTreeBundle({ files, outDir, scope, validation, selection }) {
  writeTree(outDir, files);
  process.stdout.write(
    `${JSON.stringify({ ok: validation.ok, scope: scope.id, written: outDir, files: files.size, total_bytes: validation.total_bytes, included: selection.scope.included, omitted: { relations: selection.scope.omitted.relations, functions: selection.scope.omitted.functions }, errors: validation.errors.slice(0, 20) }, null, 2)}\n`,
  );
}

export async function runMaterialize(values) {
  if (!values.scope) throw new WorkspaceError(ErrorCode.USAGE, "materialize requires --scope <id|file>");
  const config = loadConfig({ workspace: values.workspace });
  const scope = loadScope(values.scope, config);
  const { ir, enrichment } = loadCommittedWorkspace(config);
  const selection = selectionForScope(ir, enrichment, scope);
  const { files, validation, manifest } = await assembleWorkspace({ ir, enrichment, selection, config, introspectedAt: null });
  const format = values.format ?? FORMAT_TREE;
  const outDir = values.out ?? path.join(config.repositoryRoot, "workspace-bundles", scope.id);
  if (format === FORMAT_JSON_BUNDLE) {
    writeJsonBundle({ files, manifest, scope, validation, values, config });
  } else if (format === FORMAT_TREE) {
    writeTreeBundle({ files, outDir, scope, validation, selection });
  } else {
    throw new WorkspaceError(ErrorCode.USAGE, `Unknown --format "${format}" (tree | json-bundle)`);
  }
  return validation.ok ? ExitCode.OK : ExitCode.DOMAIN;
}
