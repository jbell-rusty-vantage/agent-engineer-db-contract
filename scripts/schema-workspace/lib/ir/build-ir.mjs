import { canonical, canonicalJson, digest, digestText, sortBy } from "../canonical.mjs";
import { extractRaises, extractTouches, parseArguments } from "./function-body.mjs";
import { ids } from "./ids.mjs";
import { pgArray, rowCountClass } from "./pg-values.mjs";
import { typescriptPath } from "./repository-inputs.mjs";

export { functionQualifiedName, ids, idTail, isPolymorphicTarget, polymorphicTargetIds } from "./ids.mjs";

const WRITE_PRIVILEGES = new Set(["INSERT", "UPDATE", "DELETE"]);
const TABLE_LIKE = new Set(["table", "partitioned_table", "foreign_table"]);
const POLICY_PERMISSIVE = "PERMISSIVE";
const CANONICAL_TABLE_COLUMN = "canonical_table";
const CANONICAL_SCHEMA_COLUMN = "canonical_schema";
const EXCLUSIVE_NONNULL_CHECK = /num_nonnulls\(([^)]*)\)\s*=\s*1/i;
const MIN_EXCLUSIVE_TARGETS = 2;

function typeName(pgTypeName) {
  return pgTypeName.startsWith("_") ? `${pgTypeName.slice(1)}[]` : pgTypeName;
}

function groupBy(rows, keyOf) {
  const groups = new Map();
  for (const row of rows) {
    const key = keyOf(row);
    if (!groups.has(key)) groups.set(key, []);
    groups.get(key).push(row);
  }
  return groups;
}

const relationKey = (row) => `${row.schema}.${row.relation}`;

function buildGrants(rows, roles) {
  const grants = Object.fromEntries(roles.map((role) => [role, []]));
  for (const row of rows) grants[row.role]?.push(row.privilege);
  for (const role of roles) grants[role].sort();
  return grants;
}

function readersAndWriters(grants) {
  const readers = Object.keys(grants).filter((role) => grants[role].includes("SELECT")).sort();
  const writers = Object.keys(grants)
    .filter((role) => grants[role].some((privilege) => WRITE_PRIVILEGES.has(privilege)))
    .sort();
  return { readers, writers };
}

function buildColumns(rows, foreignKeys, schema, relation) {
  const fkByColumn = new Map();
  for (const fk of foreignKeys) {
    if (fk.columns.length === 1) fkByColumn.set(fk.columns[0], fk);
  }
  return rows.map((row) => {
    const fk = fkByColumn.get(row.name);
    return {
      id: ids.column(schema, relation, row.name),
      position: row.position,
      name: row.name,
      type: row.type,
      nullable: row.nullable,
      default: row.default_expression,
      generated: row.generated_expression,
      identity: row.identity,
      comment: row.comment,
      fk: fk ? { to: fk.to, columns: fk.to_columns, constraint: fk.name } : null,
    };
  });
}

function buildConstraints(rows, relationIdOf) {
  const foreignKeys = [];
  const unique = [];
  const checks = [];
  const exclusions = [];
  let primaryKey = [];
  for (const row of rows) {
    const columns = pgArray(row.columns);
    switch (row.type) {
      case "primary_key":
        primaryKey = columns;
        break;
      case "unique":
        unique.push(columns);
        break;
      case "check":
        checks.push({ name: row.name, expression: row.expression ?? row.definition });
        break;
      case "exclusion":
        exclusions.push({ name: row.name, definition: row.definition });
        break;
      case "foreign_key":
        foreignKeys.push({
          name: row.name,
          columns,
          to: relationIdOf(row.target_schema, row.target_relation),
          to_columns: pgArray(row.target_columns),
          deferrable: row.deferrable,
          initially_deferred: row.initially_deferred,
          on_delete: row.on_delete,
        });
        break;
      default:
        break;
    }
  }
  return { primaryKey, unique, checks, exclusions, foreignKeys };
}

function mapIndexes(rows, schema) {
  return (rows ?? [])
    .filter((index) => !index.is_primary)
    .map((index) => ({
      id: ids.index(schema, index.name),
      name: index.name,
      definition: index.definition,
      unique: index.is_unique,
      method: index.method,
      predicate: index.predicate,
    }));
}

function mapTriggers(rows, schema, relation) {
  return (rows ?? []).map((trigger) => ({
    id: ids.trigger(schema, relation, trigger.name),
    name: trigger.name,
    function: `${trigger.function_schema}.${trigger.function_name}`,
    definition: trigger.definition,
    constraint: trigger.is_constraint,
    initially_deferred: trigger.initially_deferred,
  }));
}

function mapPolicies(rows, schema, relation) {
  return (rows ?? []).map((policy) => ({
    id: ids.policy(schema, relation, policy.name),
    name: policy.name,
    permissive: policy.permissive === POLICY_PERMISSIVE,
    command: policy.command,
    roles: pgArray(policy.roles).sort(),
    using: policy.using_expression,
    with_check: policy.with_check_expression,
  }));
}

function mapTypescript(row, group, resolves) {
  if (!resolves) return null;
  return {
    row: typescriptPath(row.schema, group, row.name, "Row"),
    ...(group === "Tables"
      ? {
          insert: typescriptPath(row.schema, group, row.name, "Insert"),
          update: typescriptPath(row.schema, group, row.name, "Update"),
        }
      : {}),
  };
}

function mapPartitions(row, children) {
  return row.kind === "partitioned_table" ? { strategy: row.partition_strategy, key: row.partition_key, children } : null;
}

function partitionChildrenOf(row, partitionChildren, childRows) {
  const qualified = `${row.schema}.${row.name}`;
  return (partitionChildren.get(qualified) ?? []).map((child) => {
    const childRow = childRows.get(`${child.child_schema}.${child.child}`);
    return { name: `${child.child_schema}.${child.child}`, bound: childRow?.partition_bound ?? null };
  });
}

function recordInbound(inbound, fromId, foreignKeys) {
  for (const fk of foreignKeys) {
    const list = inbound.get(fk.to) ?? [];
    list.push({ from: fromId, columns: fk.columns, to_columns: fk.to_columns, constraint: fk.name });
    inbound.set(fk.to, list);
  }
}

function buildRelations(raw, context) {
  const { config, migrationIndex, typePaths } = context;
  const partitionChildren = groupBy(raw.inherits, (row) => `${row.parent_schema}.${row.parent}`);
  const childRows = new Map(raw.relations.filter((row) => row.is_partition).map((row) => [`${row.schema}.${row.name}`, row]));
  const columnsByRelation = groupBy(raw.columns, relationKey);
  const constraintsByRelation = groupBy(raw.constraints, relationKey);
  const indexesByRelation = groupBy(raw.indexes, relationKey);
  const policiesByRelation = groupBy(raw.policies, relationKey);
  const triggersByRelation = groupBy(raw.triggers, relationKey);
  const grantsByRelation = groupBy(raw.tableGrants, relationKey);
  const relationIdOf = (schema, name) => ids.relation(schema, name);
  const inbound = new Map();
  const relations = {};
  const volatileRowClass = {};
  const typescriptIssues = [];

  for (const row of raw.relations) {
    if (row.is_partition) continue;
    const qualified = `${row.schema}.${row.name}`;
    const id = ids.relation(row.schema, row.name);
    const constraints = buildConstraints(constraintsByRelation.get(qualified) ?? [], relationIdOf);
    const grants = buildGrants(grantsByRelation.get(qualified) ?? [], config.allRoles);
    const group = TABLE_LIKE.has(row.kind) ? "Tables" : "Views";
    const resolves = typePaths.has(`${row.schema}.${group}.${row.name}`);
    if (!resolves) typescriptIssues.push({ id, expected: `${row.schema}.${group}.${row.name}` });
    const children = partitionChildrenOf(row, partitionChildren, childRows);
    recordInbound(inbound, id, constraints.foreignKeys);
    volatileRowClass[id] = rowCountClass(row.reltuples);
    relations[id] = {
      id,
      schema: row.schema,
      name: row.name,
      kind: row.kind,
      comment: row.comment,
      columns: buildColumns(columnsByRelation.get(qualified) ?? [], constraints.foreignKeys, row.schema, row.name),
      primary_key: constraints.primaryKey,
      unique: constraints.unique,
      checks: constraints.checks,
      exclusions: constraints.exclusions,
      foreign_keys: constraints.foreignKeys,
      inbound_foreign_keys: [],
      indexes: mapIndexes(indexesByRelation.get(qualified), row.schema),
      triggers: mapTriggers(triggersByRelation.get(qualified), row.schema, row.name),
      rls: {
        enabled: row.rls_enabled,
        forced: row.rls_forced,
        policies: mapPolicies(policiesByRelation.get(qualified), row.schema, row.name),
      },
      grants,
      ...readersAndWriters(grants),
      partitions: mapPartitions(row, children),
      view_definition: row.view_definition,
      typescript: mapTypescript(row, group, resolves),
      defined_in: migrationIndex.get(qualified) ?? [],
    };
  }
  for (const [target, list] of inbound) {
    if (relations[target]) relations[target].inbound_foreign_keys = sortBy(list, (item) => `${item.from}:${item.constraint}`);
  }
  return { relations, volatileRowClass, typescriptIssues };
}

function buildFunctions(raw, context, relationNames) {
  const grantsByOid = groupBy(raw.functionGrants, (row) => row.oid);
  const functionNames = [...new Set(raw.functions.map((row) => `${row.schema}.${row.name}`))].sort();
  const functions = {};
  for (const row of raw.functions) {
    const argTypes = pgArray(row.argument_type_names).map(typeName);
    const id = ids.function(row.schema, row.name, argTypes);
    const executors = (grantsByOid.get(row.oid) ?? []).map((grant) => grant.role).sort();
    const touches = extractTouches(row.body ?? "", { relationNames, functionNames });
    functions[id] = {
      id,
      schema: row.schema,
      name: row.name,
      kind: row.kind,
      arguments: parseArguments(row.arguments_with_defaults ?? ""),
      identity_arguments: row.identity_arguments,
      returns: row.returns,
      returns_set: row.returns_set,
      volatility: row.volatility,
      security: row.security,
      language: row.language,
      config: pgArray(row.config),
      comment: row.comment,
      grants: Object.fromEntries(executors.map((role) => [role, ["EXECUTE"]])),
      executors,
      body_sha256: row.body ? digestText(row.body) : null,
      raises: extractRaises(row.body ?? ""),
      touches: { ...touches, basis: "best_effort" },
      typescript: context.typePaths.has(`${row.schema}.Functions.${row.name}`)
        ? typescriptPath(row.schema, "Functions", row.name)
        : null,
      defined_in: context.migrationIndex.get(`${row.schema}.${row.name}`) ?? [],
    };
  }
  return functions;
}

function buildTypes(raw, typePaths) {
  const types = {};
  for (const row of raw.enums) {
    const id = ids.enum(row.schema, row.name);
    types[id] = {
      id,
      kind: "enum",
      schema: row.schema,
      name: row.name,
      labels: pgArray(row.labels),
      comment: row.comment,
      typescript: typePaths.has(`${row.schema}.Enums.${row.name}`) ? typescriptPath(row.schema, "Enums", row.name) : null,
    };
  }
  for (const row of raw.domains) {
    const id = ids.pgDomain(row.schema, row.name);
    types[id] = { id, kind: "domain", schema: row.schema, name: row.name, base_type: row.base_type, nullable: row.nullable, constraints: row.constraints, comment: row.comment };
  }
  for (const row of raw.composites) {
    const id = ids.composite(row.schema, row.name);
    types[id] = { id, kind: "composite", schema: row.schema, name: row.name, attributes: pgArray(row.attributes), comment: row.comment };
  }
  return types;
}

function buildVocabularies(raw) {
  const vocabularies = {};
  for (const [qualified, snapshot] of Object.entries(raw.vocabularies)) {
    const [schema, table] = qualified.split(".");
    const id = ids.vocabulary(schema, table);
    const rows = sortBy(snapshot.rows, (row) => String(row[snapshot.key]));
    vocabularies[id] = {
      id,
      schema,
      table,
      key: snapshot.key,
      columns: rows.length > 0 ? Object.keys(rows[0]).sort() : [],
      rows,
      rows_sha256: digest(rows),
    };
  }
  return vocabularies;
}

function buildRoles(raw) {
  return Object.fromEntries(
    raw.roles.map((row) => [
      row.name,
      { login: row.login, bypass_rls: row.bypass_rls, member_of: pgArray(row.member_of), granted_to: pgArray(row.granted_to), purpose_comment: row.comment },
    ]),
  );
}

function buildSchemas(raw, relations, functions, types) {
  const schemas = {};
  for (const row of raw.schemaComments) {
    schemas[row.name] = { id: ids.schema(row.name), name: row.name, comment: row.comment, relation_ids: [], function_ids: [], type_ids: [], domain_ids: [] };
  }
  for (const relation of Object.values(relations)) schemas[relation.schema]?.relation_ids.push(relation.id);
  for (const fn of Object.values(functions)) schemas[fn.schema]?.function_ids.push(fn.id);
  for (const type of Object.values(types)) schemas[type.schema]?.type_ids.push(type.id);
  for (const schema of Object.values(schemas)) {
    schema.relation_ids.sort();
    schema.function_ids.sort();
    schema.type_ids.sort();
  }
  return schemas;
}

function deriveViewSources(raw, functionIdsByName) {
  const sources = {};
  for (const row of raw.viewDependencies) {
    const viewId = ids.relation(row.view_schema, row.view_name);
    const targetId =
      row.target_kind === "relation"
        ? ids.relation(row.target_schema, row.target_name)
        : functionIdsByName.get(`${row.target_schema}.${row.target_name}`)?.[0];
    if (!targetId) continue;
    sources[viewId] = [...new Set([...(sources[viewId] ?? []), targetId])].sort();
  }
  return sources;
}

function vocabularyPolymorphics(relation, vocabularyByRelationId, relations) {
  const results = [];
  for (const column of relation.columns) {
    const vocabulary = column.fk ? vocabularyByRelationId.get(column.fk.to) : null;
    if (!vocabulary || !vocabulary.columns.includes(CANONICAL_TABLE_COLUMN)) continue;
    const targetsByValue = {};
    for (const row of vocabulary.rows) {
      if (!row[CANONICAL_TABLE_COLUMN]) continue;
      const targetId = ids.relation(row[CANONICAL_SCHEMA_COLUMN] ?? relation.schema, row[CANONICAL_TABLE_COLUMN]);
      if (relations[targetId]) targetsByValue[row[vocabulary.key]] = targetId;
    }
    if (Object.keys(targetsByValue).length > 0) {
      results.push({
        id: `poly:${relation.schema}.${relation.name}.${column.name}`,
        relation: relation.id,
        discriminator: column.id,
        vocabulary: vocabulary.id,
        targets_by_value: targetsByValue,
        basis: `vocabulary ${vocabulary.schema}.${vocabulary.table}.canonical_table + FK ${column.fk.constraint}`,
      });
    }
  }
  return results;
}

function exclusiveCheckPolymorphics(relation) {
  const results = [];
  for (const check of relation.checks) {
    const match = check.expression.match(EXCLUSIVE_NONNULL_CHECK);
    if (!match) continue;
    const columnNames = match[1].split(",").map((name) => name.trim().replaceAll('"', ""));
    const targets = columnNames.map((name) => relation.columns.find((column) => column.name === name)?.fk?.to).filter(Boolean);
    if (targets.length >= MIN_EXCLUSIVE_TARGETS) {
      results.push({
        id: `poly:${relation.schema}.${relation.name}.${check.name}`,
        relation: relation.id,
        discriminator: check.expression,
        columns: columnNames,
        targets: [...new Set(targets)].sort(),
        basis: `check constraint ${check.name}`,
      });
    }
  }
  return results;
}

function derivePolymorphic(relations, vocabularies) {
  const results = [];
  const vocabularyByRelationId = new Map(Object.values(vocabularies).map((voc) => [ids.relation(voc.schema, voc.table), voc]));
  for (const relation of Object.values(relations)) {
    results.push(...vocabularyPolymorphics(relation, vocabularyByRelationId, relations));
    results.push(...exclusiveCheckPolymorphics(relation));
  }
  return sortBy(results, (item) => item.id);
}

function deriveWritePaths(relations, functions) {
  const writePaths = {};
  for (const relation of Object.values(relations)) {
    const viaFunctions = Object.values(functions)
      .filter((fn) => fn.touches.writes.includes(`${relation.schema}.${relation.name}`))
      .map((fn) => fn.id)
      .sort();
    writePaths[relation.id] = { direct_dml_roles: relation.writers, via_functions: viaFunctions, basis: "grants + best_effort body scan" };
  }
  return writePaths;
}

function deriveTriggerFunctions(relations, functionIdsByName) {
  const byRelation = {};
  for (const relation of Object.values(relations)) {
    const fnIds = relation.triggers.map((trigger) => functionIdsByName.get(trigger.function)?.[0]).filter(Boolean);
    if (fnIds.length > 0) byRelation[relation.id] = [...new Set(fnIds)].sort();
  }
  return byRelation;
}

/**
 * Builds the derived part of schema-ir.v1 (no enrichment, no fingerprint yet).
 * @param raw output of `introspect`
 * @param context `{ config, migrationIndex, typePaths, build }`
 */
export function buildIr(raw, context) {
  const { relations, volatileRowClass, typescriptIssues } = buildRelations(raw, context);
  const relationNames = Object.values(relations).map((relation) => `${relation.schema}.${relation.name}`).sort();
  const functions = buildFunctions(raw, context, relationNames);
  const functionIdsByName = new Map();
  for (const fn of Object.values(functions)) {
    const key = `${fn.schema}.${fn.name}`;
    functionIdsByName.set(key, [...(functionIdsByName.get(key) ?? []), fn.id].sort());
  }
  const types = buildTypes(raw, context.typePaths);
  const vocabularies = buildVocabularies(raw);
  // Canonical key order in memory so rendering from a fresh IR and from the committed JSON agree byte for byte.
  const ir = canonical({
    format: context.config.irFormat,
    build: context.build,
    fingerprint: null,
    workspace_fingerprint: null,
    schemas: buildSchemas(raw, relations, functions, types),
    relations,
    functions,
    types,
    vocabularies,
    roles: buildRoles(raw),
    derived: {
      write_paths: deriveWritePaths(relations, functions),
      polymorphic: derivePolymorphic(relations, vocabularies),
      view_sources: deriveViewSources(raw, functionIdsByName),
      trigger_functions: deriveTriggerFunctions(relations, functionIdsByName),
      function_ids_by_name: Object.fromEntries([...functionIdsByName].sort()),
    },
    enrichment: null,
    volatile: { row_count_class: volatileRowClass },
  });
  ir.fingerprint = structuralFingerprint(ir);
  return { ir, typescriptIssues };
}

export function structuralFingerprint(ir) {
  const { schemas, relations, functions, types, vocabularies, roles, derived } = ir;
  return digest({ schemas, relations, functions, types, vocabularies, roles, derived });
}

export function workspaceFingerprint(ir, enrichmentSha256, rendererVersion) {
  return digestText(canonicalJson({ fingerprint: ir.fingerprint, enrichment_sha256: enrichmentSha256, renderer_version: rendererVersion }));
}
