import { prettyJson } from "../canonical.mjs";
import { operationLink } from "./links.mjs";
import { anchorOf, code, frontmatter, heading, joinBlocks, link, table, truncate } from "./markdown.mjs";
import { isViewKind, pages } from "./model.mjs";

/** The knowledge continuum router: question shape → level → the one page to open. Names are resolved against the selection. */
const ROUTER = [
  {
    level: "L1 catalog",
    question: "filter, compare, rank a kind of thing (no embeddings)",
    relations: ["api.models", "api.model_offerings", "api.software", "api.software_releases", "api.talks", "api.people", "api.organizations", "api.events", "api.concepts", "api.papers", "api.benchmark_scores", "api.works_authored", "api.guidance_items", "api.verified_claims", "api.claim_verdicts", "api.probes", "api.source_registry"],
    functions: [],
  },
  {
    level: "L2 facts and time",
    question: "true when, changed since, what is due, where a number was read",
    relations: [],
    functions: ["api.changes_since", "api.price_history", "api.fact_locators", "api.entity_at", "api.what_changed", "api.modules_affected_by_release", "api.attention_due", "api.probe_revalidation_due", "api.releases_needing_review"],
  },
  {
    level: "L3 scoped semantic",
    question: "passages inside a scope (lens, tier, space, doc type, unit kind, entity, as-of, workspace)",
    relations: [],
    functions: ["api.search_unified", "api.talk_segments", "api.document_units", "api.document_digest"],
  },
];
const REPORT_OPERATION = "create_work";
/** The task page that lists the governed writes of the verification chain (claims, probes, verdicts, triage, sweeps). */
const CHAIN_WRITE_TASK = "write-verification-chain";
const MAP_SUMMARY_LENGTH = 64;

function relationLinkByName(model, fromPage, qualifiedName) {
  const relationId = `rel:${qualifiedName}`;
  const target = model.relationPage(relationId);
  const label = qualifiedName.slice(qualifiedName.indexOf(".") + 1);
  return target ? link(label, fromPage, target) : code(label);
}

function functionLinkByName(model, fromPage, qualifiedName) {
  const overloads = model.ir.derived.function_ids_by_name[qualifiedName] ?? [];
  const target = overloads.length > 0 ? model.functionPage(overloads[0]) : null;
  const label = qualifiedName.slice(qualifiedName.indexOf(".") + 1);
  return target ? link(label, fromPage, target) : code(label);
}

function routerLine(model, fromPage, row) {
  const links = [...row.relations.map((name) => relationLinkByName(model, fromPage, name)), ...row.functions.map((name) => functionLinkByName(model, fromPage, name))];
  return `- **${row.level}** — ${row.question}: ${links.join(", ")}.`;
}

function hiddenLensLine(model) {
  const hidden = (model.lenses.hidden ?? []).filter((lens) => Object.values(model.lenses.schemas ?? {}).includes(lens));
  return hidden.length > 0 ? `${hidden.join(" and ")}: see ${link("INDEX.md", pages.start, pages.index)}.` : "";
}

/** One sentence of the Writing section, present when the selection carries the task (a scope may leave it out). */
function chainWriteLine(model, fromPage) {
  if (!model.selection.taskSlugs.has(CHAIN_WRITE_TASK)) return "";
  const target = pages.task(CHAIN_WRITE_TASK);
  return ` Claims, probes, verdicts, triage and sweeps go through governed ${code("api")} writes: ${link(target, fromPage, target)}.`;
}

export function renderStartHere(model) {
  const { buildInfo, selection } = model;
  const page = pages.start;
  const scopeLine = selection.scope ? `Scope ${code(selection.scope.id)} omits ${selection.scope.omitted.relations} relations.` : "";
  const visibleLenses = (model.lenses.names ?? []).filter((lens) => !model.isHiddenLens(lens));
  const content =
    frontmatter({ id: "start", kind: "entry", workspace_fingerprint: buildInfo.workspace_fingerprint, migration_head: buildInfo.migration_head, contract_version: buildInfo.contract_version, scope: selection.scope?.id ?? null }) +
    joinBlocks([
      heading(1, "Start here"),
      `AI Engineer database at head ${code(buildInfo.migration_head)} (contract ${buildInfo.contract_version}); generated from the catalog, ${code("> curated")} blocks are guidance. ${scopeLine}`.trim(),
      heading(2, "Router: question shape → level → page"),
      [
        ...ROUTER.map((row) => routerLine(model, page, row)),
        `- **L4 agentic** — budgeted loop over L1–L3 (search → read → verify with fact_locators), filed as a report: ${operationLink(model, page, REPORT_OPERATION)} with kind ${code("report")} via ${functionLinkByName(model, page, "api.product_command")}.`,
      ].join("\n"),
      heading(2, "Four reads, at most"),
      [
        `1. ${code('rg -n "<word>" search/index.json')} (never whole); entries carry ${code("lens")} and ${code("domain")}.`,
        `2. The matching domain (${code("domains/<slug>.md")}) or task (${code("tasks/<slug>.md")}) page.`,
        `3. The one relation, function or operation page it names.`,
        `4. Run the named query (${link("queries/README.md", page, pages.queriesReadme)}) or the operation (${code("ops/<op>.md")}).`,
      ].join("\n"),
      heading(2, "Lenses"),
      `${visibleLenses.map(code).join(", ")} — whose knowledge: ours (courses, notes, reports), private (one workspace's passages), corpus (industry knowledge), evidence (claims, locators, admissions). ${hiddenLensLine(model)}`.trim(),
      heading(2, "Entry points"),
      `${link("MAP.md", page, pages.map)} schemas by lens · ${link("INDEX.md", page, pages.index)} domains, ops, counts · ${code("relations.txt")} · ${link("rules/README.md", page, pages.rulesReadme)} ingestion rules.`,
      heading(2, "Writing"),
      `Apps and agents write through product operations (${code("ops/")}); canonical facts only via ${code("executor_service")} (${code("temporal.begin_batch")} → ${code("assert_*")} → ${code("commit_batch")}, under a receipt). You author intents; the executor writes.${chainWriteLine(model, page)}`,
    ]);
  return { path: page, content };
}

function schemaSummary(model, schema) {
  const domainSlug = model.enrichment.schema_domains[schema.name];
  const domain = domainSlug ? model.domainBySlug.get(domainSlug) : null;
  return truncate(schema.comment ?? domain?.summary ?? `relations and functions of ${schema.name}`, MAP_SUMMARY_LENGTH);
}

function mapLine(model, schema) {
  const page = pages.map;
  const domainSlug = model.enrichment.schema_domains[schema.name];
  const entry = model.schemaHasPages(schema.name) ? link("schema", page, pages.schemaReadme(schema.name)) : "schema";
  const domainLink = domainSlug && model.selection.domainSlugs.has(domainSlug) ? link(`dom:${domainSlug}`, page, pages.domain(domainSlug)) : domainSlug ? `dom:${domainSlug}` : "";
  return `- ${code(schema.name)} — ${schemaSummary(model, schema)} → ${entry}${domainLink ? ` · ${domainLink}` : ""}`;
}

/** One screen: schemas grouped by lens, one line each, with the entry page. Hidden lenses collapse to one line. */
export function renderMap(model) {
  const page = pages.map;
  const schemas = Object.values(model.ir.schemas);
  const lensOrder = model.lenses.names ?? [...new Set(schemas.map((schema) => model.lensOfSchema(schema.name)))];
  const sections = [];
  const hidden = [];
  for (const lens of lensOrder) {
    const members = schemas.filter((schema) => model.lensOfSchema(schema.name) === lens);
    if (members.length === 0) continue;
    if (model.isHiddenLens(lens)) {
      hidden.push(`${lens}: ${members.map((schema) => code(schema.name)).join(", ")}`);
      continue;
    }
    sections.push(`${heading(2, lens)}${members.map((schema) => mapLine(model, schema)).join("\n")}\n`);
  }
  const content =
    frontmatter({ id: "map", kind: "entry", workspace_fingerprint: model.buildInfo.workspace_fingerprint, lenses: lensOrder }) +
    joinBlocks([
      heading(1, "Map: schemas by lens"),
      ...sections,
      hidden.length > 0 ? `Machinery and legacy (hidden by default): ${hidden.join("; ")} — see ${link("INDEX.md", page, pages.index)}.` : "",
    ]);
  return { path: page, content };
}

function domainIndexRow(model, domain) {
  const relationIds = model.relationsOfDomain(domain.slug).filter((relationId) => model.selection.relationIds.has(relationId));
  const functionIds = model.functionsOfDomain(domain.slug).filter((functionId) => model.selection.functionIds.has(functionId));
  const schemas = [...new Set(relationIds.map((relationId) => model.ir.relations[relationId].schema))].sort();
  const tasks = model.tasksOfDomain(domain.slug).filter((task) => model.selection.taskSlugs.has(task.slug)).slice(0, 2);
  const starts = [link(code(pages.domain(domain.slug)), pages.index, pages.domain(domain.slug)), ...tasks.map((task) => link(code(pages.task(task.slug)), pages.index, pages.task(task.slug)))];
  return [link(domain.slug, pages.index, pages.domain(domain.slug)), model.lensOfDomain(domain.slug) ?? "—", schemas.join(", ") || "—", relationIds.length, functionIds.length, starts.join(", ")];
}

function schemaIndexRow(model, schema) {
  const relationCount = schema.relation_ids.filter((relationId) => model.selection.relationIds.has(relationId)).length;
  const functionCount = schema.function_ids.filter((functionId) => model.selection.functionIds.has(functionId)).length;
  const label = relationCount + functionCount > 0 ? link(code(schema.name), pages.index, pages.schemaReadme(schema.name)) : `${code(schema.name)} (out of scope)`;
  return [label, model.lensOfSchema(schema.name) ?? "—", relationCount, functionCount, model.enrichment.schema_domains[schema.name] ?? "—"];
}

function operationIndexRow(model, operation) {
  const touched = [...operation.writes, ...operation.reads].sort();
  return [link(code(operation.name), pages.index, pages.operation(operation.name)), operation.dispatcher, code(operation.call), touched.map(code).join(", ") || "—"];
}

export function renderIndex(model) {
  const rows = model.visibleDomains().map((domain) => domainIndexRow(model, domain));
  const schemaRows = Object.values(model.ir.schemas).map((schema) => schemaIndexRow(model, schema));
  const operations = model.visibleOperations();
  const totals = {
    relations: model.visibleRelations().length,
    functions: model.visibleFunctions().length,
    tasks: model.visibleTasks().length,
    queries: model.visibleQueries().length,
    operations: operations.length,
  };
  const content =
    frontmatter({ id: "index", kind: "entry", workspace_fingerprint: model.buildInfo.workspace_fingerprint, migration_head: model.buildInfo.migration_head }) +
    joinBlocks([
      heading(1, "Index"),
      `Lenses: ${(model.lenses.names ?? []).map(code).join(", ")}. ${link("MAP.md", pages.index, pages.map)} shows the visible lenses only; this page lists everything, including ${(model.lenses.hidden ?? []).map(code).join(" and ") || "nothing hidden"}.`,
      heading(2, "Domains"),
      table(["Domain", "Lens", "Schemas", "#Relations", "#Functions", "Start with"], rows),
      heading(2, "Schemas"),
      table(["Schema", "Lens", "#Relations", "#Functions", "Default domain"], schemaRows),
      heading(2, "Operations"),
      operations.length > 0
        ? `Product operations dispatched by ${code("product.dispatch_*")}; call them through ${code("api.product_command")} / ${code("api.product_read")} / ${code("api.product_worker")}. One page each under ${code("ops/")}.\n\n${table(["Operation", "Dispatcher", "Call", "Relations touched (best effort)"], operations.map((operation) => operationIndexRow(model, operation)))}`
        : "_No operations in this selection._\n",
      `Counts at head ${code(model.buildInfo.migration_head)}: ${totals.relations} relations (child partitions folded into their parents), ${totals.functions} function overloads, ${totals.operations} operations, ${totals.tasks} tasks, ${totals.queries} named queries. Vocabularies: ${Object.values(model.ir.vocabularies).map((vocabulary) => link(code(`${vocabulary.schema}.${vocabulary.table}`), pages.index, pages.vocabulary(vocabulary))).join(", ")}.`,
    ]);
  return { path: pages.index, content };
}

export function renderRelationsList(model) {
  const lines = [];
  for (const schema of Object.values(model.ir.schemas)) {
    const relations = schema.relation_ids.filter((relationId) => model.selection.relationIds.has(relationId)).map((relationId) => model.ir.relations[relationId]);
    if (relations.length === 0) continue;
    const views = relations.filter((relation) => isViewKind(relation.kind));
    lines.push(`# ${schema.name}${views.length === relations.length ? " (views)" : ""}  lens=${model.lensOfSchema(schema.name) ?? "none"}`);
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
