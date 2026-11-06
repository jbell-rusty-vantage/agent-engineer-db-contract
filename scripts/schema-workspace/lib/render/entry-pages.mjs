import { prettyJson } from "../canonical.mjs";
import { anchorOf, code, curated, frontmatter, heading, joinBlocks, link, table } from "./markdown.mjs";
import { isViewKind, pages } from "./model.mjs";

export function renderStartHere(model) {
  const { buildInfo, selection } = model;
  const scopeParagraph = selection.scope
    ? `This bundle (\`${selection.scope.id}\`, digest \`${selection.scope.sha256}\`) omits ${selection.scope.omitted.relations} relations you were not expected to need. **Omission is not access control**; the executor and the database roles decide what you may do. The complete workspace is available to operators at fingerprint \`${buildInfo.workspace_fingerprint}\`.`
    : "";
  const content =
    frontmatter({ id: "start", kind: "entry", workspace_fingerprint: buildInfo.workspace_fingerprint, migration_head: buildInfo.migration_head, contract_version: buildInfo.contract_version, scope: selection.scope?.id ?? null }) +
    joinBlocks([
      heading(1, "Start here"),
      `This workspace describes the shared AI Engineer database at migration head \`${buildInfo.migration_head}\` (contract ${buildInfo.contract_version}). It is generated from the database catalog; blocks marked \`> curated\` are human guidance that was validated against the catalog but is not enforced by it.`,
      scopeParagraph,
      heading(2, "Navigation rule (≤ 4 reads to an operation)"),
      [
        "1. Search before reading: `rg -n \"<word>\" search/index.json` or `jq -c '.[] | select(.aliases[]? == \"<alias>\")' search/index.json`.",
        "2. Read the **domain** page (`domains/<slug>.md`) before any relation page.",
        "3. Read a **task** page (`tasks/<slug>.md`) if your question matches one; it names the exact named query or intent skeleton.",
        "4. Open a **relation** or **function** page only to compose a proposal or an unusual read.",
        "5. Never read `schema-ir.json` or `search/index.json` whole.",
      ].join("\n"),
      heading(2, "Entry points"),
      ["- `INDEX.md` — domains, schemas, counts.", "- `relations.txt` — every relation name (grep it).", "- `queries/README.md` — every named query you can run with `knowledge db query`.", "- `rules/README.md` — ingestion rules the executor applies to your proposals."].join("\n"),
      heading(2, "Reading and writing"),
      "Applications and agents read through named queries (role `app_reader` or `pipeline_agent`). Canonical facts are written only by `executor_service` through `temporal.begin_batch` → `temporal.assert_*` → `temporal.commit_batch`, and only via a receipt. You author intents; the knowledge executor writes. Only facts rendered as plain text or tables are enforced by the database; `> curated` blocks are guidance.",
    ]);
  return { path: pages.start, content };
}

function domainIndexRow(model, domain) {
  const relationIds = model.relationsOfDomain(domain.slug).filter((relationId) => model.selection.relationIds.has(relationId));
  const functionIds = model.functionsOfDomain(domain.slug).filter((functionId) => model.selection.functionIds.has(functionId));
  const schemas = [...new Set(relationIds.map((relationId) => model.ir.relations[relationId].schema))].sort();
  const tasks = model.tasksOfDomain(domain.slug).filter((task) => model.selection.taskSlugs.has(task.slug)).slice(0, 2);
  const starts = [link(code(pages.domain(domain.slug)), pages.index, pages.domain(domain.slug)), ...tasks.map((task) => link(code(pages.task(task.slug)), pages.index, pages.task(task.slug)))];
  return [link(domain.slug, pages.index, pages.domain(domain.slug)), schemas.join(", ") || "—", relationIds.length, functionIds.length, starts.join(", ")];
}

function schemaIndexRow(model, schema) {
  const relationCount = schema.relation_ids.filter((relationId) => model.selection.relationIds.has(relationId)).length;
  const functionCount = schema.function_ids.filter((functionId) => model.selection.functionIds.has(functionId)).length;
  const label = relationCount + functionCount > 0 ? link(code(schema.name), pages.index, pages.schemaReadme(schema.name)) : `${code(schema.name)} (out of scope)`;
  return [label, relationCount, functionCount, model.enrichment.schema_domains[schema.name] ?? "—"];
}

export function renderIndex(model) {
  const rows = model.visibleDomains().map((domain) => domainIndexRow(model, domain));
  const schemaRows = Object.values(model.ir.schemas).map((schema) => schemaIndexRow(model, schema));
  const totals = {
    relations: model.visibleRelations().length,
    functions: model.visibleFunctions().length,
    tasks: model.visibleTasks().length,
    queries: model.visibleQueries().length,
  };
  const content =
    frontmatter({ id: "index", kind: "entry", workspace_fingerprint: model.buildInfo.workspace_fingerprint, migration_head: model.buildInfo.migration_head }) +
    joinBlocks([
      heading(1, "Index"),
      heading(2, "Domains"),
      table(["Domain", "Schemas", "#Relations", "#Functions", "Start with"], rows),
      heading(2, "Schemas"),
      table(["Schema", "#Relations", "#Functions", "Default domain"], schemaRows),
      `Counts at head \`${model.buildInfo.migration_head}\`: ${totals.relations} relations (child partitions folded into their parents), ${totals.functions} function overloads, ${totals.tasks} tasks, ${totals.queries} named queries. Vocabularies: ${Object.values(model.ir.vocabularies).map((vocabulary) => link(code(`${vocabulary.schema}.${vocabulary.table}`), pages.index, pages.vocabulary(vocabulary))).join(", ")}.`,
    ]);
  return { path: pages.index, content };
}

export function renderRelationsList(model) {
  const lines = [];
  for (const schema of Object.values(model.ir.schemas)) {
    const relations = schema.relation_ids.filter((relationId) => model.selection.relationIds.has(relationId)).map((relationId) => model.ir.relations[relationId]);
    if (relations.length === 0) continue;
    const views = relations.filter((relation) => isViewKind(relation.kind));
    lines.push(`# ${schema.name}${views.length === relations.length ? " (views)" : ""}`);
    for (const relation of relations) lines.push(`${relation.schema}.${relation.name}${isViewKind(relation.kind) ? "  # view" : ""}`);
  }
  if (model.selection.scope) lines.push(`# omitted by scope ${model.selection.scope.id}: ${model.selection.scope.omitted.relations} relations`);
  return { path: pages.relationsList, content: `${lines.join("\n")}\n` };
}

function queryRow(model, entry) {
  return [
    `<a id="${anchorOf(entry.name)}"></a>${code(entry.name)}`,
    entry.role,
    entry.cost_class,
    entry.paramOrder.map((name) => code(name)).join(", ") || "—",
    entry.result.shape,
    entry.domain ? (model.selection.domainSlugs.has(entry.domain) ? link(code(entry.domain), pages.queriesReadme, pages.domain(entry.domain)) : code(entry.domain)) : "—",
    entry.summary,
  ];
}

export function renderQueriesReadme(model) {
  const entries = model.visibleQueries();
  const pending = entries.filter((entry) => !entry.execute);
  const content =
    frontmatter({ id: "queries", kind: "entry", queries: entries.length, catalog_version: model.enrichment.queries.catalog_version, workspace_fingerprint: model.buildInfo.workspace_fingerprint }) +
    joinBlocks([
      heading(1, "Named queries"),
      `Every entry runs as data from \`catalog.json\` (\`knowledge-query-catalog.v1\`, digest \`${model.enrichment.queries.catalog_version}\`): the executor opens a read-only transaction, sets \`app.tenant_id\`, \`SET LOCAL ROLE <role>\`, applies the statement timeout of the cost class, binds \`paramOrder\` positionally, and caps rows at \`limit\` (default ${model.enrichment.queries.defaults.limit}, max ${model.enrichment.queries.defaults.maxLimit}). Run one with \`knowledge db query <name> --param k=v\`, or batch several in a \`knowledge-read-intent.v1\` (\`knowledge db read-intent intent.json\`). The snapshot records the knowledge head so your ingestion intent can cite it.`,
      table(["Query", "Role", "Cost", "Params", "Shape", "Domain", "Summary"], entries.map((entry) => queryRow(model, entry))),
      pending.length > 0 ? `${heading(2, "Pending (not executed at build)")}\n${pending.map((entry) => `- ${code(entry.name)}: ${entry.execute_skip_reason}`).join("\n")}\n` : "",
      heading(2, "Parameters"),
      entries.map(queryParameterLine).join("\n"),
    ]);
  return { path: pages.queriesReadme, content };
}

function queryParameterLine(entry) {
  const properties =
    Object.entries(entry.params.properties ?? {})
      .map(([name, schema]) => `${code(name)} ${Array.isArray(schema.type) ? schema.type.join("|") : schema.type ?? "any"}${(entry.params.required ?? []).includes(name) ? "" : "?"}`)
      .join(", ") || "none";
  const example = Object.keys(entry.example).length > 0 ? ` — example ${code(JSON.stringify(entry.example))}` : "";
  return `- ${code(entry.name)}: ${properties}${example}`;
}

export function renderCatalog(model) {
  const entries = model.visibleQueries().map(({ provenance, reviewed, execute, execute_skip_reason, aliases, summary, ...entry }) => ({
    ...entry,
    ...(execute ? {} : { pending: execute_skip_reason }),
  }));
  return {
    path: pages.catalog,
    content: prettyJson({
      schemaVersion: "knowledge-query-catalog.v1",
      catalogVersion: model.enrichment.queries.catalog_version,
      migrationHead: model.buildInfo.migration_head,
      workspaceFingerprint: model.buildInfo.workspace_fingerprint,
      defaults: model.enrichment.queries.defaults,
      entries,
    }),
  };
}

export function renderRules(model) {
  const { ingestion_rules: rules } = model.enrichment;
  const rulesVersion = `${rules.version}@${model.buildInfo.rules_sha256}`;
  const readme =
    frontmatter({ id: "rules", kind: "entry", rules: rules.rules.length, rules_version: rulesVersion, workspace_fingerprint: model.buildInfo.workspace_fingerprint }) +
    joinBlocks([
      heading(1, "Ingestion rules"),
      `The knowledge executor applies these rules in its plan phase and cites \`rulesVersion: ${rulesVersion}\` in every plan and receipt. \`basis: enforced\` means the database already guarantees the rule (the executor only reports it early); \`basis: curated\` means only the executor checks it.`,
      table(
        ["Rule", "Basis", "Applies to", "Action", "Detail"],
        rules.rules.map((rule) => [code(rule.id), rule.basis, Object.entries(rule.applies_to).map(([key, value]) => `${key}=${code(value)}`).join(" ") || "all", rule.action, rule.detail]),
      ),
      ...rules.rules.filter((rule) => rule.refs.length > 0).map((rule) => `${code(rule.id)} refs: ${rule.refs.map(code).join(", ")}`),
    ]);
  const json = prettyJson({
    schemaVersion: rules.version,
    rulesVersion,
    migrationHead: model.buildInfo.migration_head,
    rules: rules.rules,
  });
  return [
    { path: pages.rulesReadme, content: readme },
    { path: pages.rulesJson, content: json },
  ];
}
