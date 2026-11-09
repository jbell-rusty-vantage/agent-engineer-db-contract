import { test } from "node:test";
import assert from "node:assert/strict";
import { canonical, canonicalJson, digest } from "../lib/canonical.mjs";
import { pgArray, rowCountClass } from "../lib/ir/pg-values.mjs";
import { extractRaises, extractTouches, parseArguments } from "../lib/ir/function-body.mjs";
import { extractCaseBranches, tokenizeBody } from "../lib/ir/case-branches.mjs";
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
    insert into catalog.entity (id) select id from staging.candidate;
    perform util.current_tenant_id();
    select util.some_value;`;
  const known = {
    relationNames: ["catalog.entity", "staging.candidate", "catalog.entity_alias"],
    functionNames: ["util.current_tenant_id", "util.some_value"],
  };
  assert.deepEqual(extractTouches(body, known), {
    reads: ["staging.candidate"],
    writes: ["catalog.entity"],
    calls: ["util.current_tenant_id"],
  });
});

test("extractCaseBranches splits a dispatcher body into top-level arms and skips nested case/if/else", () => {
  const body = `
    declare x int;
    begin
      case op
      when 'create_work' then
        insert into authoring.work (id) values (1); -- when 'nope' then
        if pl ? 'x' then x := 1; else x := 2; end if;
        return jsonb_build_object('k', case when x = 1 then 'ours' else 'private' end);
      when 'get_revision', 'get_rev' then
        select * from authoring.work_revision where id = (pl ->> 'id')::uuid;
        for r in select 1 loop null; end loop;
      else
        return product.dispatch_research_command(op);
      end case;
    end`;
  const parsed = extractCaseBranches(body);
  assert.equal(parsed.variable, "op");
  assert.deepEqual(parsed.branches.map((branch) => branch.operations), [["create_work"], ["get_revision", "get_rev"]]);
  assert.match(parsed.branches[0].text, /insert into authoring\.work/);
  assert.ok(!parsed.branches[0].text.includes("authoring.work_revision"));
  assert.match(parsed.fallthrough, /dispatch_research_command/);
  assert.equal(extractCaseBranches("begin return 1; end"), null);
  assert.deepEqual(tokenizeBody("a 'it''s' -- c\n b").map((token) => token.value), ["a", "it's", "b"]);
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
  const plain = { to: "catalog.entity", columns: ["entity_id"] };
  const twin = { to: "catalog.entity", columns: ["tenant_id", "entity_id"] };
  const lone = { to: "orchestration.mission", columns: ["tenant_id", "mission_id"] };
  const folded = foldTenantScopedForeignKeys([plain, twin, lone]);
  assert.deepEqual(folded, [
    { ...plain, tenant_scoped: true },
    { ...lone, tenant_scoped: false },
  ]);
  assert.equal("tenant_scoped" in plain, false);
});

test("idTail and functionQualifiedName strip IR prefixes", () => {
  assert.equal(idTail("rel:catalog.entity"), "catalog.entity");
  assert.equal(idTail("voc:taxonomy.entity_kind"), "taxonomy.entity_kind");
  assert.equal(idTail("op:create_work"), "create_work");
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
  assert.equal(matchesAny("catalog.entity", ["catalog.*"]), true);
  assert.equal(matchesAny("catalog_entity", ["catalog.*"]), false);
  assert.equal(matchesAny("list_claims", ["list_*", "get_*"]), true);
  assert.equal(matchesAny("other", []), false);
});
