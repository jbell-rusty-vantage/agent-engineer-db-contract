import { canonicalJson } from "../canonical.mjs";
import { loadConfig } from "../config.mjs";
import { openPool, resolveDatabaseUrl } from "../db.mjs";
import { ExitCode } from "../errors.mjs";
import { introspectToIr } from "../pipeline.mjs";
import { loadCommittedWorkspace } from "./committed.mjs";

function diffKeyed(before, after, describe) {
  const added = Object.keys(after).filter((key) => !(key in before)).sort();
  const removed = Object.keys(before).filter((key) => !(key in after)).sort();
  const changed = Object.keys(after)
    .filter((key) => key in before && canonicalJson(before[key]) !== canonicalJson(after[key]))
    .sort()
    .map((key) => ({ id: key, ...describe(before[key], after[key]) }));
  return { added, removed, changed };
}

function keyedBy(items, keyOf) {
  return Object.fromEntries(items.map((item) => [keyOf(item), item]));
}

function describeRelationChange(before, after) {
  const columns = diffKeyed(keyedBy(before.columns, (column) => column.name), keyedBy(after.columns, (column) => column.name), () => ({}));
  const policies = diffKeyed(keyedBy(before.rls.policies, (policy) => policy.name), keyedBy(after.rls.policies, (policy) => policy.name), () => ({}));
  const indexes = diffKeyed(keyedBy(before.indexes, (index) => index.name), keyedBy(after.indexes, (index) => index.name), () => ({}));
  const grants = diffKeyed(before.grants, after.grants, (b, a) => ({ before: b, after: a }));
  const other = ["primary_key", "unique", "checks", "exclusions", "foreign_keys", "triggers", "view_definition", "kind", "comment", "partitions"].filter((field) => canonicalJson(before[field]) !== canonicalJson(after[field]));
  return { columns, policies, indexes, grants, other_fields: other };
}

function describeFunctionChange(before, after) {
  return { fields: ["returns", "volatility", "security", "body_sha256", "executors", "raises", "arguments"].filter((field) => canonicalJson(before[field]) !== canonicalJson(after[field])) };
}

function describeVocabularyChange(before, after) {
  const rows = diffKeyed(keyedBy(before.rows, (row) => String(row[before.key])), keyedBy(after.rows, (row) => String(row[after.key])), () => ({}));
  return { rows };
}

/** Structural drift between the committed IR and a fresh introspection. Never writes into `workspace/`. */
export function diffIr(committed, fresh) {
  return {
    relations: diffKeyed(committed.relations, fresh.relations, describeRelationChange),
    functions: diffKeyed(committed.functions, fresh.functions, describeFunctionChange),
    types: diffKeyed(committed.types, fresh.types, (b, a) => ({ before: b.labels ?? b, after: a.labels ?? a })),
    vocabularies: diffKeyed(committed.vocabularies, fresh.vocabularies, describeVocabularyChange),
    roles: diffKeyed(committed.roles, fresh.roles, (b, a) => ({ before: b, after: a })),
  };
}

export async function runCheck(values) {
  const config = loadConfig({ workspace: values.workspace });
  const { ir: committed, fingerprint } = loadCommittedWorkspace(config);
  const databaseUrl = resolveDatabaseUrl(values["db-url"]);
  const pool = await openPool(databaseUrl);
  try {
    const { ir: fresh } = await introspectToIr(pool, config, databaseUrl);
    const same = fresh.fingerprint === fingerprint.fingerprint;
    const report = {
      same,
      committed_fingerprint: fingerprint.fingerprint,
      database_fingerprint: fresh.fingerprint,
      migration_head: { committed: committed.build.migration_head, database: fresh.build.migration_head },
      generated_types_changed: committed.build.generated_types_sha256 !== fresh.build.generated_types_sha256,
      drift: same ? null : diffIr(committed, fresh),
    };
    process.stdout.write(`${JSON.stringify(report, null, 2)}\n`);
    return same && !report.generated_types_changed ? ExitCode.OK : ExitCode.DOMAIN;
  } finally {
    await pool.end();
  }
}
