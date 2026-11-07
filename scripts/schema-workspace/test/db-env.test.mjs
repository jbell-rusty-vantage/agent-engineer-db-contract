import { test } from "node:test";
import assert from "node:assert/strict";
import { isLoopbackUrl, optionalDatabaseUrl, resolveDatabaseUrl } from "../lib/db.mjs";

const ADMIN = "postgresql://postgres.fakeref:fake@aws-0-fake.pooler.example.invalid:5432/postgres";
const LOCAL = "postgresql://postgres:fake@127.0.0.1:54322/postgres";

test("explicit URL wins, then AIENG_DB_ADMIN_DSN, then loopback AIENG_DB_LOCAL_DSN", () => {
  assert.equal(optionalDatabaseUrl("postgresql://explicit", { AIENG_DB_ADMIN_DSN: ADMIN }), "postgresql://explicit");
  assert.equal(optionalDatabaseUrl(undefined, { AIENG_DB_ADMIN_DSN: ADMIN, AIENG_DB_LOCAL_DSN: LOCAL }), ADMIN);
  assert.equal(optionalDatabaseUrl(undefined, { AIENG_DB_LOCAL_DSN: LOCAL }), LOCAL);
  assert.equal(optionalDatabaseUrl(undefined, {}), null);
});

test("old names are not read", () => {
  const old = { POSTGRES_URL: LOCAL, POSTGRES_URL_NON_POOLING: ADMIN };
  assert.equal(optionalDatabaseUrl(undefined, old), null);
  assert.throws(() => resolveDatabaseUrl(undefined, old), /AIENG_DB_ADMIN_DSN/);
});

test("a non-loopback AIENG_DB_LOCAL_DSN is refused, never used", () => {
  assert.throws(() => optionalDatabaseUrl(undefined, { AIENG_DB_LOCAL_DSN: ADMIN }), /loopback/);
  assert.ok(isLoopbackUrl("postgresql://u:p@localhost:5432/postgres"));
  assert.ok(isLoopbackUrl("postgresql://u:p@[::1]:5432/postgres"));
  assert.ok(!isLoopbackUrl("not a url"));
});
