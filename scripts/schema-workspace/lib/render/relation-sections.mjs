import { idTail, isPolymorphicTarget } from "../ir/ids.mjs";
import { functionLink, relationLink } from "./links.mjs";
import { code, curated, heading, link, table, truncate } from "./markdown.mjs";
import { isViewKind, pages } from "./model.mjs";

const AGENT_ROLES = ["executor_service", "pipeline_agent", "verifier_agent", "control_plane", "app_reader"];
const COMPACT_EDGE_LIMIT = 12;
const COMPACT_POLYMORPHIC_LIMIT = 8;
const DEFAULT_TRUNCATE = 60;
const CHECK_EXPRESSION_TRUNCATE = 140;
const POLICY_USING_TRUNCATE = 90;
const TENANT_ID_COLUMN = "tenant_id";
const ON_DELETE_NO_ACTION = "no action";
const INBOUND_SEPARATOR = ", ";
const OUTBOUND_SEPARATOR = "; ";

export { COMPACT_EDGE_LIMIT };

function agentRolesAmong(roles) {
  return roles.filter((role) => AGENT_ROLES.includes(role));
}

export function foldTenantScopedForeignKeys(foreignKeys) {
  const isTenantScoped = (fk) => fk.columns.length > 1 && fk.columns[0] === TENANT_ID_COLUMN;
  const twinKey = (fk) => `${fk.to}|${fk.columns.join(",")}`;
  const restAfterTenant = (fk) => `${fk.to}|${fk.columns.slice(1).join(",")}`;
  const tenantTwins = new Set(foreignKeys.filter(isTenantScoped).map(restAfterTenant));
  const plainKeys = new Set(foreignKeys.filter((fk) => !isTenantScoped(fk)).map(twinKey));
  return foreignKeys
    .filter((fk) => !isTenantScoped(fk) || !plainKeys.has(restAfterTenant(fk)))
    .map((fk) => ({ ...fk, tenant_scoped: !isTenantScoped(fk) && tenantTwins.has(twinKey(fk)) }));
}

function columnNotes({ model, relation, column, fromPage }) {
  const overlay = model.overlay(relation.id);
  const notes = [];
  if (relation.primary_key.includes(column.name)) notes.push("PK");
  for (const unique of relation.unique) if (unique.includes(column.name)) notes.push(`unique (${unique.join(", ")})`);
  if (column.fk) notes.push(`FK → ${relationLink(model, fromPage, column.fk.to)}.${column.fk.columns.join(",")}`);
  if (column.generated) notes.push(`generated: ${code(column.generated)}`);
  if (column.identity) notes.push(`identity ${column.identity}`);
  if (column.comment) notes.push(column.comment);
  const curatedNote = overlay?.column_notes?.[column.name];
  if (curatedNote) notes.push(`_curated:_ ${curatedNote}`);
  return notes.join("; ");
}

function columnsTable(model, relation, fromPage) {
  return table(
    ["#", "Column", "Type", "Null", "Default", "Notes"],
    relation.columns.map((column) => [
      column.position,
      code(column.name),
      code(column.type),
      column.nullable ? "yes" : "no",
      column.default ? code(truncate(column.default, DEFAULT_TRUNCATE)) : "",
      columnNotes({ model, relation, column, fromPage }),
    ]),
  );
}

function compactColumns(relation) {
  return `${relation.columns.map((column) => `${code(column.name)} ${column.type}${column.nullable ? "" : " not null"}`).join(", ")}\n`;
}

/** `checks`: "inline" (truncated expressions), "full", or a details link when spilled. */
function constraintsSection(relation, checks, detailsLink = null) {
  const lines = [];
  if (relation.primary_key.length > 0) lines.push(`- PK (${relation.primary_key.join(", ")})`);
  for (const unique of relation.unique) lines.push(`- unique (${unique.join(", ")})`);
  for (const exclusion of relation.exclusions) lines.push(`- **exclusion** ${code(exclusion.name)}: ${code(exclusion.definition)}`);
  if (checks === "spilled") lines.push(`- ${relation.checks.length} check constraints; see ${detailsLink}`);
  else for (const check of relation.checks) lines.push(`- check ${code(check.name)}: ${code(checks === "full" ? check.expression : truncate(check.expression, CHECK_EXPRESSION_TRUNCATE))}`);
  return lines.length > 0 ? `${lines.join("\n")}\n` : "_None._\n";
}

function outboundEdges(model, relation, fromPage) {
  return foldTenantScopedForeignKeys(relation.foreign_keys).map((fk) => {
    const onDelete = fk.on_delete && fk.on_delete !== ON_DELETE_NO_ACTION ? ` on delete ${fk.on_delete}` : "";
    return `${code(fk.columns.join(","))} → ${relationLink(model, fromPage, fk.to)}${code(`.${fk.to_columns.join(",")}`)}${fk.tenant_scoped ? " (+tenant)" : ""}${fk.deferrable ? " (deferrable)" : ""}${onDelete}`;
  });
}

function inboundEdges(model, relation, fromPage) {
  const bySource = new Map();
  for (const fk of relation.inbound_foreign_keys) {
    const columns = fk.columns.filter((column) => column !== TENANT_ID_COLUMN || fk.columns.length === 1);
    bySource.set(fk.from, new Set([...(bySource.get(fk.from) ?? []), columns.join(",")]));
  }
  return [...bySource].map(([from, columns]) => `${relationLink(model, fromPage, from)}.${[...columns].join("|")}`);
}

function formatPolymorphicItem(model, item, fromPage, full) {
  if (!item.targets_by_value) {
    return `exactly one of ${item.columns.map(code).join(", ")} → ${item.targets.map((target) => relationLink(model, fromPage, target)).join(" | ")} — basis: ${item.basis}`;
  }
  const entries = Object.entries(item.targets_by_value);
  const vocabulary = model.ir.vocabularies[item.vocabulary];
  const vocabularyLink = vocabulary ? link(code(idTail(item.vocabulary)), fromPage, pages.vocabulary(vocabulary)) : code(idTail(item.vocabulary));
  const discriminator = code(item.discriminator.split(".").at(-1));
  if (!full && entries.length > COMPACT_POLYMORPHIC_LIMIT) {
    return `${discriminator} selects one of ${entries.length} typed tables listed in ${vocabularyLink} (${code("canonical_table")}) — basis: ${item.basis}`;
  }
  return `${discriminator} selects the typed table via ${vocabularyLink}: ${entries.map(([value, target]) => `${value} → ${relationLink(model, fromPage, target)}`).join(", ")} — basis: ${item.basis}`;
}

function polymorphicEdges(model, relation, fromPage, full) {
  return model.ir.derived.polymorphic.filter((item) => item.relation === relation.id).map((item) => formatPolymorphicItem(model, item, fromPage, full));
}

function formatEdgeList(items, { kind, full, fromPage, detailsPage }) {
  const separator = kind === "inbound" ? INBOUND_SEPARATOR : OUTBOUND_SEPARATOR;
  if (!full && items.length > COMPACT_EDGE_LIMIT && detailsPage) {
    return `${items.slice(0, COMPACT_EDGE_LIMIT).join(separator)} … ${items.length - COMPACT_EDGE_LIMIT} more in ${link("details", fromPage, detailsPage)}`;
  }
  return items.join(separator);
}

function referencedBySummary(referencedBy, full) {
  return full || referencedBy.length <= COMPACT_EDGE_LIMIT ? referencedBy.join(", ") : `${referencedBy.length} relations (see details)`;
}

function relationshipsSection(model, relation, fromPage, full, detailsPage = null) {
  const outbound = outboundEdges(model, relation, fromPage);
  const inbound = inboundEdges(model, relation, fromPage);
  const referencedBy = model.ir.derived.polymorphic
    .filter((item) => item.relation !== relation.id && isPolymorphicTarget(item, relation.id))
    .map((item) => `${relationLink(model, fromPage, item.relation)} (${item.basis})`);
  const overflow = (items, kind) => formatEdgeList(items, { kind, full, fromPage, detailsPage });
  const blocks = [`Outbound: ${outbound.length > 0 ? overflow(outbound, "outbound") : "none"}.`, `Inbound: ${inbound.length > 0 ? overflow(inbound, "inbound") : "none"}.`];
  const polymorphic = polymorphicEdges(model, relation, fromPage, full);
  if (polymorphic.length > 0) blocks.push(`Polymorphic: ${polymorphic.join("; ")}.`);
  if (referencedBy.length > 0) blocks.push(`Polymorphic target of: ${referencedBySummary(referencedBy, full)}.`);
  return `${blocks.join("\n")}\n`;
}

function indexesSection(relation, full) {
  if (relation.indexes.length === 0) return "_None._\n";
  if (full) return table(["Index", "Definition"], relation.indexes.map((index) => [code(index.name), code(index.definition)]));
  return `${relation.indexes.map((index) => `${code(index.name)}${index.unique ? " unique" : ""}${index.predicate ? ` where ${code(truncate(index.predicate, DEFAULT_TRUNCATE))}` : ""}`).join("; ")}\n`;
}

function constraintTriggerSuffix(trigger) {
  if (!trigger.constraint) return "";
  return " (constraint trigger" + (trigger.initially_deferred ? ", deferred)" : ")");
}

function triggersSection(model, relation, fromPage, full) {
  if (relation.triggers.length === 0) return "_None._\n";
  const rows = relation.triggers.map((trigger) => {
    const functionId = model.ir.derived.function_ids_by_name[trigger.function]?.[0];
    const fnText = functionId ? functionLink(model, fromPage, functionId) : code(trigger.function);
    const suffix = constraintTriggerSuffix(trigger);
    return full ? `- ${code(trigger.name)} → ${fnText}${suffix}: ${code(trigger.definition)}` : `- ${code(trigger.name)} → ${fnText}${suffix}`;
  });
  return `${rows.join("\n")}\n`;
}

function rlsStatus(relation) {
  return relation.rls.enabled ? `Enabled${relation.rls.forced ? " and forced" : ""}.` : "Disabled.";
}

function formatPolicy(policy, full) {
  if (full) {
    return `- ${code(policy.name)} (${policy.command}${policy.permissive ? "" : ", restrictive"}) for ${policy.roles.map(code).join(", ")}: using ${code(policy.using)}${policy.with_check ? `; with check ${code(policy.with_check)}` : ""}`;
  }
  return `- ${code(policy.name)} (${policy.command}) for ${policy.roles.map(code).join(", ")}: ${code(truncate(policy.using ?? policy.with_check, POLICY_USING_TRUNCATE))}`;
}

function rlsSection(relation, full) {
  const status = rlsStatus(relation);
  if (relation.rls.policies.length === 0) return `${status}\n`;
  return `${status}\n${relation.rls.policies.map((policy) => formatPolicy(policy, full)).join("\n")}\n`;
}

function grantsSection(relation) {
  const rows = Object.entries(relation.grants)
    .filter(([, privileges]) => privileges.length > 0)
    .map(([role, privileges]) => `${code(role)}: ${privileges.join(", ")}`);
  const none = Object.entries(relation.grants)
    .filter(([, privileges]) => privileges.length === 0)
    .map(([role]) => code(role));
  return `${rows.length > 0 ? rows.join("; ") : "No role has privileges"}.${none.length > 0 ? ` None: ${none.join(", ")}.` : ""}\n`;
}

function readPathsSection(model, relation, fromPage) {
  const queries = model.queriesMentioning(relation.id).map((name) => code(`q:${name}`));
  const views = model.viewsOver(relation.id).map((viewId) => relationLink(model, fromPage, viewId));
  const directReaders = agentRolesAmong(relation.readers);
  const lines = [];
  if (queries.length > 0) lines.push(`- Named queries: ${queries.join(", ")}.`);
  if (views.length > 0) lines.push(`- Exposed through: ${views.join(", ")}.`);
  lines.push(directReaders.length > 0 ? `- Direct SELECT: ${directReaders.map(code).join(", ")}.` : "- No agent role may SELECT directly.");
  return `${lines.join("\n")}\n`;
}

function writePathSection(model, relation, fromPage) {
  const writePath = model.ir.derived.write_paths[relation.id];
  const direct = agentRolesAmong(writePath.direct_dml_roles);
  const via = writePath.via_functions.map((functionId) => functionLink(model, fromPage, functionId));
  if (isViewKind(relation.kind)) return "Views are not written.\n";
  const lines = [];
  lines.push(direct.length > 0 ? `- Direct DML: ${direct.map(code).join(", ")}.` : "- No direct DML for any agent role.");
  if (via.length > 0) lines.push(`- Via functions (best effort): ${via.join(", ")}.`);
  if (direct.length === 0 && via.length === 0) lines.push("- No write path for agents; rows are seeded by migrations or platform tooling.");
  return `${lines.join("\n")}\n`;
}

function examplesSection(model, relation) {
  const overlay = model.overlay(relation.id);
  if (!overlay || overlay.examples.length === 0) return "";
  const blocks = overlay.examples.map((example) => {
    const params = Object.entries(example.params)
      .map(([key, value]) => `--param ${key}=${typeof value === "string" ? value : JSON.stringify(value)}`)
      .join(" ");
    return `${example.title}\n\n\`\`\`bash\nknowledge db query ${example.query}${params ? ` ${params}` : ""}\n\`\`\`${example.note ? `\n${example.note}` : ""}`;
  });
  return `${heading(2, "Examples")}\n${curated(overlay, "")}${blocks.join("\n\n")}\n`;
}

function partitionsSection(relation) {
  if (!relation.partitions) return "";
  const children = relation.partitions.children.map((child) => `${code(child.name)}${child.bound ? ` ${child.bound}` : ""}`);
  return `${heading(2, "Partitions")}\n${relation.partitions.strategy} by ${code(relation.partitions.key)}; ${children.length} children: ${children.join(", ")}.\n`;
}

function viewDefinitionSql(relation) {
  return `${heading(2, "View definition")}\n\`\`\`sql\n${relation.view_definition.trim()}\n\`\`\`\n`;
}

function mainViewDefinitionBlocks({ relation, spilled, mainPage, detailsPage }) {
  if (!relation.view_definition) return ["", ""];
  if (spilled.has("view")) return ["", `${heading(2, "View definition")}\nSee ${link("details", mainPage, detailsPage)}.\n`];
  return [viewDefinitionSql(relation), ""];
}

function typescriptLine(relation) {
  if (!relation.typescript) return "";
  return `${heading(2, "TypeScript")}\n${Object.entries(relation.typescript).map(([member, path]) => `${member}: ${code(path)}`).join("; ")}\n`;
}

/** Main-page body blocks after the title (headings + compact-or-full sections). */
export function relationMainSections({ model, relation, mainPage, detailsPage, spilled, needsDetailsForEdges }) {
  return [
    heading(2, "Columns"),
    spilled.has("columns") ? `${compactColumns(relation)}\nFull column table: ${link("details", mainPage, detailsPage)}.` : columnsTable(model, relation, mainPage),
    heading(2, "Constraints"),
    constraintsSection(relation, spilled.has("checks") ? "spilled" : "inline", link("details", mainPage, detailsPage)),
    heading(2, "Relationships"),
    spilled.has("relationships")
      ? `${relation.foreign_keys.length} outbound and ${relation.inbound_foreign_keys.length} inbound foreign keys; full list in ${link("details", mainPage, detailsPage)}.\n`
      : relationshipsSection(model, relation, mainPage, false, needsDetailsForEdges ? detailsPage : null),
    heading(2, "Indexes"),
    spilled.has("indexes") ? `${relation.indexes.length} indexes; see ${link("details", mainPage, detailsPage)}.\n` : indexesSection(relation, false),
    heading(2, "Triggers"),
    spilled.has("triggers") ? `${relation.triggers.length} triggers; see ${link("details", mainPage, detailsPage)}.\n` : triggersSection(model, relation, mainPage, false),
    heading(2, "Row-level security"),
    spilled.has("policies") ? `${relation.rls.enabled ? "Enabled" : "Disabled"}; ${relation.rls.policies.length} policies in ${link("details", mainPage, detailsPage)}.\n` : rlsSection(relation, false),
    heading(2, "Grants"),
    grantsSection(relation),
    heading(2, "Read paths"),
    readPathsSection(model, relation, mainPage),
    heading(2, "Write path"),
    writePathSection(model, relation, mainPage),
    ...mainViewDefinitionBlocks({ relation, spilled, mainPage, detailsPage }),
    partitionsSection(relation),
    typescriptLine(relation),
    examplesSection(model, relation),
    `Defined in: ${relation.defined_in.map(code).join(", ") || "unknown"}.`,
  ];
}

/** Details-page body blocks (full forms of spilled or always-expanded sections). */
export function relationDetailsSections({ model, relation, detailsPage, spilled }) {
  return [
    spilled.has("columns") ? heading(2, "Columns") + columnsTable(model, relation, detailsPage) : "",
    spilled.has("checks") ? heading(2, "Constraints") + constraintsSection(relation, "full") : "",
    heading(2, "Relationships"),
    relationshipsSection(model, relation, detailsPage, true),
    heading(2, "Indexes"),
    indexesSection(relation, true),
    heading(2, "Triggers"),
    triggersSection(model, relation, detailsPage, true),
    heading(2, "Row-level security"),
    rlsSection(relation, true),
    relation.view_definition ? viewDefinitionSql(relation) : "",
  ];
}
