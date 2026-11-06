import { sortBy } from "../canonical.mjs";

export function isViewKind(kind) {
  return kind === "view" || kind === "materialized_view";
}

export const pages = {
  start: "START_HERE.md",
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
};

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
  };
}

/**
 * Read model over IR + enrichment + selection: domain assignment, page paths, per-relation
 * query/task lookups. Renderers only consume this; they never touch the raw enrichment.
 */
export function buildModel(ir, enrichment, selection, buildInfo) {
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

  return {
    ir,
    enrichment,
    selection,
    buildInfo,
    domainBySlug,
    domainOfRelation,
    domainOfFunction,
    relationsOfDomain: (slug) => sortBy(relationsByDomain.get(slug) ?? [], (id) => id),
    functionsOfDomain: (slug) => sortBy(functionsByDomain.get(slug) ?? [], (id) => id),
    tasksOfDomain: (slug) => sortBy(tasksByDomain.get(slug) ?? [], (task) => task.slug),
    queriesMentioning: (id) => [...new Set(queriesMentioning.get(id) ?? [])].sort(),
    viewsOver: (id) => [...new Set(viewSourcesInverse.get(id) ?? [])].sort(),
    functionOverloads: (qualifiedName) => sortBy(functionsByName.get(qualifiedName) ?? [], (fn) => fn.id),
    queryByName: (name) => queryByName.get(name) ?? null,
    overlay: (relationId) => enrichment.relation_overlays[relationId] ?? null,
    isRelationVisible,
    relationPage,
    functionPage,
    visibleRelations: () => sortBy(Object.values(ir.relations).filter((relation) => selection.relationIds.has(relation.id)), (relation) => relation.id),
    visibleFunctions: () => sortBy(Object.values(ir.functions).filter((fn) => selection.functionIds.has(fn.id)), (fn) => fn.id),
    visibleDomains: () => enrichment.domains.filter((domain) => selection.domainSlugs.has(domain.slug)),
    visibleTasks: () => enrichment.tasks.filter((task) => selection.taskSlugs.has(task.slug)),
    visibleQueries: () => enrichment.queries.entries.filter((entry) => selection.queryNames.has(entry.name)),
  };
}
