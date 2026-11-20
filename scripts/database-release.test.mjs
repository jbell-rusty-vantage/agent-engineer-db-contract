import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { test } from "node:test";
import { fileURLToPath } from "node:url";
import { CHECK_VARIABLE, RELEASE_FORMAT, checkMode, compareVersions, inRange, notApplicable, releaseVerdict } from "./database-release.mjs";

const repository = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const cases = JSON.parse(readFileSync(join(repository, "release-check.cases.json"), "utf8"));

test("the shared cases name the format and the variable this implementation uses", () => {
  assert.equal(cases.format, "ai-engineer-release-check-cases/1");
  assert.equal(cases.mode.variable, CHECK_VARIABLE);
  assert.deepEqual(Object.keys(cases.mode.values), ["enforce", "warn", "off"]);
  assert.ok(cases.verdict.some((c) => c.observed?.format === RELEASE_FORMAT));
});

test("a range is an exact version or a half-open interval, compared by number", () => {
  for (const c of cases.range) assert.equal(inRange(c.version, c.range), c.in, `${c.version} in ${c.range}`);
  assert.equal(compareVersions("1.10.0", "1.9.9"), 1);
  assert.throws(() => inRange("1.0.0", "^1.0.0"), /not a release range/);
  assert.throws(() => inRange("1.0", "1.0.0"), /not a release version/);
});

test("every shared verdict case holds", () => {
  for (const c of cases.verdict) {
    const verdict = releaseVerdict(c.observed, c.range);
    assert.equal(verdict.verdict, c.verdict, c.name);
    assert.equal(verdict.start, c.start, c.name);
    assert.equal(verdict.warning, c.warning, c.name);
    assert.ok(verdict.reason.length > 0, c.name);
  }
});

test("a database without the contract is not applicable and the consumer starts", () => {
  const verdict = notApplicable("0.12.0");
  assert.equal(verdict.verdict, "not_applicable");
  assert.equal(verdict.start, true);
  assert.equal(verdict.warning, false);
});

test("the mode defaults to enforce and refuses an unknown value", () => {
  assert.equal(checkMode({}), "enforce");
  assert.equal(checkMode({ [CHECK_VARIABLE]: "WARN" }), "warn");
  assert.equal(checkMode({ [CHECK_VARIABLE]: "off" }), "off");
  assert.throws(() => checkMode({ [CHECK_VARIABLE]: "maybe" }), /enforce, warn or off/);
});
