import { digest, prettyJson } from "./canonical.mjs";
import { assertHeadMatches, describeSource, openPool, resolveDatabaseUrl } from "./db.mjs";
import { loadEnrichment } from "./enrichment/load.mjs";
import { ErrorCode, WorkspaceError } from "./errors.mjs";
import { buildIr, workspaceFingerprint } from "./ir/build-ir.mjs";
import { indexGeneratedTypes, indexMigrations } from "./ir/repository-inputs.mjs";
import { introspect } from "./introspect.mjs";
import { fullSelection, pages } from "./render/model.mjs";
import { renderWorkspace } from "./render/render-workspace.mjs";
import { validateWorkspace } from "./validate.mjs";

/** Introspects the connected database into the derived IR. Caller owns the pool. */
export async function introspectToIr(pool, config, databaseUrl) {
  const migrationHead = await assertHeadMatches(pool, config.paths.migrations);
  const raw = await introspect(pool, config);
  const migrationIndex = indexMigrations(config.paths.migrations);
  const generatedTypes = indexGeneratedTypes(config.paths.generatedTypes);
  const build = {
    contract_version: config.contractVersion,
    migration_head: migrationHead,
    generated_types_sha256: generatedTypes.sha256,
    enrichment_sha256: null,
    renderer_version: config.rendererVersion,
    source: describeSource(databaseUrl),
  };
  return buildIr(raw, { config, migrationIndex, typePaths: generatedTypes.paths, build });
}

function attachEnrichment(ir, config) {
  const { enrichment, issues } = loadEnrichment(config.paths.enrichment, ir);
  if (issues.length > 0) throw new WorkspaceError(ErrorCode.ENRICHMENT_INVALID, `${issues.length} enrichment issue(s)`, { issues });
  ir.build.enrichment_sha256 = enrichment.sha256;
  ir.workspace_fingerprint = workspaceFingerprint(ir, enrichment.sha256, config.rendererVersion);
  return enrichment;
}

export function buildInfoFor(ir, enrichment, config) {
  return {
    ...ir.build,
    fingerprint: ir.fingerprint,
    workspace_fingerprint: ir.workspace_fingerprint,
    rules_sha256: digest(enrichment.ingestion_rules.rules).slice("sha256:".length),
    renderer_version: config.rendererVersion,
  };
}

function layerCounts(files) {
  const count = (predicate) => [...files.keys()].filter(predicate).length;
  return {
    domains: count((file) => file.startsWith("domains/")),
    schemas: count((file) => file.startsWith("schemas/")),
    relations: count((file) => file.startsWith("relations/") && file.endsWith(".md") && !file.endsWith(".details.md") && !file.endsWith(".stub.md")),
    relation_details: count((file) => file.endsWith(".details.md")),
    relation_stubs: count((file) => file.endsWith(".stub.md")),
    functions: count((file) => file.startsWith("functions/")),
    types: count((file) => file.startsWith("types/")),
    vocabularies: count((file) => file.startsWith("vocabularies/")),
    tasks: count((file) => file.startsWith("tasks/")),
  };
}

function manifestFor({ files, buildInfo, selection, validation, config, enrichment, introspectedAt }) {
  return {
    format: config.workspaceFormat,
    build: {
      contract_version: buildInfo.contract_version,
      migration_head: buildInfo.migration_head,
      renderer_version: buildInfo.renderer_version,
      fingerprint: buildInfo.fingerprint,
      workspace_fingerprint: buildInfo.workspace_fingerprint,
      generated_types_sha256: buildInfo.generated_types_sha256,
      enrichment_sha256: buildInfo.enrichment_sha256,
      rules_version: `${enrichment.ingestion_rules.version}@${buildInfo.rules_sha256}`,
      catalog_version: enrichment.queries.catalog_version,
      volatile: { introspected_at: introspectedAt, source: buildInfo.source },
    },
    scope: selection.scope,
    layers: { ...layerCounts(files), queries: selection.queryNames.size },
    sizes: { total_bytes: validation.total_bytes, files: validation.files, largest: validation.largest },
    budgets: config.budgets,
    entry_points: [pages.start, pages.index, pages.relationsList, pages.queriesReadme, pages.rulesReadme],
  };
}

/**
 * Renders + validates a workspace for a selection and appends manifest/fingerprint/validation
 * files. Returns `{ files, validation, manifest }`; throws nothing on validation errors (the
 * caller decides the exit code) but throws on infrastructure failures.
 */
export async function assembleWorkspace({ ir, enrichment, selection, config, pool = null, typescriptIssues = [], introspectedAt = null }) {
  const buildInfo = buildInfoFor(ir, enrichment, config);
  const { files, model } = renderWorkspace({ ir, enrichment, selection, buildInfo, budgets: config.budgets });
  const validation = await validateWorkspace({ files, model, config, pool, typescriptIssues });
  const manifest = manifestFor({ files, buildInfo, selection, validation, config, enrichment, introspectedAt });
  files.set(pages.fingerprint, prettyJson({
    fingerprint: buildInfo.fingerprint,
    workspace_fingerprint: buildInfo.workspace_fingerprint,
    inputs: { migration_head: buildInfo.migration_head, contract_version: buildInfo.contract_version, generated_types_sha256: buildInfo.generated_types_sha256, enrichment_sha256: buildInfo.enrichment_sha256, renderer_version: buildInfo.renderer_version },
    scope: selection.scope ? { id: selection.scope.id, sha256: selection.scope.sha256 } : null,
  }));
  files.set(pages.validation, prettyJson(validation));
  files.set(pages.manifest, prettyJson(manifest));
  return { files, validation, manifest, model };
}

/** Full build from a live database: introspect → IR → enrichment → render → validate. */
export async function buildFromDatabase(config, options = {}) {
  const databaseUrl = resolveDatabaseUrl(options.databaseUrl);
  const pool = await openPool(databaseUrl);
  try {
    const introspectedAt = new Date().toISOString();
    const { ir, typescriptIssues } = await introspectToIr(pool, config, databaseUrl);
    const enrichment = attachEnrichment(ir, config);
    const selection = fullSelection(ir, enrichment);
    const assembled = await assembleWorkspace({ ir, enrichment, selection, config, pool, typescriptIssues, introspectedAt });
    return { ...assembled, ir, enrichment };
  } finally {
    await pool.end();
  }
}
