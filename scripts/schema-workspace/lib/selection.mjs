import { digest } from "./canonical.mjs";
import { ErrorCode, WorkspaceError } from "./errors.mjs";
import { polymorphicTargetIds } from "./ir/ids.mjs";
import { buildModel, fullSelection } from "./render/model.mjs";

const FK_TARGETS_STUB = "stub";

export function globToRegExp(pattern) {
  return new RegExp(`^${pattern.replaceAll(".", "\\.").replaceAll("*", ".*")}$`);
}

export function matchesAny(name, patterns) {
  return patterns.some((pattern) => globToRegExp(pattern).test(name));
}

function qualifiedName(item) {
  return `${item.schema}.${item.name}`;
}

function selectByDomainOrName({ items, includedDomains, includePatterns, excludePatterns, domainOf }) {
  const selected = new Set();
  for (const item of items) {
    const included = includedDomains.has(domainOf(item.id)) || matchesAny(qualifiedName(item), includePatterns);
    if (included && !matchesAny(qualifiedName(item), excludePatterns)) selected.add(item.id);
  }
  return selected;
}

function stubTargetsOutside(ir, relationIds) {
  const stubs = new Set();
  for (const relationId of relationIds) {
    for (const fk of ir.relations[relationId].foreign_keys) {
      if (!relationIds.has(fk.to)) stubs.add(fk.to);
    }
  }
  for (const item of ir.derived.polymorphic) {
    if (!relationIds.has(item.relation)) continue;
    for (const target of polymorphicTargetIds(item)) {
      if (!relationIds.has(target)) stubs.add(target);
    }
  }
  return stubs;
}

function requireKnownDomains(enrichment, includedDomains) {
  for (const slug of includedDomains) {
    if (!enrichment.domains.some((domain) => domain.slug === slug)) {
      throw new WorkspaceError(ErrorCode.SCOPE_INVALID, `Scope includes unknown domain "${slug}"`);
    }
  }
}

/**
 * Turns a `schema-scope.v1` document into a selection: included relations get full pages, FK
 * targets outside the scope become stubs, vocabularies stay complete, tasks/queries filter by list.
 */
export function selectionForScope(ir, enrichment, scope) {
  const full = fullSelection(ir, enrichment);
  const model = buildModel(ir, enrichment, full, {});
  const include = scope.include ?? {};
  const exclude = scope.exclude ?? {};
  const includedDomains = new Set(include.domains ?? []);
  requireKnownDomains(enrichment, includedDomains);

  const relationIds = selectByDomainOrName({
    items: Object.values(ir.relations),
    includedDomains,
    includePatterns: include.relations ?? [],
    excludePatterns: exclude.relations ?? [],
    domainOf: (relationId) => model.domainOfRelation(relationId),
  });
  const functionIds = selectByDomainOrName({
    items: Object.values(ir.functions),
    includedDomains,
    includePatterns: include.functions ?? [],
    excludePatterns: exclude.functions ?? [],
    domainOf: (functionId) => model.domainOfFunction(functionId),
  });

  const stubRelationIds = (scope.closure?.fk_targets ?? FK_TARGETS_STUB) === FK_TARGETS_STUB ? stubTargetsOutside(ir, relationIds) : new Set();
  for (const vocabulary of Object.values(ir.vocabularies)) {
    const relationId = `rel:${vocabulary.schema}.${vocabulary.table}`;
    relationIds.add(relationId);
    stubRelationIds.delete(relationId);
  }

  const taskSlugs = new Set((scope.tasks ?? []).filter((slug) => enrichment.tasks.some((task) => task.slug === slug)));
  const queryNames = new Set(enrichment.queries.entries.map((entry) => entry.name).filter((name) => matchesAny(name, scope.queries ?? [])));
  const domainSlugs = new Set([...includedDomains, ...[...relationIds].map((relationId) => model.domainOfRelation(relationId)).filter(Boolean)]);
  const omittedRelations = Object.keys(ir.relations).filter((relationId) => !relationIds.has(relationId) && !stubRelationIds.has(relationId)).sort();
  const omittedFunctions = Object.keys(ir.functions).filter((functionId) => !functionIds.has(functionId)).sort();
  return {
    scope: {
      id: scope.id,
      description: scope.description ?? "",
      sha256: digest(scope),
      included: { relations: relationIds.size, functions: functionIds.size, stubs: stubRelationIds.size, tasks: taskSlugs.size, queries: queryNames.size },
      omitted: { relations: omittedRelations.length, functions: omittedFunctions.length, relation_ids: omittedRelations, function_ids: omittedFunctions },
      definition: scope,
    },
    relationIds,
    stubRelationIds,
    functionIds,
    domainSlugs,
    taskSlugs,
    queryNames,
  };
}
