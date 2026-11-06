import { ids } from "../ir/build-ir.mjs";

/**
 * Resolves the qualified names used in enrichment YAML (`schema.relation`, `schema.function`,
 * `schema.table:code`, `schema.relation.column`, `q:name`, `task:slug`, `dom:slug`, `term:slug`)
 * to IR ids, recording an issue for every unknown reference.
 */
export class ReferenceResolver {
  constructor(ir, issues) {
    this.ir = ir;
    this.issues = issues;
  }

  relationIds(names, file, location) {
    return names
      .map((name) => {
        const id = `rel:${name}`;
        if (this.ir.relations[id]) return id;
        this.issues.add(file, location, `unknown relation "${name}"`);
        return null;
      })
      .filter(Boolean);
  }

  functionIds(names, file, location) {
    const found = [];
    for (const name of names) {
      const overloads = this.ir.derived.function_ids_by_name[name];
      if (overloads) found.push(...overloads);
      else this.issues.add(file, location, `unknown function "${name}"`);
    }
    return found;
  }

  column(relationId, column, file, location) {
    const relation = this.ir.relations[relationId];
    const exists = relation?.columns.some((item) => item.name === column);
    if (!exists) this.issues.add(file, location, `unknown column "${column}" on ${relationId}`);
    return exists ? ids.column(relation.schema, relation.name, column) : null;
  }

  vocabularyRow(reference, file, location) {
    const [table, code] = reference.split(":");
    const vocabulary = this.ir.vocabularies[`voc:${table}`];
    if (!vocabulary) {
      this.issues.add(file, location, `unknown vocabulary "${table}"`);
      return null;
    }
    if (!vocabulary.rows.some((row) => String(row[vocabulary.key]) === code)) {
      this.issues.add(file, location, `unknown ${table} code "${code}"`);
      return null;
    }
    return `voc:${table}.${code}`;
  }

  /** Resolves a mixed list of references; prefixed ids (`q:`, `task:`, `dom:`, `term:`) pass through. */
  anyIds(references, file, location) {
    return references
      .map((reference) => {
        if (/^(q|task|dom|term):/.test(reference)) return reference;
        if (reference.includes(":")) return this.vocabularyRow(reference, file, location);
        const parts = reference.split(".");
        if (parts.length === 3) return this.column(`rel:${parts[0]}.${parts[1]}`, parts[2], file, location);
        if (this.ir.relations[`rel:${reference}`]) return `rel:${reference}`;
        const overloads = this.ir.derived.function_ids_by_name[reference];
        if (overloads) return overloads[0];
        this.issues.add(file, location, `unknown reference "${reference}"`);
        return null;
      })
      .filter(Boolean);
  }
}
