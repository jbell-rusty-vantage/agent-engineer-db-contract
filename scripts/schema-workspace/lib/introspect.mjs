/**
 * Live catalog introspection. Returns raw, row-shaped metadata; `ir/build-ir.mjs` turns it into
 * schema-ir.v1. Every query is ordered so the output is deterministic.
 */

const RELATION_KINDS = `case c.relkind when 'r' then 'table' when 'p' then 'partitioned_table' when 'v' then 'view'
  when 'm' then 'materialized_view' when 'f' then 'foreign_table' end`;

const queries = {
  relations: `
    select n.nspname as schema, c.relname as name, c.oid::int as oid, ${RELATION_KINDS} as kind,
      obj_description(c.oid, 'pg_class') as comment,
      c.relrowsecurity as rls_enabled, c.relforcerowsecurity as rls_forced, c.relispartition as is_partition,
      c.reltuples::float8 as reltuples,
      case when c.relkind in ('v','m') then pg_get_viewdef(c.oid, true) end as view_definition,
      case pt.partstrat when 'r' then 'range' when 'l' then 'list' when 'h' then 'hash' end as partition_strategy,
      case when pt.partrelid is not null then pg_get_partkeydef(c.oid) end as partition_key,
      case when c.relispartition then pg_get_expr(c.relpartbound, c.oid) end as partition_bound
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
    left join pg_partitioned_table pt on pt.partrelid = c.oid
    where n.nspname = any($1) and c.relkind in ('r','p','v','m','f')
    order by n.nspname, c.relname`,
  columns: `
    select n.nspname as schema, c.relname as relation, a.attnum as position, a.attname as name,
      pg_catalog.format_type(a.atttypid, a.atttypmod) as type, not a.attnotnull as nullable,
      case when a.attgenerated = '' then pg_get_expr(d.adbin, d.adrelid) end as default_expression,
      case when a.attgenerated <> '' then pg_get_expr(d.adbin, d.adrelid) end as generated_expression,
      case a.attidentity when 'a' then 'always' when 'd' then 'by_default' end as identity,
      col_description(c.oid, a.attnum) as comment
    from pg_attribute a
    join pg_class c on c.oid = a.attrelid
    join pg_namespace n on n.oid = c.relnamespace
    left join pg_attrdef d on d.adrelid = a.attrelid and d.adnum = a.attnum
    where n.nspname = any($1) and c.relkind in ('r','p','v','m','f') and a.attnum > 0 and not a.attisdropped
    order by n.nspname, c.relname, a.attnum`,
  constraints: `
    select n.nspname as schema, c.relname as relation, con.conname as name,
      case con.contype when 'p' then 'primary_key' when 'f' then 'foreign_key' when 'u' then 'unique'
        when 'c' then 'check' when 'x' then 'exclusion' else con.contype::text end as type,
      pg_get_constraintdef(con.oid, true) as definition,
      (select array_agg(a.attname order by k.ord) from unnest(con.conkey) with ordinality k(attnum, ord)
         join pg_attribute a on a.attrelid = con.conrelid and a.attnum = k.attnum) as columns,
      fn.nspname as target_schema, fc.relname as target_relation,
      (select array_agg(a.attname order by k.ord) from unnest(con.confkey) with ordinality k(attnum, ord)
         join pg_attribute a on a.attrelid = con.confrelid and a.attnum = k.attnum) as target_columns,
      con.condeferrable as deferrable, con.condeferred as initially_deferred,
      case con.confdeltype when 'a' then 'no action' when 'r' then 'restrict' when 'c' then 'cascade'
        when 'n' then 'set null' when 'd' then 'set default' end as on_delete,
      case con.contype when 'c' then pg_get_expr(con.conbin, con.conrelid) end as expression
    from pg_constraint con
    join pg_class c on c.oid = con.conrelid
    join pg_namespace n on n.oid = c.relnamespace
    left join pg_class fc on fc.oid = con.confrelid
    left join pg_namespace fn on fn.oid = fc.relnamespace
    where n.nspname = any($1)
    order by n.nspname, c.relname, con.contype, con.conname`,
  indexes: `
    select n.nspname as schema, c.relname as relation, ic.relname as name, pg_get_indexdef(i.indexrelid) as definition,
      i.indisunique as is_unique, i.indisprimary as is_primary,
      pg_get_expr(i.indpred, i.indrelid) as predicate, am.amname as method
    from pg_index i
    join pg_class c on c.oid = i.indrelid
    join pg_class ic on ic.oid = i.indexrelid
    join pg_namespace n on n.oid = c.relnamespace
    join pg_am am on am.oid = ic.relam
    where n.nspname = any($1)
    order by n.nspname, c.relname, ic.relname`,
  policies: `
    select schemaname as schema, tablename as relation, policyname as name, permissive, cmd as command,
      roles::text[] as roles, qual as using_expression, with_check as with_check_expression
    from pg_policies where schemaname = any($1)
    order by schemaname, tablename, policyname`,
  triggers: `
    select n.nspname as schema, c.relname as relation, t.tgname as name,
      pn.nspname as function_schema, p.proname as function_name, pg_get_triggerdef(t.oid, true) as definition,
      t.tgconstraint <> 0 as is_constraint, t.tginitdeferred as initially_deferred, t.tgenabled as enabled
    from pg_trigger t
    join pg_class c on c.oid = t.tgrelid
    join pg_namespace n on n.oid = c.relnamespace
    join pg_proc p on p.oid = t.tgfoid
    join pg_namespace pn on pn.oid = p.pronamespace
    where n.nspname = any($1) and not t.tgisinternal
    order by n.nspname, c.relname, t.tgname`,
  functions: `
    select n.nspname as schema, p.proname as name, p.oid::int as oid,
      pg_get_function_identity_arguments(p.oid) as identity_arguments,
      pg_get_function_arguments(p.oid) as arguments_with_defaults,
      pg_get_function_result(p.oid) as returns,
      case p.prokind when 'f' then 'function' when 'p' then 'procedure' when 'a' then 'aggregate' when 'w' then 'window' end as kind,
      case p.provolatile when 'i' then 'immutable' when 's' then 'stable' else 'volatile' end as volatility,
      case when p.prosecdef then 'definer' else 'invoker' end as security,
      p.proretset as returns_set, l.lanname as language, p.prosrc as body,
      p.proconfig as config, obj_description(p.oid, 'pg_proc') as comment,
      (select array_agg(t.typname order by k.ord) from unnest(p.proargtypes::oid[]) with ordinality k(oid, ord)
         join pg_type t on t.oid = k.oid) as argument_type_names
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    join pg_language l on l.oid = p.prolang
    where n.nspname = any($1)
    order by n.nspname, p.proname, pg_get_function_identity_arguments(p.oid)`,
  enums: `
    select n.nspname as schema, t.typname as name, obj_description(t.oid, 'pg_type') as comment,
      array_agg(e.enumlabel order by e.enumsortorder) as labels
    from pg_type t
    join pg_namespace n on n.oid = t.typnamespace
    join pg_enum e on e.enumtypid = t.oid
    where n.nspname = any($1)
    group by n.nspname, t.typname, t.oid
    order by n.nspname, t.typname`,
  domains: `
    select n.nspname as schema, t.typname as name, pg_catalog.format_type(t.typbasetype, t.typtypmod) as base_type,
      not t.typnotnull as nullable, obj_description(t.oid, 'pg_type') as comment,
      (select string_agg(pg_get_constraintdef(c.oid, true), '; ' order by c.conname) from pg_constraint c where c.contypid = t.oid) as constraints
    from pg_type t
    join pg_namespace n on n.oid = t.typnamespace
    where n.nspname = any($1) and t.typtype = 'd'
    order by n.nspname, t.typname`,
  composites: `
    select n.nspname as schema, t.typname as name, obj_description(t.oid, 'pg_type') as comment,
      array_agg(a.attname || ' ' || pg_catalog.format_type(a.atttypid, a.atttypmod) order by a.attnum) as attributes
    from pg_type t
    join pg_namespace n on n.oid = t.typnamespace
    join pg_class c on c.oid = t.typrelid and c.relkind = 'c'
    join pg_attribute a on a.attrelid = c.oid and a.attnum > 0 and not a.attisdropped
    where n.nspname = any($1) and t.typtype = 'c'
    group by n.nspname, t.typname, t.oid
    order by n.nspname, t.typname`,
  tableGrants: `
    select n.nspname as schema, c.relname as relation, r.rolname as role, priv.name as privilege
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
    cross join pg_roles r
    cross join unnest(array['SELECT','INSERT','UPDATE','DELETE']) as priv(name)
    where n.nspname = any($1) and c.relkind in ('r','p','v','m','f') and r.rolname = any($2)
      and has_table_privilege(r.rolname, c.oid, priv.name)
    order by n.nspname, c.relname, r.rolname, priv.name`,
  functionGrants: `
    select p.oid::int as oid, r.rolname as role
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    cross join pg_roles r
    where n.nspname = any($1) and r.rolname = any($2) and p.prokind in ('f','p')
      and has_function_privilege(r.rolname, p.oid, 'EXECUTE')
    order by p.oid, r.rolname`,
  inherits: `
    select pn.nspname as parent_schema, pc.relname as parent, cn.nspname as child_schema, cc.relname as child
    from pg_inherits i
    join pg_class pc on pc.oid = i.inhparent
    join pg_namespace pn on pn.oid = pc.relnamespace
    join pg_class cc on cc.oid = i.inhrelid
    join pg_namespace cn on cn.oid = cc.relnamespace
    where pn.nspname = any($1)
    order by pn.nspname, pc.relname, cn.nspname, cc.relname`,
  viewDependencies: `
    select distinct vn.nspname as view_schema, v.relname as view_name,
      case d.refclassid when 'pg_class'::regclass then 'relation' when 'pg_proc'::regclass then 'function' end as target_kind,
      coalesce(rn.nspname, fn.nspname) as target_schema, coalesce(rc.relname, fp.proname) as target_name,
      fp.oid::int as target_function_oid
    from pg_depend d
    join pg_rewrite rw on rw.oid = d.objid and d.classid = 'pg_rewrite'::regclass
    join pg_class v on v.oid = rw.ev_class and v.relkind in ('v','m')
    join pg_namespace vn on vn.oid = v.relnamespace
    left join pg_class rc on d.refclassid = 'pg_class'::regclass and rc.oid = d.refobjid and rc.oid <> v.oid
    left join pg_namespace rn on rn.oid = rc.relnamespace
    left join pg_proc fp on d.refclassid = 'pg_proc'::regclass and fp.oid = d.refobjid
    left join pg_namespace fn on fn.oid = fp.pronamespace
    where vn.nspname = any($1) and (rc.oid is not null or fp.oid is not null)
    order by 1, 2, 3, 4, 5`,
  roles: `
    select r.rolname as name, r.rolcanlogin as login, r.rolbypassrls as bypass_rls,
      shobj_description(r.oid, 'pg_authid') as comment,
      coalesce((select array_agg(g.rolname order by g.rolname) from pg_auth_members m join pg_roles g on g.oid = m.roleid where m.member = r.oid), '{}') as member_of,
      coalesce((select array_agg(g.rolname order by g.rolname) from pg_auth_members m join pg_roles g on g.oid = m.member where m.roleid = r.oid), '{}') as granted_to
    from pg_roles r where r.rolname = any($1)
    order by r.rolname`,
};

async function vocabularyRows(pool, qualifiedName, volatileColumns) {
  const [schema, table] = qualifiedName.split(".");
  const exists = await pool.query(
    "select 1 from pg_class c join pg_namespace n on n.oid = c.relnamespace where n.nspname = $1 and c.relname = $2",
    [schema, table],
  );
  if (exists.rowCount === 0) return null;
  const { rows } = await pool.query(`select * from ${quoteIdentifier(schema)}.${quoteIdentifier(table)} order by 1`);
  const stripped = rows.map((row) =>
    Object.fromEntries(Object.entries(row).filter(([column]) => !volatileColumns.includes(column))),
  );
  return { key: rows.length > 0 ? Object.keys(rows[0])[0] : "code", rows: stripped };
}

function quoteIdentifier(name) {
  return `"${name.replaceAll('"', '""')}"`;
}

/**
 * @param {import("pg").Pool} pool
 * @param {{schemas: string[], allRoles: string[], vocabularies: string[], vocabularyVolatileColumns: string[]}} config
 */
export async function introspect(pool, config) {
  const run = (sql, params) => pool.query(sql, params).then((result) => result.rows);
  const [schemaComments, ...catalog] = await Promise.all([
    run(
      "select n.nspname as name, obj_description(n.oid, 'pg_namespace') as comment from pg_namespace n where n.nspname = any($1) order by n.nspname",
      [config.schemas],
    ),
    run(queries.relations, [config.schemas]),
    run(queries.columns, [config.schemas]),
    run(queries.constraints, [config.schemas]),
    run(queries.indexes, [config.schemas]),
    run(queries.policies, [config.schemas]),
    run(queries.triggers, [config.schemas]),
    run(queries.functions, [config.schemas]),
    run(queries.enums, [config.schemas]),
    run(queries.domains, [config.schemas]),
    run(queries.composites, [config.schemas]),
    run(queries.tableGrants, [config.schemas, config.allRoles]),
    run(queries.functionGrants, [config.schemas, config.allRoles]),
    run(queries.inherits, [config.schemas]),
    run(queries.viewDependencies, [config.schemas]),
    run(queries.roles, [config.allRoles]),
  ]);
  const [relations, columns, constraints, indexes, policies, triggers, functions, enums, domains, composites, tableGrants, functionGrants, inherits, viewDependencies, roles] = catalog;
  const vocabularies = {};
  for (const qualifiedName of config.vocabularies) {
    const snapshot = await vocabularyRows(pool, qualifiedName, config.vocabularyVolatileColumns);
    if (snapshot) vocabularies[qualifiedName] = snapshot;
  }
  return {
    schemaComments,
    relations,
    columns,
    constraints,
    indexes,
    policies,
    triggers,
    functions,
    enums,
    domains,
    composites,
    tableGrants,
    functionGrants,
    inherits,
    viewDependencies,
    roles,
    vocabularies,
  };
}
