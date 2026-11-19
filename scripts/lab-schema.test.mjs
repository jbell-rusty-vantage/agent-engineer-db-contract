// Offline tests for scripts/lab-schema.mjs: they render from the committed workspace IR and never open a database.
import assert from "node:assert/strict";
import { mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import path from "node:path";
import { test } from "node:test";
import { fileURLToPath } from "node:url";
import { compareWithContract, readLabConfig, renderSchemaPage, renderVocabularies } from "./lab-schema.mjs";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const ir = JSON.parse(readFileSync(path.join(root, "workspace", "schema-ir.json"), "utf8"));
const anchorsOf = (page) => new Set([...page.matchAll(/<a id="([^"]+)"><\/a>/g)].map((m) => m[1]));

test("a schema page lists every relation of the schema with its columns", () => {
  const page = renderSchemaPage("temporal", ir, ir.enrichment);
  for (const relation of Object.values(ir.relations).filter((r) => r.schema === "temporal")) {
    assert.ok(page.includes(`### temporal.${relation.name}\n`), relation.name);
    for (const column of relation.columns) assert.ok(page.includes(`| \`${column.name}\` | \`${column.type}\``), `${relation.name}.${column.name}`);
  }
  assert.ok(page.includes("caused_by_event_id"));
});

test("every link on every schema page resolves to an anchor that a page defines", () => {
  const schemas = [...new Set(Object.values(ir.relations).map((r) => r.schema))];
  const pages = new Map(schemas.map((schema) => [schema, renderSchemaPage(schema, ir, ir.enrichment)]));
  let links = 0;
  for (const [schema, page] of pages) {
    for (const [, file, anchor] of page.matchAll(/\]\(([a-z_]*\.md)?#([a-z0-9-]+)\)/g)) {
      const target = file ? file.replace(/\.md$/, "") : schema;
      assert.ok(pages.has(target), `${schema} links to a page that is not rendered: ${file}`);
      assert.ok(anchorsOf(pages.get(target)).has(anchor), `${schema} -> ${target}#${anchor}`);
      links += 1;
    }
  }
  assert.ok(links > 200);
});

test("a reference to a relation outside the rendered schemas is text, not a link", () => {
  const page = renderSchemaPage("learning", ir, ir.enrichment);
  assert.ok(page.includes("`auth.users`"));
  assert.ok(!page.includes("auth.md"));
});

test("vocabularies are rendered with every code", () => {
  const page = renderVocabularies(ir);
  for (const row of ir.vocabularies["voc:taxonomy.entity_kind"].rows) assert.ok(page.includes(`| \`${row.code}\` |`), row.code);
});

test("a lab equal to the contract compares as no difference, and a changed column is reported", () => {
  assert.ok(Object.values(compareWithContract(ir, ir)).every((ids) => ids.length === 0));
  const changed = structuredClone(ir);
  changed.relations["rel:temporal.segment"].columns.push({ name: "reason_code", type: "text", nullable: true });
  delete changed.relations["rel:temporal.extent"];
  const result = compareWithContract(changed, ir);
  assert.deepEqual(result.relations_with_different_columns, ["rel:temporal.segment"]);
  assert.deepEqual(result.relations_only_in_contract, ["rel:temporal.extent"]);
});

test("only a disposable project is accepted as a lab", () => {
  const dir = mkdtempSync(path.join(tmpdir(), "lab-schema-"));
  try {
    mkdirSync(path.join(dir, "supabase"));
    const write = (project) => writeFileSync(path.join(dir, "supabase", "config.toml"), `project_id = "${project}"\n\n[db]\nport = 55622\n`, "utf8");
    write("disposable-aieng-build04");
    assert.deepEqual(readLabConfig(dir), { project: "disposable-aieng-build04", port: 55622 });
    write("aiengineer");
    assert.throws(() => readLabConfig(dir), /DISPOSABLE_PROJECT_REQUIRED/);
  } finally {
    rmSync(dir, { recursive: true, force: true });
  }
});
