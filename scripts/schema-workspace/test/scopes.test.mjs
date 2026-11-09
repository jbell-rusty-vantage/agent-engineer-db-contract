import { test } from "node:test";
import assert from "node:assert/strict";
import { readdirSync, readFileSync } from "node:fs";
import path from "node:path";
import { loadConfig } from "../lib/config.mjs";
import { loadCommittedWorkspace } from "../lib/commands/committed.mjs";
import { loadEnrichment } from "../lib/enrichment/load.mjs";
import { selectionForScope } from "../lib/selection.mjs";
import { buildModel } from "../lib/render/model.mjs";
import { buildSearchIndex } from "../lib/render/search.mjs";

const config = loadConfig();
const { ir } = loadCommittedWorkspace(config);
const { enrichment, issues } = loadEnrichment(config.paths.enrichment, ir);
const HIDDEN = new Set(config.lenses.hidden);

function entriesFor(scopeId) {
  const scope = JSON.parse(readFileSync(path.join(config.paths.scopes, `${scopeId}.json`), "utf8"));
  const selection = selectionForScope(ir, enrichment, scope);
  const model = buildModel(ir, enrichment, selection, config, config.lenses);
  return { scope, selection, model, entries: buildSearchIndex(model) };
}

test("enrichment loads against the committed IR without issues", () => {
  assert.deepEqual(issues, []);
});

test("every search-index entry of the full workspace carries a lens and operations are indexed", () => {
  const { entries } = entriesFor("full");
  for (const entry of entries) assert.ok("lens" in entry, `entry without lens: ${entry.id}`);
  const operations = entries.filter((entry) => entry.kind === "operation");
  assert.ok(operations.length >= 70, `expected the product operations, found ${operations.length}`);
  for (const name of ["create_work", "revise_work", "search", "propose_research", "index_passages"]) {
    const found = operations.find((entry) => entry.qualified_name === name);
    assert.ok(found, `missing operation ${name}`);
    assert.equal(found.lens, "ours");
  }
  assert.equal(operations.find((entry) => entry.qualified_name === "create_work").relations.includes("authoring.work"), true);
  assert.ok(!entries.some((entry) => entry.id.startsWith("rel:corpus.") || entry.id.startsWith("rel:research.") || entry.id === "dom:research"));
});

test("every scope file selects known domains, tasks and queries", () => {
  for (const file of readdirSync(config.paths.scopes).filter((name) => name.endsWith(".json"))) {
    const { scope, selection } = entriesFor(path.basename(file, ".json"));
    for (const slug of scope.tasks ?? []) assert.ok(enrichment.tasks.some((task) => task.slug === slug), `${scope.id}: unknown task ${slug}`);
    assert.ok(selection.relationIds.size > 0, `${scope.id}: selects no relations`);
    if ((scope.queries ?? []).length > 0) assert.ok(selection.queryNames.size > 0, `${scope.id}: selects no queries`);
  }
});

for (const scopeId of ["research", "report-writer", "course-authoring", "learner-assistant", "content-refresh", "ingestion"]) {
  test(`${scopeId} scope keeps its mission pages and excludes machinery and legacy relations`, () => {
    const { scope, selection, model, entries } = entriesFor(scopeId);
    const vocabularies = new Set(Object.values(ir.vocabularies).map((vocabulary) => `${vocabulary.schema}.${vocabulary.table}`));
    // A hidden-lens domain a mission deliberately includes (course authoring writes curriculum rows) is allowed in full.
    const includedHiddenDomains = new Set((scope.include.domains ?? []).filter((slug) => HIDDEN.has(model.lensOfDomain(slug))));
    const machinery = entries.filter(
      (entry) =>
        ["table", "view", "partitioned_table"].includes(entry.kind) &&
        !entry.stub &&
        HIDDEN.has(entry.lens) &&
        !vocabularies.has(entry.qualified_name) &&
        !includedHiddenDomains.has(entry.domain) &&
        !(scope.include.relations ?? []).some((pattern) => entry.qualified_name === pattern),
    );
    assert.deepEqual(machinery.map((entry) => entry.id), [], `${scopeId} renders hidden-lens relations as full pages`);
    for (const name of scope.operations ?? []) assert.ok(selection.operationNames.has(name), `${scopeId}: operation ${name} not selected`);
    assert.ok(!entries.some((entry) => entry.id === "dom:research"));
  });
}

test("mission scopes reach the knowledge continuum levels they need", () => {
  const research = entriesFor("research").entries;
  for (const id of ["rel:api.models", "rel:api.model_offerings", "rel:api.talks", "op:get_report", "task:compare-models", "q:facts.changes_since", "q:retrieval.search_unified"]) {
    assert.ok(research.some((entry) => entry.id === id), `research scope lacks ${id}`);
  }
  assert.ok(research.some((entry) => entry.kind === "function" && entry.qualified_name === "api.search_unified"));
  const learner = entriesFor("learner-assistant").entries;
  for (const id of ["op:search", "op:enroll", "task:search-my-notes", "rel:library.passage"]) assert.ok(learner.some((entry) => entry.id === id), `learner-assistant scope lacks ${id}`);
  assert.equal(learner.find((entry) => entry.id === "rel:library.passage").lens, "private");
  const authoring = entriesFor("course-authoring").entries;
  for (const id of ["op:create_work", "op:freeze_release", "rel:authoring.work_revision", "task:modules-affected-by-release"]) assert.ok(authoring.some((entry) => entry.id === id), `course-authoring scope lacks ${id}`);
  assert.equal(authoring.find((entry) => entry.id === "rel:api.works_authored").lens, "ours");
});
