import path from "node:path/posix";
import { byteLength } from "./canonical.mjs";
import { ErrorCode } from "./errors.mjs";
import { pages } from "./render/model.mjs";

const MARKDOWN_LINK = /\]\(([^)\s]+)\)/g;
const FRONTMATTER_LINE = /^([a-z_]+): (.*)$/;
const VOCABULARY_REFERENCE = /`([a-z_]+):([a-z0-9_.-]+)`/g;
const READ_INTENT_SCHEMA = "knowledge-read-intent.v1";
const INGESTION_INTENT_SCHEMA = "knowledge-ingestion-intent.v1";
const KNOWN_PROPOSAL_KINDS = new Set(["entity.create", "entity.alias", "entity.identifier", "relationship.assert", "fact.assert_state", "event.assert", "support.admit", "claim.materialize", "metric.observe", "candidate.stage", "report.publish"]);

class Report {
  constructor() {
    this.errors = [];
    this.warnings = [];
  }
  error(code, file, message) {
    this.errors.push({ code, file, message });
  }
  warn(code, file, message) {
    this.warnings.push({ code, file, message });
  }
}

function budgetFor(filePath, budgets) {
  if (filePath.endsWith(".details.md")) return budgets.relation_details_bytes;
  if (filePath.startsWith("relations/")) return budgets.relation_main_bytes;
  if (filePath.startsWith("domains/")) return budgets.domain_bytes;
  if (filePath.startsWith("schemas/")) return budgets.schema_readme_bytes;
  if (filePath.startsWith("tasks/")) return budgets.task_bytes;
  if (filePath === pages.searchIndex) return budgets.search_index_bytes;
  return null;
}

function checkBudgets(files, budgets, report) {
  for (const [filePath, content] of files) {
    const budget = budgetFor(filePath, budgets);
    const bytes = byteLength(content);
    if (budget && bytes > budget) report.error(ErrorCode.SIZE_BUDGET_EXCEEDED, filePath, `${bytes} bytes > budget ${budget}`);
  }
}

function checkLinks(files, report) {
  for (const [filePath, content] of files) {
    if (!filePath.endsWith(".md")) continue;
    for (const match of content.matchAll(MARKDOWN_LINK)) {
      const target = match[1];
      if (/^[a-z]+:/.test(target)) continue;
      const [file] = target.split("#");
      if (!file) continue;
      const resolved = path.normalize(path.join(path.dirname(filePath), file));
      if (!files.has(resolved)) report.error(ErrorCode.BROKEN_LINK, filePath, `link to missing file ${resolved}`);
    }
  }
}

function frontmatterOf(content) {
  if (!content.startsWith("---\n")) return null;
  const end = content.indexOf("\n---\n", 4);
  if (end < 0) return null;
  const fields = {};
  for (const line of content.slice(4, end).split("\n")) {
    const match = line.match(FRONTMATTER_LINE);
    if (match) fields[match[1]] = match[2];
  }
  return fields;
}

function checkFrontmatter(files, model, report) {
  const seen = new Map();
  for (const [filePath, content] of files) {
    if (!filePath.endsWith(".md")) continue;
    const fields = frontmatterOf(content);
    if (!fields) {
      report.error(ErrorCode.VALIDATION_FAILED, filePath, "missing frontmatter");
      continue;
    }
    if (seen.has(fields.id)) report.error(ErrorCode.VALIDATION_FAILED, filePath, `frontmatter id ${fields.id} collides with ${seen.get(fields.id)}`);
    seen.set(fields.id, filePath);
    const relation = model.ir.relations[fields.id];
    if (relation && !fields.stub && filePath.startsWith("relations/")) {
      const expected = `[${relation.writers.join(", ")}]`;
      if (fields.writers !== expected) report.error(ErrorCode.VALIDATION_FAILED, filePath, `writers ${fields.writers} disagree with grants ${expected}`);
    }
  }
}

function checkCoverage(files, model, report) {
  for (const relation of model.visibleRelations()) {
    if (!files.has(pages.relation(relation))) report.error(ErrorCode.VALIDATION_FAILED, pages.relation(relation), "relation has no page");
  }
  for (const fn of model.visibleFunctions()) {
    if (!files.has(pages.function(fn))) report.error(ErrorCode.VALIDATION_FAILED, pages.function(fn), "function has no page");
  }
  for (const schema of Object.keys(model.ir.schemas)) {
    if (!model.enrichment.schema_domains[schema]) report.error(ErrorCode.ENRICHMENT_INVALID, "domains.yaml", `schema ${schema} has no default domain`);
  }
}

function checkVocabularyReferences(files, model, report) {
  const tables = new Map(Object.values(model.ir.vocabularies).map((vocabulary) => [vocabulary.table, new Set(vocabulary.rows.map((row) => String(row[vocabulary.key])))]));
  for (const [filePath, content] of files) {
    if (!(filePath.startsWith("tasks/") || filePath.startsWith("domains/") || filePath.startsWith("rules/"))) continue;
    for (const match of content.matchAll(VOCABULARY_REFERENCE)) {
      const codes = tables.get(match[1]);
      if (codes && !codes.has(match[2])) report.error(ErrorCode.ENRICHMENT_INVALID, filePath, `vocabulary code ${match[1]}:${match[2]} does not exist`);
    }
  }
}

function intentJsonBlocks(markdown) {
  return markdown.matchAll(/```json\n([\s\S]*?)```/g);
}

function parseIntentDocument(source, file, report) {
  try {
    return JSON.parse(source);
  } catch (error) {
    report.error(ErrorCode.ENRICHMENT_INVALID, file, `intent skeleton is not JSON: ${error.message}`);
    return null;
  }
}

function checkIntentDocument(document, { queryNames, file, report }) {
  if (document.schemaVersion === READ_INTENT_SCHEMA) {
    for (const operation of document.operations ?? []) {
      if (!queryNames.has(operation.query)) report.error(ErrorCode.ENRICHMENT_INVALID, file, `read intent references unknown query ${operation.query}`);
    }
    return;
  }
  if (document.schemaVersion === INGESTION_INTENT_SCHEMA) {
    for (const proposal of document.proposals ?? []) {
      if (!KNOWN_PROPOSAL_KINDS.has(proposal.kind)) report.error(ErrorCode.ENRICHMENT_INVALID, file, `ingestion intent uses unknown proposal kind ${proposal.kind}`);
    }
  }
}

function checkIntentSkeletons(model, report) {
  const queryNames = new Set(model.enrichment.queries.entries.map((entry) => entry.name));
  for (const task of model.visibleTasks()) {
    const file = pages.task(task.slug);
    for (const block of intentJsonBlocks(task.operation)) {
      const document = parseIntentDocument(block[1], file, report);
      if (document) checkIntentDocument(document, { queryNames, file, report });
    }
  }
}

function positionalParams(entry, params) {
  return entry.paramOrder.map((name) => {
    if (name.startsWith("$")) return null;
    const value = params[name] ?? entry.params.properties?.[name]?.default ?? null;
    return value !== null && typeof value === "object" && !Array.isArray(value) ? JSON.stringify(value) : value;
  });
}

async function runReadOnly(pool, { role, tenantId, timeoutMs, sql, params }) {
  const client = await pool.connect();
  try {
    await client.query("begin");
    await client.query(`set local statement_timeout = ${Number(timeoutMs)}`);
    await client.query("select set_config('app.tenant_id', $1, true)", [tenantId]);
    await client.query(`set local role ${role.replaceAll(/[^a-z_]/g, "")}`);
    await client.query("set transaction read only");
    const result = await client.query(sql, params);
    return result.rowCount;
  } finally {
    await client.query("rollback").catch(() => undefined);
    client.release();
  }
}

async function checkExecutableExamples(model, pool, config, report) {
  const executed = [];
  const timeouts = model.enrichment.queries.defaults.statementTimeoutMs;
  const timeoutFor = (entry) => timeouts[entry.cost_class] ?? config.exampleStatementTimeoutMs;
  const runExample = async (entry, params, file) => {
    try {
      const rows = await runReadOnly(pool, { role: entry.role, tenantId: config.exampleTenantId, timeoutMs: timeoutFor(entry), sql: entry.sql, params: positionalParams(entry, params) });
      executed.push({ query: entry.name, file, rows });
    } catch (error) {
      report.error(ErrorCode.EXAMPLE_FAILED, file, `${entry.name}: ${error.message}`);
    }
  };
  for (const entry of model.visibleQueries()) {
    if (!entry.execute) continue;
    await runExample(entry, entry.example, "queries.yaml");
  }
  for (const relation of model.visibleRelations()) {
    for (const example of model.overlay(relation.id)?.examples ?? []) {
      const entry = model.queryByName(example.query);
      if (!entry) continue;
      if (entry.execute) await runExample(entry, example.params, pages.relation(relation));
    }
  }
  return executed;
}

/**
 * Validates a rendered tree. `pool` is optional: without it, executable examples are skipped
 * and reported as such (used by `materialize`, which never touches the database).
 */
export async function validateWorkspace({ files, model, config, pool = null, typescriptIssues = [] }) {
  const report = new Report();
  checkBudgets(files, config.budgets, report);
  checkLinks(files, report);
  checkFrontmatter(files, model, report);
  checkCoverage(files, model, report);
  checkVocabularyReferences(files, model, report);
  checkIntentSkeletons(model, report);
  for (const issue of typescriptIssues) report.error(ErrorCode.TYPES_OUT_OF_DATE, config.paths.generatedTypes, `${issue.id}: no TypeScript path ${issue.expected}`);
  const examples = pool ? await checkExecutableExamples(model, pool, config, report) : null;
  const sizes = [...files].map(([filePath, content]) => ({ path: filePath, bytes: byteLength(content) }));
  const largest = sizes.reduce((max, item) => (item.bytes > max.bytes ? item : max), { path: null, bytes: 0 });
  return {
    ok: report.errors.length === 0,
    error_count: report.errors.length,
    warning_count: report.warnings.length,
    errors: report.errors,
    warnings: report.warnings,
    examples: examples ? { executed: examples.length, skipped: model.visibleQueries().filter((entry) => !entry.execute).map((entry) => entry.name) } : { executed: 0, skipped: "no database connection" },
    files: files.size,
    total_bytes: sizes.reduce((sum, item) => sum + item.bytes, 0),
    largest,
  };
}
