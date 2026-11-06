import { readdirSync, readFileSync } from "node:fs";
import path from "node:path";
import { digestText } from "../canonical.mjs";

const CREATE_STATEMENT =
  /create\s+(?:or\s+replace\s+)?(?:unlogged\s+|temp(?:orary)?\s+)?(?:table|view|materialized\s+view|function|procedure|foreign\s+table|type)\s+(?:if\s+not\s+exists\s+)?(?:"?([a-z_][a-z0-9_]*)"?\.)?"?([a-z_][a-z0-9_]*)"?/gi;

/** Maps `schema.name` → sorted migration file names that create it (best effort, grep-based). */
export function indexMigrations(migrationsDir) {
  const index = new Map();
  for (const file of readdirSync(migrationsDir).filter((name) => name.endsWith(".sql")).sort()) {
    const sql = readFileSync(path.join(migrationsDir, file), "utf8");
    for (const match of sql.matchAll(CREATE_STATEMENT)) {
      const qualified = `${(match[1] ?? "public").toLowerCase()}.${match[2].toLowerCase()}`;
      const files = index.get(qualified) ?? new Set();
      files.add(file);
      index.set(qualified, files);
    }
  }
  return new Map([...index].map(([qualified, files]) => [qualified, [...files].sort()]));
}

/**
 * Indexes the generated Database type by indentation so `Database["s"]["Tables"]["n"]` paths can be
 * verified without a TypeScript compiler. Returns `{ paths: Set<"schema.Group.name">, sha256 }`.
 */
export function indexGeneratedTypes(generatedTypesPath) {
  const source = readFileSync(generatedTypesPath, "utf8");
  const paths = new Set();
  let schema = null;
  let group = null;
  for (const line of source.split(/\r?\n/)) {
    const schemaMatch = line.match(/^ {2}([a-z_][a-z0-9_]*): \{$/);
    if (schemaMatch) {
      schema = schemaMatch[1];
      group = null;
      continue;
    }
    const groupMatch = line.match(/^ {4}(Tables|Views|Functions|Enums|CompositeTypes): (?:\{$|Record|\[|never)/);
    if (groupMatch) {
      group = groupMatch[1];
      continue;
    }
    const memberMatch = line.match(/^ {6}([a-z_][a-z0-9_]*): (?:\{|"|\[|Database)/);
    if (memberMatch && schema && group) paths.add(`${schema}.${group}.${memberMatch[1]}`);
  }
  return { paths, sha256: digestText(source) };
}

export function typescriptPath(schema, group, name, member) {
  return `Database["${schema}"]["${group}"]["${name}"]${member ? `["${member}"]` : ""}`;
}
