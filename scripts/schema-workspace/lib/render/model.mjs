import { sortBy } from "../canonical.mjs";

export function isViewKind(kind) {
  return kind === "view" || kind === "materialized_view";
}

export const pages = {
  start: "START_HERE.md",
  map: "MAP.md",
  index: "INDEX.md",
  relationsList: "relations.txt",
  manifest: "manifest.json",
  fingerprint: "fingerprint.json",
  validation: "validation.json",
  ir: "schema-ir.json",
  scope: "scope.json",
  queriesReadme: "queries/README.md",
  catalog: "queries/catalog.json",
  rulesReadme: "rules/README.md",
  rulesJson: "rules/ingestion-rules.v1.json",
  searchIndex: "search/index.json",
  aliases: "search/aliases.json",
  terminology: "search/terminology.json",
  domain: (slug) => `domains/${slug}.md`,
  schemaReadme: (schema) => `schemas/${schema}/README.md`,
  relation: (relation) => `relations/${relation.schema}/${relation.name}.md`,
  relationDetails: (relation) => `relations/${relation.schema}/${relation.name}.details.md`,
  relationStub: (relation) => `relations/${relation.schema}/${relation.name}.stub.md`,
  function: (fn) => `functions/${fn.schema}/${fn.name}.md`,
  types: (schema) => `types/${schema}.md`,
  vocabulary: (vocabulary) => `vocabularies/${vocabulary.schema}.${vocabulary.table}.md`,
  task: (slug) => `tasks/${slug}.md`,
  operation: (name) => `ops/${name}.md`,
};

/** Lens configuration when workspace.config.json has none: everything is corpus, nothing hidden. */
export const DEFAULT_LENSES = Object.freeze({ names: ["corpus"], hidden: [], schemas: {}, relations: {}, functions: {}, triggerFunctions: null });

/** Everything selected: the full workspace. */
export function fullSelection(ir, enrichment) {
  return {
    scope: null,
    relationIds: new Set(Object.keys(ir.relations)),
    stubRelationIds: new Set(),
    functionIds: new Set(Object.keys(ir.functions)),
    domainSlugs: new Set(enrichment.domains.map((domain) => domain.slug)),
    taskSlugs: new Set(enrichment.tasks.map((task) => task.slug)),
    queryNames: new Set(enrichment.queries.entries.map((entry) => entry.name)),
    operationNames: new Set((ir.derived.operations ?? []).map((operation) => operation.name)),
  };
}

function mostCommon(values) {
  const counts = new Map();
  for (const value of values) if (value) counts.set(value, (counts.get(value) ?? 0) + 1);
  return [...counts].sort((a, b) => b[1] - a[1] || (a[0] < b[0] ? -1 : 1))[0]?.[0] ?? null;
}

/**
 * Read model over IR + enrichment + selection: domain and lens assignment, page paths,
 * per-relation query/task lookups. Renderers only consume this; they never touch the raw enrichment.
 */
export function buildModel(ir, enrichment, selection, buildInfo, lenses = DEFAULT_LENSES) {
  const domainBySlug = new Map(enrichment.domains.map((domain) => [domain.slug, domain]));
  const listedRelationDomain = new Map();
  const listedFunctionDomain = new Map();
  for (const domain of enrichment.domains) {
    for (const relationId of domain.relations) if (!listedRelationDomain.has(relationId)) listedRelationDomain.set(relationId, domain.slug);
    for (const functionId of domain.functions) if (!listedFunctionDomain.has(functionId)) listedFunctionDomain.set(functionId, domain.slug);
  }
  const domainOfRelation = (relationId) => {
    const relation = ir.relations[relationId];
    return enrichment.relation_overlays[relationId]?.domain ?? listedRelationDomain.get(relationId) ?? enrichment.schema_domains[relation.schema] ?? null;
  };
  const domainOfFunction = (functionId) => listedFunctionDomain.get(functionId) ?? enrichment.schema_domains[ir.functions[functionId].schema] ?? null;

  const lensOfRelation = (relationId) => {
    const relation = ir.relations[relationId];
    if (!relation) return null;
    return enrichment.relation_overlays[relationId]?.lens ?? lenses.relations?.[`${relation.schema}.${relation.name}`] ?? lenses.schemas?.[relation.schema] ?? null;
  };
  const lensOfFunction = (functionId) => {
    const fn = ir.functions[functionId];
    if (!fn) return null;
    const configured = lenses.functions?.[`${fn.schema}.${fn.name}`];
    if (configured) return configured;
    if (fn.returns === "trigger" && lenses.triggerFunctions) return lenses.triggerFunctions;
    return lenses.schemas?.[fn.schema] ?? null;
  };

  const relationsByDomain = new Map();
  const functionsByDomain = new Map();
  for (const relationId of Object.keys(ir.relations)) {
    const slug = domainOfRelation(relationId);
    relationsByDomain.set(slug, [...(relationsByDomain.get(slug) ?? []), relationId]);
  }
  for (const functionId of Object.keys(ir.functions)) {
    const slug = domainOfFunction(functionId);
    functionsByDomain.set(slug, [...(functionsByDomain.get(slug) ?? []), functionId]);
  }
  const lensOfDomain = (slug) => {
    const domain = domainBySlug.get(slug);
    if (!domain) return null;
    if (domain.lens) return domain.lens;
    const relationIds = domain.relations.length > 0 ? domain.relations : relationsByDomain.get(slug) ?? [];
    const functionIds = domain.functions.length > 0 ? domain.functions : functionsByDomain.get(slug) ?? [];
    return mostCommon(relationIds.map(lensOfRelation)) ?? mostCommon(functionIds.map(lensOfFunction)) ?? mostCommon(domain.schemas.map((schema) => lenses.schemas?.[schema]));
  };
  const lensOfSchema = (schema) => lenses.schemas?.[schema] ?? null;
  const hiddenLenses = new Set(lenses.hidden ?? []);

  const relationIdsReadBy = (functionId) => (ir.functions[functionId]?.touches.reads ?? []).map((name) => `rel:${name}`).filter((id) => ir.relations[id]);
  const append = (map, key, value) => map.set(key, [...(map.get(key) ?? []), value]);

  const queriesMentioning = new Map();
  for (const entry of enrichment.queries.entries) {
    const lowered = entry.sql.toLowerCase();
    for (const relation of Object.values(ir.relations)) {
      if (new RegExp(`\\b${relation.schema}\\.${relation.name}\\b`).test(lowered)) append(queriesMentioning, relation.id, entry.name);
    }
    for (const fn of Object.values(ir.functions)) {
      if (!new RegExp(`\\b${fn.schema}\\.${fn.name}\\s*\\(`).test(lowered)) continue;
      append(queriesMentioning, fn.id, entry.name);
      for (const relationId of relationIdsReadBy(fn.id)) append(queriesMentioning, relationId, entry.name);
    }
    const view = Object.values(ir.relations).find((relation) => relation.kind === "view" && new RegExp(`\\b${relation.schema}\\.${relation.name}\\b`).test(lowered));
    for (const source of view ? ir.derived.view_sources[view.id] ?? [] : []) {
      if (source.startsWith("fn:")) for (const relationId of relationIdsReadBy(source)) append(queriesMentioning, relationId, entry.name);
      else append(queriesMentioning, source, entry.name);
    }
  }
  const viewSourcesInverse = new Map();
  for (const [viewId, sources] of Object.entries(ir.derived.view_sources)) {
    for (const source of sources) {
      append(viewSourcesInverse, source, viewId);
      if (source.startsWith("fn:")) for (const relationId of relationIdsReadBy(source)) append(viewSourcesInverse, relationId, viewId);
    }
  }
  const functionsByName = new Map();
  for (const fn of Object.values(ir.functions)) {
    const key = `${fn.schema}.${fn.name}`;
    functionsByName.set(key, [...(functionsByName.get(key) ?? []), fn]);
  }
  const tasksByDomain = new Map();
  for (const task of enrichment.tasks) for (const slug of task.domains) tasksByDomain.set(slug, [...(tasksByDomain.get(slug) ?? []), task]);
  const queryByName = new Map(enrichment.queries.entries.map((entry) => [entry.name, entry]));
  const operations = ir.derived.operations ?? [];
  const operationsTouching = new Map();
  for (const operation of operations) {
    for (const name of [...operation.reads, ...operation.writes]) append(operationsTouching, `rel:${name}`, operation.name);
  }

  const isRelationVisible = (relationId) => selection.relationIds.has(relationId) || selection.stubRelationIds.has(relationId);
  const relationPage = (relationId) => {
    const relation = ir.relations[relationId];
    if (!relation || !isRelationVisible(relationId)) return null;
    return selection.stubRelationIds.has(relationId) ? pages.relationStub(relation) : pages.relation(relation);
  };
  const functionPage = (functionId) => {
    const fn = ir.functions[functionId];
    return fn && selection.functionIds.has(functionId) ? pages.function(fn) : null;
  };
  const operationPage = (name) => (selection.operationNames?.has(name) ? pages.operation(name) : null);
  const schemaHasPages = (schemaName) => {
    const schema = ir.schemas[schemaName];
    return Boolean(schema) && (schema.relation_ids.some((id) => selection.relationIds.has(id)) || schema.function_ids.some((id) => selection.functionIds.has(id)));
  };

  return {
    ir,
    enrichment,
    selection,
    buildInfo,
    lenses,
    domainBySlug,
    domainOfRelation,
    domainOfFunction,
    lensOfRelation,
    lensOfFunction,
    lensOfDomain,
    lensOfSchema,
    isHiddenLens: (lens) => hiddenLenses.has(lens),
    relationsOfDomain: (slug) => sortBy(relationsByDomain.get(slug) ?? [], (id) => id),
    functionsOfDomain: (slug) => sortBy(functionsByDomain.get(slug) ?? [], (id) => id),
    tasksOfDomain: (slug) => sortBy(tasksByDomain.get(slug) ?? [], (task) => task.slug),
    queriesMentioning: (id) => [...new Set(queriesMentioning.get(id) ?? [])].sort(),
    operationsTouching: (relationId) => [...new Set(operationsTouching.get(relationId) ?? [])].sort(),
    viewsOver: (id) => [...new Set(viewSourcesInverse.get(id) ?? [])].sort(),
    functionOverloads: (qualifiedName) => sortBy(functionsByName.get(qualifiedName) ?? [], (fn) => fn.id),
    queryByName: (name) => queryByName.get(name) ?? null,
    overlay: (relationId) => enrichment.relation_overlays[relationId] ?? null,
    isRelationVisible,
    relationPage,
    functionPage,
    operationPage,
    schemaHasPages,
    visibleRelations: () => sortBy(Object.values(ir.relations).filter((relation) => selection.relationIds.has(relation.id)), (relation) => relation.id),
    visibleFunctions: () => sortBy(Object.values(ir.functions).filter((fn) => selection.functionIds.has(fn.id)), (fn) => fn.id),
    visibleDomains: () => enrichment.domains.filter((domain) => selection.domainSlugs.has(domain.slug)),
    visibleTasks: () => enrichment.tasks.filter((task) => selection.taskSlugs.has(task.slug)),
    visibleQueries: () => enrichment.queries.entries.filter((entry) => selection.queryNames.has(entry.name)),
    visibleOperations: () => operations.filter((operation) => selection.operationNames?.has(operation.name)),
  };
}
