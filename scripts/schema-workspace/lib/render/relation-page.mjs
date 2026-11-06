import { byteLength } from "../canonical.mjs";
import { code, curated, frontmatter, heading, joinBlocks, link } from "./markdown.mjs";
import { pages } from "./model.mjs";
import { COMPACT_EDGE_LIMIT, foldTenantScopedForeignKeys, relationDetailsSections, relationMainSections } from "./relation-sections.mjs";

const VIEW_DEFINITION_SPILL_CHARS = 400;
const SPILL_ORDER = ["view", "indexes", "policies", "triggers", "relationships", "checks", "columns"];

export { foldTenantScopedForeignKeys };

function tokensOf(relation) {
  return [relation.schema, relation.name, `${relation.schema}.${relation.name}`, ...relation.columns.map((column) => column.name)];
}

export function relationFrontmatter(model, relation) {
  const overlay = model.overlay(relation.id);
  const summary = overlay?.summary ?? relation.comment ?? null;
  return {
    id: relation.id,
    kind: relation.kind,
    schema: relation.schema,
    name: relation.name,
    domain: model.domainOfRelation(relation.id),
    aliases: overlay?.aliases ?? [],
    tokens: tokensOf(relation),
    summary,
    summary_basis: overlay?.summary ? "curated" : relation.comment ? "comment" : "none",
    rls: relation.rls.enabled ? "enabled" : "disabled",
    readers: relation.readers,
    writers: relation.writers,
    typescript: relation.typescript?.row ?? null,
    defined_in: relation.defined_in,
    workspace_fingerprint: model.buildInfo.workspace_fingerprint,
  };
}

function edgesExceedCompactLimit(relation) {
  return relation.inbound_foreign_keys.length > COMPACT_EDGE_LIMIT || relation.foreign_keys.length > COMPACT_EDGE_LIMIT;
}

function spillUntilBudget({ relation, budgets, compose }) {
  const spilled = new Set();
  if (relation.view_definition && relation.view_definition.length > VIEW_DEFINITION_SPILL_CHARS) spilled.add("view");
  let main = compose(spilled);
  for (const section of SPILL_ORDER) {
    if (byteLength(main) <= budgets.relation_main_bytes) break;
    if (spilled.has(section)) continue;
    spilled.add(section);
    main = compose(spilled);
  }
  return { spilled, main };
}

function composeMainPage({ model, relation, overlay, mainPage, detailsPage, spilled, needsDetailsForEdges }) {
  const intro = [
    heading(1, `${relation.schema}.${relation.name}`),
    `${relation.kind.replaceAll("_", " ")} in domain ${code(model.domainOfRelation(relation.id) ?? "none")}${relation.comment ? ` — ${relation.comment}` : ""}.`,
    overlay ? curated(overlay, overlay.notes ?? overlay.summary) : "",
  ];
  return frontmatter(relationFrontmatter(model, relation)) + joinBlocks([...intro, ...relationMainSections({ model, relation, mainPage, detailsPage, spilled, needsDetailsForEdges })]);
}

function composeDetailsPage({ model, relation, mainPage, detailsPage, spilled }) {
  return (
    frontmatter({ id: `${relation.id}#details`, kind: "details", schema: relation.schema, name: relation.name, of: relation.id, workspace_fingerprint: model.buildInfo.workspace_fingerprint }) +
    joinBlocks([
      heading(1, `${relation.schema}.${relation.name} — details`),
      `Spill-over from ${link("the main page", detailsPage, mainPage)}.`,
      ...relationDetailsSections({ model, relation, detailsPage, spilled }),
    ])
  );
}

/**
 * Renders the relation page and, when the main page would exceed its budget, a details page.
 * Sections spill in a fixed order so the output is deterministic.
 */
export function renderRelationPages(model, relation, budgets) {
  const mainPage = pages.relation(relation);
  const detailsPage = pages.relationDetails(relation);
  const overlay = model.overlay(relation.id);
  const needsDetailsForEdges = edgesExceedCompactLimit(relation);
  const compose = (spilled) => composeMainPage({ model, relation, overlay, mainPage, detailsPage, spilled, needsDetailsForEdges });
  const { spilled, main } = spillUntilBudget({ relation, budgets, compose });
  if (spilled.size === 0 && !needsDetailsForEdges) return { main: { path: mainPage, content: main }, details: null };
  return {
    main: { path: mainPage, content: main },
    details: { path: detailsPage, content: composeDetailsPage({ model, relation, mainPage, detailsPage, spilled }) },
  };
}

export function renderRelationStub(model, relation, scope) {
  const referencing = model
    .visibleRelations()
    .flatMap((source) => source.foreign_keys.filter((fk) => fk.to === relation.id).map((fk) => ({ source, fk })));
  const referencedColumns = [...new Set(referencing.flatMap(({ fk }) => fk.to_columns))].sort();
  const page = pages.relationStub(relation);
  const content =
    frontmatter({ id: relation.id, kind: relation.kind, schema: relation.schema, name: relation.name, stub: true, scope: scope.id, workspace_fingerprint: model.buildInfo.workspace_fingerprint }) +
    joinBlocks([
      heading(1, `${relation.schema}.${relation.name} (stub)`),
      `Out of scope for this bundle. Referenced by in-scope relations: ${referencing.map(({ source, fk }) => `${link(code(`${source.schema}.${source.name}.${fk.columns.join(",")}`), page, pages.relation(source))}`).join(", ") || "none"}. Columns referenced: ${referencedColumns.map(code).join(", ") || "none"}.`,
      `Full page in the complete workspace (fingerprint ${code(model.buildInfo.workspace_fingerprint)}).`,
    ]);
  return { path: page, content };
}
