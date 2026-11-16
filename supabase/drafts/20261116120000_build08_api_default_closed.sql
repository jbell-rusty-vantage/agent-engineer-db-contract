-- Build 08, the exposures the signed-in-reads change (20261115130000, D-82) left open (lab draft, disposable-aieng-build04).
--   1. 36 of the 59 api functions were executable by PUBLIC, so anon could call them, and most carry no tenant filter that
--      stops it (api.library_dossier returned a row to anon). The api surface is now closed by default.
--   2. api.works_authored showed every signed-in user all works of every workspace, and api.releases_needing_review the
--      release ids of every workspace. A signed-in user now sees a row only when the product access model entitles them.
--      api.modules_using_software and api.modules_affected_by_release list the same head revisions and get the same rule.
--   3. One foreign-key index of the product schemas existed or not depending on a catalog scan order (section 5, added
--      2026-11-16 after the first fresh install; it creates nothing on the lab).
begin;

-- ------------------------------------------------------------------ 1. the api surface is closed by default
-- PostgreSQL grants EXECUTE on every new function to PUBLIC. Migrations that created api functions granted them to named
-- roles and mostly did not take the PUBLIC grant away (and a function re-created under a new signature starts open again:
-- api.current_fact_rows() was closed in 20260912011100 and reopened by the R2 rewrite). Every role that uses an api function
-- today already holds its own grant, with one exception below, so the PUBLIC grant only added anon and whichever role had
-- been left out on purpose.
revoke execute on all routines in schema api from public, anon;

-- The one function that was reachable through PUBLIC only: R2 replaced api.leaderboard(text) (granted to authenticated,
-- service_role, app_reader in 20260826001500) with api.leaderboard(text, integer) and granted the new signature to nobody.
-- Its caller is the named query ranking.leaderboard, which runs as app_reader.
grant execute on function api.leaderboard(text, integer) to app_reader;

-- A per-schema default privilege cannot take PUBLIC's EXECUTE away (PostgreSQL adds schema defaults to the global ones), and
-- a global one would change every schema of this database. So a later migration that creates an api function must revoke it
-- itself; supabase/tests/api_default_closed.sql and the installer's custody step fail on any api routine that PUBLIC or anon
-- can execute, and on any api relation anon can read.

-- ------------------------------------------------------------------ 2. who is reading, one definition point
-- The product access model (20261105010300) decides what a principal may read: product.role_in (membership of the owning
-- workspace), product.can_read_offer (a release offered or distributed to them) and product.readable_revision (either, for
-- one revision). Those run inside api.product_read with the principal product.actor() resolves. The knowledge readers of api
-- are read directly, so they need the same answer for the session that reads them:
--   - a PostgREST session of role authenticated is a product user: the principal is the verified JWT subject, under the
--     identity test of product.actor() and util.current_tenant_id() (active role authenticated, JWT role authenticated, a
--     subject). Without one it is entitled to nothing;
--   - anon is entitled to nothing;
--   - every other role (app_reader, pipeline_agent, executor_service, verifier_agent, control_plane, service_role, the
--     database owner) is not a product user and reads what its grants allow, as before.
create or replace function product.session_reader(out trusted boolean, out principal uuid)
language plpgsql stable set search_path = '' as $function$
declare active text := coalesce(pg_catalog.current_setting('role', true), 'none'); c jsonb;
begin
  trusted := active not in ('authenticated', 'anon');
  principal := null;
  if active = 'authenticated' then
    c := product.claims();
    if c ->> 'role' = 'authenticated' then
      begin
        principal := nullif(pg_catalog.btrim(c ->> 'sub'), '')::uuid;
      exception when invalid_text_representation then principal := null;
      end;
    end if;
  end if;
end $function$;
comment on function product.session_reader() is
 'Who reads an api knowledge reader directly: trusted for every role but authenticated and anon (database roles and service_role keep reading what their grants allow); for a PostgREST session of role authenticated the principal is the verified JWT subject, else null (entitled to nothing).';

create or replace function product.session_reads_revision(rid uuid) returns boolean
language sql stable security definer set search_path = '' as $function$
  select s.trusted or (s.principal is not null and product.readable_revision(rid, s.principal)) from product.session_reader() s
$function$;
comment on function product.session_reads_revision(uuid) is
 'True when the reading session may see a work revision: a signed-in user under product.readable_revision (a member of the owning workspace, or a release that includes the revision is offered or distributed to them); a trusted role always. The row filter of api.works_authored, api.modules_using_software and api.modules_affected_by_release.';

create or replace function product.session_reads_workspace(ws uuid) returns boolean
language sql stable security definer set search_path = '' as $function$
  select s.trusted or (s.principal is not null and product.role_in(ws, s.principal) is not null) from product.session_reader() s
$function$;
comment on function product.session_reads_workspace(uuid) is
 'True when the reading session may see a workspace''s own records: a signed-in user who is a member of it (product.role_in); a trusted role always. The row filter of api.releases_needing_review.';

grant create on schema product to product_api_owner;   -- needed only to transfer ownership; revoked below
alter function product.session_reader() owner to product_api_owner;
alter function product.session_reads_revision(uuid) owner to product_api_owner;
alter function product.session_reads_workspace(uuid) owner to product_api_owner;
revoke create on schema product from product_api_owner;
revoke all on function product.session_reader(), product.session_reads_revision(uuid), product.session_reads_workspace(uuid) from public, anon, authenticated, service_role;
-- A view runs the functions it names as the role that reads it, so every role that selects api.works_authored needs the
-- revision check (none of them holds USAGE on schema product, so none can call it by name). The definer functions below run
-- as their owner, a member of product_api_owner.
grant execute on function product.session_reads_revision(uuid) to authenticated, service_role, app_reader, pipeline_agent, executor_service, verifier_agent, control_plane;

-- ------------------------------------------------------------------ 3. works at their head revision
-- The row is the head revision (title, bindings, runtime requirements), so the head revision is what must be readable: a
-- learner offered release 1 does not see the draft that followed it. security_barrier keeps a caller's own filter from
-- running before the entitlement check.
create or replace view api.works_authored with (security_barrier = true) as
  select w.id as work_id, w.kind, w.slug, r.title, r.id as head_revision_id, r.revision_no, w.workspace_id, ws.kind workspace_kind,
    exists (select 1 from authoring.release_item i where i.revision_id = r.id and i.disposition in ('include','snapshot')) released,
    api.names((select array_agg(b.entity_id) from authoring.revision_binding b where b.revision_id = r.id and b.relation = 'covers' and b.entity_id is not null)) covers_concepts,
    api.names((select array_agg(x) from (select b.entity_id x from authoring.revision_binding b where b.revision_id = r.id and b.relation = 'uses' and b.entity_id is not null union select q.entity_id from authoring.runtime_requirement q where q.revision_id = r.id and q.entity_id is not null) u)) uses_software,
    (select array_agg(q.name||' '||coalesce(q.version_spec,'')) from authoring.runtime_requirement q where q.revision_id = r.id) runtime_requirements,
    r.knowledge_seq, r.created_at, 1::smallint source_tier
  from authoring.work w join authoring.work_revision r on r.id = w.head_revision_id join authoring.workspace ws on ws.id = w.workspace_id
  where w.tenant_id = util.default_tenant_id() and w.kind in ('course','track','module','lesson','activity','report','project_template','challenge','component','experience')
    and product.session_reads_revision(r.id);
comment on view api.works_authored is 'L1 (ours, tier 1): our courses, modules, lessons, activities, reports and templates at their head revision, whether released, which concepts they cover and which software/versions they use. A signed-in user sees the works whose head revision they may read (a member of the owning workspace, or a release that includes it is offered or distributed to them); database roles see every work.';

-- ------------------------------------------------------------------ 4. the readers that list the same head revisions, and the release review list
create or replace function api.modules_affected_by_release(p_release uuid) returns table(
  work_id uuid, work_kind text, work_slug text, revision_id uuid, revision_title text, revision_created_at timestamptz, software text, release text, released_at timestamptz, breaking boolean, binding text, version_spec text)
language sql stable security definer set search_path = '' as $$
  with rel as (select r.* from api.software_releases r where r.release_id = p_release)
  select w.id, w.kind, w.slug, rv.id, rv.title, rv.created_at, rel.software, rel.release, rel.released_at, rel.breaking, b.binding, b.version_spec
  from rel join (
    select x.revision_id, 'binding:'||x.relation binding, null::text version_spec, x.entity_id from authoring.revision_binding x where x.entity_id is not null
    union all select q.revision_id, 'runtime_requirement', q.version_spec, q.entity_id from authoring.runtime_requirement q where q.entity_id is not null
  ) b on b.entity_id = rel.software_id
  join authoring.work_revision rv on rv.id = b.revision_id join authoring.work w on w.id = rv.work_id and w.head_revision_id = rv.id
  where (rel.released_at is null or rv.created_at < rel.released_at) and product.session_reads_revision(rv.id)
  order by rel.released_at desc, w.slug
$$;
comment on function api.modules_affected_by_release is 'L2 flywheel: our head revisions (modules, activities, courses) that bind or require the software a release belongs to and were authored before that release; breaking tells which need review first. A signed-in user sees the head revisions they may read (api.works_authored has the rule); database roles see all.';

create or replace function api.modules_using_software(p_software uuid) returns table(
  work_id uuid, work_kind text, work_slug text, revision_id uuid, revision_title text, revision_created_at timestamptz, binding text, version_spec text, software text,
  latest_release text, latest_release_at timestamptz, latest_release_breaking boolean, releases_since_revision bigint)
language sql stable security definer set search_path = '' as $$
  with b as (
    select x.revision_id, 'binding:'||x.relation binding, null::text version_spec from authoring.revision_binding x where x.entity_id = p_software
    union all select q.revision_id, 'runtime_requirement', q.version_spec from authoring.runtime_requirement q where q.entity_id = p_software
  ), rel as (select r.* from api.software_releases r where r.software_id = p_software)
  select w.id, w.kind, w.slug, rv.id, rv.title, rv.created_at, b.binding, b.version_spec, s.display_name,
    (select r.release from rel r order by r.released_at desc nulls last limit 1), (select r.released_at from rel r order by r.released_at desc nulls last limit 1),
    (select r.breaking from rel r order by r.released_at desc nulls last limit 1), (select count(*) from rel r where r.released_at > rv.created_at)
  from b join authoring.work_revision rv on rv.id = b.revision_id join authoring.work w on w.id = rv.work_id and w.head_revision_id = rv.id join catalog.entity s on s.id = p_software
  where product.session_reads_revision(rv.id)
  order by w.slug
$$;
comment on function api.modules_using_software is 'L2 flywheel (time-independent): our head revisions that bind or require a software thing, with its latest known release and how many releases landed after the revision was authored. A signed-in user sees the head revisions they may read (api.works_authored has the rule); database roles see all.';

-- A release is its workspace's own record and the list is the authors' review queue: membership of the owning workspace, no
-- offer route.
create or replace function api.releases_needing_review() returns table(release_id uuid, release_no integer, root_work_id uuid, released_at timestamptz, claim_id uuid, statement text, verdict_at_release text, verdict_now text, status_now text, decided_at timestamptz)
language sql stable security definer set search_path = '' as $$
  with bound as (
    select r.id rid, r.release_no, r.root_work_id, r.created_at rat, ri.claim_id from authoring.release r join authoring.release_item ri on ri.release_id = r.id
     where r.tenant_id = util.current_tenant_id() and ri.claim_id is not null and product.session_reads_workspace(r.workspace_id)
    union
    select r.id, r.release_no, r.root_work_id, r.created_at, b.claim_id from authoring.release r join authoring.revision_binding b on b.revision_id = r.root_revision_id
     where r.tenant_id = util.current_tenant_id() and b.claim_id is not null and product.session_reads_workspace(r.workspace_id)
  )
  select b.rid, b.release_no, b.root_work_id, b.rat, b.claim_id, c.statement, at_rel.verdict, now_.verdict, c.status::text, now_.decided_at
    from bound b join evidence.claim c on c.id = b.claim_id
    left join lateral (select v.verdict::text verdict from verification.probe_verdict v where v.claim_id = b.claim_id and v.decided_at <= b.rat and v.review_state <> 'human_rejected' order by v.decided_at desc limit 1) at_rel on true
    left join lateral (select v.verdict::text verdict, v.decided_at from verification.probe_verdict v where v.claim_id = b.claim_id and v.review_state <> 'human_rejected' order by v.decided_at desc limit 1) now_ on true
   where now_.decided_at > b.rat and now_.verdict is distinct from at_rel.verdict
   order by b.rat, c.statement
$$;
comment on function api.releases_needing_review() is 'Loop 5: releases whose bound claims have a current probe verdict, decided after the release, that differs from the verdict current when the release was frozen; a human confirmation of the same verdict does not trigger. A signed-in user sees the releases of the workspaces they are a member of; database roles see all.';

-- ------------------------------------------------------------------ 5. foreign-key indexes do not depend on a catalog scan order
-- 20261105010100 gave every foreign key of the product schemas an index unless some index already led with its columns, visiting
-- the keys in whatever order pg_constraint returned them. Where one key's columns lead another's (authoring.event:
-- (tenant_id, workspace_id, work_id) and (tenant_id, workspace_id, work_id, revision_id)) the shorter key got its own index only
-- when it was visited first, so two installs of the same chain could differ by that index (recorded on fresh installs since
-- loop 1; seen again on 2026-11-16, where it made the schema workspace check fail on one fresh install and pass on another).
-- The rule without an order: a foreign key has its own index unless an index that loop did not create (a key, a hand-written
-- index) leads with its columns. On a database that already has the index this creates nothing.
do $do$
declare c record; cols text;
begin
  for c in
    select con.conrelid, con.conrelid::regclass as tbl, n.nspname, con.conkey, left(con.conname, 55) || '_ix' as ix_name
    from pg_constraint con join pg_class cl on cl.oid = con.conrelid join pg_namespace n on n.oid = cl.relnamespace
    where con.contype = 'f' and n.nspname in ('authoring','curriculum','learning','library','conversation','access','inquiry','dataset')
    order by n.nspname, cl.relname, con.conname
  loop
    continue when exists (select 1 from pg_index i join pg_class ic on ic.oid = i.indexrelid
                           where i.indrelid = c.conrelid
                             and (string_to_array(i.indkey::text, ' ')::int2[])[1:array_length(c.conkey, 1)] = c.conkey
                             and not exists (select 1 from pg_constraint f where f.contype = 'f' and f.conrelid = i.indrelid and left(f.conname, 55) || '_ix' = ic.relname));
    continue when exists (select 1 from pg_class ic where ic.relnamespace = c.nspname::regnamespace and ic.relname = c.ix_name);
    select string_agg(quote_ident(a.attname), ',' order by k.ord) into cols
      from unnest(c.conkey) with ordinality k(attnum, ord) join pg_attribute a on a.attrelid = c.conrelid and a.attnum = k.attnum;
    execute format('create index %I on %s (%s)', c.ix_name, c.tbl, cols);
  end loop;
end $do$;

commit;
