import { existsSync, readdirSync, readFileSync } from "node:fs";
import path from "node:path";
import { parse as parseYaml } from "yaml";
import { canonical, digest, digestText, sortBy } from "../canonical.mjs";
import { ids } from "../ir/build-ir.mjs";
import { ReferenceResolver } from "./references.mjs";

const FORMAT = "ai-engineer-workspace-enrichment/1";
const FILES = ["domains", "relations", "terminology", "tasks", "queries", "ingestion-rules"];
const PROVENANCE = new Set(["human", "model_assisted", "generated"]);
const COST_CLASSES = new Set(["cheap", "medium", "heavy"]);
const RULE_ACTIONS = new Set(["rewrite", "reject", "hold", "stage", "note"]);
const RULE_BASES = new Set(["enforced", "curated"]);

const DEFAULT_QUERY_DEFAULTS = {
  role: "app_reader",
  limit: 200,
  maxLimit: 2000,
  statementTimeoutMs: { cheap: 15000, medium: 15000, heavy: 60000 },
};

class Issues {
  constructor() {
    this.items = [];
  }
  add(file, location, message) {
    this.items.push({ file, location, message });
  }
  get count() {
    return this.items.length;
  }
}

function readYamlFile(directory, name, issues) {
  const file = path.join(directory, `${name}.yaml`);
  if (!existsSync(file)) return { file: null, document: null, text: "" };
  const text = readFileSync(file, "utf8");
  let document;
  try {
    document = parseYaml(text);
  } catch (error) {
    issues.add(`${name}.yaml`, "$", `YAML parse error: ${error.message}`);
    return { file, document: null, text };
  }
  if (document?.format !== FORMAT) issues.add(`${name}.yaml`, "format", `expected "${FORMAT}"`);
  return { file, document, text };
}

function checkProvenance(entry, file, location, issues) {
  if (!PROVENANCE.has(entry.provenance)) issues.add(file, `${location}.provenance`, "must be human | model_assisted");
  if (!("reviewed" in entry)) issues.add(file, `${location}.reviewed`, "must be a date or null");
}

function slugify(text) {
  return text.replaceAll("_", "-");
}

function implicitDomains(ir) {
  return Object.values(ir.schemas).map((schema) => ({
    slug: slugify(schema.name),
    title: schema.name,
    provenance: "generated",
    reviewed: null,
    aliases: [],
    schemas: [schema.name],
    relations: [],
    functions: [],
    tasks: [],
    queries: [],
    summary: `Relations and functions of schema \`${schema.name}\` (no curated domain yet).`,
    body: "",
  }));
}

function loadDomains(directory, ir, resolver, issues) {
  const { document } = readYamlFile(directory, "domains", issues);
  const file = "domains.yaml";
  if (!document) {
    const generated = implicitDomains(ir);
    return {
      domains: generated,
      schemaDomains: Object.fromEntries(generated.map((domain) => [domain.schemas[0], domain.slug])),
    };
  }
  const schemaDomains = document.schema_domains ?? {};
  const domains = (document.domains ?? []).map((entry, index) => {
    const location = `domains[${index}]`;
    if (!entry.slug) issues.add(file, location, "slug is required");
    checkProvenance(entry, file, location, issues);
    return {
      slug: entry.slug,
      title: entry.title ?? entry.slug,
      provenance: entry.provenance,
      reviewed: entry.reviewed ?? null,
      aliases: entry.aliases ?? [],
      schemas: (entry.schemas ?? []).filter((schema) => {
        if (ir.schemas[schema]) return true;
        issues.add(file, `${location}.schemas`, `unknown schema "${schema}"`);
        return false;
      }),
      relations: resolver.relationIds(entry.relations ?? [], file, `${location}.relations`),
      functions: resolver.functionIds(entry.functions ?? [], file, `${location}.functions`),
      tasks: entry.tasks ?? [],
      queries: entry.queries ?? [],
      summary: entry.summary ?? "",
      body: entry.body ?? "",
    };
  });
  const slugs = new Set(domains.map((domain) => domain.slug));
  for (const [schema, slug] of Object.entries(schemaDomains)) {
    if (!ir.schemas[schema]) issues.add(file, `schema_domains.${schema}`, "unknown schema");
    if (!slugs.has(slug)) issues.add(file, `schema_domains.${schema}`, `unknown domain "${slug}"`);
  }
  for (const schema of Object.keys(ir.schemas)) {
    if (!schemaDomains[schema]) issues.add(file, `schema_domains.${schema}`, "every schema needs a default domain");
  }
  return { domains, schemaDomains };
}

function loadRelationOverlays(directory, resolver, issues) {
  const { document } = readYamlFile(directory, "relations", issues);
  const overlays = {};
  for (const [index, entry] of (document?.relations ?? []).entries()) {
    const location = `relations[${index}]`;
    const [relationId] = resolver.relationIds([entry.relation], "relations.yaml", location);
    if (!relationId) continue;
    checkProvenance(entry, "relations.yaml", location, issues);
    for (const column of Object.keys(entry.column_notes ?? {})) {
      resolver.column(relationId, column, "relations.yaml", `${location}.column_notes.${column}`);
    }
    overlays[relationId] = {
      domain: entry.domain ?? null,
      aliases: entry.aliases ?? [],
      summary: entry.summary ?? null,
      notes: entry.notes ?? null,
      column_notes: entry.column_notes ?? {},
      examples: (entry.examples ?? []).map((example) => ({ title: example.title, query: example.query, params: example.params ?? {}, note: example.note ?? null })),
      provenance: entry.provenance,
      reviewed: entry.reviewed ?? null,
    };
  }
  return overlays;
}

function loadTerminology(directory, resolver, issues) {
  const { document } = readYamlFile(directory, "terminology", issues);
  return (document?.terms ?? []).map((entry, index) => {
    const location = `terms[${index}]`;
    if (!entry.slug || !entry.term || !entry.definition) issues.add("terminology.yaml", location, "slug, term, definition are required");
    checkProvenance(entry, "terminology.yaml", location, issues);
    return {
      slug: entry.slug,
      id: ids.term(entry.slug),
      term: entry.term,
      aliases: entry.aliases ?? [],
      definition: entry.definition,
      refs: resolver.anyIds(entry.refs ?? [], "terminology.yaml", `${location}.refs`),
      provenance: entry.provenance,
      reviewed: entry.reviewed ?? null,
    };
  });
}

function loadTasks(directory, issues) {
  const { document } = readYamlFile(directory, "tasks", issues);
  return (document?.tasks ?? []).map((entry, index) => {
    const location = `tasks[${index}]`;
    if (!entry.slug || !entry.title) issues.add("tasks.yaml", location, "slug and title are required");
    checkProvenance(entry, "tasks.yaml", location, issues);
    return {
      slug: entry.slug,
      id: ids.task(entry.slug),
      title: entry.title,
      domains: entry.domains ?? [],
      queries: entry.queries ?? [],
      aliases: entry.aliases ?? [],
      navigation: entry.navigation ?? "",
      operation: entry.operation ?? "",
      expected_shape: entry.expected_shape ?? "",
      pitfalls: entry.pitfalls ?? "",
      provenance: entry.provenance,
      reviewed: entry.reviewed ?? null,
    };
  });
}

function placeholderCount(sql) {
  const numbers = [...sql.matchAll(/\$(\d+)/g)].map((match) => Number(match[1]));
  return numbers.length === 0 ? 0 : Math.max(...numbers);
}

function loadQueries(directory, issues) {
  const { document } = readYamlFile(directory, "queries", issues);
  const defaults = { ...DEFAULT_QUERY_DEFAULTS, ...(document?.defaults ?? {}) };
  const entries = (document?.queries ?? []).map((entry, index) => {
    const location = `queries[${index}]`;
    if (!entry.name || !entry.sql) issues.add("queries.yaml", location, "name and sql are required");
    if (entry.cost_class && !COST_CLASSES.has(entry.cost_class)) issues.add("queries.yaml", `${location}.cost_class`, "cheap | medium | heavy");
    const paramOrder = entry.paramOrder ?? [];
    const placeholders = placeholderCount(entry.sql ?? "");
    if (placeholders !== paramOrder.length) {
      issues.add("queries.yaml", `${location}.paramOrder`, `sql has ${placeholders} placeholders but paramOrder has ${paramOrder.length}`);
    }
    checkProvenance(entry, "queries.yaml", location, issues);
    return {
      id: ids.query(entry.name),
      name: entry.name,
      title: entry.title ?? entry.name,
      kind: entry.kind ?? "named_query",
      role: entry.role ?? defaults.role,
      sql: entry.sql,
      paramOrder,
      params: entry.params ?? { type: "object", properties: {}, additionalProperties: false },
      result: entry.result ?? { shape: "rows" },
      cost_class: entry.cost_class ?? "cheap",
      temporal: entry.temporal ?? { world_time: "n/a", knowledge: "head" },
      pagination: entry.pagination ?? null,
      volatile: entry.volatile ?? false,
      domain: entry.domain ?? null,
      tasks: entry.tasks ?? [],
      aliases: entry.aliases ?? [],
      summary: entry.summary ?? entry.title ?? entry.name,
      example: entry.example ?? {},
      execute: entry.execute ?? true,
      execute_skip_reason: entry.execute === false ? entry.reason ?? "not executable at build" : null,
      embedding: entry.embedding ?? null,
      provenance: entry.provenance,
      reviewed: entry.reviewed ?? null,
    };
  });
  const names = new Set();
  for (const entry of entries) {
    if (names.has(entry.name)) issues.add("queries.yaml", entry.name, "duplicate query name");
    names.add(entry.name);
  }
  return { defaults, entries: sortBy(entries, (entry) => entry.name) };
}

function loadIngestionRules(directory, resolver, issues) {
  const { document } = readYamlFile(directory, "ingestion-rules", issues);
  const rules = (document?.rules ?? []).map((entry, index) => {
    const location = `rules[${index}]`;
    if (!entry.id) issues.add("ingestion-rules.yaml", location, "id is required");
    if (!RULE_BASES.has(entry.basis)) issues.add("ingestion-rules.yaml", `${location}.basis`, "enforced | curated");
    if (!RULE_ACTIONS.has(entry.action)) issues.add("ingestion-rules.yaml", `${location}.action`, "rewrite | reject | hold | stage | note");
    checkProvenance(entry, "ingestion-rules.yaml", location, issues);
    return {
      id: entry.id,
      title: entry.title ?? entry.id,
      basis: entry.basis,
      applies_to: entry.applies_to ?? {},
      action: entry.action,
      detail: entry.detail ?? "",
      refs: resolver.anyIds(entry.refs ?? [], "ingestion-rules.yaml", `${location}.refs`),
      provenance: entry.provenance,
      reviewed: entry.reviewed ?? null,
    };
  });
  return { version: document?.version ?? "ingestion-rules.v1", rules: sortBy(rules, (rule) => rule.id) };
}

function crossCheck(enrichment, issues) {
  const taskSlugs = new Set(enrichment.tasks.map((task) => task.slug));
  const querySlugs = new Set(enrichment.queries.entries.map((entry) => entry.name));
  const domainSlugs = new Set(enrichment.domains.map((domain) => domain.slug));
  const check = (file, location, values, known, label) => {
    for (const value of values) if (!known.has(value)) issues.add(file, location, `unknown ${label} "${value}"`);
  };
  for (const domain of enrichment.domains) {
    check("domains.yaml", `${domain.slug}.tasks`, domain.tasks, taskSlugs, "task");
    check("domains.yaml", `${domain.slug}.queries`, domain.queries, querySlugs, "query");
  }
  for (const task of enrichment.tasks) {
    check("tasks.yaml", `${task.slug}.domains`, task.domains, domainSlugs, "domain");
    check("tasks.yaml", `${task.slug}.queries`, task.queries, querySlugs, "query");
  }
  for (const entry of enrichment.queries.entries) {
    if (entry.domain) check("queries.yaml", `${entry.name}.domain`, [entry.domain], domainSlugs, "domain");
    check("queries.yaml", `${entry.name}.tasks`, entry.tasks, taskSlugs, "task");
  }
  for (const [relationId, overlay] of Object.entries(enrichment.relation_overlays)) {
    if (overlay.domain) check("relations.yaml", `${relationId}.domain`, [overlay.domain], domainSlugs, "domain");
    for (const example of overlay.examples) check("relations.yaml", `${relationId}.examples`, [example.query], querySlugs, "query");
  }
}

function enrichmentDigest(directory) {
  if (!existsSync(directory)) return digestText("");
  const files = readdirSync(directory).filter((name) => name.endsWith(".yaml")).sort();
  return digestText(files.map((name) => `${name}\n${readFileSync(path.join(directory, name), "utf8")}`).join("\n\u0000"));
}

/**
 * Loads and validates `workspace-enrichment/*.yaml` against the IR.
 * Returns `{ enrichment, issues }`; `issues` non-empty means ENRICHMENT_INVALID.
 */
export function loadEnrichment(directory, ir) {
  const issues = new Issues();
  const resolver = new ReferenceResolver(ir, issues);
  const { domains, schemaDomains } = loadDomains(directory, ir, resolver, issues);
  const enrichment = {
    domains: sortBy(domains, (domain) => domain.slug),
    schema_domains: schemaDomains,
    relation_overlays: loadRelationOverlays(directory, resolver, issues),
    terminology: sortBy(loadTerminology(directory, resolver, issues), (term) => term.slug),
    tasks: sortBy(loadTasks(directory, issues), (task) => task.slug),
    queries: loadQueries(directory, issues),
    ingestion_rules: loadIngestionRules(directory, resolver, issues),
    files_present: FILES.filter((name) => existsSync(path.join(directory, `${name}.yaml`))),
    sha256: enrichmentDigest(directory),
  };
  enrichment.queries.catalog_version = digest(enrichment.queries.entries);
  crossCheck(enrichment, issues);
  // Canonical key order so a fresh load and the committed schema-ir.json render identically.
  return { enrichment: canonical(enrichment), issues: issues.items };
}
