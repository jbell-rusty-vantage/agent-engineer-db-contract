import assert from "node:assert/strict";
import { PostgresMeta } from "@supabase/postgres-meta";
import { getGeneratorMetadata } from "@supabase/postgres-meta/dist/lib/generators.js";
import { apply } from "@supabase/postgres-meta/dist/server/templates/typescript.js";

// Parent supplies a minimal environment and the canonical schema list.
const schemas = JSON.parse(process.argv[2]);
assert.ok(Array.isArray(schemas) && schemas.length > 0 && schemas.every((s) => typeof s === "string"));
const url = new URL(process.env.POSTGRES_URL ?? "");
if (!["postgres:", "postgresql:"].includes(url.protocol)
  || !["localhost", "127.0.0.1"].includes(url.hostname) || url.port !== "54322"
  || url.pathname !== "/postgres" || url.search || url.hash) {
  throw new Error("NATIVE_TYPEGEN_REQUIRES_LOCAL_POSTGRES_54322");
}
url.searchParams.set("options", "-c default_transaction_read_only=on -c statement_timeout=20000");
const meta = new PostgresMeta({ connectionString: url.toString(), connectionTimeoutMillis: 5000, query_timeout: 25000 });
let ended = false;
try {
  const readonly = await meta.query("show transaction_read_only");
  assert.equal(readonly.data?.[0]?.transaction_read_only, "on", "NATIVE_TYPEGEN_READ_ONLY_REQUIRED");
  const { data, error } = await getGeneratorMetadata(meta, { includedSchemas: schemas });
  if (error) throw new Error("NATIVE_TYPEGEN_INTROSPECTION_FAILED");
  ended = true;
  assert.deepEqual(data.schemas.map((s) => s.name).sort(), [...schemas].sort(), "NATIVE_TYPEGEN_SCHEMA_SET_MISMATCH");
  process.stdout.write(await apply({ ...data, detectOneToOneRelationships: true }));
} finally {
  if (!ended) await meta.end();
}
