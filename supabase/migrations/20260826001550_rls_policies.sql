-- 0015b | RLS policies for the bounded roles.
--
-- 0015 enabled row-level security on every table but created no policies. RLS
-- with no permissive policy denies everything for any role without BYPASSRLS, so
-- the five bounded roles were left unable to touch even the tables they hold
-- grants on: pipeline_agent could not INSERT into staging, which is the one
-- place it is supposed to have broad write access.
--
-- This was masked because service_role and postgres both have BYPASSRLS, so
-- anything connecting as those still worked. The bug only appears once a service
-- does SET ROLE, which is exactly how the grant model is meant to be used.
--
-- The fix keeps RLS genuinely enforcing something rather than papering over it
-- with `using (true)`: every policy is tenant-scoped where a tenant_id column
-- exists. Today that resolves to the single default tenant; multi-tenancy later
-- becomes a GUC change, not a migration.
--
-- Grants remain the primary control. RLS is the second lock, not the first.

begin;

-- Resolves the active tenant: an explicit GUC if the service set one, otherwise
-- the single default tenant.
create or replace function util.current_tenant_id() returns uuid
language plpgsql stable parallel safe
set search_path = ''
as $$
declare
  v text;
begin
  v := current_setting('app.tenant_id', true);
  if v is null or v = '' then
    return util.default_tenant_id();
  end if;
  return v::uuid;
exception when others then
  return util.default_tenant_id();
end;
$$;

comment on function util.current_tenant_id() is
  'Active tenant for RLS: the app.tenant_id GUC when set, else the single default tenant.';

grant execute on function util.current_tenant_id() to
  executor_service, pipeline_agent, verifier_agent, control_plane, app_reader, service_role;

-- ---------------------------------------------------------------------------
-- One policy per table, for the roles that hold grants on it.
--
-- Tables carrying tenant_id are scoped to the active tenant. Tables without one
-- are child or join rows reachable only through a scoped parent, so they take an
-- unrestricted policy -- their access is already gated by the grant and by the
-- parent's own policy.
-- ---------------------------------------------------------------------------
do $$
declare
  r            record;
  v_has_tenant boolean;
  v_using      text;
  v_roles      text;
begin
  for r in
    select c.oid,
           c.relnamespace::regnamespace::text as sch,
           c.relname as tbl
    from pg_class c
    where c.relnamespace::regnamespace::text in
          ('orchestration','evidence','taxonomy','corpus','knowledge','staging',
           'ranking','research','retrieval','evaluation','observability','curriculum')
      and c.relkind in ('r','p')
      and not c.relispartition
    order by 2, 3
  loop
    select exists (
      select 1 from pg_attribute a
      where a.attrelid = r.oid and a.attname = 'tenant_id'
        and a.attnum > 0 and not a.attisdropped
    ) into v_has_tenant;

    if v_has_tenant then
      v_using := 'tenant_id = util.current_tenant_id()';
    else
      v_using := 'true';
    end if;

    -- Every bounded role gets the same policy; what actually differs between
    -- them is the GRANT, which decides whether the statement is allowed at all.
    v_roles := 'executor_service, pipeline_agent, verifier_agent, control_plane, app_reader';

    execute format(
      'create policy bounded_role_access on %I.%I
         as permissive for all to %s
         using (%s) with check (%s)',
      r.sch, r.tbl, v_roles, v_using, v_using);
  end loop;
end;
$$;

commit;
