-- 20261025010100_research_force_rls
-- Sprint V SV-17 review finding F12: the four research tables added by 20261024010100 enabled row level security but
-- did not force it, so their owner could read and write across tenants outside the bounded-role policies. Force it,
-- as the retrieval ledgers already do (20260904011000, 20260904014000, 20260904015000). 20261025010000 created no tables.
--
-- The SECURITY DEFINER readers and guards of 20261024010100 run as the owner `postgres`, which holds BYPASSRLS on
-- Supabase, so they keep working; every query they run is already filtered by the asserted tenant. The bounded roles
-- (executor_service, pipeline_agent, verifier_agent, control_plane, app_reader) keep their tenant policy unchanged.
begin;
set local lock_timeout = '15s';

alter table research.use_admission force row level security;
alter table research.report_v2_revision force row level security;
alter table research.report_v2_assertion force row level security;
alter table research.report_v2_ingestion force row level security;

do $$
declare unforced text;
begin
  select string_agg(c.oid::regclass::text, ', ') into unforced
    from pg_catalog.pg_class c join pg_catalog.pg_namespace n on n.oid = c.relnamespace
   where n.nspname = 'research' and c.relname in ('use_admission', 'report_v2_revision', 'report_v2_assertion', 'report_v2_ingestion')
     and not (c.relrowsecurity and c.relforcerowsecurity);
  if unforced is not null then raise exception 'RESEARCH_RLS_NOT_FORCED: %', unforced; end if;
end $$;

commit;
