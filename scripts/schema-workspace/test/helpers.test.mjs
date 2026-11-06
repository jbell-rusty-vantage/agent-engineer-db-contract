import { test } from "node:test";
import assert from "node:assert/strict";
import { canonical, canonicalJson, digest } from "../lib/canonical.mjs";
import { pgArray, rowCountClass } from "../lib/ir/pg-values.mjs";
import { extractRaises, extractTouches, parseArguments } from "../lib/ir/function-body.mjs";
import { functionQualifiedName, idTail, isPolymorphicTarget, polymorphicTargetIds } from "../lib/ir/ids.mjs";
import { isViewKind } from "../lib/render/model.mjs";
import { foldTenantScopedForeignKeys } from "../lib/render/relation-page.mjs";
import { matchesAny } from "../lib/selection.mjs";

test("canonical sorts keys recursively and drops undefined", () => {
  const value = { b: 1, a: { z: undefined, y: [{ d: 1, c: 2 }] } };
  assert.equal(canonicalJson(value), '{"a":{"y":[{"c":2,"d":1}]},"b":1}');
});

test("digest is independent of key insertion order", () => {
  assert.equal(digest({ a: 1, b: 2 }), digest({ b: 2, a: 1 }));
});

test("canonical returns a structurally equal copy", () => {
  const value = { list: [3, { k: "v" }], n: null };
  assert.deepEqual(canonical(value), value);
});

test("pgArray parses quoted and unquoted text array literals", () => {
  assert.deepEqual(pgArray('{a,"b c","d\\"e"}'), ["a", "b c", 'd"e']);
  assert.deepEqual(pgArray("{}"), []);
  assert.deepEqual(pgArray(null), []);
  assert.deepEqual(pgArray(["x"]), ["x"]);
});

test("rowCountClass buckets reltuples", () => {
  assert.equal(rowCountClass(-1), "unknown");
  assert.equal(rowCountClass(0), "none");
  assert.equal(rowCountClass(999), "small");
  assert.equal(rowCountClass(1_000), "medium");
  assert.equal(rowCountClass(1_000_000), "large");
});

test("extractRaises prefers message = literal and unescapes quotes", () => {
  const body = `
    begin
      raise exception using errcode = 'P0001', message = 'tenant isn''t set';
      raise exception 'entity % missing', p_id;
    end`;
  assert.deepEqual(extractRaises(body), ["entity % missing", "tenant isn't set"]);
});

test("extractTouches separates writes, reads, and calls", () => {
  const body = `
    insert into corpus.entity (id) select id from staging.candidate;
    perform util.current_tenant_id();
    select util.some_value;`;
  const known = {
    relationNames: ["corpus.entity", "staging.candidate", "corpus.entity_alias"],
    functionNames: ["util.current_tenant_id", "util.some_value"],
  };
  assert.deepEqual(extractTouches(body, known), {
    reads: ["staging.candidate"],
    writes: ["corpus.entity"],
    calls: ["util.current_tenant_id"],
  });
});

test("parseArguments handles modes, defaults, and unnamed multi-word types", () => {
  assert.deepEqual(parseArguments("p_id uuid, OUT total bigint, p_at timestamp with time zone DEFAULT now(), text[]"), [
    { mode: "in", name: "p_id", type: "uuid", default: null },
    { mode: "out", name: "total", type: "bigint", default: null },
    { mode: "in", name: "p_at", type: "timestamp with time zone", default: "now()" },
    { mode: "in", name: null, type: "text[]", default: null },
  ]);
  assert.deepEqual(parseArguments(""), []);
});

test("foldTenantScopedForeignKeys folds the tenant twin into the plain edge without mutating input", () => {
  const plain = { to: "corpus.entity", columns: ["entity_id"] };
  const twin = { to: "corpus.entity", columns: ["tenant_id", "entity_id"] };
  const lone = { to: "orchestration.mission", columns: ["tenant_id", "mission_id"] };
  const folded = foldTenantScopedForeignKeys([plain, twin, lone]);
  assert.deepEqual(folded, [
    { ...plain, tenant_scoped: true },
    { ...lone, tenant_scoped: false },
  ]);
  assert.equal("tenant_scoped" in plain, false);
});

test("idTail and functionQualifiedName strip IR prefixes", () => {
  assert.equal(idTail("rel:corpus.entity"), "corpus.entity");
  assert.equal(idTail("voc:knowledge.entity_kind"), "knowledge.entity_kind");
  assert.equal(functionQualifiedName("fn:temporal.begin_batch(uuid,text)"), "temporal.begin_batch");
});

test("polymorphicTargetIds unions exclusive columns and vocabulary maps", () => {
  const item = { targets: ["rel:a.one"], targets_by_value: { x: "rel:b.two", y: "rel:a.one" } };
  assert.deepEqual(polymorphicTargetIds(item), ["rel:a.one", "rel:b.two", "rel:a.one"]);
  assert.equal(isPolymorphicTarget(item, "rel:b.two"), true);
  assert.equal(isPolymorphicTarget({ targets: ["rel:a.one"] }, "rel:b.two"), false);
});

test("isViewKind covers views and materialized views only", () => {
  assert.equal(isViewKind("view"), true);
  assert.equal(isViewKind("materialized_view"), true);
  assert.equal(isViewKind("table"), false);
});

test("matchesAny treats * as a glob and dots as literals", () => {
  assert.equal(matchesAny("corpus.entity", ["corpus.*"]), true);
  assert.equal(matchesAny("corpus_entity", ["corpus.*"]), false);
  assert.equal(matchesAny("list_claims", ["list_*", "get_*"]), true);
  assert.equal(matchesAny("other", []), false);
});
