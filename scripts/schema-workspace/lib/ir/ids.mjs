/** Stable IR identifiers. Changing a format here changes every page id and link. */

export const ids = {
  schema: (schema) => `sch:${schema}`,
  relation: (schema, name) => `rel:${schema}.${name}`,
  column: (schema, relation, column) => `col:${schema}.${relation}.${column}`,
  function: (schema, name, argTypes) => `fn:${schema}.${name}(${argTypes.join(",")})`,
  enum: (schema, name) => `enum:${schema}.${name}`,
  pgDomain: (schema, name) => `pgdomain:${schema}.${name}`,
  composite: (schema, name) => `composite:${schema}.${name}`,
  policy: (schema, relation, policy) => `pol:${schema}.${relation}.${policy}`,
  index: (schema, index) => `idx:${schema}.${index}`,
  trigger: (schema, relation, trigger) => `trg:${schema}.${relation}.${trigger}`,
  vocabulary: (schema, table) => `voc:${schema}.${table}`,
  domain: (slug) => `dom:${slug}`,
  task: (slug) => `task:${slug}`,
  query: (name) => `q:${name}`,
  term: (slug) => `term:${slug}`,
};

/** Drops the `rel:` / `voc:` / `fn:` prefix, leaving the qualified name (and args, for functions). */
export function idTail(id) {
  return id.slice(id.indexOf(":") + 1);
}

/** `fn:schema.name(args)` → `schema.name`. */
export function functionQualifiedName(functionId) {
  const tail = idTail(functionId);
  const cut = tail.indexOf("(");
  return cut < 0 ? tail : tail.slice(0, cut);
}

/** Every typed table a polymorphic edge can resolve to. */
export function polymorphicTargetIds(item) {
  return [...(item.targets ?? []), ...Object.values(item.targets_by_value ?? {})];
}

export function isPolymorphicTarget(item, relationId) {
  return item.targets?.includes(relationId) || Object.values(item.targets_by_value ?? {}).includes(relationId);
}
