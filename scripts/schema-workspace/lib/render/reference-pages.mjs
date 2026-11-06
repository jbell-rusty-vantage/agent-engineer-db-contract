import { idTail } from "../ir/ids.mjs";
import { relationRef } from "./links.mjs";
import { code, curated, frontmatter, heading, joinBlocks, link, table, truncate } from "./markdown.mjs";
import { pages } from "./model.mjs";

function overloadSection(model, fn, fromPage) {
  const argumentRows = fn.arguments.map((argument) => [code(argument.name ?? "—"), code(argument.type), argument.default ? code(argument.default) : "—", argument.mode !== "in" ? argument.mode : ""]);
  const lines = [
    heading(2, `${fn.name}(${fn.arguments.map((argument) => argument.type).join(", ")}) → ${fn.returns}`),
    `${fn.kind}, ${fn.volatility}, security ${fn.security}, language ${fn.language}${fn.config.length > 0 ? `, config ${fn.config.map(code).join(" ")}` : ""}.${fn.comment ? ` ${fn.comment}` : ""}`,
    fn.arguments.length > 0 ? table(["Argument", "Type", "Default", "Mode"], argumentRows) : "No arguments.\n",
    `Execute: ${fn.executors.length > 0 ? fn.executors.map(code).join(", ") : "no configured role"}.`,
  ];
  if (fn.raises.length > 0) lines.push(`Raises (mechanically extracted): ${fn.raises.map((message) => code(message)).join("; ")}.`);
  const reads = fn.touches.reads.map((name) => relationRef(model, fromPage, name));
  const writes = fn.touches.writes.map((name) => relationRef(model, fromPage, name));
  const calls = fn.touches.calls.map((name) => {
    const overloads = model.ir.derived.function_ids_by_name[name] ?? [];
    const target = overloads.length > 0 ? model.functionPage(overloads[0]) : null;
    return target ? link(code(name), fromPage, target) : code(name);
  });
  if (reads.length + writes.length + calls.length > 0) {
    lines.push(`Touches (best effort): reads ${reads.join(", ") || "—"}; writes ${writes.join(", ") || "—"}; calls ${calls.join(", ") || "—"}.`);
  }
  const queries = model.queriesMentioning(fn.id);
  if (queries.length > 0) lines.push(`Named queries: ${queries.map((name) => code(`q:${name}`)).join(", ")}.`);
  if (fn.typescript) lines.push(`TypeScript: ${code(fn.typescript)}.`);
  return joinBlocks(lines);
}

/** One page per function name; overloads are sections. */
export function renderFunctionPage(model, overloads) {
  const [first] = overloads;
  const page = pages.function(first);
  const domain = model.domainOfFunction(first.id);
  const usedByViews = [...new Set(overloads.flatMap((fn) => model.viewsOver(fn.id)))].map((viewId) => {
    const target = model.relationPage(viewId);
    return target ? link(code(idTail(viewId)), page, target) : code(idTail(viewId));
  });
  const content =
    frontmatter({
      id: first.id,
      kind: "function",
      schema: first.schema,
      name: first.name,
      domain,
      overloads: overloads.map((fn) => fn.id),
      security: first.security,
      volatility: first.volatility,
      executors: [...new Set(overloads.flatMap((fn) => fn.executors))].sort(),
      raises: [...new Set(overloads.flatMap((fn) => fn.raises))].sort(),
      touches: { reads: [...new Set(overloads.flatMap((fn) => fn.touches.reads))].sort(), writes: [...new Set(overloads.flatMap((fn) => fn.touches.writes))].sort() },
      tokens: [first.schema, first.name, `${first.schema}.${first.name}`],
      defined_in: [...new Set(overloads.flatMap((fn) => fn.defined_in))].sort(),
      workspace_fingerprint: model.buildInfo.workspace_fingerprint,
    }) +
    joinBlocks([
      heading(1, `${first.schema}.${first.name}`),
      `${overloads.length > 1 ? `${overloads.length} overloads. ` : ""}Domain ${code(domain ?? "none")}.${usedByViews.length > 0 ? ` Used by views: ${usedByViews.join(", ")}.` : ""}`,
      ...overloads.map((fn) => overloadSection(model, fn, page)),
      `Defined in: ${[...new Set(overloads.flatMap((fn) => fn.defined_in))].sort().map(code).join(", ") || "unknown"}.`,
    ]);
  return { path: page, content };
}

export function renderTypesPage(model, schema, types) {
  const page = pages.types(schema);
  const enums = types.filter((type) => type.kind === "enum");
  const domains = types.filter((type) => type.kind === "domain");
  const composites = types.filter((type) => type.kind === "composite");
  const content =
    frontmatter({ id: `types:${schema}`, kind: "types", schema, enums: enums.length, domains: domains.length, composites: composites.length, workspace_fingerprint: model.buildInfo.workspace_fingerprint }) +
    joinBlocks([
      heading(1, `Types in ${schema}`),
      enums.length > 0 ? heading(2, "Enums") + table(["Enum", "Labels", "TypeScript"], enums.map((type) => [code(type.name), type.labels.map(code).join(", "), type.typescript ? code(type.typescript) : "—"])) : "",
      domains.length > 0 ? heading(2, "Domains") + table(["Domain", "Base type", "Constraints"], domains.map((type) => [code(type.name), code(type.base_type), type.constraints ?? "—"])) : "",
      composites.length > 0 ? heading(2, "Composite types") + table(["Type", "Attributes"], composites.map((type) => [code(type.name), type.attributes.map(code).join(", ")])) : "",
    ]);
  return { path: page, content };
}

function formatVocabularyCell(value) {
  if (value === null || value === undefined) return "—";
  if (Array.isArray(value)) return value.length > 0 ? value.join(", ") : "—";
  if (typeof value === "object") return `\`${truncate(JSON.stringify(value), 80)}\``;
  if (typeof value === "boolean") return value ? "yes" : "no";
  return truncate(String(value), 120);
}

export function renderVocabularyPage(model, vocabulary) {
  const page = pages.vocabulary(vocabulary);
  const columns = [vocabulary.key, ...vocabulary.columns.filter((column) => column !== vocabulary.key)];
  const relationId = `rel:${vocabulary.schema}.${vocabulary.table}`;
  const target = model.relationPage(relationId);
  const content =
    frontmatter({
      id: vocabulary.id,
      kind: "vocabulary",
      schema: vocabulary.schema,
      name: vocabulary.table,
      rows: vocabulary.rows.length,
      rows_sha256: vocabulary.rows_sha256,
      codes: vocabulary.rows.map((row) => String(row[vocabulary.key])),
      workspace_fingerprint: model.buildInfo.workspace_fingerprint,
    }) +
    joinBlocks([
      heading(1, `${vocabulary.schema}.${vocabulary.table}`),
      `Reference data snapshot (${vocabulary.rows.length} rows, digest ${code(vocabulary.rows_sha256)}). Codes are enforced wherever a column has a foreign key to ${target ? link(code(`${vocabulary.schema}.${vocabulary.table}`), page, target) : code(`${vocabulary.schema}.${vocabulary.table}`)}.`,
      table(columns, vocabulary.rows.map((row) => columns.map((column) => (column === vocabulary.key ? code(row[column]) : formatVocabularyCell(row[column]))))),
    ]);
  return { path: page, content };
}

export function renderDomainPage(model, domain) {
  const page = pages.domain(domain.slug);
  const listed = domain.relations.length > 0 ? domain.relations : model.relationsOfDomain(domain.slug);
  const relationRows = listed
    .filter((relationId) => model.isRelationVisible(relationId))
    .map((relationId) => {
      const relation = model.ir.relations[relationId];
      const overlay = model.overlay(relationId);
      const enforced = [];
      if (relation.primary_key.length > 0) enforced.push(`PK (${relation.primary_key.join(", ")})`);
      if (relation.unique.length > 0) enforced.push(`unique ${relation.unique.map((columns) => `(${columns.join(", ")})`).join(", ")}`);
      if (relation.exclusions.length > 0) enforced.push(`${relation.exclusions.length} exclusion`);
      if (relation.rls.enabled) enforced.push("RLS");
      const writers = relation.writers.filter((role) => role !== "service_role");
      return [
        link(code(`${relation.schema}.${relation.name}`), page, model.relationPage(relationId)),
        truncate(overlay?.summary ?? relation.comment ?? relation.kind, 110),
        enforced.join("; ") || "—",
        writers.length > 0 ? writers.map(code).join(", ") : "helpers only",
      ];
    });
  const functionNames = [...new Set((domain.functions.length > 0 ? domain.functions : model.functionsOfDomain(domain.slug)).map((functionId) => `${model.ir.functions[functionId].schema}.${model.ir.functions[functionId].name}`))].sort();
  const functionLinks = functionNames.map((name) => {
    const [fn] = model.functionOverloads(name);
    const target = fn ? model.functionPage(fn.id) : null;
    return target ? link(code(name), page, target) : code(name);
  });
  const taskLinks = model
    .visibleTasks()
    .filter((task) => domain.tasks.includes(task.slug) || task.domains.includes(domain.slug))
    .map((task) => link(code(task.slug), page, pages.task(task.slug)));
  const queryLinks = [...new Set([...domain.queries, ...model.visibleQueries().filter((entry) => entry.domain === domain.slug).map((entry) => entry.name)])]
    .filter((name) => model.selection.queryNames.has(name))
    .sort()
    .map((name) => link(code(`q:${name}`), page, pages.queriesReadme));
  const omitted = listed.length - relationRows.length;
  const content =
    frontmatter({
      id: `dom:${domain.slug}`,
      kind: "domain",
      schemas: domain.schemas,
      aliases: domain.aliases,
      relations: listed.map((relationId) => idTail(relationId)),
      functions: functionNames,
      tasks: taskLinks.length > 0 ? model.visibleTasks().filter((task) => domain.tasks.includes(task.slug) || task.domains.includes(domain.slug)).map((task) => task.slug) : [],
      summary: domain.summary,
      provenance: domain.provenance,
      reviewed: domain.reviewed,
      workspace_fingerprint: model.buildInfo.workspace_fingerprint,
    }) +
    joinBlocks([
      heading(1, domain.title),
      domain.summary,
      curated(domain, domain.body),
      heading(2, "Relations that matter"),
      table(["Relation", "Summary", "Enforced", "Direct writers"], relationRows) + (omitted > 0 ? `\n${omitted} listed relations are outside this bundle.\n` : ""),
      functionLinks.length > 0 ? `${heading(2, "Functions")}\n${functionLinks.join(", ")}\n` : "",
      queryLinks.length > 0 ? `${heading(2, "Named queries")}\n${queryLinks.join(", ")}\n` : "",
      taskLinks.length > 0 ? `${heading(2, "Tasks")}\n${taskLinks.join(", ")}\n` : "",
      `Schemas: ${domain.schemas.map((schema) => link(code(schema), page, pages.schemaReadme(schema))).join(", ") || "—"}.`,
    ]);
  return { path: page, content };
}

export function renderSchemaReadme(model, schema) {
  const page = pages.schemaReadme(schema.name);
  const relations = schema.relation_ids.filter((relationId) => model.selection.relationIds.has(relationId)).map((relationId) => model.ir.relations[relationId]);
  const rows = relations.map((relation) => {
    const overlay = model.overlay(relation.id);
    const edges = relation.foreign_keys
      .map((fk) => fk.to)
      .filter((target, index, all) => all.indexOf(target) === index && target !== relation.id)
      .slice(0, 4)
      .map((target) => `→ ${code(idTail(target))}`);
    return [
      link(code(relation.name), page, pages.relation(relation)),
      relation.kind.replaceAll("_", " "),
      model.ir.volatile.row_count_class[relation.id] ?? "unknown",
      truncate(overlay?.summary ?? relation.comment ?? "", 90) || "—",
      edges.join(", ") || "—",
    ];
  });
  const functionNames = [...new Set(schema.function_ids.filter((functionId) => model.selection.functionIds.has(functionId)).map((functionId) => model.ir.functions[functionId].name))].sort();
  const vocabularies = Object.values(model.ir.vocabularies).filter((vocabulary) => vocabulary.schema === schema.name);
  const domains = [...new Set(schema.relation_ids.map((relationId) => model.domainOfRelation(relationId)).filter(Boolean))].sort();
  const content =
    frontmatter({ id: schema.id, kind: "schema", name: schema.name, domains, relations: relations.length, functions: functionNames.length, workspace_fingerprint: model.buildInfo.workspace_fingerprint }) +
    joinBlocks([
      heading(1, schema.name),
      `${schema.comment ?? ""} Domains: ${domains.map((slug) => (model.selection.domainSlugs.has(slug) ? link(code(slug), page, pages.domain(slug)) : code(slug))).join(", ") || "—"}.`.trim(),
      table(["Relation", "Kind", "Rows", "Summary", "Key edges"], rows),
      functionNames.length > 0 ? `Functions: ${functionNames.map((name) => link(code(name), page, `functions/${schema.name}/${name}.md`)).join(", ")}.` : "Functions: none.",
      schema.type_ids.length > 0 ? `Types: ${link(code(`types/${schema.name}.md`), page, pages.types(schema.name))}.` : "Types: none.",
      vocabularies.length > 0 ? `Vocabularies: ${vocabularies.map((vocabulary) => link(code(vocabulary.table), page, pages.vocabulary(vocabulary))).join(", ")}.` : "",
    ]);
  return { path: page, content };
}

export function renderTaskPage(model, task) {
  const page = pages.task(task.slug);
  const content =
    frontmatter({
      id: task.id,
      kind: "task",
      domains: task.domains,
      queries: task.queries,
      aliases: task.aliases,
      provenance: task.provenance,
      reviewed: task.reviewed,
      workspace_fingerprint: model.buildInfo.workspace_fingerprint,
    }) +
    joinBlocks([
      heading(1, task.title),
      `Domains: ${task.domains.map((slug) => (model.selection.domainSlugs.has(slug) ? link(code(slug), page, pages.domain(slug)) : code(slug))).join(", ") || "—"}. Queries: ${task.queries.map((name) => link(code(`q:${name}`), page, pages.queriesReadme)).join(", ") || "—"}.`,
      heading(2, "Navigation"),
      task.navigation,
      heading(2, "Operation"),
      task.operation,
      heading(2, "Expected shape"),
      task.expected_shape,
      heading(2, "Pitfalls"),
      task.pitfalls,
    ]);
  return { path: page, content };
}
