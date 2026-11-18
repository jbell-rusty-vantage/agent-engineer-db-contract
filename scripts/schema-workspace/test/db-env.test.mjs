import { test } from "node:test";
import assert from "node:assert/strict";
import { isLoopbackUrl, optionalDatabaseUrl, resolveDatabaseUrl } from "../lib/db.mjs";

const ADMIN = "postgresql://postgres.fakeref:fake@aws-0-fake.pooler.example.invalid:5432/postgres";
const LOCAL = "postgresql://postgres:fake@127.0.0.1:54322/postgres";
const BOTH = { AIENG_DB_ADMIN_DSN: ADMIN, AIENG_DB_LOCAL_DSN: LOCAL };

test("an explicit --db-url wins over every variable and target", () => {
  assert.equal(optionalDatabaseUrl({ url: "postgresql://explicit" }, BOTH), "postgresql://explicit");
  assert.equal(optionalDatabaseUrl({ url: "postgresql://explicit", target: "remote" }, BOTH), "postgresql://explicit");
});

test("no target means local: the loopback DSN, never the remote admin DSN", () => {
  assert.equal(optionalDatabaseUrl({}, BOTH), LOCAL);
  assert.equal(optionalDatabaseUrl(undefined, BOTH), LOCAL);
  assert.equal(optionalDatabaseUrl({ target: "local" }, BOTH), LOCAL);
  assert.equal(optionalDatabaseUrl({}, { AIENG_DB_ADMIN_DSN: ADMIN }), null);
  assert.throws(() => resolveDatabaseUrl({}, { AIENG_DB_ADMIN_DSN: ADMIN }), (error) => {
    assert.equal(error.code, "DB_UNREACHABLE");
    assert.match(error.message, /read only with --target remote/);
    assert.doesNotMatch(error.message, /fakeref|pooler/);
    return true;
  });
});

test("--target remote reads AIENG_DB_ADMIN_DSN, and refuses when it is unset", () => {
  assert.equal(optionalDatabaseUrl({ target: "remote" }, BOTH), ADMIN);
  assert.throws(() => optionalDatabaseUrl({ target: "remote" }, { AIENG_DB_LOCAL_DSN: LOCAL }), /--target remote needs AIENG_DB_ADMIN_DSN/);
});

test("an unknown target is a usage error", () => {
  assert.throws(() => optionalDatabaseUrl({ target: "production" }, BOTH), (error) => error.code === "USAGE");
});

test("old names are not read", () => {
  const old = { POSTGRES_URL: LOCAL, POSTGRES_URL_NON_POOLING: ADMIN };
  assert.equal(optionalDatabaseUrl({}, old), null);
  assert.throws(() => resolveDatabaseUrl({}, old), /AIENG_DB_LOCAL_DSN/);
});

test("a non-loopback AIENG_DB_LOCAL_DSN is refused, never used", () => {
  assert.throws(() => optionalDatabaseUrl({}, { AIENG_DB_LOCAL_DSN: ADMIN }), /loopback/);
  assert.ok(isLoopbackUrl("postgresql://u:p@localhost:5432/postgres"));
  assert.ok(isLoopbackUrl("postgresql://u:p@[::1]:5432/postgres"));
  assert.ok(!isLoopbackUrl("not a url"));
});
