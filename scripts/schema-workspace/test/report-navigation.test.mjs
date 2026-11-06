import { test } from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import path from "node:path";
import { loadConfig } from "../lib/config.mjs";
import { loadCommittedWorkspace } from "../lib/commands/committed.mjs";
import { loadEnrichment } from "../lib/enrichment/load.mjs";
import { selectionForScope } from "../lib/selection.mjs";
import { buildModel } from "../lib/render/model.mjs";
import { buildSearchIndex } from "../lib/render/search.mjs";

for (const scopeId of ["db-aware-research", "ingestion-author"]) {
  test(`${scopeId} keeps report navigation and evidence targets discoverable`, () => {
    const config = loadConfig();
    const { ir } = loadCommittedWorkspace(config);
    const { enrichment, issues } = loadEnrichment(config.paths.enrichment, ir);
    assert.deepEqual(issues, []);
    const scope = JSON.parse(readFileSync(path.join(config.paths.scopes, `${scopeId}.json`), "utf8"));
    const selection = selectionForScope(ir, enrichment, scope);
    const entries = buildSearchIndex(buildModel(ir, enrichment, selection, config));
    const entry = (id) => {
      const found = entries.find((item) => item.id === id);
      assert.ok(found, `Missing navigation entry: ${id}`);
      assert.ok(!found.stub, `Report navigation unexpectedly reduced to a stub: ${id}`);
      return found;
    };

    entry("dom:research");
    entry("task:register-report");
    for (const query of entry("task:navigate-report").queries) entry(`q:${query}`);
    for (const name of ["report", "report_version", "report_package", "report_section",
      "report_section_version", "report_section_dependency", "report_assertion",
      "report_assertion_claim", "report_artifact", "report_question", "report_question_section"]) {
      assert.equal(entry(`rel:research.${name}`).domain, "research");
    }
    assert.ok(entry("rel:research.report_question").aliases.includes("report gaps"));
    // v1 seals, assessments and ingestion links were withdrawn (20261025010000); the component owns them now.
    for (const name of ["report_package_seal", "report_assessment", "report_ingestion_link"]) {
      assert.ok(!entries.some((item) => item.id === `rel:research.${name}`), `Withdrawn relation still navigable: ${name}`);
    }
    assert.ok(!entries.some((item) => item.id === "q:reports.assessments" || item.id === "q:reports.ingestion_links"));
    entry("rel:orchestration.artifact");
    assert.ok(entries.some((item) => item.id === "rel:evidence.claim"));
  });
}
