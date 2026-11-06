import { prettyJson } from "../canonical.mjs";
import { renderCatalog, renderIndex, renderQueriesReadme, renderRelationsList, renderRules, renderStartHere } from "./entry-pages.mjs";
import { buildModel, pages } from "./model.mjs";
import { renderDomainPage, renderFunctionPage, renderSchemaReadme, renderTaskPage, renderTypesPage, renderVocabularyPage } from "./reference-pages.mjs";
import { renderRelationPages, renderRelationStub } from "./relation-page.mjs";
import { renderSearchFiles } from "./search.mjs";

/**
 * Renders every page of a (possibly scoped) workspace into a `Map<path, content>`.
 * `manifest.json`, `fingerprint.json`, and `validation.json` are added by the build step after
 * validation because they describe the rendered tree.
 */
export function renderWorkspace({ ir, enrichment, selection, buildInfo, budgets }) {
  const model = buildModel(ir, enrichment, selection, buildInfo);
  const files = new Map();
  const put = (file) => {
    if (file) files.set(file.path, file.content);
  };

  put(renderStartHere(model));
  put(renderIndex(model));
  put(renderRelationsList(model));
  for (const domain of model.visibleDomains()) put(renderDomainPage(model, domain));
  for (const schema of Object.values(ir.schemas)) {
    if (schema.relation_ids.some((relationId) => selection.relationIds.has(relationId)) || schema.function_ids.some((functionId) => selection.functionIds.has(functionId))) {
      put(renderSchemaReadme(model, schema));
    }
    const types = schema.type_ids.map((typeId) => ir.types[typeId]);
    if (types.length > 0) put(renderTypesPage(model, schema.name, types));
  }
  for (const relation of model.visibleRelations()) {
    const { main, details } = renderRelationPages(model, relation, budgets);
    put(main);
    put(details);
  }
  for (const relationId of selection.stubRelationIds) put(renderRelationStub(model, ir.relations[relationId], selection.scope));
  const renderedFunctions = new Set();
  for (const fn of model.visibleFunctions()) {
    const key = `${fn.schema}.${fn.name}`;
    if (renderedFunctions.has(key)) continue;
    renderedFunctions.add(key);
    put(renderFunctionPage(model, model.functionOverloads(key).filter((overload) => selection.functionIds.has(overload.id))));
  }
  for (const vocabulary of Object.values(ir.vocabularies)) put(renderVocabularyPage(model, vocabulary));
  for (const task of model.visibleTasks()) put(renderTaskPage(model, task));
  put(renderQueriesReadme(model));
  put(renderCatalog(model));
  for (const file of renderRules(model)) put(file);
  for (const file of renderSearchFiles(model)) put(file);
  if (selection.scope) files.set(pages.scope, prettyJson(selection.scope));
  else files.set(pages.ir, prettyJson({ ...ir, enrichment }));
  return { files, model };
}
