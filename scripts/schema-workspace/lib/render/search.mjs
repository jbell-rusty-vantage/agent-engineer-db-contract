import { canonicalJson, prettyJson, sortBy } from "../canonical.mjs";
import { functionQualifiedName } from "../ir/ids.mjs";
import { anchorOf } from "./markdown.mjs";
import { pages } from "./model.mjs";
import { foldTenantScopedForeignKeys, relationFrontmatter } from "./relation-page.mjs";

function relationEntry(model, relation) {
  const front = relationFrontmatter(model, relation);
  const stub = model.selection.stubRelationIds.has(relation.id);
  const enforcedEdges = foldTenantScopedForeignKeys(relation.foreign_keys).map((fk) => ({ to: fk.to, via: fk.columns.join(","), basis: "enforced" }));
  const vocabularyEdges = model.ir.derived.polymorphic
    .filter((item) => item.relation === relation.id && item.targets_by_value)
    .flatMap((item) => Object.entries(item.targets_by_value).map(([value, target]) => ({ to: target, via: `${item.discriminator.split(".").at(-1)}=${value}`, basis: "vocabulary" })));
  return {
    id: relation.id,
    kind: relation.kind,
    qualified_name: `${relation.schema}.${relation.name}`,
    path: model.relationPage(relation.id),
    domain: front.domain,
    aliases: front.aliases,
    tokens: front.tokens,
    summary: front.summary,
    summary_basis: front.summary_basis,
    edges: [...enforcedEdges, ...vocabularyEdges],
    readers: relation.readers,
    writers: relation.writers,
    write_via: [...new Set(model.ir.derived.write_paths[relation.id].via_functions.map(functionQualifiedName))],
    ...(stub ? { stub: true } : {}),
  };
}

function functionEntry(model, overloads) {
  const [first] = overloads;
  return {
    id: first.id,
    kind: "function",
    qualified_name: `${first.schema}.${first.name}`,
    path: pages.function(first),
    domain: model.domainOfFunction(first.id),
    aliases: [],
    tokens: [first.schema, first.name, `${first.schema}.${first.name}`],
    summary: first.comment ?? `${first.volatility} ${first.kind} returning ${first.returns}`,
    summary_basis: first.comment ? "comment" : "derived",
    executors: [...new Set(overloads.flatMap((fn) => fn.executors))].sort(),
    raises: [...new Set(overloads.flatMap((fn) => fn.raises))].sort(),
    overloads: overloads.length,
  };
}

export function buildSearchIndex(model) {
  const entries = [];
  for (const relation of model.visibleRelations()) entries.push(relationEntry(model, relation));
  for (const relationId of model.selection.stubRelationIds) entries.push(relationEntry(model, model.ir.relations[relationId]));
  const seenFunctions = new Set();
  for (const fn of model.visibleFunctions()) {
    const key = `${fn.schema}.${fn.name}`;
    if (seenFunctions.has(key)) continue;
    seenFunctions.add(key);
    entries.push(functionEntry(model, model.functionOverloads(key).filter((overload) => model.selection.functionIds.has(overload.id))));
  }
  for (const domain of model.visibleDomains()) {
    entries.push({ id: `dom:${domain.slug}`, kind: "domain", qualified_name: domain.slug, path: pages.domain(domain.slug), domain: domain.slug, aliases: domain.aliases, tokens: [domain.slug, ...domain.schemas], summary: domain.summary, summary_basis: "curated", provenance: domain.provenance });
  }
  for (const task of model.visibleTasks()) {
    entries.push({ id: task.id, kind: "task", qualified_name: task.slug, path: pages.task(task.slug), domain: task.domains[0] ?? null, aliases: task.aliases, tokens: [task.slug, ...task.queries], summary: task.title, summary_basis: "curated", queries: task.queries });
  }
  for (const entry of model.visibleQueries()) {
    entries.push({ id: entry.id, kind: "query", qualified_name: entry.name, path: `${pages.queriesReadme}#${anchorOf(entry.name)}`, domain: entry.domain, aliases: entry.aliases, tokens: [entry.name, ...entry.paramOrder.filter((name) => !name.startsWith("$"))], summary: entry.summary, summary_basis: "curated", role: entry.role, cost_class: entry.cost_class });
  }
  for (const term of model.enrichment.terminology) {
    entries.push({ id: term.id, kind: "term", qualified_name: term.slug, path: `${pages.terminology}#${term.slug}`, domain: null, aliases: [term.term, ...term.aliases], tokens: [term.slug], summary: term.definition, summary_basis: "curated", refs: term.refs });
  }
  for (const vocabulary of Object.values(model.ir.vocabularies)) {
    entries.push({ id: vocabulary.id, kind: "vocabulary", qualified_name: `${vocabulary.schema}.${vocabulary.table}`, path: pages.vocabulary(vocabulary), domain: model.domainOfRelation(`rel:${vocabulary.schema}.${vocabulary.table}`), aliases: [], tokens: vocabulary.rows.map((row) => String(row[vocabulary.key])), summary: `${vocabulary.rows.length} codes`, summary_basis: "derived" });
  }
  return sortBy(entries, (entry) => entry.id);
}

export function buildAliases(entries) {
  const aliases = {};
  for (const entry of entries) {
    for (const alias of entry.aliases ?? []) {
      const key = alias.toLowerCase();
      aliases[key] = [...new Set([...(aliases[key] ?? []), entry.id])].sort();
    }
  }
  return Object.fromEntries(Object.entries(aliases).sort(([a], [b]) => (a < b ? -1 : 1)));
}

/** One canonical JSON entry per line so `rg` returns whole entries and `jq -c '.[]'` streams them. */
function lineDelimitedArray(entries) {
  return `[\n${entries.map((entry) => `  ${canonicalJson(entry)}`).join(",\n")}\n]\n`;
}

export function renderSearchFiles(model) {
  const entries = buildSearchIndex(model);
  const terminology = Object.fromEntries(model.enrichment.terminology.map((term) => [term.slug, { term: term.term, aliases: term.aliases, definition: term.definition, refs: term.refs, provenance: term.provenance, reviewed: term.reviewed }]));
  return [
    { path: pages.searchIndex, content: lineDelimitedArray(entries) },
    { path: pages.aliases, content: prettyJson(buildAliases(entries)) },
    { path: pages.terminology, content: prettyJson(terminology) },
  ];
}
