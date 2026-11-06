import { stringify as toYaml } from "yaml";
import { loadConfig } from "../config.mjs";
import { ErrorCode, ExitCode, WorkspaceError } from "../errors.mjs";
import { loadCommittedWorkspace } from "./committed.mjs";

function relationDraft(ir, qualifiedName) {
  const relation = ir.relations[`rel:${qualifiedName}`];
  if (!relation) throw new WorkspaceError(ErrorCode.USAGE, `Unknown relation "${qualifiedName}"`);
  return {
    relation: qualifiedName,
    domain: null,
    aliases: [relation.name.replaceAll("_", " ")],
    summary: relation.comment ?? "",
    notes: "",
    column_notes: Object.fromEntries(relation.columns.map((column) => [column.name, ""])),
    examples: [],
    provenance: "model_assisted",
    reviewed: null,
  };
}

function domainDraft(ir, enrichment, slug) {
  const relations = Object.values(ir.relations).filter((relation) => enrichment.schema_domains[relation.schema] === slug || enrichment.domains.find((domain) => domain.slug === slug)?.relations.includes(relation.id));
  const functions = [...new Set(Object.values(ir.functions).filter((fn) => enrichment.schema_domains[fn.schema] === slug).map((fn) => `${fn.schema}.${fn.name}`))];
  return {
    slug,
    title: slug,
    provenance: "model_assisted",
    reviewed: null,
    aliases: [],
    schemas: [...new Set(relations.map((relation) => relation.schema))].sort(),
    relations: relations.map((relation) => `${relation.schema}.${relation.name}`).sort(),
    functions: functions.sort(),
    tasks: [],
    queries: [],
    summary: "",
    body: "",
  };
}

export async function runEnrichDraft(values) {
  if (!values.draft) throw new WorkspaceError(ErrorCode.USAGE, "enrich requires --draft <schema.relation | domain:slug>");
  const config = loadConfig();
  const { ir, enrichment } = loadCommittedWorkspace(config);
  const draft = values.draft.startsWith("domain:") ? domainDraft(ir, enrichment, values.draft.slice("domain:".length)) : relationDraft(ir, values.draft);
  process.stdout.write(toYaml(draft));
  return ExitCode.OK;
}
